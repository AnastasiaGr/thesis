#!/usr/bin/env bash -ex

echo "============================================================================"
echo "== Word-level speech recognition system trained using HTK on TIMIT corpus =="
echo "==                    Anastasia Grigoropoulou - 2015                      =="
echo "============================================================================"


# Setting up the paths
TIMIT=$HOME/Desktop/thesis/TIMIT/TIMIT/     # TIMIT Corpus burnt from CD
SAMPLES=$HOME/Desktop/thesis/HTK_Samples/   # HTK Samples folder from http://htk.eng.cam.ac.uk/
WORK_DIR=HTK_TIMIT_WRD                      # Working directory for particular script

if [ ! -d ${WORK_DIR} ]; then               # If working directory doesn't exist, create it !
    mkdir -p ${WORK_DIR}
fi

NMIXMONO=20              # number of Gaussians per state in monophones
NMIXTRI=20               # number of Gaussians per state in triphones
MINTESTMONO=1            # test the monophones after this number of Gaussians
MINTESTTRI=1             # test the triophones after this number of Gaussians
NPASSPERMIX=4            # number of fwd/bwd passes per mixture increase
TESTSET=coreTEST         # set to "test" for full test set or "coreTest"

exec >& $0.log

cd ${WORK_DIR}

echo "Started Preparing at `date`"

## write the timit config used if using HTK MFCC
#  cat <<"EOF" > config
#SOURCEKIND     = WAVEFORM
#SOURCEFORMAT   = NIST
#SAVECOMPRESSED = TRUE
#SAVEWITHCRC    = TRUE
#TARGETKIND     = MFCC_E_D_A_Z
#TARGETRATE     = 100000
#SOURCERATE     = 625
#WINDOWSIZE     = 250000.0
#PREEMCOEF      = 0.97
#ZMEANSOURCE    = TRUE
#USEHAMMING     = TRUE
#CEPLIFTER      = 22
#NUMCHANS       = 26
#NUMCEPS        = 12
#ENORMALISE     = TRUE
#ESCALE         = 1.0
#EOF
#
#
#cat <<"EOF" > monotimit.led
#DE q
#RE sil pau epi h# #h
#ME b bcl b
#ME p pcl p
#ME g gcl g
#ME d dcl d
#ME t tcl t
#ME k kcl k
#ME q qcl q
#DE bcl pcl gcl dcl tcl kcl qcl
#RE ah ax-h
#RE ng eng
#RE n nx
#RE uw ux
#RE hh hv
#RE d dx
#EOF
#
##  read the TIMIT disk and encode into acoustic features
#for DIR in TRAIN TEST ; do
#    # create a mirror of the TIMIT directory structure
#   (cd ${TIMIT} ; find ${DIR} -type d) | xargs mkdir -p
#
#    # generate lists of files
#    (cd $TIMIT ; find ${DIR} -type f -name S[IX]\*WAV) | sort > ${DIR}.WAV
#    sed "s/WAV$/PHN/" $DIR.WAV > $DIR.PHN
#    sed "s/WAV$/WRD/" $DIR.WAV > $DIR.WRD
#    sed "s/WAV$/MFC/" $DIR.WAV > $DIR.SCP
#    sed "s/WAV$/TXT/" $DIR.WAV > $DIR.TXT
#
#    # generate the acoutic feature vectors
#    paste $DIR.WAV $DIR.SCP | sed "s:^:$TIMIT:" > $DIR.convert
#    HCopy -C config -S $DIR.convert
#    rm -f $DIR.convert
#
#
#    # ax-h conflicts with HTK's triphone naming convention, so change it
#    # also generate .txt files suitable for use in language modelling
#    sed "s/.WAV$//" $DIR.WAV | while read base ; do
#    cp $TIMIT/$base.PHN $base.PHN
#    cp $TIMIT/$base.WRD $base.WRD
#    egrep -v 'h#$' $base.PHN > $base.TXT
#    done
#
#    # create phone level MLF
#    HLEd -n monophones -S $DIR.PHN -G TIMIT -i ${DIR}Mono.mlf monotimit.led
#    sort monophones > ${DIR}monophones
#    # create words level MLF
#    HLEd -n wordlist -S $DIR.WRD -G TIMIT -i ${DIR}Word.mlf /dev/null
#    sort wordlist | sed "s/'em/\\\'em/" > ${DIR}wordlist
#
#    rm -f $DIR.WAV
#    rm -f monophones
#    rm -f wordlist
#done

