#!/usr/bin/ruby
# encoding: utf-8
#
# busca_comentarios.rb
# Popula tabelas em uma base PostgreSQL com os dados dos comentarios de uma região.
# (c)2015-2017 Eduardo Garcia <edulg72@gmail.com>
#
# Utilização:
# busca_comentarios.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo em graus*>
#
# * Define o tamanho dos quadrados das áreas para análise. Em regiões muito populosas usar valores pequenos para não sobrecarregar o server.
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
@requests = 0

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
@users = {}
@comments = {}
@conversations = []

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
        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?mapComments=true&bbox=#{area.join('%2C')}&sandbox=true"
        @requests += 1

        json = JSON.parse(wme.body)

        # Coleta os usuários que editaram na área
        json['users']['objects'].each {|u| @users[u['id']] = "#{u['id']},\"#{u['userName'].nil? ? u['userName'] : u['userName'][0..49]}\",#{u['rank']+1}\n" if not @users.has_key?(u['id']) }

        # Coleta informacoes sobre os comentarios
        json['mapComments']['objects'].each do |c|
          nodes = []
          if c['geometry']['type'] == 'Point'
            geom = "SRID=4674;POINT(#{c['geometry']['coordinates'][0]} #{c['geometry']['coordinates'][1]})"
          elsif c['geometry']['type'] == 'Polygon'
            c['geometry']['coordinates'][0].each {|x| nodes << "#{x[0]} #{x[1]}"}
            geom = "SRID=4674;POLYGON((#{nodes.join(',')}))"
          end
          @comments[c['id']] = "\"#{c['id']}\",\"#{c['subject'].gsub(/"/,'""')}\",\"#{c['body'].gsub(/"/,'""')}\",#{c['lockRank'].nil? ? 0 : c['lockRank']+1},#{c['createdBy']},#{Time.at(c['createdOn']/1000)},#{c['updatedBy'].nil? ? c['createdBy'] : c['updatedBy']},#{c['updatedOn'].nil? ? Time.at(c['createdOn']/1000) : Time.at(c['updatedOn']/1000)},\"#{geom}\"\n" if not @comments.has_key?(c['id'])
          if c.has_key?('conversation')
            c['conversation'].each {|cc| @conversations << "\"#{c['id']}\",#{Time.at(cc['createdOn']/1000)},\"#{cc['text']}\",#{cc['userID']}\n"}
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

if @comments.size > 0
  db.exec("delete from usuario where id in (#{@users.keys.join(',')})") if @users.size > 0
  db.copy_data('COPY usuario (id,username,rank) FROM STDIN CSV') do
    @users.each_value {|u| db.put_copy_data u}
  end
  db.exec('vacuum usuario')

  db.exec("delete from comments where id in ('#{@comments.keys.join("','")}')") if @comments.size > 0
  db.exec("delete from comments_conversation where comment_id in ('#{@comments.keys.join("','")}')") if @comments.size > 0
  db.copy_data('COPY comments (id,subject,body,lock,created_by,created_on,updated_by,updated_on,geom) FROM STDIN CSV') do
    @comments.each_value {|c| db.put_copy_data c}
#  @comments.each_value do |c|
#    puts c
#    db.put_copy_data c
#  end
  end
  db.copy_data('COPY comments_conversation (comment_id,created_on,text,user_id) FROM STDIN CSV') do
    @conversations.each {|c| db.put_copy_data c}
  end
  db.exec('vacuum comments')
  db.exec('vacuum comments_conversation')
end

puts @requests
