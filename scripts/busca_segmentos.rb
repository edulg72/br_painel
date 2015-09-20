#!/usr/bin/ruby
# encoding: utf-8
#
# busca_segmentos_pg.rb
# Popula tabelas em uma base PostgreSQL com os dados dos segmentos de uma região.
# (c)2015 Eduardo Garcia <edulg72@gmail.com>
#
# Utilização:
# busca_segmentos.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo em graus*>
#
# * Define o tamanho dos quadrados das áreas para análise. Em regiões muito populosas usar valore pequenos para não sobrecarregar o server.

=begin
CREATE TABLE cidades
(
  id integer NOT NULL,
  nome character varying(100),
  estadoid integer,
  paisid integer,
  semnome boolean,
  CONSTRAINT cidades_pkey PRIMARY KEY (id)
)

CREATE TABLE estados
(
  id integer NOT NULL,
  nome character varying(100),
  paisid integer,
  CONSTRAINT estados_pkey PRIMARY KEY (id)
)

CREATE TABLE ruas
(
  id integer NOT NULL,
  nome character varying(100),
  cidadeid integer,
  semnome boolean,
  CONSTRAINT ruas_pkey PRIMARY KEY (id)
)

CREATE TABLE segmentos
(
  id integer NOT NULL,
  tipo integer,
  lock integer,
  elevacao integer,
  criado_por integer,
  criado_em timestamp without time zone,
  alterado_por integer,
  alterado_em timestamp without time zone,
  interdicoes boolean,
  tamanho integer,
  ruaid integer,
  posicao geometry(Point, 4674),
  CONSTRAINT segmentos_pkey PRIMARY KEY (id)
)
=end

require 'mechanize'
require 'pg'
require 'json'

if ARGV.size < 7
  puts "Uso: ruby busca_segmentos.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo>"
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

db = PG::Connection.new(:hostaddr => '192.168.1.7', :dbname => 'wazedb', :user => 'waze', :password => 'waze')
#db = PG::Connection.new(:hostaddr => '10.4.106.116', :dbname => 'wazedb', :user => 'waze', :password => 'waze')
db.prepare('insere_usuario','insert into usuario (id, username, rank) values ($1,$2,$3)')
db.prepare('insere_rua','insert into ruas (id,nome,cidadeid,semnome) values ($1,$2,$3,$4)')
db.prepare('insere_cidade','insert into cidades (id,nome,estadoid,paisid,semnome) values ($1,$2,$3,$4,$5)')
db.prepare('insere_estado','insert into estados (id,nm_estado,paisid) values ($1,$2,$3)')
db.prepare('insere_segmento','insert into segmentos (id,tipo,lock,elevacao,criado_por,criado_em,alterado_por,alterado_em,interdicoes,tamanho,ruaid,posicao) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,ST_SetSRID(ST_Point($12,$13),4674))') 
#db.prepare('insere_segmento','insert into segmentos (id,tipo,lock,elevacao,criado_por,criado_em,alterado_por,alterado_em,interdicoes,tamanho,ruaid) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)') 

usuarios = []
db.exec("select id from usuario").each {|u| usuarios << u['id']}
puts "Usuarios: #{usuarios.size}"
ruas = []
db.exec("select id from ruas").each {|r| ruas << r['id']}
cidades = []
db.exec("select id from cidades").each {|c| cidades << c['id']}
estados = []
db.exec("select id from estados").each {|e| estados << e['id']}
segmentos = []
db.exec("select id from segmentos").each {|s| segmentos << s['id']}

lonIni = LongOeste
while lonIni < LongLeste do
  lonFim = [((lonIni + Passo)*100000).to_int/100000.0 , LongLeste].min
  lonFim = LongLeste if (LongLeste - lonFim) < (Passo / 2)
  latIni = LatNorte
  while latIni > LatSul do
    latFim = [((latIni - Passo)*100000).to_int/100000.0, LatSul].max
    latFim = LatSul if (latFim - LatSul) < (Passo / 2)
    area = [lonIni, latIni, lonFim, latFim]

    begin
      wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?roadTypes=1%2C2%2C3%2C4%2C5%2C6%2C7%2C8%2C10%2C15%2C16%2C17%2C18%2C19%2C20&bbox=#{area.join('%2C')}"

      json = JSON.parse(wme.body)

      # Coleta os usuários que editaram na área
      json['users']['objects'].each do |u|
#       if db.exec_params('select * from usuario where id = $1',[u['id']]).ntuples == 0
        if not usuarios.include?(u['id'].to_s)
          db.exec_prepared('insere_usuario', [u['id'],u['userName'],u['rank']+1])
          usuarios << u['id'].to_s
        end
      end
    
      # Coleta os nomes dos estados na área
      json['states']['objects'].each do |s|
#        if db.exec_params('select * from estados where id = $1',[s['id']]).ntuples == 0
        if not estados.include?(s['id'].to_s)
          db.exec_prepared('insere_estado', [s['id'],s['name'],s['countryID']])
          estados << s['id'].to_s
        end
      end
    
      # Coleta os nomes das cidades na área
      json['cities']['objects'].each do |s|
#        if db.exec_params('select * from cidades where id = $1',[s['id']]).ntuples == 0
        if not cidades.include?(s['id'].to_s)
          db.exec_prepared('insere_cidade', [s['id'],s['name'],s['stateID'],s['countryID'],s['isEmpty']])
          cidades << s['id'].to_s
        end
      end
    
      # Coleta os nomes das ruas na área
      json['streets']['objects'].each do |s|
#        if db.exec_params('select * from ruas where id = $1',[s['id']]).ntuples == 0
        if not ruas.include?(s['id'].to_s)
          db.exec_prepared('insere_rua', [s['id'],s['name'],s['cityID'],s['isEmpty']])
          ruas << s['id'].to_s
        end
      end

      # Coleta os dados sobre os segmentos na area
      json['segments']['objects'].each do |m|
#        if db.exec_params('select * from segmentos where id = $1',[m['id']]).ntuples == 0
        if not segmentos.include?(m['id'].to_s)
          db.exec_prepared('insere_segmento',[m['id'], m['roadType'], m['lockRank'], m['level'], m['createdBy'], (m['createdOn'].nil? ? nil : Time.at(m['createdOn']/1000)), m['updatedBy'], (m['updatedOn'].nil? ? nil : Time.at(m['updatedOn']/1000)), m['hasClosures'], m['length'], m['primaryStreetID'], m['geometry']['coordinates'][0][0], m['geometry']['coordinates'][0][1]])
          segmentos << m['id'].to_s
#          db.exec_prepared('insere_segmento',[m['id'], m['roadType'], m['lockRank'], m['level'], m['createdBy'], (m['createdOn'].nil? ? nil : Time.at(m['createdOn']/1000)), m['updatedBy'], (m['updatedOn'].nil? ? nil : Time.at(m['updatedOn']/1000)), m['hasClosures'], m['length'],m['primaryStreetID']])
        end
      end
    rescue Mechanize::ResponseCodeError
      puts "ResponseCodeError em #{area}"
    rescue JSON::ParserError
      puts "Erro JSON em #{area}"
    end

#    latIni = ((latIni - Passo)*100000).to_int/100000.0
    latIni = latFim
  end
#  lonIni = ((lonIni + Passo)*100000).to_int/100000.0
  lonIni = lonFim
end
