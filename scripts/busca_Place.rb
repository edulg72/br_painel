#!/usr/bin/ruby
# encoding: utf-8
#
# busca_PU.rb
# Popula tabelas em uma base PostgreSQL com os dados dos PUs de uma região.
# (c)2015 Eduardo Garcia <edulg72@gmail.com>
#
# Utilização:
# busca_PU.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo em graus*>
#
# * Define o tamanho dos quadrados das áreas para análise. Em regiões muito populosas usar valore pequenos para não sobrecarregar o server.
#
require 'mechanize'
require 'pg'
require 'json'

if ARGV.size < 7
  puts "Uso: ruby busca_Place.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo>"
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
begin
  page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
rescue Mechanize::ResponseCodeError
  csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value
end
login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => csrf_token})

db = PG::Connection.new(:hostaddr => '127.0.0.1', :dbname => 'wazedb', :user => 'waze', :password => 'waze')
db.prepare('insere_usuario','insert into users (id, username, rank) values ($1,$2,$3)')
#db.prepare('insere_pu','insert into pu (id, autor, nome_local, data_criacao, posicao,staff,localID) values ($1,$2,left($3,80),$4,ST_SetSRID(ST_Point($5, $6),4674),$7,$8)')
db.prepare('insere_local','insert into places (id,name,street_id,created_on,created_by,updated_on,updated_by,position,lock,approved,residential,category) values ($1,$2,$3,$4,$5,$6,$7,ST_SetSRID(ST_Point($8,$9),4326),$10,$11,$12,$13)')

def busca(db,agent,longOeste,latNorte,longLeste,latSul,passo,exec)
  lonIni = longOeste
  while lonIni < longLeste do
    lonFim = [((lonIni + passo)*100000).to_int/100000.0 , longLeste].min
    lonFim = longLeste if (longLeste - lonFim) < (passo / 2)
    latIni = latNorte
    while latIni > latSul do
      latFim = [((latIni - passo)*100000).to_int/100000.0, latSul].max
      latFim = latSul if (latFim - latSul) < (passo / 2)
      area = [lonIni, latIni, lonFim, latFim]

      begin
        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?venueLevel=5&venueFilter=1&venueUpdateRequests=true&bbox=#{area.join('%2C')}"

        json = JSON.parse(wme.body)

        # Coleta os usuários que editaram na área
        json['users']['objects'].each do |u|
          if db.exec_params('select * from users where id = $1',[u['id']]).ntuples == 0
            db.exec_prepared('insere_usuario', [u['id'],u['userName'],u['rank']+1])
          end
        end

        # Coleta os dados dos PUs na area
        json['venues']['objects'].each do |v|

            if db.exec_params('select id from places where id = $1',[v['id']]).ntuples == 0
              db.exec_prepared('insere_local',[v['id'], v['name'], v['streetID'], (v.has_key?('createdOn') ? Time.at(v['createdOn']/1000) : nil), v['createdBy'], (v.has_key?('updatedOn') ? Time.at(v['updatedOn']/1000) : nil), v['updatedBy'], (v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0]), (v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1]), v['lockRank'], v['approved'], v['residential'], v['categories'][0] ])
            end

        end
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
    end
    lonIni = lonFim
  end
end

busca(db,agent,LongOeste,LatNorte,LongLeste,LatSul,Passo,1)
