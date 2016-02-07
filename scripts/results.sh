#!/usr/bin/env bash

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

echo "Results......" > ${LOG}/log.results_mono

for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=${HMM}/hmm1/mono-nmix${nmix}-npass4
    HResults -A -T 1 -n -I ${TESTSET}Mono.mlf monophones ${DIR}/phn_recout.mlf >> ${LOG}/log.results_mono
    HResults -A -T 1 -I ${TESTSET}Word.mlf monophones ${DIR}/wrd_recout.mlf >> ${LOG}/log.results_mono
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf monophones ${DIR}/wrd_lm_recout.mlf >> ${LOG}/log.results_mono
done

echo "Results......" > ${LOG}/log.results_mono_sp

for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=${HMM}/hmm5/mono-nmix${nmix}-npass4
    HResults -A -T 1 -I ${TESTSET}Mono.mlf monophones ${DIR}/phn_recout.mlf  >> ${LOG}/log.results_mono_sp
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf monophones ${DIR}/wrd_recout.mlf  >> ${LOG}/log.results_mono_sp
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf monophones ${DIR}/wrd_lm_recout.mlf  >> ${LOG}/log.results_mono_sp
done

echo "Results......" > ${LOG}/log.results_mono_al

for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=${HMM}/hmm9/mono-nmix${nmix}-npass4
    HResults -A -T 1 -I ${TESTSET}Mono.mlf monophones ${DIR}/phn_recout.mlf  >> ${LOG}/log.results_mono_al
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf monophones ${DIR}/wrd_recout.mlf  >> ${LOG}/log.results_mono_al
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf monophones ${DIR}/wrd_lm_recout.mlf  >> ${LOG}/log.results_mono_al
done

echo "Results......" > ${LOG}/log.results_tied

for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=${HMM}/hmm13/tri-nmix${nmix}-npass4
    HResults -A -T 1 -I ${TESTSET}Mono.mlf tiedlist ${DIR}/phn_recout.mlf   >> ${LOG}/log.results_tied
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf tiedlist ${DIR}/wrd_recout.mlf  >> ${LOG}/log.results_tied
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf tiedlist ${DIR}/wrd_lm_recout.mlf  >> ${LOG}/log.results_tied
done

echo "Results......" > ${LOG}/log.results_mixed

for nmix in 22 24 28 32; do
    DIR=${HMM}/hmm62/tri-nmix${nmix}-npass4
    HResults -A -T 1 -I ${TESTSET}Mono.mlf tiedlist ${DIR}/phn_recout.mlf   >> ${LOG}/log.results_mixed
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf tiedlist ${DIR}/wrd_recout.mlf  >> ${LOG}/log.results_mixed
    HResults -A -T 1 -c -I ${TESTSET}Word.mlf tiedlist ${DIR}/wrd_lm_recout.mlf  >> ${LOG}/log.results_mixed
done

echo "Results......" > ${LOG}/log.results_tune
DIR=HMM/hmm62/tri-nmix28-npass4
for p in -0.0 ; do
    for s in 12.0 12.5 13.0 13.5 14.0 14.5 15.0 15.5 16.0 16.5 17.0 ; do
        HResults -A -T 1 -I ${TESTSET}1Mono.mlf tiedlist ${DIR}/phn_${p}_${s}_recout.mlf   >> ${LOG}/log.results_tune
        HResults -A -T 1 -c -I ${TESTSET}1Word.mlf tiedlist  ${DIR}/wrd_${p}_${s}_recout.mlf  >> ${LOG}/log.results_tune
        HResults -A -T 1 -c -I ${TESTSET}1Word.mlf tiedlist ${DIR}/wrd_lm_${p}_${s}_recout.mlf  >> ${LOG}/log.results_tune
    done
done

for p in -2.0 -4.0 -6.0 -8.0 -10.0 ; do
    for s in 12.0 13.0 14.0 15.0 16.0 17.0  ; do
        HResults -A -T 1 -I ${TESTSET}1Mono.mlf tiedlist ${DIR}/phn_${p}_${s}_recout.mlf   >> ${LOG}/log.results_tune
        HResults -A -T 1 -c -I ${TESTSET}1Word.mlf tiedlist  ${DIR}/wrd_${p}_${s}_recout.mlf  >> ${LOG}/log.results_tune
        HResults -A -T 1 -c -I ${TESTSET}1Word.mlf tiedlist ${DIR}/wrd_lm_${p}_${s}_recout.mlf  >> ${LOG}/log.results_tune
    done
done