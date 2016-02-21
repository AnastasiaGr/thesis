#!/usr/bin/env bash

# This scripts evaluates the performance of the recognizer after the audio has been
# separated by the FastICA algorithm.
#
# Copyright 2016 Anastasia Grigoropoulou

# Setting up the path variables
PROJECT=$HOME/Desktop/thesis
CONFIG=${PROJECT}/configs
SCRIPT=${PROJECT}/scripts
DICT=${PROJECT}/dicts
LOG=${PROJECT}/logs
LMODEL=${PROJECT}/models
WORKDIR=${PROJECT}/HTK_TIMIT_WRD         # Working directory for particular script
HMM=${WORKDIR}/HMM
OUTPUTS=${PROJECT}/MATLAB/Outputs
INPUTS=${PROJECT}/MATLAB/Inputs


cd ${OUTPUTS}
ls *.wav > temp
sed 's/.wav/.mfc/' < temp > MATLAB.MFC
sed 's/.wav/.rec/' < temp > MATLAB.REC
paste temp MATLAB.MFC > MATLAB.SCP

DIR=${HMM}/hmm62/tri-nmix28-npass4
p=-2.0
s=13.0

#HCopy -A -T 1 -S MATLAB.SCP -C ${CONFIG}/configMATLAB
#HVite -A -T 1 -S MATLAB.MFC -C ${CONFIG}/configCROSS -H ${DIR}/MMF -w ${LMODEL}/timit_lm/wdnet_ug -t 250.0 -p ${p} -s ${s} ${DICT}/dict ${WORKDIR}/tiedlist
echo Results > log.results
while read file; do
    HResults -A -T 1 -t -c -I MATLABWord.mlf ${WORKDIR}/tiedlist ${file}>> log.results
done < MATLAB.REC
