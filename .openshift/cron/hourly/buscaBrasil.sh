#!/bin/bash

USER='edulg'
PASS='9u625o58'

psql -d painel -U waze -c "delete from ur; delete from mp;" >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
#echo "Regiao Norte"
#ruby busca_UR.rb $USER $PASS -61.5 6 -59 5 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -66 5.3 -59 3 1  >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -52.5 5 -50 3 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -69 3 -50 2 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -67.5 2 -49 0 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
#echo "Aguardando 15s"
sleep 15
ruby busca_UR.rb $USER $PASS -67.5 0 -43.5 -2 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -67.5 -2 -37.5 -4 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -73.5 -4 -34.5 -6 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -74 -6 -34.5 -9 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
#echo "Norte e Nordeste (ate Alagoas)"
sleep 15
ruby busca_UR.rb $USER $PASS -73.5 -9 -34.5 -11 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -72 -11 -36 -12 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
sleep 10
#echo "Centro-oeste"
ruby busca_UR.rb $USER $PASS -66 -12 -36 -14 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -61.5 -14 -38.5 -17 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
sleep 15
ruby busca_UR.rb $USER $PASS -58.5 -17 -38.5 -21 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
sleep 10
ruby busca_UR.rb $USER $PASS -58.5 -21 -40.5 -23 .5 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
sleep 10
ruby busca_UR.rb $USER $PASS -55.5 -23 -47.5 -26 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
sleep 10
#echo "Sao Paulo"
ruby busca_UR.rb $USER $PASS -47.5 -23 -43.5 -24 0.5 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -47.5 -24 -45.5 -25 0.5 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
#echo "Santa Catarina"
ruby busca_UR.rb $USER $PASS -54 -26 -48 -29 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
sleep 10 
ruby busca_UR.rb $USER $PASS -57 -27 -54 -29 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -58 -29 -49 -31 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -57 -31 -50 -32 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -54.5 -32 -51.5 -33 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
ruby busca_UR.rb $USER $PASS -54 -33 -52 -33.8 1 >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log

psql -d painel -U waze -c 'update ur set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, ur.posicao)) where municipioid is null;' >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
psql -d painel -U waze -c 'update mp set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, mp.posicao)) where municipioid is null;' >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
#psql -d wazedb -U waze -c 'refresh materialized view vw_ur;' >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
#psql -d wazedb -U waze -c 'refresh materialized view vw_mp;' >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
psql -d painel -U waze -c "update atualizacao set data = current_timestamp where objeto = 'ur';" >> ${OPENSHIFT_LOG_DIR}/buscaBrasil.log
