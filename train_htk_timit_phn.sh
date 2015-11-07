#!/usr/bin/env bash -ex

echo "Continuus speech recognition system trained using HTK on TIMIT corpus"
echo "Anastasia Grigoropoulou - 2015"
echo "based on HTK Tutorial v3.4.1 and work from (C) Cantab Research"

# Setting up the paths
TIMIT=$HOME/Desktop/thesis/TIMIT/TIMIT/
SAMPLES=$HOME/Desktop/thesis/HTK_Samples/
WORK_DIR=HTK_TIMIT_PHN`echo $* | tr -d ' '`

NMIXMONO=20              # number of Gaussians per state in monophones
NMIXTRI=20               # number of Gaussians per state in triphones
MINTESTMONO=1            # test the monophones after this number of Gaussians
MINTESTTRI=1             # test the triophones after this number of Gaussians
NPASSPERMIX=4            # number of fwd/bwd passes per mixture increase
TESTSET=coreTest         # set to "test" for full test set or "coreTest"
KFLMAP=false             # set to true to addionally output KFL mapped scores

exec >& logs/$0.log

echo "Started Preparing at `date`"
cd $WORK_DIR

# write the timit config used if using HTK MFCC
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


## read the TIMIT disk and encode into acoustic features
#for DIR in train test ; do
#    # create a mirror of the TIMIT directory structure
#    (cd ${TIMIT} ; find ${DIR} -type d) | xargs mkdir -p
#
#    # generate lists of files
#    (cd $TIMIT ; find ${DIR} -type f -name S[IX]\*WAV) | sort > ${DIR}.WAV
#    sed "s/WAV$/PHN/" $DIR.WAV > $DIR.PHN
#    sed "s/WAV$/MFC/" $DIR.WAV > $DIR.SCP
#    sed "s/WAV$/TXT/" $DIR.WAV > $DIR.TXT
#
#    # generate the acoutic feature vectors
#    paste $DIR.WAV $DIR.SCP | sed "s:^:$TIMIT/:" > $DIR.convert
#    HCopy -C config -S $DIR.convert
#    rm -f $DIR.convert
#
#
#    # ax-h conflicts with HTK's triphone naming convention, so change it
#    # also generate .txt files suitable for use in language modelling
#    sed "s/.WAV$//" $DIR.WAV | while read base ; do
#    sed 's/ ax-h$/ axh/' < $TIMIT/$base.PHN > $base.PHN
#    egrep -v 'h#$' $base.PHN > $base.TXT
#    done
#
#    # create MLF
#    HLEd -S $DIR.PHN -i ${DIR}Mono.mlf /dev/null
#
#    rm -f $DIR.WAV
#done

## filter the main test set to get the core test set
#FILTER='^test/dr./[mf](DAB0|WBT0|ELC0|TAS1|WEW0|PAS0|JMP0|LNT0|PKT0|LLL0|TLS0|JLM0|BPM0|KLT0|NLP0|CMJ0|JDH0|MGD0|GRT0|NJM0|DHC0|JLN0|PAM0|MLD0)/s[ix]'
#egrep -i $FILTER test.SCP > coreTest.SCP
#egrep -i $FILTER test.PHN > coreTest.PHN
#HLEd -S coreTest.PHN -i coreTestMono.mlf /dev/null

## create list of monophones
#find train -name \*PHN | xargs cat | awk '{print $3}' | sort -u > monophones

## and derive the dictionary and the modified monophone list from the monophones
#egrep -v h# monophones > monophones-h#   #-v inverts the matching to select lines that don't match
#paste monophones-h# monophones-h# > dict
#echo "!ENTER	[] h#" >> dict
#echo "!EXIT	[] h#" >> dict
#echo '!ENTER' >> monophones-h#
#echo '!EXIT' >> monophones-h#

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

## generate a prototype model
#echo proto > protolist
#echo N | $SAMPLES/HTKDemo/MakeProtoHMMSet sim.pcf

#HCompV $CONFIG -T 1 -m -S train.scp -f 0.01 -M . -o new proto

KFLCFG='-e n en -e aa ao -e ah ax-h -e ah ax -e ih ix -e l el -e sh zh -e uw ux -e er axr -e m em -e n nx -e ng eng -e hh hv -e pau pcl -e pau tcl -e pau kcl -e pau q -e pau bcl -e pau dcl -e pau gcl -e pau epi -e pau h#'

nmix=1
NEWDIR=mono-nmix$nmix-npass0

## concatenate prototype models to build a flat-start model
#mkdir -p $NEWDIR
#sed '1,3!d' new > $NEWDIR/MMF
#cat vFloors >> $NEWDIR/MMF
#for i in `cat monophones` ; do
#  sed -e "1,3d" -e "s/new/$i/" new >> $NEWDIR/MMF
#done

#HLEd -S train.TXT -i trainTxt.mlf /dev/null
#HLStats -T 1 -b bigfn -o -I trainTxt.mlf -S train.TXT monophones-h#
#HBuild -T 1 -n bigfn monophones-h# outLatFile
#
## HVITE needs to be told to perform cross word context expansion
#cat <<"EOF" > hvite.config
#FORCECXTEXP = TRUE
#ALLOWXWRDEXP = TRUE
#EOF

OPT="$CONFIG -T 1 -m 0 -t 250 150 1000 -S train.SCP"

