#!/usr/bin/env bash

# This script creates triphones models, trains triphones, ties the triphones, trains tied triphones, then
# mixes-up the number of Gaussians per state.
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
NMIXTRI=20               # number of Gaussians per state in triphones
NPASSPERMIX=4            # number of fwd/bwd passes per mixture increase

cd ${WORKDIR}

#echo generating the list of seen triphones and trainTri.mlf > ${LOG}/log.tri

#HLEd -A -T 1 -n triphones_sp -i TRAINTri.mlf ${CONFIG}/mktri_cross.led TRAINaligned.mlf >> ${LOG}/log.tri

#echo generate mktri.hed >>${LOG}/log.tri
#${SAMPLES}/HTKTutorial/maketrihed monophones_sp triphones_sp

#echo converting the single Gaussian model to triphones >>${LOG}/log.tri
OLDDIR=HMM/mono_aligned-nmix1-npass${NPASSPERMIX}
NEWDIR=HMM/tri-nmix1-npass0a
#mkdir -p ${NEWDIR}
#HHEd -A -T 1 -B -H ${OLDDIR}/MMF -M ${NEWDIR} mktri.hed monophones_sp >>${LOG}/log.tri

OPTTRI=" -B -A -T 1 -m 1 -t 250.0 150.0 1500.0 -S TRAIN.SCP"

#echo reestimating all seen triphones independently >>${LOG}/log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0b
#mkdir -p ${NEWDIR}
#HERest ${OPTTRI} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} -s ${NEWDIR}/stats triphones_sp >>${LOG}/log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0b2
#mkdir -p ${NEWDIR}
#HERest ${OPTTRI} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} -s ${NEWDIR}/stats triphones_sp >>${LOG}/log.tri


#echo generating all possible triphones models >>${LOG}/log.tri
#perl ../CreateFullList.pl monophones > fulllist

#echo building the question set for tree based state clustering >>${LOG}/log.tri
#echo "RO 200 ${NEWDIR}/stats" > tree.hed
#echo "TR 0" >> tree.hed
#cat tree_qs >> tree.hed
#echo "TR 12" >> tree.hed
#perl ../MakeClusteredTri.pl TB 750 monophones_sp >> tree.hed
#echo "TR 1" >> tree.hed
#echo "AU \"fulllist\"" >> tree.hed
#echo "CO \"tiedlist\"" >> tree.hed
#echo "ST \"trees\"" >> tree.hed


#echo performing topdown tree based clustering >>${LOG}/log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0c
#mkdir -p ${NEWDIR}
#HHEd -A -T 1 -B -H ${OLDDIR}/MMF -M ${NEWDIR} tree.hed triphones_sp >>${LOG}/log.tri

OPTTIE=" -B -A -T 1 -m 0 -t 250.0 150.0 1000.0 -S TRAIN.SCP"

#echo Start training triphones cross word at: `date` >> log.train_tri
#nmix=1
#
#while [ ${nmix} -le ${NMIXTRI} ] ; do
#  ## NB the inner loop of both cases is duplicated - change both!
#  if [ ${nmix} -eq 1 ] ; then
#    npass=1;
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/tri-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> log.train_tri
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {sil.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=${NEWDIR}
#    NEWDIR=HMM/tri-nmix${nmix}-npass0
#    mkdir -p ${NEWDIR}
#    HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
#    npass=1
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/tri-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> log.train_tri
#      npass=$(($npass+1))
#    done
#    if [ ${nmix} -eq 2 ]; then
#      echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    else
#      echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    fi
#    echo 'MU +2 {sil.state[2-4].mix}' >> tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#done
#
#echo Completed training aligned monophone with sp training at: `date` >> log.train_tri

