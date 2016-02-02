#!/usr/bin/env bash

echo "============================================================================"
echo "== Word-level speech recognition system trained using HTK on TIMIT corpus =="
echo "==                    Anastasia Grigoropoulou - 2015                      =="
echo "============================================================================"

# Setting up the path variables
PROJECT=$HOME/Desktop/thesis/
CONFIG=${PROJECT}/configs/
SCRIPT=${PROJECT}/scripts/
DICT=${PROJECT}/dicts/
LOG=${PROJECT}/logs/
TIMIT=${PROJECT}/TIMIT/TIMIT/               # TIMIT Corpus burnt from CD
SAMPLES=${PROJECT}/HTK_Samples/             # HTK Samples folder from http://htk.eng.cam.ac.uk/
WORK_DIR=${PROJECT}/HTK_TIMIT_WRD           # Working directory for particular script
if [ ! -d ${WORK_DIR} ]; then               # If working directory doesn't exist, create it !
    mkdir -p ${WORK_DIR}
fi

# Setting up project variables
NMIXMONO=20              # number of Gaussians per state in monophones
NMIXTRI=20               # number of Gaussians per state in triphones
NPASSPERMIX=4            # number of fwd/bwd passes per mixture increase
TESTSET=coreTEST         # set to "test" for full test set or "coreTest"

# Code the audio files to MFCC feature vectors and create MLF files for training
#echo "Generating MFCC feature vectors and creating training and test MLF files ..."
#source ${SCRIPT}/prep_timit.sh

# We need to massage the CMU and TIMIT dictionaries for our use and then merge them
#echo "Preparing the joint TIMIT and cmu dictionary ..."
#source ${SCRIPT}/prep_dict.sh

# Initial setup of language model and working dictionary
#echo "Building language models and working dictionary..."
#source ${SCRIPT}/build_lm.sh



#echo 'Generating a prototype model' >> log

## generate a prototype model
#echo proto > protolist
#echo N | ../scripts/MakeProtoHMMSet sim.pcf >> log
#rm protolist

#if [ ! -d HMM/hmm0/hmmdefs ]; then
#    mkdir -p HMM/hmm0/hmmdefs
#fi
#if [ ! -d HMM/hmm1/hmmdefs ]; then
#    mkdir -p HMM/hmm1/hmmdefs
#fi

#echo 'Starting initial hmms for each monophone with HInit' >> log
#
#while read phn; do
#    echo "Creating HMM for phoneme" ${phn} >> log
#    HInit -A -T 1 -l ${phn} -o ${phn} -M HMM/hmm0/hmmdefs -S TRAIN.SCP -I TRAINMono.mlf proto >> log
#    HRest -A -T 1 -v 0.01 -S TRAIN.SCP -I TRAINMono.mlf -M HMM/hmm1/hmmdefs HMM/hmm0/hmmdefs/${phn} >> log
#done < monophones

#echo 'Figuring out the global variance with HCompV' >> log
#HCompV -A -T 1 -f 0.01 -m -S TRAIN.SCP -M HMM/hmm1/ -I TRAINMono.mlf proto >> log
#rm -f HMM/hmm1/proto

#echo 'Concatenating prototype models to build a starting definition file' >> log
nmix=1
NEWDIR=HMM/mono-nmix${nmix}-npass0
#if [ ! -d ${NEWDIR} ]; then               # If working directory doesn't exist, create it !
#    mkdir -p ${NEWDIR}
#fi
#
#cat macros > ${NEWDIR}/MMF
#cat HMM/hmm1/vFloors >> ${NEWDIR}/MMF
#for phn in `cat monophones` ; do
#    sed -e "1,3d" HMM/hmm1/hmmdefs/${phn} >> ${NEWDIR}/MMF
#done


OPT=" -A -T 1 -m 3 -t 250.0 150.0 1000.0 -S TRAIN.SCP"

