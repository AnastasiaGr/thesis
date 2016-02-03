#!/usr/bin/env bash

# This script aligns the word transcription based on multiple pronunciations in dictionary,
# and then trains up the new monophone models.
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

#echo align monophone models using word mlf > ${LOG}/log.aligned
#HVite -A -T 1 -o SWT -b silence -a -H ${HMM}/hmm5/mono-nmix1-npass4/MMF -i TRAINaligned.mlf -m -t 250.0 150.0 2000.0 -I TRAINWord.mlf -S TRAIN.MFC ${DICT}/cmu_timit_dict_sp_sil monophones_sp >> ${LOG}/log.aligned


#HLEd -A -T 1 -l '*' -i TRAINaligned2.mlf ${CONFIG}/merge_sp_sil.led TRAINaligned.mlf >> ${LOG}/log.aligned
#rm -f TRAINaligned.mlf
#mv TRAINaligned2.mlf TRAINaligned.mlf

OLDDIR=HMM/hmm5/mono-nmix1-npass${NPASSPERMIX}
NEWDIR=HMM/hmm9/mono-nmix1-npass0
#mkdir -p ${NEWDIR}
#HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} /dev/null monophones_sp

OPT=" -A -T 1 -m 3 -t 250.0 150.0 1000.0 -S TRAIN.MFC"

echo Start training aligned monophones with sp at: `date` >> ${LOG}/log.aligned

nmix=1

while [ ${nmix} -le ${NMIXMONO} ] ; do

  ## NB the inner loop of both cases is duplicated - change both!
  if [ ${nmix} -eq 1 ] ; then
    npass=1;
    while [ ${npass} -le ${NPASSPERMIX} ] ; do
      OLDDIR=${NEWDIR}
      NEWDIR=HMM/hmm9/mono-nmix${nmix}-npass${npass}
      mkdir -p ${NEWDIR}
      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINaligned.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> ${LOG}/log.aligned
      npass=$(($npass+1))
    done
    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
    nmix=2
  else
    OLDDIR=${NEWDIR}
    NEWDIR=HMM/hmm9/mono-nmix${nmix}-npass0
    mkdir -p ${NEWDIR}
    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed monophones_sp >> ${LOG}/log.aligned
    npass=1
    while [ ${npass} -le ${NPASSPERMIX} ] ; do
      OLDDIR=${NEWDIR}
      NEWDIR=HMM/hmm9/mono-nmix${nmix}-npass${npass}
      mkdir -p ${NEWDIR}
      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINaligned.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> ${LOG}/log.aligned
      npass=$(($npass+1))
    done
    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
    nmix=$(($nmix+2))
  fi

done

echo Completed training aligned monophones with sp training at: `date` >> ${LOG}/log.aligned
