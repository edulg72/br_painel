#!/bin/bash

cd $OPENSHIFT_HOMEDIR/app-root/repo/scripts/

USER='AbsalomBrazil'
PASS='12segredo'

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')" > ${OPENSHIFT_LOG_DIR}/trataUR.log

ruby trata_UR.rb $USER $PASS 48 -53.11011 -19.77965 -44.16136 -25.31232 SP >> ${OPENSHIFT_LOG_DIR}/trataUR.log

echo "Final de execucao: $(date '+%d/%m/%Y %H:%M:%S')" >> ${OPENSHIFT_LOG_DIR}/trataUR.log
