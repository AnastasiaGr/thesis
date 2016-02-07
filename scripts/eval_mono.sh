#!/usr/bin/env bash

# Evaluate the TIMIT monophone models by testing them on the
# coreTEST data.
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


# Note: Here we use monophones without sp since sp is not allowed in the grammar since as it has a transition with no output.

echo Testing monophone HMM\'s on coreTest data, phn output at: `date` > ${LOG}/log.eval_mono

for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=${HMM}/hmm1/mono-nmix${nmix}-npass4
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/phn_recout.mlf -w ${LMODEL}/mlf/wdnet_monophones -p 1.0 -s 4.0 ${DICT}/dict_monophones monophones >> ${LOG}/log.eval_mono
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_recout.mlf -w ${LMODEL}/mlf/wdnet_bigram -p 1.0 -s 4.0 ${DICT}/dict_no_sp monophones >> ${LOG}/log.eval_mono
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_lm_recout.mlf -w ${LMODEL}/timit_lm/wdnet_ug -p 1.0 -s 4.0 ${DICT}/dict_no_sp monophones >> ${LOG}/log.eval_mono
done


echo Testing monophone with sp HMM\'s on coreTest data, phn output at: `date` >> ${LOG}/log.eval_mono_sp

for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=HMM/hmm5/mono-nmix${nmix}-npass4
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/phn_recout.mlf -w ${LMODEL}/mlf/wdnet_monophones -p 1.0 -s 4.0 ${DICT}/dict_monophones monophones >> ${LOG}/log.eval_mono_sp
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_recout.mlf -w ${LMODEL}/mlf/wdnet_bigram -p 1.0 -s 4.0 ${DICT}/dict monophones_sp  >> ${LOG}/log.eval_mono_sp
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_lm_recout.mlf -w ${LMODEL}/timit_lm/wdnet_ug -p 1.0 -s 4.0 ${DICT}/dict monophones_sp  >> ${LOG}/log.eval_mono_sp
done


echo Testing aligned monophone with sp HMM\'s on coreTest data, phn output at: `date` >> log.eval_mono_al

for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=HMM/hmm9/mono-nmix${nmix}-npass4
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/phn_recout.mlf -w ${LMODEL}/mlf/wdnet_monophones -p 1.0 -s 4.0 ${DICT}/dict_monophones monophones >> ${LOG}/log.eval_mono_al
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_recout.mlf -w ${LMODEL}/mlf/wdnet_bigram -p 1.0 -s 4.0 ${DICT}/dict monophones_sp  >> ${LOG}/log.eval_mono_al
    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.MFC -i ${DIR}/wrd_lm_recout.mlf -w ${LMODEL}/timit_lm/wdnet_ug -p 1.0 -s 4.0 ${DICT}/dict monophones_sp  >> ${LOG}/log.eval_mono_al
done



