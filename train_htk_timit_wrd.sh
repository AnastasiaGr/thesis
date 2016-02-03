#!/usr/bin/env bash

echo "============================================================================"
echo "== Word-level speech recognition system trained using HTK on TIMIT corpus =="
echo "==                    Anastasia Grigoropoulou - 2015                      =="
echo "============================================================================"

# Setting up the path variables
PROJECT=$HOME/Desktop/thesis
CONFIG=${PROJECT}/configs
SCRIPT=${PROJECT}/scripts
DICT=${PROJECT}/dicts
LOG=${PROJECT}/logs
LMODEL=${PROJECT}/models
TIMIT=${PROJECT}/TIMIT/TIMIT             # TIMIT Corpus burnt from CD
SAMPLES=${PROJECT}/HTK_Samples             # HTK Samples folder from http://htk.eng.cam.ac.uk/
WORKDIR=${PROJECT}/HTK_TIMIT_WRD           # Working directory for particular script
if [ ! -d ${WORKDIR} ]; then               # If working directory doesn't exist, create it !
    mkdir -p ${WORKDIR}
fi
HMM=${WORKDIR}/HMM


# Code the audio files to MFCC feature vectors and create MLF files for training
#echo "Generating MFCC feature vectors and creating training and test MLF files ..."
#source ${SCRIPT}/prep_timit.sh

# We need to massage the CMU and TIMIT dictionaries for our use and then merge them
#echo "Preparing the joint TIMIT and cmu dictionary..."
#source ${SCRIPT}/prep_dict.sh

# Initial setup of language model and working dictionary
#echo "Building language models and working dictionary..."
#source ${SCRIPT}/build_lm.sh

# Train up the monophone models using the phonetic transcriptions of TIMIT
#echo "Training monophone models... "
#source ${SCRIPT}/train_mono.sh

# Fix the silence model introducing sp between words and retrain
#echo "Fixing silence model... "
#source ${SCRIPT}/fix_silence.sh

# Create a new MLF that is aligned based on our monophone model
#echo "Aligning transcriptions... "
#source ${SCRIPT}/align_mono.sh

# Create triphones, train triphones, tie the triphones, train tied triphones, then
# mix-up the number of Gaussians per state.
#echo "Training tied triphones models..."
#source ${SCRIPT}/train_tri.sh



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