## Create pronunciation dictionary for TRAIN and TEST from TIMITDIC
#(tail -n +15 ${TIMIT}/DOC/TIMITDIC.TXT) | sed 's/[;\.\-]//' | sed '/^$/d' | sed 's/^ //' | sed "s/\///;s/\///" > TIMITDIC.TXT
#sed "s/'em/\\\'em/"  TIMITDIC.TXT | sed "s/~v_past//;s/~v_pres//;s/~adj//;s/~v//;s/~pres//;s/~past//" | sed "s/[1-3]//g" | sort > TIMITdict
#rm TIMITDIC.TXT
#echo "!ENTER	[] sil" >> TIMITdict
#echo "!EXIT	[] sil" >> TIMITdict
#
#cat <<"EOF" > timit.ded
#RS cmu
#EOF
#
#for DIR in TRAIN TEST ; do
#    HDMan -l ${DIR}log -g timit.ded -p ${DIR}monophones -w ${DIR}wordlist -T 1 ${DIR}dict TIMITdict
#    echo "!ENTER	[] sil" >> ${DIR}dict
#    echo "!EXIT	[] sil" >> ${DIR}dict
#    echo "!ENTER" >> ${DIR}wordlist
#    echo "!EXIT" >> ${DIR}wordlist
#done


##TODO: remove stressmarks from timit tic

## generate a template for a prototype model
#cat <<"EOF" > sim.pcf
#<BEGINproto_config_file>
#<COMMENT>
#   This PCF produces a single mixture, single stream prototype system
#<BEGINsys_setup>
#hsKind: P
#covKind: D
#nStates: 3
#nStreams: 1
#sWidths: 39
#mixes: 1
#parmKind: MFCC_E_D_A_Z
#vecSize: 39
#outDir: .
#hmmList: protolist
#<ENDsys_setup>
#<ENDproto_config_file>
#EOF
#
## generate a prototype model
#echo proto > protolist
#echo N | $SAMPLES/HTKDemo/MakeProtoHMMSet sim.pcf

## Flat start the prototype model
#HCompV  -T 1 -m -S TRAIN.SCP -f 0.01 -M . -o flat proto

nmix=1
NEWDIR=HMM/mono-nmix${nmix}-npass0

## concatenate prototype models to build a flat-start definition file
#mkdir -p $NEWDIR
#sed '1,3!d' flat > $NEWDIR/MMF
#cat vFloors >> $NEWDIR/MMF
#for i in `cat TRAINmonophones` ; do
#  sed -e "1,3d" -e "s/flat/$i/" flat >> $NEWDIR/MMF
#done

## Build phone network
#HLEd -S TRAIN.TXT -i TRAINTxt.mlf monotimit.led
#HLStats -T 1 -b TRAINbigfn -o -I TRAINTxt.mlf TRAINmonophones
## Build word network
#HLStats -T 1 -b TRAINwordfn -o -I TRAINWord.mlf TRAINwordlist  #TODO: build proper language model
#HBuild -T 1 -n TRAINwordfn TRAINwordlist TRAINwordnetwork
#cat TRAINwordlist TESTwordlist | sort -u  > TIMITwordlist
#HBuild -T 1 TRAINwordlist TRAINwordloop
#HBuild -T 1 TIMITwordlist TIMITwordloop


## HVITE needs to be told to perform cross word context expansion
#cat <<"EOF" > hvite.config
#FORCECXTEXP = TRUE
#ALLOWXWRDEXP = TRUE
#EOF

OPT=" -T 1 -m 0 -t 250 150 1000 -S TRAIN.SCP"

#echo Start training monophones at: `date`
#
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
#      HERest ${OPT} -I TRAINMono.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} TRAINmonophones > ${NEWDIR}/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=${NEWDIR}
#    NEWDIR=HMM/mono-nmix${nmix}-npass0
#    mkdir -p ${NEWDIR}
#    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed TRAINmonophones
#    npass=1
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/mono-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -I TRAINMono.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} TRAINmonophones > ${NEWDIR}/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#done
#
#echo Completed monophone training at: `date`


