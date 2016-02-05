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

echo generating the list of seen triphones and TRAINTri.mlf > ${LOG}/log.tri

HLEd -A -T 1 -l '*' -n triphones_sp -i TRAINTri.mlf ${CONFIG}/mktri_cross.led TRAINaligned.mlf >> ${LOG}/log.tri

echo generate mktri.hed >>${LOG}/log.tri
rm -f ${CONFIG}/mktri.hed
${SCRIPT}/help/maketrihed.pl monophones_sp triphones_sp
mv mktri.hed ${CONFIG}/mktri.hed

echo converting the single Gaussian model to triphones >>${LOG}/log.tri
OLDDIR=HMM/hmm9/mono-nmix1-npass${NPASSPERMIX}
NEWDIR=HMM/hmm10/tri-nmix1-npass0
mkdir -p ${NEWDIR}
HHEd -A -T 1 -B -H ${OLDDIR}/MMF -M ${NEWDIR} ${CONFIG}/mktri.hed monophones_sp >>${LOG}/log.tri

OPTTRI=" -B -A -T 1 -m 1 -t 250.0 150.0 1500.0 -S TRAIN.MFC"

echo re-estimating all seen triphones independently >>${LOG}/log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/hmm11/tri-nmix1-npass0
mkdir -p ${NEWDIR}
HERest ${OPTTRI} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} -s ${NEWDIR}/stats triphones_sp >>${LOG}/log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/hmm12/tri-nmix1-npass0
mkdir -p ${NEWDIR}
HERest ${OPTTRI} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} -s ${NEWDIR}/stats triphones_sp >>${LOG}/log.tri

echo Generate all possible monophone, left and right biphones, and triphones. >> ${LOG}/log.tri
perl ${SCRIPT}/help/CreateFullList.pl monophones > fulllist

echo Creating the instructions for doing the decision tree clustering >> ${LOG}/log.tri
echo "RO 200 ${NEWDIR}/stats" > tree.hed
echo "TR 0" >> tree.hed
cat ${CONFIG}/tree_qs >> tree.hed
while read phn; do
echo "QS \"R_${phn}\"       {*+${phn}}" >> tree.hed
echo "QS \"L_${phn}\"       {${phn}-*}" >> tree.hed
done < monophones
echo "TR 2" >> tree.hed
perl ${SCRIPT}/help/MakeClusteredTri.pl TB 550 monophones_sp >> tree.hed
echo "TR 1" >> tree.hed
echo "AU \"fulllist\"" >> tree.hed
echo "CO \"tiedlist\"" >> tree.hed
echo "ST \"trees\"" >> tree.hed
mv tree.hed ${CONFIG}/tree.hed

OLDDIR=${NEWDIR}
NEWDIR=HMM/hmm13/tri-nmix1-npass0
echo performing top-down tree based clustering >>${LOG}/log.tri
mkdir -p ${NEWDIR}
HHEd -A -T 1 -B -H ${OLDDIR}/MMF -M ${NEWDIR} ${CONFIG}/tree.hed triphones_sp >>${LOG}/log.tri

OPTTIE=" -B -A -T 1 -m 0 -t 250.0 150.0 2000.0 -S TRAIN.MFC"

echo Start training triphones cross word at: `date` > ${LOG}/log.train_tri
nmix=1
# Separated first mix here to check sanity
npass=1;
while [ ${npass} -le ${NPASSPERMIX} ] ; do
  OLDDIR=${NEWDIR}
  NEWDIR=HMM/hmm13/tri-nmix${nmix}-npass${npass}
  mkdir -p ${NEWDIR}
  HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> ${LOG}/log.train_tri
  npass=$(($npass+1))
done

