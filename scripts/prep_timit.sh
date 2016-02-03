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

cd ${WORK_DIR}


echo "Started Preparing at `date`" > ${LOG}/log.prep

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

# Create a monophones list that includes sp
cat monophones > monophones_sp
echo "sp" >> monophones_sp


# Filter the main test set to get the a subset of it used for testing in case coreTEST is True
# generate lists of files
(cd ${TIMIT} ; find TEST -type f -name S[IX]\*WAV) | sort > TEST.x
sed "s/WAV$/PHN/" TEST.x > TEST.PHN
sed "s/WAV$/WRD/" TEST.x > TEST.WRD
FILTER='^TEST/DR./[mf](DAB0|WBT0|ELC0|TAS1|WEW0|PAS0|JMP0|LNT0|PKT0|LLL0|TLS0|JLM0|BPM0|KLT0|NLP0|CMJ0|JDH0|MGD0|GRT0|NJM0|DHC0|JLN0|PAM0|MLD0)/s[ix]'
egrep -i ${FILTER} TEST.MFC > coreTEST.MFC
egrep -i ${FILTER} TEST.PHN > coreTEST.px
egrep -i ${FILTER} TEST.WRD > coreTEST.wx
sed "s:^:${TIMIT}/:" coreTEST.px > coreTEST.PHN
sed "s:^:${TIMIT}/:" coreTEST.wx > coreTEST.WRD
HLEd -S coreTEST.PHN -G TIMIT -l '*' -i coreTESTMono.mlf ${CONFIG}/monotimit.led
HLEd -S coreTEST.WRD -G TIMIT -l '*' -i coreTESTWord.mlf /dev/null
rm -f TEST.x TEST.PHN TEST.WRD coreTEST.PHN coreTEST.WRD coreTEST.px coreTEST.wx

tr '[:lower:]' '[:upper:]' < TRAINWord.mlf > TRAINWord.x
sed 's/\.LAB/\.lab/' TRAINWord.x > TRAINWord.mlf
rm -f TRAINWord.x

tr '[:lower:]' '[:upper:]' < TESTWord.mlf > TESTWord.x
sed 's/\.LAB/\.lab/' TESTWord.x > TESTWord.mlf
rm -f TESTWord.x

tr '[:lower:]' '[:upper:]' < coreTESTWord.mlf > coreTESTWord.x
sed 's/\.LAB/\.lab/' coreTESTWord.x > coreTESTWord.mlf
rm -f coreTESTWord.x