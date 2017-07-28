#!/bin/bash

cd /home/rails/br_painel/scripts/

if [ `ps -ef | grep busca_comentarios | wc -l` -le "1" ]
  then
    echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')"
    #echo "Regiao Norte"
    ruby busca_comentarios.rb $1 $2 -66 5.3 -59 3 1
    ruby busca_comentarios.rb $1 $2 -52.5 5 -50 3 1
    ruby busca_comentarios.rb $1 $2 -69 3 -50 2 1
    ruby busca_comentarios.rb $1 $2 -67.5 2 -49 0 1
    ruby busca_comentarios.rb $1 $2 -67.5 0 -43.5 -2 1
    ruby busca_comentarios.rb $1 $2 -67.5 -2 -37.5 -4 1
    ruby busca_comentarios.rb $1 $2 -73.5 -4 -34.5 -6 1
    ruby busca_comentarios.rb $1 $2 -74 -6 -34.5 -8 1

    ruby busca_comentarios.rb $1 $2 -75 -8 -43.5 -9 1
    ruby busca_comentarios.rb $1 $2 -43.5 -8 -43.2 -8.7 1
    # Ghost Town => [-43.5,-8.7,-43.2,-9.0]
    ruby busca_comentarios.rb $1 $2 -43.2 -8 -34.5 -9 1

    #echo "Norte e Nordeste (ate Alagoas)"
    ruby busca_comentarios.rb $1 $2 -73.5 -9 -34.5 -10 1

    # Com Bahia
    ruby busca_comentarios.rb $1 $2 -73.5 -10 -34.5 -11 1
    ruby busca_comentarios.rb $1 $2 -72 -11 -36 -12 1
    ruby busca_comentarios.rb $1 $2 -66 -12 -36 -14 1
    ruby busca_comentarios.rb $1 $2 -61.5 -14 -38.5 -17 1

    # Sem Bahia
    #ruby busca_comentarios.rb $1 $2 -73.5 -10 -43.7 -11 1
    #ruby busca_comentarios.rb $1 $2 -38.4 -10 -34.5 -11 1
    #ruby busca_comentarios.rb $1 $2 -72 -11 -46 -12 1
    #ruby busca_comentarios.rb $1 $2 -38.2 -11 -36 -12 1
    #ruby busca_comentarios.rb $1 $2 -66 -12 -46 -14 1
    #ruby busca_comentarios.rb $1 $2 -61.5 -14 -39.8 -17 1
    #

    #echo "Centro-oeste"
    ruby busca_comentarios.rb $1 $2 -58.5 -17 -38.5 -21 1
    ruby busca_comentarios.rb $1 $2 -58.5 -21 -40.5 -23 0.5
    ruby busca_comentarios.rb $1 $2 -55.5 -23 -47.5 -26 1

    #echo "Sao Paulo"
    ruby busca_comentarios.rb $1 $2 -47.5 -23 -43.5 -24 0.5
    ruby busca_comentarios.rb $1 $2 -47.5 -24 -45.5 -25 0.5

    #echo "Santa Catarina"
    ruby busca_comentarios.rb $1 $2 -54 -26 -48 -29 1
    ruby busca_comentarios.rb $1 $2 -57 -27 -54 -29 1
    ruby busca_comentarios.rb $1 $2 -58 -29 -49 -31 1
    ruby busca_comentarios.rb $1 $2 -57 -31 -50 -32 1
    ruby busca_comentarios.rb $1 $2 -54.5 -32 -51.5 -33 1
    ruby busca_comentarios.rb $1 $2 -54 -33 -52 -33.8 1

    psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update comments set city_id = (select cd_geocmu from municipios where ST_Contains(geom, ST_Centroid(comments.geom))) where city_id is null;'
    psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_comments;'
    psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c "update atualizacao set data = current_timestamp where objeto = 'comments';"
    psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'vacuum analyze;'
    echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')] Já existe um script em execução"
fi
