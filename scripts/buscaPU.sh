#!/bin/bash

cd $HOME/br_painel/scripts/

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')"

psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'delete from pu;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'delete from local;'

ruby busca_PU.rb $1 $2 -61.5 6 -59 5 0.1
ruby busca_PU.rb $1 $2 -66 5 -59 3 0.1
ruby busca_PU.rb $1 $2 -52.5 5 -50 3 0.1
ruby busca_PU.rb $1 $2 -69 3 -50 2 0.1
ruby busca_PU.rb $1 $2 -67.5 2 -49 0 0.1
ruby busca_PU.rb $1 $2 -67.5 0 -43.5 -2 0.1
ruby busca_PU.rb $1 $2 -67.5 -2 -37.5 -4 0.1
ruby busca_PU.rb $1 $2 -73.5 -4 -34.5 -6 0.1
ruby busca_PU.rb $1 $2 -75 -6 -34.5 -8 0.1

ruby busca_PU.rb $1 $2 -75 -8 -43.5 -9 0.1
ruby busca_PU.rb $1 $2 -43.5 -8 -43.2 -8.7 0.1
# Ghost Town => [-43.5,-8.7,-43.2,-9.0]
ruby busca_PU.rb $1 $2 -43.2 -8 -34.5 -9 0.1

ruby busca_PU.rb $1 $2 -73.5 -9 -34.5 -10 0.1

# Com Bahia
#ruby busca_PU.rb $1 $2 -73.5 -10 -34.5 -11 0.1
#ruby busca_PU.rb $1 $2 -72 -11 -36 -12 0.1
#ruby busca_PU.rb $1 $2 -66 -12 -36 -14 0.1
#ruby busca_PU.rb $1 $2 -61.5 -14 -38.5 -17 0.1

# Sem Bahia
ruby busca_PU.rb $1 $2 -73.5 -10 -43.7 -11 0.1
ruby busca_PU.rb $1 $2 -38.4 -10 -34.5 -11 0.1
ruby busca_PU.rb $1 $2 -72 -11 -46 -12 0.1
ruby busca_PU.rb $1 $2 -38.2 -11 -36 -12 0.1
ruby busca_PU.rb $1 $2 -66 -12 -46 -14 0.1
ruby busca_PU.rb $1 $2 -61.5 -14 -39.8 -17 0.1
#

ruby busca_PU.rb $1 $2 -58.5 -17 -38.5 -21 0.1
ruby busca_PU.rb $1 $2 -58.5 -21 -40.5 -23 0.1
ruby busca_PU.rb $1 $2 -55.5 -23 -47.5 -26 0.1

# Sao Paulo
ruby busca_PU.rb $1 $2 -47.5 -23 -43.5 -24 0.1
ruby busca_PU.rb $1 $2 -47.5 -24 -45.5 -25 0.1

# Santa Catarina
ruby busca_PU.rb $1 $2 -54 -26 -48 -29 0.1
ruby busca_PU.rb $1 $2 -57 -27 -54 -29 0.1
ruby busca_PU.rb $1 $2 -58 -29 -49 -31 0.1
ruby busca_PU.rb $1 $2 -57 -31 -50 -32 0.1
ruby busca_PU.rb $1 $2 -54.5 -32 -51.5 -33 0.1
ruby busca_PU.rb $1 $2 -54 -33 -52 -34 0.1

psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c "update atualizacao set data = current_timestamp where objeto = 'pu';"
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update pu set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, pu.posicao)) where municipioid is null;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_pu;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'vacuum analyze;'

echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')"
