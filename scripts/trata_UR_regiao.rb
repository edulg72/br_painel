#!/usr/bin/ruby
# encoding: utf-8
#
# trata_UR_regiao.rb
# Faz o tratamento das User Requests (UR) de uma região de forma automática
# (c)2015-2017 Eduardo Garcia <edulg72@gmail.com>
#
# Utilização:
# trata_UR_regiao.rb <usuario> <senha> <região> <horas para encerramento por inatividade - sem info> <horas para encerramento por inatividade - com info> [<debug>]
#
require 'mechanize'
require 'json'
require 'pg'

if ARGV.size < 5
  puts "Uso: ruby trata_UR_regiao.rb <usuario> <senha> <região> <horas para encerramento por inatividade - sem info> <horas para encerramento por inatividade - com info> [debug]"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
Regiao = ARGV[2]
HORAS_SemInfo = ARGV[3].to_i
HORAS_ComInfo = ARGV[4].to_i
debug = (ARGV.size > 5 ? true : false)

msgInicial = {
  0 => ["Olá, wazer!\n\nNão consegui entender o problema :/\n\nPode fornecer mais detalhes, por favor?"],
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

db = PG::Connection.new(:hostaddr => ENV['POSTGRESQL_DB_HOST'], :dbname => 'br_painel', :user => ENV['POSTGRESQL_DB_USERNAME'], :password => ENV['POSTGRESQL_DB_PASSWORD'])
db.prepare('localiza_regiao',"select cd_geocme from regioes where cd_geocme = '#{Regiao}' and ST_Contains(geom, ST_SetSRID(ST_Point($1, $2),4674))")

ur_comentadas = 0
ur_encerradas = 0

coords = db.exec_params('select ST_XMin(ST_envelope(geom)) longoeste, ST_YMax(ST_envelope(geom)) latnorte, ST_Xmax(ST_Envelope(geom)) longleste, ST_YMin(ST_envelope(geom)) latsul from regioes where cd_geocme = $1',[Regiao])
puts "###### Rodando em modo DEBUG - Nenhuma alteraçao/tratamento será feito! ######" if debug
puts "Região analisada: [#{coords[0]['longoeste']} #{coords[0]['latnorte']}] [#{coords[0]['longleste']} #{coords[0]['latsul']}]" if debug

LongOeste = coords[0]['longoeste'].to_f
LongLeste = coords[0]['longleste'].to_f
LatNorte = coords[0]['latnorte'].to_f
LatSul = coords[0]['latsul'].to_f

lonIni = LongOeste
while lonIni < LongLeste do
  lonFim = [lonIni + 1.0 , LongLeste].min
  lonFim = lonIni + 0.1 if (lonFim - lonIni) < 0.1
  latIni = LatNorte
  while latIni > LatSul do
    latFim = [latIni - 1.0, LatSul].max
    area = [lonIni, latIni, lonFim, latFim]
    puts "\nAnalisando #{area}" if debug

    wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?mapUpdateRequestFilter=0&bbox=#{area.join('%2C')}"

    urs_area = {}
    json = JSON.parse(wme.body)

    # Coleta os IDs e coordenadas de todas as URs na area
    json['mapUpdateRequests']['objects'].each {|u| urs_area[u['id']] = {'coords' => u['geometry']['coordinates'], 'desc' => u['description']} if db.exec_prepared('localiza_regiao', [u['geometry']['coordinates'][0], u['geometry']['coordinates'][1]]).ntuples > 0}

    # Identifica as URs abertas sem descricao nem comentários abertas há pelo menos 2 horas
    urs = {}
    json['mapUpdateRequests']['objects'].each do |u|
      if db.exec_prepared('localiza_regiao',[u['geometry']['coordinates'][0],u['geometry']['coordinates'][1]]).ntuples > 0
        urs[u['id']] = u['geometry']['coordinates'] if u['open'] and (not u['hasComments']) and (u['description'] == nil) and ((Time.now.to_i - (u['driveDate']/1000)) > 7200)
      end
    end

    # Envia comentario apenas para as URs identificadas no passo anterior que nao possuem nenhum tracado
    puts "URs que receberão comentário" if debug
    if urs.size > 0
      wme = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs.keys.join('%2C')}").body)
      wme['updateRequestSessions']['objects'].each do |u|
