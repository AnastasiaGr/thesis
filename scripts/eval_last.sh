#!/usr/bin/env bash

# Evaluate the last mixu-ps if the tied triphone models by testing them on the
# coreTEST data.
# We use monophones without sp since sp is not allowed in the grammar since as it has a transition with no output.
#
# Copyright 2016 Anastasia Grigoropoulou

# Setting up the path variables
PROJECT=$HOME/Desktop/thesis
CONFIG=${PROJECT}/configs
SCRIPT=${PROJECT}/scripts
DICT=${PROJECT}/dicts
LOG=${PROJECT}/logs
LMODEL=${PROJECT}/models
TIMIT=${PROJECT}/TIMIT/TIMIT              # TIMIT Corpus burnt from CD
SAMPLES=${PROJECT}/HTK_Samples            # HTK Samples folder from http://htk.eng.cam.ac.uk/
WORKDIR=${PROJECT}/HTK_TIMIT_WRD         # Working directory for particular script
HMM=${WORKDIR}/HMM
TESTSET=coreTEST         # set to "test" for full test set or "coreTest"


cd ${WORKDIR}

echo "RESULTS" > ${LOG}/log.results_tri

echo Testing tied list triphone HMM\'s on coreTest data, phn output at: `date` >> log.eval_tri
for nmix in $1 ; do
    DIR=HMM/hmm62/tri-nmix${nmix}-npass4
#    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/phn_recout.mlf -w ${LMODEL}/mlf/wdnet_monophones -t 250.0 -p 1.0 -s 4.0 ${DICT}/dict_monophones tiedlist >> ${LOG}/log.eval_tri
#    HVite -A -T 1 -C ${CONFIG}/configCROSS -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_recout.mlf -w ${LMODEL}/mlf/wdnet_bigram -t 250.0 -p 1.0 -s 4.0 ${DICT}/dict tiedlist  >> ${LOG}/log.eval_tri
    HVite -A -T 1 -C ${CONFIG}/configCROSS -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_lm_recout.mlf -w ${LMODEL}/timit_lm/wdnet_ug -t 250.0 -p 1.0 -s 4.0 ${DICT}/dict tiedlist >> ${LOG}/log.eval_tri
done

#for nmix in ; do
#    DIR=${HMM}/hmm13/tri-nmix${nmix}-npass4
#    HResults -A -T 1 -I ${TESTSET}Mono.mlf tiedlist ${DIR}/phn_recout.mlf   >> ${LOG}/log.results_tri
#    HResults -A -T 1 -c -I ${TESTSET}Word.mlf tiedlist ${DIR}/wrd_recout.mlf  >> ${LOG}/log.results_tri
#    HResults -A -T 1 -c -I ${TESTSET}Word.mlf tiedlist ${DIR}/wrd_lm_recout.mlf  >> ${LOG}/log.results_tri
#done

