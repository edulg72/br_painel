#!/usr/bin/ruby
# encoding: utf-8
#
# cerca_virtual.rb
# Monitora alterações realizadas em uma região.
# (c)2016 Eduardo Garcia <edulg72@gmail.com>
#
# Utilização:
# cerca_virtual.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <tempo em horas> [<rank máximo>]
#
require 'mechanize'
require 'pg'
require 'json'

if ARGV.size < 7
  puts "Uso: ruby cerca_virtual.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <tempo em horas>  [<rank máximo>]"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
LongOeste = ARGV[2].to_f
LatNorte = ARGV[3].to_f
LongLeste = ARGV[4].to_f
LatSul = ARGV[5].to_f
Intervalo = ARGV[6].to_f * 3600 + 300
if ARGV.size == 8
  RankMaximo = ARGV[7].to_i
else
  RankMaximo = 7
end
HorarioInicio = Time.now - Intervalo
Passo = 0.09

agent = Mechanize.new
begin
  page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
rescue Mechanize::ResponseCodeError
  csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value
end
login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => csrf_token})

def insere_log(timestamp,descricao)
  @log[timestamp] = [] if not @log.has_key?(timestamp)
  @log[timestamp] << descricao
end

@users = {}
@log = {}
db = nil


payload = '{"text": "'

#payload += "Edições realizadas entre #{HorarioInicio.strftime('%d/%m/%Y %H:%M')} e #{Time.now.strftime('%d/%m/%Y %H:%M')}" + '\n'

def busca(db,agent,longOeste,latNorte,longLeste,latSul,passo)
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
        # Busca alteracoes em places
        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?venueLevel=5&venueFilter=1&venueUpdateRequests=true&bbox=#{area.join('%2C')}"

        json = JSON.parse(wme.body)

        # Coleta os usuários que editaram na área
        json['users']['objects'].each {|u| @users[u['id']] = {name: u['userName'], rank: u['rank']+1} if not @users.key?(u['id'])}

        # Coleta os dados dos PUs na area
        json['venues']['objects'].each do |v|
          if v.has_key?('createdOn') and Time.at(v['createdOn']/1000) >= HorarioInicio

            insere_log(Time.at(v['createdOn']/1000).strftime('%Y%m%d%H%M%S'),"[#{Time.at(v['createdOn']/1000).strftime('%d/%m/%Y %H:%M:%S')}] *#{@users[v['createdBy']][:name]}*(#{@users[v['createdBy']][:rank]}) criou place '#{v.has_key?('name') ? v['name'] : (v['residential'] ? '[Residencia]' : '[Sem nome]')}' - <https://www.waze.com/editor/?zoom=5\&lon=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0]}\&lat=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1]}\&venues=#{v['id']}|Permalink>") if @users[v['createdBy']][:rank] <= RankMaximo

#            puts "#{@users[v['createdBy']][:name]}(#{@users[v['createdBy']][:rank]}) criou place \"#{v.has_key?('name') ? v['name'] : (v['residential'] ? '[Residencia]' : '[Sem nome]')}\" - https://www.waze.com/editor/?zoom=5\&lon=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0]}\&lat=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1]}\&showpur=#{v['id']}\&endshow" if @users[v['createdBy']][:rank] <= RankMaximo
          end

          if v.has_key?('updatedOn') and v['updatedOn'].nil?
            if Time.at(v['updatedOn']/1000) >= HorarioInicio
              insere_log(Time.at(v['updatedOn']/1000).strftime('%Y%m%d%H%M%S'),"[#{Time.at(v['updatedOn']/1000).strftime('%d/%m/%Y %H:%M:%S')}] *#{@users[v['updatedBy']][:name]}*(#{@users[v['updatedBy']][:rank]}) editou place '#{v.has_key?('name') ? v['name'] : (v['residential'] ? '[Residencia]' : '[Sem nome]')}' - <https://www.waze.com/editor/?zoom=5\&lon=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0]}\&lat=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1]}\&venues=#{v['id']}|Permalink>") if @users[v['updatedBy']][:rank] <= RankMaximo

