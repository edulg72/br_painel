#!/usr/bin/ruby
# encoding: utf-8
#
# busca_UR.rb
# Popula tabelas em uma base PostgreSQL com os dados das URs e MPs de uma região.
# (c)2015-2017 Eduardo Garcia <edulg72@gmail.com>
#
# Utilização:
# busca_UR.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo em graus*>
#
# * Define o tamanho dos quadrados das áreas para análise. Em regiões muito populosas usar valore pequenos para não sobrecarregar o server.
#
require 'mechanize'
require 'pg'
require 'json'

if ARGV.size < 7
  puts "Uso: ruby busca_UR.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo>"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
LongOeste = ARGV[2].to_f
LatNorte = ARGV[3].to_f
LongLeste = ARGV[4].to_f
LatSul = ARGV[5].to_f
Passo = ARGV[6].to_f

agent = Mechanize.new
count = 0
while agent.cookie_jar.jar.empty?
  begin
    page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
  rescue Mechanize::ResponseCodeError
    csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value if agent.cookie_jar.jar.size > 0
    sleep (2 * (count + 1))
  end
  count += 1
end
puts "Tentativas: #{count}"
login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => csrf_token})

db = PG::Connection.new(:hostaddr => ENV['POSTGRESQL_DB_HOST'], :dbname => 'br_painel', :user => ENV['POSTGRESQL_DB_USERNAME'], :password => ENV['POSTGRESQL_DB_PASSWORD'])
db.prepare('insere_usuario','insert into usuario (id, username, rank) values ($1,$2,$3)')
db.prepare('update_usuario','update usuario set username = $2, rank = $3 where id = $1')
db.prepare('insere_mp','insert into mp (id,resolvida_por,resolvida_em,peso,posicao,resolucao) values ($1,$2,$3,$4,ST_SetSRID(ST_Point($5, $6), 4674),$7)')
db.prepare('insere_ur',"insert into ur (id,posicao,resolvida_por,resolvida_em,data_abertura,resolucao) values ($1,ST_SetSRID(ST_Point($2, $3), 4674),$4,$5,$6,$7)")
db.prepare('update_ur','update ur set comentarios = $1, ultimo_comentario = $2, data_ultimo_comentario = $3, autor_comentario = $4 where id = $5')

#$usuario = {}
#db.exec('select * from usuario').each {|u| $usuario[u['id']] = u['rank']}

def busca(db,agent,longOeste,latNorte,longLeste,latSul,passo,exec)
  lonIni = longOeste
  while lonIni < longLeste do
    lonFim = [((lonIni + passo)*100000).to_int/100000.0 , longLeste].min
    lonFim = longLeste if (longLeste - lonFim) < (passo / 4)
    latIni = latNorte
    while latIni > latSul do
      latFim = [((latIni - passo)*100000).to_int/100000.0, latSul].max
      latFim = latSul if (latFim - latSul) < (passo / 4)
      area = [lonIni, latIni, lonFim, latFim]

      begin
        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?mapUpdateRequestFilter=1&problemFilter=0&bbox=#{area.join('%2C')}"

        json = JSON.parse(wme.body)

        # Coleta os usuários que editaram na área
        json['users']['objects'].each do |u|
          if u['id'].to_i > 0
            usuario = db.exec_params('select rank from usuario where id = $1',[u['id']])
            if usuario.ntuples > 0
              if usuario[0]['rank'] != (u['rank']+1)
                db.exec_prepared('update_usuario', [u['id'],u['userName'],u['rank']+1])
              end
            else
              db.exec_prepared('insere_usuario', [u['id'],u['userName'],u['rank']+1])
            end
          end
        end

        # Coleta os dados sobre as MPs na area
        json['problems']['objects'].each do |m|
          begin
            db.exec_prepared('insere_mp',[m['id'][2..-1], m['resolvedBy'], (m['resolvedOn'].nil? ? nil : Time.at(m['resolvedOn']/1000)), m['weight'], m['geometry']['coordinates'][0], m['geometry']['coordinates'][1], m['resolution']])
          rescue PG::InvalidTextRepresentation
            puts "#{m}"
          end
        end

        urs_area = []
        # Coleta os IDs de todas as URs na area
        json['mapUpdateRequests']['objects'].each do |u|
          urs_area << u['id']
          db.exec_prepared('insere_ur', [u['id'], u['geometry']['coordinates'][0], u['geometry']['coordinates'][1], u['resolvedBy'], (u['resolvedOn'].nil? ? nil : Time.at(u['resolvedOn']/1000)), Time.at(u['driveDate']/1000), u['resolution'] ] )
        end

        # Busca todas as informacoes sobre as URs encontradas
        if urs_area.size > 0
          ur = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs_area.join('%2C')}").body)

          ur['updateRequestSessions']['objects'].each do |u|
            begin
              db.exec_prepared('update_ur', [(u.has_key?('comments') and u['comments'].size > 0 ? u['comments'].size : 0 ),(u.has_key?('comments') and u['comments'].size > 0 ? u['comments'][-1]['text'].gsub('"',"'") : nil), (u.has_key?('comments') and u['comments'].size > 0 ? Time.at(u['comments'][-1]['createdOn']/1000) : nil), (u.has_key?('comments') and u['comments'].size > 0 ? u['comments'][-1]['userID'] : nil), u['id']] )
            rescue NoMethodError
              puts "#{u}"
              exit
            end
          end
        end

      # Trata eventuais erros de conexao
      rescue Mechanize::ResponseCodeError
        # Caso o problema tenha sido no tamanho do pacote de resposta, divide a area em 4 pedidos menores (limitado a 3 reducoes)
        if exec < 3
          busca(db,agent,area[0],area[1],area[2],area[3],(passo/2),(exec+1))
        else
          puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - ResponseCodeError em #{area}"
        end
      rescue JSON::ParserError
        # Erro no corpo do pacote - precisa ser investigada a razao deste erro
        puts "Erro JSON em #{area}"
      end

      latIni = latFim
      sleep 2
    end
    lonIni = lonFim
  end
end

busca(db,agent,LongOeste,LatNorte,LongLeste,LatSul,Passo,1)
