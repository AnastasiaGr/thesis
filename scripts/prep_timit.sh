#!/usr/bin/env bash

# This script prepares the files needed to train on the TIMIT corpus.
# That is the Master Label files and the MFCC parameter files for TIMIT Train and Test
# Here we do all the front-end processing on all the speech wave form files.
#
# Copyright 2016 by Anastasia Grigoropoulou

# Setting up the path variables
PROJECT=$HOME/Desktop/thesis
CONFIG=${PROJECT}/configs
SCRIPT=${PROJECT}/scripts
DICT=${PROJECT}/dicts
LOG=${PROJECT}/logs
TIMIT=${PROJECT}/TIMIT/TIMIT              # TIMIT Corpus burnt from CD
SAMPLES=${PROJECT}/HTK_Samples            # HTK Samples folder from http://htk.eng.cam.ac.uk/
WORK_DIR=${PROJECT}/HTK_TIMIT_WRD         # Working directory for particular script

echo "Started Preparing at `date`" > ${LOG}/log.prep

cd ${WORK_DIR}

#  Read the TIMIT disk and encode into acoustic features
for DIR in TRAIN TEST ; do
    # Create a mirror of the TIMIT directory structure inside the project directory
    (cd ${TIMIT} ; find ${DIR} -type d) | xargs mkdir -p

    # generate lists of files
    (cd ${TIMIT} ; find ${DIR} -type f -name S[IX]\*WAV) | sort > ${DIR}.WAV
    sed "s:^:${TIMIT}/:" ${DIR}.WAV > ${DIR}.SCP
    sed "s/WAV$/PHN/" ${DIR}.SCP > ${DIR}.PHN
    sed "s/WAV$/WRD/" ${DIR}.SCP > ${DIR}.WRD
    sed "s/WAV$/MFC/" ${DIR}.WAV > ${DIR}.MFC

    echo 'Generate the acoustic feature vectors' >> ${LOG}/log.prep
    paste ${DIR}.WAV ${DIR}.MFC | sed "s:^:${TIMIT}/:" > ${DIR}.convert
    HCopy -A -T 1 -C ${CONFIG}/configNIST -S ${DIR}.convert >> ${LOG}/log.prep
    rm -f ${DIR}.convert

    echo 'Create phone level MLF' >> ${LOG}/log.prep
    HLEd -A -T 1 -D -l '*' -n monophones -S ${DIR}.PHN -G TIMIT -i ${DIR}Mono.mlf ${CONFIG}/monotimit.led >> ${LOG}/log.prep
    sort monophones > ${DIR}monophones
    echo 'Create words level MLF' >> ${LOG}/log.prep
    HLEd -A -T 1 -D -l '*' -n wordlist -S ${DIR}.WRD -G TIMIT -i ${DIR}Word.mlf /dev/null >> ${LOG}/log.prep
    sort wordlist | sed "s/'em/\\\'em/" > ${DICT}/${DIR}wordlist

    rm -f ${DIR}.WAV
    rm -f ${DIR}.SCP
    rm -f ${DIR}.PHN
    rm -f ${DIR}.WRD
    rm -f monophones
    rm -f wordlist
done

# Only need one monophones list, made sure it's the same
mv TRAINmonophones monophones
rm -f TESTmonophones