# test models

## filter the main test set to get the core test set
#FILTER='^TEST/DR./[mf](DAB0|WBT0|ELC0|TAS1|WEW0|PAS0|JMP0|LNT0|PKT0|LLL0|TLS0|JLM0|BPM0|KLT0|NLP0|CMJ0|JDH0|MGD0|GRT0|NJM0|DHC0|JLN0|PAM0|MLD0)/s[ix]'
#egrep -i ${FILTER} TEST.SCP > coreTEST.SCP
#egrep -i ${FILTER} TEST.PHN > coreTEST.PHN
#egrep -i ${FILTER} TEST.WRD > coreTEST.WRD
#HLEd -S coreTEST.PHN -i coreTESTMono.mlf monotimit.led
#HLEd -S coreTEST.WRD -i coreTESTWord.mlf /dev/null

#echo Testing monophone models at: `date`
#
#for nmix in 1 2 8 16 20 ; do
#    DIR=HMM/mono-nmix${nmix}-npass4
#    HVite -t 100 100 4000 -T 1 -H ${DIR}/MMF -S ${TESTSET}.SCP -i ${DIR}/wloop_recout.mlf -w TRAINwordloop -p 0.0 -s 5.0 TRAINdict TRAINmonophones
#    HResults -T 1 -I ${TESTSET}Word.mlf TRAINmonophones ${DIR}/wloop_recout.mlf
#done

## generate the list of seen triphones and trainTri.mlf
#echo "TC" > mktri.led
#HLEd -n TRAINTriphones -l '*' -i TRAINTri.mlf mktri.led TRAINMono.mlf
#
## and generate all possible triphones models
#perl -e '
#while($phone = <>) {
#  chomp $phone;
#  push @plist, $phone;
#}
#print "sil\n";
#for($i = 0; $i < scalar(@plist); $i++) {
#  for($j = 0; $j < scalar(@plist); $j++) {
#    if($plist[$j] ne "h#") {
#      for($k = 0; $k < scalar(@plist); $k++) {
#	print "$plist[$i]-$plist[$j]+$plist[$k]\n";
#      }
#    }
#  }
#}' < TRAINmonophones > allTriphones
#
## generate mktri.hed
#${SAMPLES}/HTKTutorial/maketrihed TRAINmonophones TRAINTriphones

##convert the single Gaussian model to triphones
OLDDIR=HMM/mono-nmix1-npass${NPASSPERMIX}
NEWDIR=HMM/tri-nmix1-npass0a
#mkdir -p ${NEWDIR}
#HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} mktri.hed TRAINmonophones

#reestimate all seen triphones independently
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0b
#mkdir -p ${NEWDIR}
#HERest ${OPT} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} -s ${NEWDIR}/stats TRAINTriphones > ${NEWDIR}/LOG

