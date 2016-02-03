#!/usr/bin/env bash

# This script initializes the HMM models based on TIMIT phonetic transcriptions,
# and then train up the monophone models.
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

echo "Started Training monophones at `date`" > ${LOG}/log.mono

# Generate a prototype HMM model to use as a template for monophone HMMs
echo 'Generating a prototype model ...' >> ${LOG}/log.mono
echo proto > protolist
echo N | ${SCRIPT}/help/MakeProtoHMMSet.pl ${CONFIG}/sim.pcf >> ${LOG}/log.mono
rm -f protolist

rm -rf ${HMM}/hmm0 ${HMM}/hmm1

mkdir -p HMM/hmm0/hmmdefs

echo 'Starting initial HMMs for each monophone with HInit' >> ${LOG}/log.mono

# Running HInit for each phone in the monophones file and then HRest to estimate initial parameters from training set
while read phn; do
    echo "Creating HMM for phoneme" ${phn} >> ${LOG}/log.mono
    HInit -A -T 1 -l ${phn} -o ${phn} -M ${HMM}/hmm0/hmmdefs -S TRAIN.MFC -I TRAINMono.mlf proto >> ${LOG}/log.mono
    HRest -A -T 1 -v 0.01 -S TRAIN.MFC -I TRAINMono.mlf -M ${HMM}/hmm0/hmmdefs ${HMM}/hmm0/hmmdefs/${phn} >> ${LOG}/log.mono
done < monophones

# At this point, we should have decent set of monophones stored in
# ${HMM}/hmm0/hmmdefs, but we'll carry on and do Baum-Welch
# re-estimation using the phone labeled data.

# First, we figure out the global variance, so we can have a floor
# on the variances in further re-estimation steps.
echo 'Figuring out the global variance with HCompV' >> ${LOG}/log.mono
mkdir -p HMM/hmm1
HCompV -A -T 1 -f 0.01 -m -S TRAIN.MFC -M ${HMM}/hmm1/ -I TRAINMono.mlf proto >> ${LOG}/log.mono
rm -f HMM/hmm1/proto

echo 'Concatenating prototype models to build a starting master model definition file' >> ${LOG}/log.mono
nmix=1
NEWDIR=${HMM}/hmm1/mono-nmix${nmix}-npass0
mkdir -p ${NEWDIR}

cat ${CONFIG}/macros > ${NEWDIR}/MMF
cat HMM/hmm1/vFloors >> ${NEWDIR}/MMF
for phn in `cat monophones` ; do
    sed -e "1,3d" HMM/hmm0/hmmdefs/${phn} >> ${NEWDIR}/MMF
done

OPT=" -A -T 1 -m 3 -t 250.0 150.0 1000.0 -S TRAIN.MFC"

echo Start training monophones at: `date` >> ${LOG}/log.mono

while [ ${nmix} -le ${NMIXMONO} ] ; do

  ## NB the inner loop of both cases is duplicated - change both!
  if [ ${nmix} -eq 1 ] ; then
    npass=1;
    while [ ${npass} -le ${NPASSPERMIX} ] ; do
      OLDDIR=${NEWDIR}
      NEWDIR=${HMM}/hmm1/mono-nmix${nmix}-npass${npass}
      mkdir -p ${NEWDIR}
      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones >> ${LOG}/log.mono
      npass=$(($npass+1))
    done
    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
    nmix=2
  else
    OLDDIR=${NEWDIR}
    NEWDIR=HMM/hmm1/mono-nmix${nmix}-npass0
    mkdir -p ${NEWDIR}
    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed monophones >> ${LOG}/log.mono
    npass=1
    while [ ${npass} -le ${NPASSPERMIX} ] ; do
      OLDDIR=${NEWDIR}
      NEWDIR=${HMM}/hmm1/mono-nmix${nmix}-npass${npass}
      mkdir -p ${NEWDIR}
      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones >> ${LOG}/log.mono
      npass=$(($npass+1))
    done
    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
    nmix=$(($nmix+2))
  fi

done
rm -f tmp.hed proto
echo Completed monophone training at: `date` >> ${LOG}/log.mono
