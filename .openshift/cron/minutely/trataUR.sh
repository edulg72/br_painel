#!/bin/bash

cd $OPENSHIFT_HOMEDIR/app-root/repo/scripts/

USER='AbsalomBrazil'
PASS='12segredo'

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')" > ${OPENSHIFT_LOG_DIR}/trataUR.log

case $((10#$(date +%H) % 15)) in
  0)
    # São José do Rio Preto
    ruby trata_UR_regiao.rb $USER $PASS 3501 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  1)
    # Ribeirão Preto
    ruby trata_UR_regiao.rb $USER $PASS 3502 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  2)
    # Araçatuba
    ruby trata_UR_regiao.rb $USER $PASS 3503 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  3)
    # Bauru
    ruby trata_UR_regiao.rb $USER $PASS 3504 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  4)
    # Araraquara
    ruby trata_UR_regiao.rb $USER $PASS 3505 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  5)
    # Piracicaba
    ruby trata_UR_regiao.rb $USER $PASS 3506 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  6)
    # Campinas
    ruby trata_UR_regiao.rb $USER $PASS 3507 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  7)
    # Presidente Prudente
    ruby trata_UR_regiao.rb $USER $PASS 3508 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  8)
    # Marília
    ruby trata_UR_regiao.rb $USER $PASS 3509 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  9)
    # Assis
    ruby trata_UR_regiao.rb $USER $PASS 3510 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  10)
    # Itapetininga
    ruby trata_UR_regiao.rb $USER $PASS 3511 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  11)
    # Macro Metropolitana Paulista
    ruby trata_UR_regiao.rb $USER $PASS 3512 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  12)
    # Vale do Paraíba Paulista
    ruby trata_UR_regiao.rb $USER $PASS 3513 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  13)
    # Litoral Sul Paulista
    ruby trata_UR_regiao.rb $USER $PASS 3514 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
  14)
    # Metropolitana de São Paulo
    ruby trata_UR_regiao.rb $USER $PASS 3515 48 96 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
    ;;
esac

echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')" >> ${OPENSHIFT_LOG_DIR}/trataUR.log
