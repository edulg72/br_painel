#!/bin/bash

cd $OPENSHIFT_HOMEDIR/app-root/repo/scripts/

USER='AbsalomBrazil'
PASS='12segredo'

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')" > ${OPENSHIFT_LOG_DIR}/trataUR.log

# São Paulo
#ruby trata_UR.rb $USER $PASS 48 -53.11011 -19.77965 -44.16136 -25.31232 SP >> ${OPENSHIFT_LOG_DIR}/trataUR.log

# São José do Rio Preto
ruby trata_UR_regiao.rb $USER $PASS 3501 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Ribeirão Preto
ruby trata_UR_regiao.rb $USER $PASS 3502 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Araçatuba
ruby trata_UR_regiao.rb $USER $PASS 3503 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Bauru
ruby trata_UR_regiao.rb $USER $PASS 3504 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Araraquara
ruby trata_UR_regiao.rb $USER $PASS 3505 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Piracicaba
ruby trata_UR_regiao.rb $USER $PASS 3506 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Campinas
ruby trata_UR_regiao.rb $USER $PASS 3507 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Presidente Prudente
ruby trata_UR_regiao.rb $USER $PASS 3508 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Marília
ruby trata_UR_regiao.rb $USER $PASS 3509 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Assis
ruby trata_UR_regiao.rb $USER $PASS 3510 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Itapetininga
ruby trata_UR_regiao.rb $USER $PASS 3511 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Macro Metropolitana Paulista
ruby trata_UR_regiao.rb $USER $PASS 3512 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Vale do Paraíba Paulista
ruby trata_UR_regiao.rb $USER $PASS 3513 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Litoral Sul Paulista
ruby trata_UR_regiao.rb $USER $PASS 3514 48 0 >> ${OPENSHIFT_LOG_DIR}/trataUR.log
# Metropolitana de São Paulo
ruby trata_UR_regiao.rb $USER $PASS 3515 48 96 >> ${OPENSHIFT_LOG_DIR}/trataUR.log

echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')" >> ${OPENSHIFT_LOG_DIR}/trataUR.log