# Continue with rest of mixes, first mixing sil and then at every round mix sil and all phonemes.
echo 'MU 2 {sil.state[2-4].mix}' > tmp.hed
nmix=2
OLDDIR=${NEWDIR}
NEWDIR=HMM/hmm13/tri-nmix${nmix}-npass0
mkdir -p ${NEWDIR}
HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
npass=1
while [ ${npass} -le ${NPASSPERMIX} ] ; do
  OLDDIR=${NEWDIR}
  NEWDIR=HMM/hmm13/tri-nmix${nmix}-npass${npass}
  mkdir -p ${NEWDIR}
  HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> ${LOG}/log.train_tri
  npass=$(($npass+1))
done
echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
echo 'MU +2 {sil.state[2-4].mix}' >> tmp.hed
while [ ${nmix} -le ${NMIXTRI} ] ; do
    OLDDIR=${NEWDIR}
    NEWDIR=HMM/hmm13/tri-nmix${nmix}-npass0
    mkdir -p ${NEWDIR}
    HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
    npass=1
    while [ ${npass} -le ${NPASSPERMIX} ] ; do
      OLDDIR=${NEWDIR}
      NEWDIR=HMM/hmm13/tri-nmix${nmix}-npass${npass}
      mkdir -p ${NEWDIR}
      HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> ${LOG}/log.train_tri
      npass=$(($npass+1))
    done
    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
    echo 'MU +2 {sil.state[2-4].mix}' >> tmp.hed
    nmix=$(($nmix+2))
done

echo Completed initial training triphones training at: `date` >> ${LOG}/log.train_tri
# we have trained until 20 sil mix and 20 * mix

# Training some more mixtures on triphones before tuning Viterbi parameters.
# Starting off with getting sil from 20 to 24
OLDDIR=${HMM}/hmm13/tri-nmix20-npass4
NEWDIR=HMM/hmm62/tri-nmix22-npass0
mkdir -p ${NEWDIR}
echo 'MU 22 {sil.state[2-4].mix}' >> tmp.hed
HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
npass=1
while [ ${npass} -le ${NPASSPERMIX} ] ; do
  OLDDIR=${NEWDIR}
  NEWDIR=HMM/hmm62/tri-nmix22-npass${npass}
  mkdir -p ${NEWDIR}
  HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> ${LOG}/log.train_tri
  npass=$(($npass+1))
done

OLDDIR=${NEWDIR}
NEWDIR=HMM/hmm62/tri-nmix24-npass0
mkdir -p ${NEWDIR}
echo 'MU 24 {sil.state[2-4].mix}' >> tmp.hed
HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
npass=1
while [ ${npass} -le ${NPASSPERMIX} ] ; do
  OLDDIR=${NEWDIR}
  NEWDIR=HMM/hmm62/tri-nmix24-npass${npass}
  mkdir -p ${NEWDIR}
  HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> ${LOG}/log.train_tri
  npass=$(($npass+1))
done

# And lastly getting up sil to 32 mixtures and all other to 24 mixtures.
OLDDIR=${NEWDIR}
NEWDIR=HMM/hmm62/tri-nmix28-npass0
mkdir -p ${NEWDIR}
echo 'MU 22 {*.state[2-4].mix}' >> tmp.hed
echo 'MU 28 {sil.state[2-4].mix}' >> tmp.hed
HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
npass=1
while [ ${npass} -le ${NPASSPERMIX} ] ; do
  OLDDIR=${NEWDIR}
  NEWDIR=HMM/hmm62/tri-nmix28-npass${npass}
  mkdir -p ${NEWDIR}
  HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> ${LOG}/log.train_tri
  npass=$(($npass+1))
done

OLDDIR=${NEWDIR}
NEWDIR=HMM/hmm62/tri-nmix32-npass0
mkdir -p ${NEWDIR}
echo 'MU 24 {*.state[2-4].mix}' >> tmp.hed
echo 'MU 32 {sil.state[2-4].mix}' >> tmp.hed
HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
npass=1
while [ ${npass} -le ${NPASSPERMIX} ] ; do
  OLDDIR=${NEWDIR}
  NEWDIR=HMM/hmm62/tri-nmix32-npass${npass}
  mkdir -p ${NEWDIR}
  HERest ${OPTTIE} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist >> ${LOG}/log.train_tri
  npass=$(($npass+1))
done