#        if not (u.has_key?('routeGeometry') or (u.has_key?('routeInstructions') and u['routeInstructions'] != "") or u.has_key?('driveGeometry'))
          puts "https://www.waze.com/pt-BR/editor/?zoom=4&lat=#{urs[u['id']][1]}&lon=#{urs[u['id']][0]}&mapUpdateRequest=#{u['id']}" if debug
          agent.post("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests/Comment", {"mapUpdateRequestID" => u['id'], "text" => ( msgInicial.has_key?(u['type']) ? msgInicial[u['type']][rand(msgInicial[u['type']].size)] : msgInicial[0][0] )}, {"X-CSRF-Token" => csrf_token}) if not debug
          agent.post("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests/Notification", {"mapUpdateRequestID" => u['id'], "follow" => "true"}, {"X-CSRF-Token" => csrf_token}) if not debug
          ur_comentadas += 1
#        end
      end
    end

    # Exclui da lista geral de URs aquelas que receberam comentario no passo anterior
    urs.keys.each {|k| urs_area.delete(k) }

    # Procura URs com o ultimo comentario feito por um editor ha mais de DIAS
    puts "URs com ultimo comentario há #{HORAS_SemInfo} horas" if debug
    if HORAS_SemInfo > 0
      if urs_area.size > 0
        prazo = HORAS_SemInfo * 60 * 60
        ur = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs_area.keys.join('%2C')}").body)
        ur['updateRequestSessions']['objects'].each do |u|
          if u.has_key?('comments') and u['comments'].size > 0 and (u['comments'][-1]['userID'] > 0) and ((Time.now.to_i - (u['comments'][-1]['createdOn']/1000)) > prazo) and (not u.has_key?('routeGeometry')) and (not u.has_key?('driveGeometry')) and urs_area[u['id']]['desc'].nil?
            puts "https://www.waze.com/pt-BR/editor/?zoom=4&lat=#{urs_area[u['id']]['coords'][1]}&lon=#{urs_area[u['id']]['coords'][0]}&mapUpdateRequest=#{u['id']}  description: #{urs_area[u['id']]['desc']}" if debug
            agent.post("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests/Comment", {'mapUpdateRequestID' => u['id'], "text" => msgEncerramento}, {"X-CSRF-Token" => csrf_token}) if not debug
            agent.post("https://www.waze.com/row-Descartes-live/app/Features?language=pt-BR&bbox=0%2C0%2C0%2C0", "{\"actions\":{\"name\":\"CompositeAction\",\"_subActions\":[{\"_objectType\":\"mapUpdateRequest\",\"action\":\"UPDATE\",\"attributes\":{\"open\":false,\"resolution\":1,\"id\":#{u['id']}}}]}}" , {"Content-Type" => "application/json", "X-CSRF-Token" => csrf_token}) if not debug
            ur_encerradas += 1
          end
        end
      end
    end

    # Procura URs com Descrição OU traçado OU rota com o ultimo comentario feito por um editor ha mais de HORAS_ComInfo
    puts "URs com ultimo comentario há #{HORAS_ComInfo} horas" if debug
    if HORAS_ComInfo > 0
      if urs_area.size > 0
        prazo = HORAS_ComInfo * 60 * 60
        ur = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs_area.keys.join('%2C')}").body)
        ur['updateRequestSessions']['objects'].each do |u|
          if u.has_key?('comments') and u['comments'].size > 0 and (u['comments'][-1]['userID'] > 0) and ((Time.now.to_i - (u['comments'][-1]['createdOn']/1000)) > prazo)
            puts "https://www.waze.com/pt-BR/editor/?zoom=4&lat=#{urs_area[u['id']]['coords'][1]}&lon=#{urs_area[u['id']]['coords'][0]}&mapUpdateRequest=#{u['id']}  description: #{urs_area[u['id']]['desc']}" if debug
            agent.post("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests/Comment", {'mapUpdateRequestID' => u['id'], "text" => msgEncerramento}, {"X-CSRF-Token" => csrf_token}) if not debug
            agent.post("https://www.waze.com/row-Descartes-live/app/Features?language=pt-BR&bbox=0%2C0%2C0%2C0", "{\"actions\":{\"name\":\"CompositeAction\",\"_subActions\":[{\"_objectType\":\"mapUpdateRequest\",\"action\":\"UPDATE\",\"attributes\":{\"open\":false,\"resolution\":1,\"id\":#{u['id']}}}]}}" , {"Content-Type" => "application/json", "X-CSRF-Token" => csrf_token}) if not debug
            ur_encerradas += 1
          end
        end
      end
    end

    latIni = latFim
  end
  lonIni = lonFim
end

puts "\nURs comentadas: #{ur_comentadas}\nURs encerradas: #{ur_encerradas}"
