#!/bin/bash

cd $HOME/br_painel/scripts/

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')"

psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'delete from pu;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'delete from local;'

ruby busca_PU.rb $1 $2 -61.5 6 -59 5 1
ruby busca_PU.rb $1 $2 -66 5 -59 3 1
ruby busca_PU.rb $1 $2 -52.5 5 -50 3 1
ruby busca_PU.rb $1 $2 -69 3 -50 2 1
ruby busca_PU.rb $1 $2 -67.5 2 -49 0 1
ruby busca_PU.rb $1 $2 -67.5 0 -43.5 -2 1
ruby busca_PU.rb $1 $2 -67.5 -2 -37.5 -4 1
ruby busca_PU.rb $1 $2 -73.5 -4 -34.5 -6 1
ruby busca_PU.rb $1 $2 -75 -6 -34.5 -8 1

ruby busca_PU.rb $1 $2 -75 -8 -43.5 -9 1
ruby busca_PU.rb $1 $2 -43.5 -8 -43.2 -8.7 1
# Ghost Town => [-43.5,-8.7,-43.2,-9.0]
ruby busca_PU.rb $1 $2 -43.2 -8 -34.5 -9 1

ruby busca_PU.rb $1 $2 -73.5 -9 -34.5 -11 1
ruby busca_PU.rb $1 $2 -72 -11 -36 -12 1

# Centro-oeste
ruby busca_PU.rb $1 $2 -66 -12 -36 -14 1
ruby busca_PU.rb $1 $2 -61.5 -14 -38.5 -17 1
ruby busca_PU.rb $1 $2 -58.5 -17 -38.5 -21 1
ruby busca_PU.rb $1 $2 -58.5 -21 -40.5 -23 1
ruby busca_PU.rb $1 $2 -55.5 -23 -47.5 -26 1

# Sao Paulo
ruby busca_PU.rb $1 $2 -47.5 -23 -43.5 -24 0.4
ruby busca_PU.rb $1 $2 -47.5 -24 -45.5 -25 0.4

# Santa Catarina
ruby busca_PU.rb $1 $2 -54 -26 -48 -29 1
ruby busca_PU.rb $1 $2 -57 -27 -54 -29 1
ruby busca_PU.rb $1 $2 -58 -29 -49 -31 1
ruby busca_PU.rb $1 $2 -57 -31 -50 -32 1
ruby busca_PU.rb $1 $2 -54.5 -32 -51.5 -33 1
ruby busca_PU.rb $1 $2 -54 -33 -52 -34 1

psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c "update atualizacao set data = current_timestamp where objeto = 'pu';"
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update pu set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, pu.posicao)) where municipioid is null;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_pu;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'vacuum analyze;'

echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')"