#echo Start training monophones at: `date`
#
#
#while [ $nmix -le $NMIXMONO ] ; do
#
#  ## NB the inner loop of both cases is duplicated - change both!
#  if [ $nmix -eq 1 ] ; then
#    npass=1;
#    while [ $npass -le $NPASSPERMIX ] ; do
#      OLDDIR=$NEWDIR
#      NEWDIR=mono-nmix$nmix-npass$npass
#      mkdir -p $NEWDIR
#      HERest $OPT -I trainMono.mlf -H $OLDDIR/MMF -M $NEWDIR monophones > $NEWDIR/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=$NEWDIR
#    NEWDIR=mono-nmix$nmix-npass0
#    mkdir -p $NEWDIR
#    HHEd -H $OLDDIR/MMF -M $NEWDIR tmp.hed monophones
#    npass=1
#    while [ $npass -le $NPASSPERMIX ] ; do
#      OLDDIR=$NEWDIR
#      NEWDIR=mono-nmix$nmix-npass$npass
#      mkdir -p $NEWDIR
#      HERest $OPT -I trainMono.mlf -H $OLDDIR/MMF -M $NEWDIR monophones > $NEWDIR/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#  # test models
#  if [ $nmix -ge $MINTESTMONO ] ; then
#    HVite $CONFIG -t 100 100 4000 -T 1 -H $NEWDIR/MMF -S $TESTSET.SCP -i $NEWDIR/recout.mlf -w outLatFile -p 0.0 -s 5.0 dict monophones
#    HResults -T 1 -e '???' h# -I ${TESTSET}Mono.mlf monophones $NEWDIR/recout.mlf
#    if $KFLMAP ; then
#      HResults -T 1 -e '???' h# $KFLCFG -I ${TESTSET}Mono.mlf monophones $NEWDIR/recout.mlf
#    fi
#  fi
#
#done
#
#echo Completed monophone training at: `date`

## generate the list of seen triphones and trainTri.mlf
#echo "TC" > mktri.led
#HLEd -n trainTriphones -l '*' -i trainTri.mlf mktri.led trainMono.mlf

## and generate all possible triphones models
#perl -e '
#while($phone = <>) {
#  chomp $phone;
#  push @plist, $phone;
#}
#
#print "h#\n";
#for($i = 0; $i < scalar(@plist); $i++) {
#  for($j = 0; $j < scalar(@plist); $j++) {
#    if($plist[$j] ne "h#") {
#      for($k = 0; $k < scalar(@plist); $k++) {
#	print "$plist[$i]-$plist[$j]+$plist[$k]\n";
#      }
#    }
#  }
#}' < monophones > allTriphones

## generate mktri.hed
#$SAMPLES/HTKTutorial/maketrihed monophones trainTriphones

##convert the single Gaussian model to triphones
OLDDIR=mono-nmix1-npass$NPASSPERMIX
NEWDIR=tri-nmix1-npass0a
#mkdir -p $NEWDIR
#HHEd -H $OLDDIR/MMF -M $NEWDIR mktri.hed monophones

##reestimate all seen triphones independently
OLDDIR=$NEWDIR
NEWDIR=tri-nmix1-npass0b
#mkdir -p $NEWDIR
#HERest $OPT -I trainTri.mlf -H $OLDDIR/MMF -M $NEWDIR -s $NEWDIR/stats trainTriphones > $NEWDIR/LOG

## build the question set for tree based state clustering
#cat <<EOF > tree.hed
#RO 100 tri-nmix1-npass0b/stats
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
#QS "L_Other" {pau-*, epi-*, h#-*}
#QS "R_Other" {*+pau, *+epi, -*h#}
#
#EOF

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
#' < monophones >> tree.hed

## now perform topdown tree based clustering
OLDDIR=$NEWDIR
NEWDIR=tri-nmix1-npass0c
#mkdir -p $NEWDIR
#HHEd -B -H $OLDDIR/MMF -M $NEWDIR tree.hed trainTriphones

## reestimate and mix up the state clustered triphones
#nmix=1
#while [ $nmix -le $NMIXTRI ] ; do
#
#  ## NB the inner loop of both cases is duplicated - change both!
#  if [ $nmix -eq 1 ] ; then
#    npass=1;
#    while [ $npass -le $NPASSPERMIX ] ; do
#      OLDDIR=$NEWDIR
#      NEWDIR=tri-nmix$nmix-npass$npass
#      mkdir -p $NEWDIR
#      HERest $OPT -I trainTri.mlf -H $OLDDIR/MMF -M $NEWDIR tiedlist > $NEWDIR/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU 2 {*.state[2-4].mix}' > tmp.hed
#    nmix=2
#  else
#    OLDDIR=$NEWDIR
#    NEWDIR=tri-nmix$nmix-npass0
#    mkdir -p $NEWDIR
#    HHEd -H $OLDDIR/MMF -M $NEWDIR tmp.hed tiedlist
#    npass=1
#    while [ $npass -le $NPASSPERMIX ] ; do
#      OLDDIR=$NEWDIR
#      NEWDIR=tri-nmix$nmix-npass$npass
#      mkdir -p $NEWDIR
#      HERest $OPT -I trainTri.mlf -H $OLDDIR/MMF -M $NEWDIR tiedlist > $NEWDIR/LOG
#      npass=$(($npass+1))
#    done
#    echo 'MU +2 {*.state[2-4].mix}' > tmp.hed
#    nmix=$(($nmix+2))
#  fi
#
#  # test models
#  if [ $nmix -ge $MINTESTTRI ] ; then
#    HVite $CONFIG -t 100 100 4000 -T 1 -C hvite.config -H $NEWDIR/MMF -S $TESTSET.SCP -i $NEWDIR/recout.mlf -w outLatFile -p 0.0 -s 5.0 dict tiedlist
#    HResults -T 1 -e '???' h# -I ${TESTSET}Mono.mlf monophones $NEWDIR/recout.mlf
#    if $KFLMAP ; then
#      HResults -T 1 -e '???' h# $KFLCFG -I ${TESTSET}Mono.mlf monophones $NEWDIR/recout.mlf
#    fi
#  fi
#
#done

# and exit
exit 0