#              puts "#{@users[v['updatedBy']][:name]}(#{@users[v['updatedBy']][:rank]}) editou place \"#{v.has_key?('name') ? v['name'] : (v['residential'] ? '[Residencia]' : '[Sem nome]')}\" - https://www.waze.com/editor/?zoom=5\&lon=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0]}\&lat=#{v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1]}\&showpur=#{v['id']}\&endshow" if @users[v['updatedBy']][:rank] <= RankMaximo
            end
          end
        end

        # Insere uma pequena pausa eventualmente
        sleep 1 if rand > 0.7

        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?roadTypes=1%2C2%2C3%2C4%2C5%2C6%2C7%2C8%2C10%2C15%2C16%2C17%2C18%2C19%2C20&zoom=5&bbox=#{area.join('%2C')}"

        json = JSON.parse(wme.body)

        # Coleta os usuários que editaram na área
        json['users']['objects'].each {|u| @users[u['id']] = {name: u['userName'], rank: u['rank']+1} if not @users.key?(u['id'])}

        json['segments']['objects'].each do |s|
          if s.has_key?('createdOn') and Time.at(s['createdOn']/1000) >= HorarioInicio
            if @users[s['createdBy']][:rank] <= RankMaximo
              (longitude, latitude) = s['geometry']['coordinates'][0]
              insere_log(Time.at(s['createdOn']/1000).strftime('%Y%m%d%H%M%S'),"[#{Time.at(s['createdOn']/1000).strftime('%d/%m/%Y %H:%M:%S')}] *#{@users[s['createdBy']][:name]}*(#{@users[s['createdBy']][:rank]}) criou segmento em <https://www.waze.com/editor/?zoom=5\&lat=#{latitude}\&lon=#{longitude}\&segments=#{s['id']}|Permalink>")

#              puts "#{@users[s['createdBy']][:name]}(#{@users[s['createdBy']][:rank]}) criou segmento em https://www.waze.com/editor/?zoom=5\&lat=#{latitude}\&lon=#{longitude}\&segments=#{s['id']}"
            end
          end

          if s.has_key?('updatedOn') and not s['updatedOn'].nil?
            if Time.at(s['updatedOn']/1000) > HorarioInicio
              if @users[s['updatedBy']][:rank] <= RankMaximo
                (longitude, latitude) = s['geometry']['coordinates'][0]
                insere_log(Time.at(s['updatedOn']/1000).strftime('%Y%m%d%H%M%S'),"[#{Time.at(s['updatedOn']/1000).strftime('%d/%m/%Y %H:%M:%S')}] *#{@users[s['updatedBy']][:name]}*(#{@users[s['updatedBy']][:rank]}) editou segmento em <https://www.waze.com/editor/?zoom=5\&lat=#{latitude}\&lon=#{longitude}\&segments=#{s['id']}|Permalink>")

#                puts "#{@users[s['updatedBy']][:name]}(#{@users[s['updatedBy']][:rank]}) editou segmento em https://www.waze.com/editor/?zoom=5\&lat=#{latitude}\&lon=#{longitude}\&segments=#{s['id']}"
              end
            end
          end
        end

      rescue Mechanize::ResponseCodeError
        puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - ResponseCodeError em #{area}"
      rescue JSON::ParserError
        # Erro no corpo do pacote - precisa ser investigada a razao deste erro
        puts "Erro JSON em #{area}"
      end

      latIni = latFim
    end
    lonIni = lonFim
  end
end

busca(db,agent,LongOeste,LatNorte,LongLeste,LatSul,Passo)

payload += "Sem edições realizadas entre #{HorarioInicio.strftime('%d/%m/%Y %H:%M')} e #{Time.now.strftime('%d/%m/%Y %H:%M')}" if @log.keys.size == 0
@log.keys.sort.each do |k|
  @log[k].each do |log|
#    puts log
    payload += log + '\n'
  end
end
payload += '"}'
puts payload
