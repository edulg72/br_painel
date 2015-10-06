#!/usr/bin/ruby
# encoding: utf-8
#
# trata_UR.rb
# Faz o tratamento das User Requests (UR) de forma automática
# (c)2015 Eduardo Garcia <edulg72@gmail.com>
#
# Utilização:
# trata_UR.rb <usuario> <senha> <horas para encerramento por inatividade> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> [<sigla do estado>]
#
require 'mechanize'
require 'json'
require 'pg'

if ARGV.size < 7
  puts "Uso: ruby trata_UR.rb <usuario> <senha> <horas para encerramento por inatividade> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> [<sigla do estado>]"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
HORAS = ARGV[2].to_i
LongOeste = ARGV[3].to_f
LatNorte = ARGV[4].to_f
LongLeste = ARGV[5].to_f
LatSul = ARGV[6].to_f
Sigla = (ARGV.size > 7 ? ARGV[7] : nil)

msgInicial = {
  0 => ["Desculpe, mas pelos dados que aparecem no editor de mapas eu não consigo identificar o erro reportado. Você poderia descrever o problema encontrado?\n\nPara responder a esta mensagem basta digitar a resposta na caixa de texto abaixo, no próprio aplicativo."], 
  8 => ["Olá, wazer!\nEm qual trecho você percebeu problema com a rota oferecida?"],
  10 => ["Olá, wazer!\nOlhando aqui não encontrei o erro apontado :/\nPode dar mais detalhes?","Olá, wazer!\nNão achei o problema no mapa!\nManda mais informações, por favor!","Com as informações que aparecem aqui pra mim, não consegui encontrar nenhum problema.\nManda mais informações pra eu poder ajudar!"], 
  11 => ["Olá, wazer!\nQual curva exatamente é proibida nesse trecho?\nPreciso saber as ruas que se cruzam ;)"],
  12 => ["Olá, wazer!\nPode detalhar o problema encontrado?"],
  13 => ["Olá, wazer!\nPode detalhar o problema encontrado?"],
  15 => ["Olá, wazer!\nAonde, aproximadamente, está esse problema no mapa?"]}

msgEncerramento = "Impossível identificar o problema sem sua participação. :(\n\nOs mapas do Waze são criados e mantidos pelos próprios usuários, assim como eu e você. Participe! http://www.waze.com/editor/\n\nDúvidas, visite nosso forum:\nhttp://forum.wazebrasil.com"

agent = Mechanize.new
begin
  page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
rescue Mechanize::ResponseCodeError
  csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value
end
login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => csrf_token})

db = PG::Connection.new(:hostaddr => ENV['OPENSHIFT_POSTGRESQL_DB_HOST'], :dbname => ENV['OPENSHIFT_APP_NAME'], :user => ENV['OPENSHIFT_POSTGRESQL_DB_USERNAME'], :password => ENV['OPENSHIFT_POSTGRESQL_DB_PASSWORD'])
#db = PG::Connection.new(:hostaddr => '10.4.107.138', :dbname => 'wazedb', :user => 'waze', :password => 'waze')
db.prepare('localiza_estado',"select sigla from estados where sigla = '#{Sigla}' and ST_Contains(geom, ST_SetSRID(ST_Point($1, $2),4674))")

lonIni = LongOeste
while lonIni < LongLeste do
  lonFim = [lonIni + 1.0 , LongLeste].min
  latIni = LatNorte
  while latIni > LatSul do
    latFim = [latIni - 1.0, LatSul].max
    area = [lonIni, latIni, lonFim, latFim]
#    puts "Analisando área  [#{lonIni},#{latIni}]-[#{lonFim},#{latFim}]"

    wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?mapUpdateRequestFilter=0&bbox=#{area.join('%2C')}"

    urs_area = {}
    json = JSON.parse(wme.body)

    # Coleta os IDs e coordenadas de todas as URs na area
    json['mapUpdateRequests']['objects'].each {|u| urs_area[u['id']] = u['geometry']['coordinates'] if Sigla.nil? or db.exec_prepared('localiza_estado', [u['geometry']['coordinates'][0], u['geometry']['coordinates'][1]]).ntuples > 0}

    # Identifica as URs abertas sem descricao nem comentários abertas há pelo menos 2 horas
    urs = {}
#    puts "URs que receberao comentario inicial"
    json['mapUpdateRequests']['objects'].each do |u|
      if Sigla.nil? or db.exec_prepared('localiza_estado',[u['geometry']['coordinates'][0],u['geometry']['coordinates'][1]]).ntuples > 0
        urs[u['id']] = u['geometry']['coordinates'] if u['open'] and (not u['hasComments']) and (u['description'] == nil) and ((Time.now.to_i - (u['driveDate']/1000)) > 7200)
      end
    end

    # Envia comentario apenas para as URs identificadas no passo anterior que nao possuem nenhum tracado
    if urs.size > 0
      wme = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs.keys.join('%2C')}").body)
      wme['updateRequestSessions']['objects'].each do |u|
        if not (u.has_key?('routeGeometry') or (u.has_key?('routeInstructions') and u['routeInstructions'] != "") or u.has_key?('driveGeometry'))
#          puts "https://www.waze.com/pt-BR/editor/?zoom=4&lat=#{urs[u['id']][1]}&lon=#{urs[u['id']][0]}&mapUpdateRequest=#{u['id']}"
          agent.post("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests/Comment", {"mapUpdateRequestID" => u['id'], "text" => ( msgInicial.has_key?(u['type']) ? msgInicial[u['type']][rand(msgInicial[u['type']].size)] : msgInicial[0][0] )}, {"X-CSRF-Token" => csrf_token})
          agent.post("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests/Notification", {"mapUpdateRequestID" => u['id'], "follow" => "true"}, {"X-CSRF-Token" => csrf_token})
        end
      end
    end

    # Exclui da lista geral de URs aquelas que receberam comentario no passo anterior
    urs.keys.each {|k| urs_area.delete(k) }

    # Procura URs com o ultimo comentario feito por um editor ha mais de DIAS
    if HORAS > 0
#      puts "URs que serao encerradas apos #{DIAS} dias sem resposta"
      if urs_area.size > 0 
        prazo = HORAS * 60 * 60
        ur = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs_area.keys.join('%2C')}").body)
        ur['updateRequestSessions']['objects'].each do |u|
          if u.has_key?('comments') and u['comments'].size > 0 and (u['comments'][-1]['userID'] > 0) and ((Time.now.to_i - (u['comments'][-1]['createdOn']/1000)) > prazo)
#            puts "https://www.waze.com/pt-BR/editor/?zoom=4&lat=#{urs_area[u['id']][1]}&lon=#{urs_area[u['id']][0]}&mapUpdateRequest=#{u['id']}"
            agent.post("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests/Comment", {'mapUpdateRequestID' => u['id'], "text" => msgEncerramento}, {"X-CSRF-Token" => csrf_token})
            agent.put("https://www.waze.com/row-Descartes-live/app/Features?language=pt-BR&bbox=0%2C0%2C0%2C0", "{\"actions\":{\"name\":\"CompositeAction\",\"_subActions\":[{\"_objectType\":\"mapUpdateRequest\",\"action\":\"UPDATE\",\"attributes\":{\"open\":false,\"resolution\":1,\"id\":#{u['id']}}}]}}" , {"Content-Type" => "application/json", "X-CSRF-Token" => csrf_token})
          end
        end
      end
    end

    latIni = latFim
  end
  lonIni = lonFim
end
