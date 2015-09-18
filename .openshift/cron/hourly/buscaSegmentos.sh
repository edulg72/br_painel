#!/bin/bash

psql -h 192.168.1.7 -d wazedb -U waze -c 'delete from segmentos;delete from ruas;delete from cidades;' > /dev/null
echo "Pará"
ruby busca_segmentos.rb $1 $2 -57 3 -46 -10 0.2
echo "Santa Catarina e Rio Grande do Sul"
ruby busca_segmentos.rb $1 $2 -54 -26 -48 -29 0.2
ruby busca_segmentos.rb $1 $2 -55.5 -27 -54 -28 0.2
ruby busca_segmentos.rb $1 $2 -57 -28 -54 -29 0.2
ruby busca_segmentos.rb $1 $2 -58 -29 -49 -31 0.2
ruby busca_segmentos.rb $1 $2 -57 -31 -50 -32 0.2
ruby busca_segmentos.rb $1 $2 -54.5 -32 -51.5 -33 0.2
ruby busca_segmentos.rb $1 $2 -54 -33 -52 -34 0.2

psql -h 192.168.1.7 -d wazedb -U waze -c 'refresh materialized view vw_segmentos;'
psql -h 192.168.1.7 -d wazedb -U waze -c 'refresh materialized view vw_ruas;'
psql -h 192.168.1.7 -d wazedb -U waze -c 'refresh materialized view vw_cidades;'
psql -h 192.168.1.7 -d wazedb -U waze -c "update atualizacao set data = current_timestamp where objeto = 'segmentos';"