## build the question set for tree based state clustering
#cat <<EOF > tree.hed
#RO 100 HMM/tri-nmix1-npass0b/stats
#TR 0
#
#QS "L_Stop" {b-*, d-*, g-*, p-*, t-*, k-*, dx-*, q-*}
#QS "R_Stop" {*+b, *+d, *+g, *+p, *+t, *+k, *+dx, *+q}
#QS "L_Affricate" {jh-*, ch-*}
#QS "R_Affricate" {*+jh, *+ch}
#QS "L_Fricative" {s-*, sh-*, z-*, zh-*, f-*, th-*, v-*, dh-*}
#QS "R_Fricative" {*+s, *+sh, *+z, *+zh, *+f, *+th, *+v, *+dh}
#QS "L_Nasal" {m-*, n-*, ng-*, em-*, en-*, eng-*, nx-*}
#QS "R_Nasal" {*+m, *+n, *+ng, *+em, *+en, *+eng, *+nx}
#QS "L_SemivowelGlide" {l-*, r-*, w-*, y-*, hh-*, hv-*, el-*}
#QS "R_SemivowelGlide" {*+l, *+r,, *+w, *+y, *+hh, *+hv, *+el}
#QS "L_Vowel" {iy-*, ih-*, eh-*, ey-*, ae-*, aa-*, aw-*, ay-*, ah-*, ao-*, oy-*, ow-*, uh-*, uw-*, ux-*, er-*, ax-*, ix-*, axr-*, axh-*}
#QS "R_Vowel" {*+iy, *+ih, *+eh, *+ey, *+ae, *+aa, *+aw, *+ay, *+ah, *+ao, *+oy, *+ow, *+uh, *+uw, *+ux, *+er, *+ax, *+ix, *+axr, *+axh}
#QS "L_Other" {sil-*}
#QS "R_Other" {*+sil,-*sil}
#
#EOF
#
## and add in the single phone questions and tie the transition matrices
#perl -e '
#while($phone = <>) {
#  chomp $phone;
#  push @plist, $phone;
#}
#
#for($i = 0; $i < scalar(@plist); $i++) {
#  print "QS \"L_$plist[$i]\" {$plist[$i]-*}\n";
#  print "QS \"R_$plist[$i]\" {*+$plist[$i]}\n";
#}
#
#print "\nTR 2\n";
#for($i = 0; $i < scalar(@plist); $i++) {
#  for($j = 2; $j < 5; $j++) {
#    print "TB 350 \"ST_$plist[$i]_s${j}\" {(\"$plist[$i]\", \"*-$plist[$i]+*\", \"$plist[$i]+*\", \"*-$plist[$i]\").state[$j]}\n";
#  }
#}
#
#print "\nTR 1\n";
#print "AU \"allTriphones\"\n";
#print "CO \"tiedlist\"\n";
#print "ST \"trees\"\n";
#' < TRAINmonophones >> tree.hed

# now perform topdown tree based clustering
OLDDIR=${NEWDIR}
NEWDIR=HMM/tri-nmix1-npass0c
#mkdir -p ${NEWDIR}
#HHEd -B -H ${OLDDIR}/MMF -M ${NEWDIR} tree.hed TRAINTriphones

## reestimate and mix up the state clustered triphones
#nmix=1
#while [ $nmix -le $NMIXTRI ] ; do
#
#  ## NB the inner loop of both cases is duplicated - change both!
#  if [ $nmix -eq 1 ] ; then
#    npass=1;
#    while [ $npass -le $NPASSPERMIX ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/tri-nmix$nmix-npass$npass
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist > $NEWDIR/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=${NEWDIR}
#    NEWDIR=HMM/tri-nmix$nmix-npass0
#    mkdir -p $NEWDIR
#    HHEd -H ${OLDDIR}/MMF -M ${NEWDIR} tmp.hed tiedlist
#    npass=1
#    while [ ${npass} -le ${NPASSPERMIX} ] ; do
#      OLDDIR=${NEWDIR}
#      NEWDIR=HMM/tri-nmix${nmix}-npass${npass}
#      mkdir -p ${NEWDIR}
#      HERest ${OPT} -I TRAINTri.mlf -H ${OLDDIR}/MMF -M ${NEWDIR} tiedlist > ${NEWDIR}/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#done

## Expand dict to triphones
#cat << EOF > tritimit.ded
#TC
#EOF
#
#HDMan -g tritimit.ded -l tridict.log TIMIT3dict TIMITdict
#echo "!ENTER	[] sil" >> TIMIT3dict
#echo "!EXIT	[] sil" >> TIMIT3dict
#
#
echo Testing triphone models at: `date`

for nmix in 1 2 4 8 10 12 14 16 18 20 ; do
    DIR=HMM/tri-nmix${nmix}-npass4
    HVite -t 100 100 4000 -T 1 -C hvite.config -H ${DIR}/MMF -S ${TESTSET}.SCP -i ${DIR}/wloop_recout.mlf -w TIMITwordloop -p 0.0 -s 5.0 TIMITdict tiedlist
done


#for nmix in 1 2 8 16 20 ; do
#    DIR=HMM/tri-nmix${nmix}-npass4
#    HResults -T 1 -I ${TESTSET}Word.mlf TRAINmonophones ${DIR}/wloop_recout.mlf
#done

exit 0
