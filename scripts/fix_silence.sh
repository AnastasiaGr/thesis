#!/usr/bin/env bash

# This script fixes the silence model introducing sp between words,
# and then train up the new monophone models.
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
WORKDIR=${PROJECT}/HTK_TIMIT_WRD         # Working directory for particular script
HMM=${WORKDIR}/HMM

# Setting up project variables
NMIXMONO=20              # number of Gaussians per state in monophones
NPASSPERMIX=4            # number of fwd/bwd passes per mixture increase

cd ${WORKDIR}

echo Adding sp to TIMIT PHNs > ${LOG}/log.fix_silence
for DIR in TRAIN TEST ; do
    (cd ${TIMIT} ; find ${DIR} -type f -name S[IX]\*PHN) | sort > ${DIR}.x
    sed "s:^:${TIMIT}/:" ${DIR}.x > ${DIR}.PHN
    perl ${SCRIPT}/help/AddSpToTimit.pl ${DIR}.PHN PHN_SP
    sed "s/PHN$/PHN_SP/" ${DIR}.PHN > ${DIR}.PHN_SP
    HLEd -A -T 1 -D -l '*' -n monophones_sp -S ${DIR}.PHN_SP -G TIMIT -i temp.mlf ${CONFIG}/monotimit.led >> ${LOG}/log.fix_silence
    HLEd -A -T 1 -l '*' -i  ${DIR}Mono_sp.mlf ${CONFIG}/merge_sp.led temp.mlf >> ${LOG}/log.fix_silence
    rm -f ${DIR}.x temp.mlf
done

FILTER="^${TIMIT}/TEST/DR./[mf](DAB0|WBT0|ELC0|TAS1|WEW0|PAS0|JMP0|LNT0|PKT0|LLL0|TLS0|JLM0|BPM0|KLT0|NLP0|CMJ0|JDH0|MGD0|GRT0|NJM0|DHC0|JLN0|PAM0|MLD0)/s[ix]"
egrep -i ${FILTER} TEST.PHN_SP > coreTEST.PHN_SP
HLEd -A -T 1 -D -l '*' -n monophones_sp -S coreTEST.PHN_SP -G TIMIT -i temp.mlf ${CONFIG}/monotimit.led >> ${LOG}/log.fix_silence
HLEd -A -T 1 -l '*' -i coreTESTMono_sp.mlf ${CONFIG}/merge_sp.led temp.mlf >> ${LOG}/log.fix_silence

rm -f TRAIN.PHN* TEST.PHN* coreTEST.PHN*

OLDDIR=${HMM}/hmm1/mono-nmix1-npass${NPASSPERMIX}
NEWDIR=${HMM}/hmm5/mono-nmix1-npass0
mkdir -p ${NEWDIR}

perl ${SCRIPT}/help/DuplicateSilence.pl ${OLDDIR}/MMF > temp.MMF
HHEd -A -T 1 -H temp.MMF -M ${NEWDIR} ${CONFIG}/sil.hed monophones_sp >> ${LOG}/log.fix_silence
mv ${NEWDIR}/temp.MMF ${NEWDIR}/MMF
rm -f temp.MMF

OPT=" -A -T 1 -m 3 -t 250.0 150.0 1000.0 -S TRAIN.MFC"

echo Start training monophones with sp at: `date` >> ${LOG}/log.fix_silence

nmix=1

while [ ${nmix} -le ${NMIXMONO} ] ; do

  ## NB the inner loop of both cases is duplicated - change both!
  if [ ${nmix} -eq 1 ] ; then
    npass=1;
    while [ ${npass} -le ${NPASSPERMIX} ] ; do
      OLDDIR=${NEWDIR}
      NEWDIR=HMM/hmm5/mono-nmix${nmix}-npass${npass}
      mkdir -p ${NEWDIR}
      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono_sp.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> ${LOG}/log.fix_silence
      npass=$(($npass+1))
    done
    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
    nmix=2
  else
    OLDDIR=${NEWDIR}
    NEWDIR=HMM/hmm5/mono-nmix${nmix}-npass0
    mkdir -p ${NEWDIR}
    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed monophones_sp >> ${LOG}/log.fix_silence
    npass=1
    while [ ${npass} -le ${NPASSPERMIX} ] ; do
      OLDDIR=${NEWDIR}
      NEWDIR=HMM/hmm5/mono-nmix${nmix}-npass${npass}
      mkdir -p ${NEWDIR}
      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono_sp.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> ${LOG}/log.fix_silence
      npass=$(($npass+1))
    done
    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
    nmix=$(($nmix+2))
  fi

done
rm -f tmp.hed

echo Completed monophone with sp training at: `date` >> ${LOG}/log.fix_silence