#echo Start training monophones at: `date` >> log.train
#
#while [ ${nmix} -le ${NMIXMONO} ] ; do
#
#  ## NB the inner loop of both cases is duplicated - change both!
#  if [ ${nmix} -eq 1 ] ; then
#    npass=1;
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/mono-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones >> log.train
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=${NEWDIR}
#    NEWDIR=HMM/mono-nmix${nmix}-npass0
#    mkdir -p ${NEWDIR}
#    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed monophones >> log.train
#    npass=1
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/mono-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones >> log.train
#      npass=$(($npass+1))
#    done
#    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#done
#
#echo Completed monophone training at: `date` >> log.train


#echo filter the main test set to get the core test set >> log.eval

#FILTER='^TEST/DR./[mf](DAB0|WBT0|ELC0|TAS1|WEW0|PAS0|JMP0|LNT0|PKT0|LLL0|TLS0|JLM0|BPM0|KLT0|NLP0|CMJ0|JDH0|MGD0|GRT0|NJM0|DHC0|JLN0|PAM0|MLD0)/s[ix]'
#egrep -i ${FILTER} TEST.SCP > coreTEST.SCP
#egrep -i ${FILTER} TEST.PHN > coreTEST.PHN
#egrep -i ${FILTER} TEST.WRD > coreTEST.WRD
#HLEd -S coreTEST.PHN -G TIMIT -i coreTESTMono.mlf monotimit.led
#HLEd -S coreTEST.WRD -G TIMIT -i coreTESTWord.mlf /dev/null

#echo Create a dictionary where each word is a monophone and Build phone-word network >> log.eval

#paste monophones monophones > dict_monophones
#
#HBuild -A -T 1 monophones wdnet_monophones >> log.eval

#echo Testing monophone HMM\'s on coreTest data, phn output at: `date` >> log.eval
#
#for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
#    DIR=HMM/mono-nmix${nmix}-npass4
#    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.SCP -i ${DIR}/phn_recout.mlf -w wdnet_monophones -p 1.0 -s 4.0 dict_monophones monophones >> log.eval
#    HResults -A -T 1 -I ${TESTSET}Mono.mlf monophones ${DIR}/phn_recout.mlf >> log.results
#done

#echo Adding sp to TIMIT PHNs >> log.train_sp
#perl ../AddSpToTimit.pl TRAIN.PHN PHN_SP
#perl ../AddSpToTimit.pl TEST.PHN PHN_SP
#sed "s/PHN$/PHN_SP/" TRAIN.PHN > TRAIN.PHN_SP
#sed "s/PHN$/PHN_SP/" TEST.PHN > TEST.PHN_SP
#HLEd -A -T 1 -D -n monophones_sp -S TRAIN.PHN_SP -G TIMIT -i temp.mlf monotimit.led >> log.train_sp
#HLEd -A -T 1 -i TRAINMono_sp.mlf merge_sp.led temp.mlf >> log.train_sp
#HLEd -A -T 1 -D -S TEST.PHN_SP -G TIMIT -i temp.mlf monotimit.led >> log.train_sp
#HLEd -A -T 1 -i TESTMono_sp.mlf merge_sp.led temp.mlf >> log.train_sp
#rm -f temp.mlf

OLDDIR=HMM/mono-nmix1-npass${NPASSPERMIX}
NEWDIR=HMM/mono_sp-nmix1-npass0
#mkdir -p ${NEWDIR}


#perl ../DuplicateSilence.pl ${OLDDIR}/MMF > temp.MMF
#HHEd -A -T 1 -H temp.MMF -M ${NEWDIR} sil.hed monophones_sp >> log.train_sp
#mv ${NEWDIR}/temp.MMF ${NEWDIR}/MMF
#rm -f temp.MMF

#echo Start training monophones with sp at: `date` >> log.train_sp
#
#nmix=1
#
#while [ ${nmix} -le ${NMIXMONO} ] ; do
#
#  ## NB the inner loop of both cases is duplicated - change both!
#  if [ ${nmix} -eq 1 ] ; then
#    npass=1;
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/mono_sp-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono_sp.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> log.train_sp
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=${NEWDIR}
#    NEWDIR=HMM/mono_sp-nmix${nmix}-npass0
#    mkdir -p ${NEWDIR}
#    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed monophones_sp >> log.train_sp
#    npass=1
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/mono_sp-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINMono_sp.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> log.train_sp
#      npass=$(($npass+1))
#    done
#    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#done
#
#echo Completed monophone with sp training at: `date` >> log.train_sp

