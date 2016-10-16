#!/bin/bash

cd $OPENSHIFT_HOMEDIR/app-root/repo/scripts/

USER='edulg'
PASS='xcdrtfygf6tr'

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')" > ${OPENSHIFT_LOG_DIR}/buscaPU.log
case $((10#$(date +%H) % 2)) in
  0)
    psql -d painel -c 'delete from pu where ST_Y(posicao) > -23;' >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    psql -d painel -c 'delete from local where ST_Y(posicao) > -23;' >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    psql -c 'vacuum;'
    ruby busca_PU.rb $USER $PASS -61.5 6 -59 5 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -66 5 -59 3 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -52.5 5 -50 3 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -69 3 -50 2 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -67.5 2 -49 0 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    sleep 15
    ruby busca_PU.rb $USER $PASS -67.5 0 -43.5 -2 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -67.5 -2 -37.5 -4 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -73.5 -4 -34.5 -6 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -75 -6 -34.5 -8 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log

    ruby busca_PU.rb $USER $PASS -75 -8 -43.5 -9 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -43.5 -8 -43.2 -8.7 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    # Ghost Town => [-43.5,-8.7,-43.2,-9.0]
    ruby busca_PU.rb $USER $PASS -43.2 -8 -34.5 -9 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log

    ruby busca_PU.rb $USER $PASS -73.5 -9 -34.5 -11 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -72 -11 -36 -12 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    sleep 15
    # Centro-oeste
    ruby busca_PU.rb $USER $PASS -66 -12 -36 -14 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -61.5 -14 -38.5 -17 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    sleep 15
    ruby busca_PU.rb $USER $PASS -58.5 -17 -38.5 -21 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    sleep 10
    ruby busca_PU.rb $USER $PASS -58.5 -21 -40.5 -23 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ;;
  1)
    psql -d painel -c 'delete from pu where ST_Y(posicao) <= -23;' >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    psql -d painel -c 'delete from local where ST_Y(posicao) <= -23;' >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    psql -c 'vacuum;'
    ruby busca_PU.rb $USER $PASS -55.5 -23 -47.5 -26 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    # Sao Paulo
    ruby busca_PU.rb $USER $PASS -47.5 -23 -43.5 -24 0.4 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -47.5 -24 -45.5 -25 0.4 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    # Santa Catarina
    ruby busca_PU.rb $USER $PASS -54 -26 -48 -29 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    sleep 10
    ruby busca_PU.rb $USER $PASS -57 -27 -54 -29 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -58 -29 -49 -31 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -57 -31 -50 -32 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -54.5 -32 -51.5 -33 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ruby busca_PU.rb $USER $PASS -54 -33 -52 -34 1 >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    psql -d painel -c "update atualizacao set data = current_timestamp where objeto = 'pu';" >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
    ;;
esac

psql -d painel -c 'update pu set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, pu.posicao)) where municipioid is null;' >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
psql -d painel -c 'select vw_pu_refresh_table();' >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
psql -c 'vacuum analyze;'

echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')" >> ${OPENSHIFT_LOG_DIR}/buscaPU.log
