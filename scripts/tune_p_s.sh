#!/usr/bin/env bash

# Tuning evaluation parameters: insertion penalty and word network scaling
# We are using the best model so far, which was the one with 28 mixtures for sil and
# 22 mixtures for all the rest
# We will use 50 out of the 192 test sentences as a fast sample.
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


echo Testing tied list triphone best HMM on coreTest data, phn output at: `date` >> log.eval_tune

DIR=HMM/hmm62/tri-nmix28-npass4

for p in $1 ; do
    for s in $2 ; do
        HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}1.MFC -i ${DIR}/phn_${p}_${s}_recout.mlf -w ${LMODEL}/mlf/wdnet_monophones -t 250.0 -p ${p} -s ${s} ${DICT}/dict_monophones tiedlist >> ${LOG}/log.eval_tune
        HVite -A -T 1 -C ${CONFIG}/configCROSS -H ${DIR}/MMF -S ${TESTSET}1.MFC -i ${DIR}/wrd_${p}_${s}_recout.mlf -w ${LMODEL}/mlf/wdnet_bigram -t 250.0 -p ${p} -s ${s} ${DICT}/dict tiedlist  >> ${LOG}/log.eval_tune
        HVite -A -T 1 -C ${CONFIG}/configCROSS -H ${DIR}/MMF -S ${TESTSET}1.MFC -i ${DIR}/wrd_lm_${p}_${s}_recout.mlf -w ${LMODEL}/timit_lm/wdnet_ug -t 250.0 -p ${p} -s ${s} ${DICT}/dict tiedlist >> ${LOG}/log.eval_tune
    done
done