#echo Testing monophone with sp HMM\'s on coreTest data, phn output at: `date` >> log.eval_sp
#
#for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
#    DIR=HMM/mono_sp-nmix${nmix}-npass4
#    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.SCP -i ${DIR}/phn_recout.mlf -w wdnet_monophones -p 1.0 -s 4.0 dict_monophones monophones >> log.eval_sp
#    HResults -A -T 1 -I ${TESTSET}Mono.mlf monophones_sp ${DIR}/phn_recout.mlf >> log.results
#done

#echo align monophone models using word mlf >> log.aligned
#HVite -A -T 1 -o SWT -b SILENCE -a -H HMM/mono_sp-nmix1-npass4/MMF -i TRAINaligned.mlf -m -t 250.0 -I TRAINWord.mlf -S TRAIN.SCP dict_words_sil monophones_sp >> log.aligned

#cat <<"EOF" > merge_sp_sil.led
#ME sil sp sil
#ME sil sil sil
#ME sp sil sil
#EOF
#
#HLEd -A -T 1 -i TRAINaligned2.mlf merge_sp_sil.led TRAINaligned.mlf >> log.aligned

OLDDIR=HMM/mono_sp-nmix1-npass${NPASSPERMIX}
NEWDIR=HMM/mono_aligned-nmix1-npass0
#mkdir -p ${NEWDIR}
#HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} /dev/null monophones_sp

#HCompV -A -T 1 -f 0.01 -m -S TRAIN.SCP -M ${NEWDIR} -I TRAINaligned2.mlf proto >> log.train_aligned
#rm -f ${NEWDIR}/proto
# TODO: I replaced by hand here the new vfloors... I should write a script to do it

#echo Start training aligned monophones with sp at: `date` >> log.train_aligned
#
#nmix=1
#
#while [ ${nmix} -le ${NMIXMONO} ] ; do
#
#  ## NB the inner loop of both cases is duplicated - change both!
#  if [ ${nmix} -eq 1 ] ; then
#    npass=1;
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/mono_aligned-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINaligned2.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> log.train_aligned
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=${NEWDIR}
#    NEWDIR=HMM/mono_aligned-nmix${nmix}-npass0
#    mkdir -p ${NEWDIR}
#    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed monophones_sp >> log.train_aligned
#    npass=1
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/mono_aligned-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -s ${NEWDIR}/stats -I TRAINaligned2.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} monophones_sp >> log.train_aligned
#      npass=$(($npass+1))
#    done
#    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#done
#
#echo Completed training aligned monophone with sp training at: `date` >> log.train_aligned

#echo Testing aligned monophone with sp HMM\'s on coreTest data, phn output at: `date` >> log.eval_aligned
#
#for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
#    DIR=HMM/mono_aligned-nmix${nmix}-npass4
#    HVite -A -T 1 -H ${DIR}/MMF -S ${TESTSET}.SCP -i ${DIR}/phn_recout.mlf -w wdnet_monophones -p 1.0 -s 4.0 dict_monophones monophones >> log.eval_aligned
#    HResults -A -T 1 -I ${TESTSET}Mono.mlf monophones_sp ${DIR}/phn_recout.mlf >> log.results
#done

#echo generating the list of seen triphones and trainTri.mlf >> log.tri
#cat << EOF > mktri_cross.led
#WB sil
#WB sp
#NB sp
#TC
#EOF

#HLEd -A -T 1 -n triphones_sp -i TRAINTri.mlf mktri_cross.led TRAINaligned2.mlf >> log.tri

#echo generate mktri.hed >> log.tri
#${SAMPLES}/HTKTutorial/maketrihed monophones_sp triphones_sp

#echo converting the single Gaussian model to triphones >> log.tri
OLDDIR=HMM/mono_aligned-nmix1-npass${NPASSPERMIX}
NEWDIR=HMM/tri-nmix1-npass0a
#mkdir -p ${NEWDIR}
#HHEd -A -T 1 -B -H ${OLDDIR}/MMF -M ${NEWDIR} mktri.hed monophones_sp >> log.tri

OPTTRI=" -B -A -T 1 -m 1 -t 250.0 150.0 1500.0 -S TRAIN.SCP"

