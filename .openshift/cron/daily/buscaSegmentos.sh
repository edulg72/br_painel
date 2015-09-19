#!/bin/bash

USER='edulg'
PASS='9u625o58'

cd $OPENSHIFT_HOMEDIR/app-root/repo/scripts/

psql -d painel -c 'delete from segmentos;delete from ruas;delete from cidades;' > /dev/null
# "Pará"
ruby busca_segmentos.rb $USER $PASS -57 3 -46 -10 0.2

# "Santa Catarina e Rio Grande do Sul"
ruby busca_segmentos.rb $USER $PASS -54 -26 -48 -29 0.2
ruby busca_segmentos.rb $USER $PASS -55.5 -27 -54 -28 0.2
ruby busca_segmentos.rb $USER $PASS -57 -28 -54 -29 0.2
ruby busca_segmentos.rb $USER $PASS -58 -29 -49 -31 0.2
ruby busca_segmentos.rb $USER $PASS -57 -31 -50 -32 0.2
ruby busca_segmentos.rb $USER $PASS -54.5 -32 -51.5 -33 0.2
ruby busca_segmentos.rb $USER $PASS -54 -33 -52 -34 0.2

psql -d painel -c 'select vw_segmentos_refresh_table();'
psql -d painel -c 'select vw_ruas_refresh_table();'
psql -d painel -c 'select vw_cidades_refresh_table();'
psql -d painel -c "update atualizacao set data = current_timestamp as time zone 'BRT' where objeto = 'segmentos';"
