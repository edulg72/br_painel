#!/bin/bash

cd $HOME/br_painel/scripts/

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')"

# Busca PUs

psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'delete from pu where ST_Y(posicao) < -26.0;'
# psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'delete from local;'

ruby busca_PU.rb $1 $2 -54 -26 -48 -29 1
ruby busca_PU.rb $1 $2 -57 -27 -54 -29 1
ruby busca_PU.rb $1 $2 -58 -29 -49 -31 1
ruby busca_PU.rb $1 $2 -57 -31 -50 -32 1
ruby busca_PU.rb $1 $2 -54.5 -32 -51.5 -33 1
ruby busca_PU.rb $1 $2 -54 -33 -52 -34 1

#psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c "update atualizacao set data = current_timestamp where objeto = 'pu';"
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update pu set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, pu.posicao)) where municipioid is null;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_pu;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'vacuum analyze;'

# Busca URs e MPs

psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c "delete from ur where ST_Y(posicao) < -26.0; delete from mp where ST_Y(posicao) < -26.0;"

ruby busca_UR.rb $1 $2 -54 -26 -48 -29 1
ruby busca_UR.rb $1 $2 -57 -27 -54 -29 1
ruby busca_UR.rb $1 $2 -58 -29 -49 -31 1
ruby busca_UR.rb $1 $2 -57 -31 -50 -32 1
ruby busca_UR.rb $1 $2 -54.5 -32 -51.5 -33 1
ruby busca_UR.rb $1 $2 -54 -33 -52 -33.8 1

psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update ur set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, ur.posicao)) where municipioid is null;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update mp set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, mp.posicao)) where municipioid is null;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update ur set comentarios = 0 where comentarios is null;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'update mp set peso = 0 where peso is null;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_ur;'
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_mp;'
#psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c "update atualizacao set data = current_timestamp where objeto = 'ur';"
psql -h $POSTGRESQL_DB_HOST -d br_painel -U $POSTGRESQL_DB_USERNAME -c 'vacuum analyze;'

echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')"