#echo reestimating all seen triphones independently >> log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0b
#mkdir -p ${NEWDIR}
#HERest ${OPTTRI} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} -s ${NEWDIR}/stats triphones_sp >> log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0b2
#mkdir -p ${NEWDIR}
#HERest ${OPTTRI} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} -s ${NEWDIR}/stats triphones_sp >> log.tri


#echo generating all possible triphones models >> log.tri
#perl ../CreateFullList.pl monophones > fulllist

#echo building the question set for tree based state clustering >> log.tri
#cat <<EOF > tree.hed
#RO 200 HMM/tri-nmix1-npass0b2/stats
#TR 0
#
#QS "L_Class-Stop"         {p-*,b-*,t-*,d-*,k-*,g-*}
#QS "L_Nasal"              {m-*,n-*,ng-*}
#QS "L_FricatAffricative"  {s-*,sh-*,z-*,zh-*,f-*,v-*,ch-*,jh-*,th-*,dh-*}
#QS "L_Liquid"             {l-*,el-*,r-*,ua-*,ia-*,w-*,y-*,hh-*}
#QS "L_Vowel"              {ey-*,ea-*,eh-*,ih-*,ao-*,ae-*,aa-*,oh-*,uw-*,ua-*,uh-*,er-*,ay-*,oy-*,iy-*,ia-*,aw-*,ow-*,ax-*,ah-*}
#QS "L_Silence"            {sil-*}
#QS "L_C-Front"            {p-*,b-*,m-*,f-*,v-*,w-*}
#QS "L_C-Central"          {t-*,d-*,n-*,s-*,z-*,zh-*,th-*,dh-*,l-*,el-*,r-*,ua-*,ia-*}
#QS "L_C-Back"             {sh-*,ch-*,jh-*,y-*,k-*,g-*,ng-*,hh-*}
#QS "L_V-Front"            {iy-*,ia-*,ih-*,ey-*,ea-*,eh-*}
#QS "L_V-Central"          {ae-*,oh-*,aa-*,er-*,ao-*}
#QS "L_V-Back"             {uw-*,ua-*,uh-*,ow-*,ax-*,ah-*}
#QS "L_Front"              {p-*,b-*,m-*,f-*,v-*,w-*,iy-*,ia-*,ih-*,ey-*,ea-*,eh-*}
#QS "L_Central"            {t-*,d-*,n-*,s-*,z-*,zh-*,th-*,dh-*,l-*,el-*,r-*,ua-*,ia-*,ae-*,aa-*,er-*,ao-*}
#QS "L_Back"               {sh-*,ch-*,jh-*,y-*,k-*,g-*,ng-*,hh-*,oh-*,uw-*,ua-*,uh-*,ow-*,ax-*,ah-*}
#QS "L_Fortis"             {p-*,t-*,k-*,f-*,th-*,s-*,sh-*,ch-*}
#QS "L_Lenis"              {b-*,d-*,g-*,v-*,dh-*,z-*,zh-*,jh-*}
#QS "L_UnFortLenis"        {m-*,n-*,ng-*,hh-*,l-*,el-*,r-*,ua-*,ia-*,y-*,w-*}
#QS "L_Coronal"            {t-*,d-*,n-*,th-*,dh-*,s-*,z-*,sh-*,zh-*,ch-*,jh-*,el-*,l-*,r-*,ua-*,ia-*}
#QS "L_NonCoronal"         {p-*,b-*,m-*,k-*,g-*,ng-*,f-*,v-*,hh-*,y-*,w-*}
#QS "L_Anterior"           {p-*,b-*,m-*,t-*,d-*,n-*,f-*,v-*,th-*,dh-*,s-*,z-*,l-*,el-*,w-*}
#QS "L_NonAnterior"        {k-*,g-*,ng-*,sh-*,zh-*,hh-*,ch-*,jh-*,r-*,ua-*,ia-*,y-*}
#QS "L_Continuent"         {m-*,n-*,ng-*,f-*,v-*,th-*,dh-*,s-*,z-*,sh-*,zh-*,hh-*,l-*,el-*,r-*,ua-*,ia-*,y-*,w-*}
#QS "L_NonContinuent"      {p-*,b-*,t-*,d-*,k-*,g-*,ch-*,jh-*}
#QS "L_Strident"           {s-*,z-*,sh-*,zh-*,ch-*,jh-*}
#QS "L_NonStrident"        {f-*,v-*,th-*,dh-*,hh-*}
#QS "L_UnStrident"         {p-*,b-*,m-*,t-*,d-*,n-*,k-*,g-*,ng-*,l-*,el-*,r-*,ua-*,ia-*,y-*,w-*}
#QS "L_Glide"              {hh-*,l-*,el-*,r-*,ua-*,ia-*,y-*,w-*}
#QS "L_Syllabic"           {el-*,er-*}
#QS "L_Unvoiced-cons"      {p-*,t-*,k-*,s-*,sh-*,f-*,th-*,hh-*,ch-*}
#QS "L_Voiced-cons"        {jh-*,b-*,d-*,dh-*,g-*,y-*,l-*,el-*,m-*,n-*,ng-*,r-*,ua-*,ia-*,v-*,w-*,z-*}
#QS "L_Unvoiced-all"       {p-*,t-*,k-*,s-*,sh-*,f-*,th-*,hh-*,ch-*,sil-*}
#QS "L_Long"               {iy-*,ia-*,ow-*,aw-*,ao-*,uw-*,ua-*,el-*}
#QS "L_Short"              {ae-*,ey-*,ea-*,aa-*,eh-*,ih-*,ay-*,oy-*,oh-*,ax-*,ah-*,uh-*}
#QS "L_Dipthong"           {ey-*,ea-*,ay-*,oy-*,aw-*,er-*,el-*}
#QS "L_Front-Start"        {ey-*,ea-*,aw-*,er-*}
#QS "L_Fronting"           {ay-*,ey-*,ea-*,oy-*}
#QS "L_High"               {ih-*,uw-*,ua-*,uh-*,iy-*,ia-*}
#QS "L_Medium"             {ey-*,ea-*,er-*,ax-*,ah-*,ow-*,eh-*,el-*}
#QS "L_Low"                {ae-*,ay-*,aw-*,aa-*,oh-*,ao-*,oy-*}
#QS "L_Rounded"            {ao-*,uw-*,ua-*,uh-*,oy-*,ow-*,w-*}
#QS "L_Unrounded"          {eh-*,ih-*,ae-*,aa-*,oh-*,er-*,ay-*,ey-*,ea-*,iy-*,ia-*,aw-*,ax-*,ah-*,hh-*,l-*,el-*,r-*,ua-*,ia-*,y-*}
#QS "L_Fricative"          {s-*,sh-*,z-*,zh-*,f-*,v-*,th-*,dh-*}
#QS "L_Affricate"          {ch-*,jh-*}
#QS "L_IVowel"             {ih-*,iy-*,ia-*}
#QS "L_EVowel"             {ey-*,ea-*,eh-*}
#QS "L_AVowel"             {ae-*,aa-*,oh-*,er-*,ay-*,aw-*}
#QS "L_OVowel"             {ao-*,oy-*,ow-*}
#QS "L_UVowel"             {ax-*,ah-*,el-*,uh-*,uw-*,ua-*}
#QS "L_Voiced-Stop"        {b-*,d-*,g-*}
#QS "L_Unvoiced-Stop"      {p-*,t-*,k-*}
#QS "L_Front-Stop"         {p-*,b-*}
#QS "L_Central-Stop"       {t-*,d-*}
#QS "L_Back-Stop"          {k-*,g-*}
#QS "L_Voiced-Fricative"   {z-*,zh-*,dh-*,ch-*,v-*}
#QS "L_Unvoiced-Fricative" {s-*,sh-*,th-*,f-*,ch-*}
#QS "L_Front-Fricative"    {f-*,v-*}
#QS "L_Central-Fricative"  {s-*,z-*,th-*,dh-*}
#QS "L_Back-Fricative"     {sh-*,zh-*,ch-*,jh-*}
#
#QS "R_Class-Stop"         {*+p,*+b,*+t,*+d,*+k,*+g}
#QS "R_Nasal"              {*+m,*+n,*+ng}
#QS "R_FricatAffricative"  {*+s,*+sh,*+z,*+zh,*+f,*+v,*+ch,*+jh,*+th,*+dh}
#QS "R_Liquid"             {*+l,*+el,*+r,*+ua,*+ia,*+w,*+y,*+hh}
#QS "R_Vowel"              {*+ey,*+ea,*+eh,*+ih,*+ao,*+ae,*+aa,*+oh,*+uw,*+ua,*+uh,*+er,*+ay,*+oy,*+iy,*+ia,*+aw,*+ow,*+ax,*+ah}
#QS "R_Silence"            {*+sil}
#QS "R_C-Front"            {*+p,*+b,*+m,*+f,*+v,*+w}
#QS "R_C-Central"          {*+t,*+d,*+n,*+s,*+z,*+zh,*+th,*+dh,*+l,*+el,*+r,*+ua,*+ia}
#QS "R_C-Back"             {*+sh,*+ch,*+jh,*+y,*+k,*+g,*+ng,*+hh}
#QS "R_V-Front"            {*+iy,*+ia,*+ih,*+ey,*+ea,*+eh}
#QS "R_V-Central"          {*+ae,*+oh,*+aa,*+er,*+ao}
#QS "R_V-Back"             {*+uw,*+ua,*+uh,*+ow,*+ax,*+ah}
#QS "R_Front"              {*+p,*+b,*+m,*+f,*+v,*+w,*+iy,*+ia,*+ih,*+ey,*+ea,*+eh}
#QS "R_Central"            {*+t,*+d,*+n,*+s,*+z,*+zh,*+th,*+dh,*+l,*+el,*+r,*+ua,*+ia,*+ae,*+aa,*+er,*+ao}
#QS "R_Back"               {*+sh,*+ch,*+jh,*+y,*+k,*+g,*+ng,*+hh,*+oh,*+uw,*+ua,*+uh,*+ow,*+ax,*+ah}
#QS "R_Fortis"             {*+p,*+t,*+k,*+f,*+th,*+s,*+sh,*+ch}
#QS "R_Lenis"              {*+b,*+d,*+g,*+v,*+dh,*+z,*+zh,*+jh}
#QS "R_UnFortLenis"        {*+m,*+n,*+ng,*+hh,*+l,*+el,*+r,*+ua,*+ia,*+y,*+w}
#QS "R_Coronal"            {*+t,*+d,*+n,*+th,*+dh,*+s,*+z,*+sh,*+zh,*+ch,*+jh,*+el,*+l,*+r,*+ua,*+ia}
#QS "R_NonCoronal"         {*+p,*+b,*+m,*+k,*+g,*+ng,*+f,*+v,*+hh,*+y,*+w}
#QS "R_Anterior"           {*+p,*+b,*+m,*+t,*+d,*+n,*+f,*+v,*+th,*+dh,*+s,*+z,*+l,*+el,*+w}
#QS "R_NonAnterior"        {*+k,*+g,*+ng,*+sh,*+zh,*+hh,*+ch,*+jh,*+r,*+ua,*+ia,*+y}
#QS "R_Continuent"         {*+m,*+n,*+ng,*+f,*+v,*+th,*+dh,*+s,*+z,*+sh,*+zh,*+hh,*+l,*+el,*+r,*+ua,*+ia,*+y,*+w}
#QS "R_NonContinuent"      {*+p,*+b,*+t,*+d,*+k,*+g,*+ch,*+jh}
#QS "R_Strident"           {*+s,*+z,*+sh,*+zh,*+ch,*+jh}
#QS "R_NonStrident"        {*+f,*+v,*+th,*+dh,*+hh}
#QS "R_UnStrident"         {*+p,*+b,*+m,*+t,*+d,*+n,*+k,*+g,*+ng,*+l,*+el,*+r,*+ua,*+ia,*+y,*+w}
#QS "R_Glide"              {*+hh,*+l,*+el,*+r,*+ua,*+ia,*+y,*+w}
#QS "R_Syllabic"           {*+el,*+er}
#QS "R_Unvoiced-cons"      {*+p,*+t,*+k,*+s,*+sh,*+f,*+th,*+hh,*+ch}
#QS "R_Voiced-cons"        {*+jh,*+b,*+d,*+dh,*+g,*+y,*+l,*+el,*+m,*+n,*+ng,*+r,*+ua,*+ia,*+v,*+w,*+z}
#QS "R_Unvoiced-all"       {*+p,*+t,*+k,*+s,*+sh,*+f,*+th,*+hh,*+ch,*+sil}
#QS "R_Long"               {*+iy,*+ia,*+ow,*+aw,*+ao,*+uw,*+ua,*+el}
#QS "R_Short"              {*+ae,*+ey,*+ea,*+aa,*+eh,*+ih,*+ay,*+oy,*+oh,*+ax,*+ah,*+uh}
#QS "R_Dipthong"           {*+ey,*+ea,*+ay,*+oy,*+aw,*+er,*+el}
#QS "R_Front-Start"        {*+ey,*+ea,*+aw,*+er}
#QS "R_Fronting"           {*+ay,*+ey,*+ea,*+oy}
#QS "R_High"               {*+ih,*+uw,*+ua,*+uh,*+iy,*+ia}
#QS "R_Medium"             {*+ey,*+ea,*+er,*+ax,*+ah,*+ow,*+eh,*+el}
#QS "R_Low"                {*+ae,*+ay,*+aw,*+aa,*+oh,*+ao,*+oy}
#QS "R_Rounded"            {*+ao,*+uw,*+ua,*+uh,*+oy,*+ow,*+w}
#QS "R_Unrounded"          {*+eh,*+ih,*+ae,*+aa,*+oh,*+er,*+ay,*+ey,*+ea,*+iy,*+ia,*+aw,*+ax,*+ah,*+hh,*+l,*+el,*+r,*+ua,*+ia,*+y}
#QS "R_Fricative"          {*+s,*+sh,*+z,*+zh,*+f,*+v,*+th,*+dh}
#QS "R_Affricate"          {*+ch,*+jh}
#QS "R_IVowel"             {*+ih,*+iy,*+ia}
#QS "R_EVowel"             {*+ey,*+ea,*+eh}
#QS "R_AVowel"             {*+ae,*+aa,*+oh,*+er,*+ay,*+aw}
#QS "R_OVowel"             {*+ao,*+oy,*+ow}
#QS "R_UVowel"             {*+ax,*+ah,*+el,*+uh,*+uw,*+ua}
#QS "R_Voiced-Stop"        {*+b,*+d,*+g}
#QS "R_Unvoiced-Stop"      {*+p,*+t,*+k}
#QS "R_Front-Stop"         {*+p,*+b}
#QS "R_Central-Stop"       {*+t,*+d}
#QS "R_Back-Stop"          {*+k,*+g}
#QS "R_Voiced-Fricative"   {*+z,*+zh,*+dh,*+ch,*+v}
#QS "R_Unvoiced-Fricative" {*+s,*+sh,*+th,*+f,*+ch}
#QS "R_Front-Fricative"    {*+f,*+v}
#QS "R_Central-Fricative"  {*+s,*+z,*+th,*+dh}
#QS "R_Back-Fricative"     {*+sh,*+zh,*+ch,*+jh}
#
#QS "R_ah"       {*+ah}
#QS "R_ey"       {*+ey}
#QS "R_b"        {*+b}
#QS "R_r"        {*+r}
#QS "R_iy"       {*+iy}
#QS "R_v"        {*+v}
#QS "R_t"        {*+t}
#QS "R_ay"       {*+ay}
#QS "R_d"        {*+d}
#QS "R_z"        {*+z}
#QS "R_ih"       {*+ih}
#QS "R_l"        {*+l}
#QS "R_aa"       {*+aa}
#QS "R_sh"       {*+sh}
#QS "R_ae"       {*+ae}
#QS "R_er"       {*+er}
#QS "R_jh"       {*+jh}
#QS "R_n"        {*+n}
#QS "R_aw"       {*+aw}
#QS "R_p"        {*+p}
#QS "R_s"        {*+s}
#QS "R_uw"       {*+uw}
#QS "R_ao"       {*+ao}
#QS "R_k"        {*+k}
#QS "R_eh"       {*+eh}
#QS "R_m"        {*+m}
#QS "R_ng"       {*+ng}
#QS "R_y"        {*+y}
#QS "R_ch"       {*+ch}
#QS "R_w"        {*+w}
#QS "R_hh"       {*+hh}
#QS "R_f"        {*+f}
#QS "R_ow"       {*+ow}
#QS "R_g"        {*+g}
#QS "R_dh"       {*+dh}
#QS "R_oy"       {*+oy}
#QS "R_th"       {*+th}
#QS "R_uh"       {*+uh}
#QS "R_zh"       {*+zh}
#QS "R_sil"      {*+sil}
#
#QS "L_ah"       {ah-*}
#QS "L_ey"       {ey-*}
#QS "L_b"        {b-*}
#QS "L_r"        {r-*}
#QS "L_iy"       {iy-*}
#QS "L_v"        {v-*}
#QS "L_t"        {t-*}
#QS "L_ay"       {ay-*}
#QS "L_d"        {d-*}
#QS "L_z"        {z-*}
#QS "L_ih"       {ih-*}
#QS "L_l"        {l-*}
#QS "L_aa"       {aa-*}
#QS "L_sh"       {sh-*}
#QS "L_ae"       {ae-*}
#QS "L_er"       {er-*}
#QS "L_jh"       {jh-*}
#QS "L_n"        {n-*}
#QS "L_aw"       {aw-*}
#QS "L_p"        {p-*}
#QS "L_s"        {s-*}
#QS "L_uw"       {uw-*}
#QS "L_ao"       {ao-*}
#QS "L_k"        {k-*}
#QS "L_eh"       {eh-*}
#QS "L_m"        {m-*}
#QS "L_ng"       {ng-*}
#QS "L_y"        {y-*}
#QS "L_ch"       {ch-*}
#QS "L_w"        {w-*}
#QS "L_hh"       {hh-*}
#QS "L_f"        {f-*}
#QS "L_ow"       {ow-*}
#QS "L_g"        {g-*}
#QS "L_dh"       {dh-*}
#QS "L_oy"       {oy-*}
#QS "L_th"       {th-*}
#QS "L_uh"       {uh-*}
#QS "L_zh"       {zh-*}
#QS "L_sil"      {sil-*}
#EOF
#echo "TR 12" >>tree.hed
#perl ../MakeClusteredTri.pl TB 750 monophones_sp >> tree.hed
#
#echo "TR 1" >>tree.hed
#echo "AU \"fulllist\"" >>tree.hed
#
#echo "CO \"tiedlist\"" >>tree.hed
#echo "ST \"trees\"" >>tree.hed


#echo performing topdown tree based clustering >> log.tri
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0c
#mkdir -p ${NEWDIR}
#HHEd -A -T 1 -B -H ${OLDDIR}/MMF -M ${NEWDIR} tree.hed triphones_sp >> log.tri

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

## HVITE needs to be told to perform cross word context expansion
#cat <<"EOF" > configCROSS
#FORCECXTEXP = TRUE
#ALLOWXWRDEXP = TRUE
#EOF

#echo Testing tied list triphone HMM\'s on coreTest data, phn output at: `date` >> log.eval_tri

#for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
for nmix in 1 2 4 6 8 10 12 14 16 18 20 ; do
    DIR=HMM/tri-nmix${nmix}-npass4
#    HVite -A -T 1 -t 250.0 -C configCROSS -H ${DIR}/MMF -S ${TESTSET}.SCP -i ${DIR}/phn_recout.mlf -w wdnet_bigram -p -1.0 -s 4.0 dict_train tiedlist >> log.eval_tri
#    HResults -A -T 1 -I ${TESTSET}Word.mlf tiedlist ${DIR}/phn_recout.mlf >> log.results
done

## Expand dict to triphones
#cat << EOF > tritimit.ded
#TC
#EOF
#
#HDMan -g tritimit.ded -l tridict.log TIMIT3dict TIMITdict
#echo "!ENTER	[] sil" >> TIMIT3dict
#echo "!EXIT	[] sil" >> TIMIT3dict

# and recognize with -s
# and fix wdnet_monophones to have !ENTER !EXIT

exit 0
