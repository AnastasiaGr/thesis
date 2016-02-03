#!/usr/bin/env bash

echo "============================================================================"
echo "== Word-level speech recognition system trained using HTK on TIMIT corpus =="
echo "==                    Anastasia Grigoropoulou - 2015                      =="
echo "============================================================================"

# Setting up the path variables
PROJECT=$HOME/Desktop/thesis
SCRIPT=${PROJECT}/scripts
WORKDIR=${PROJECT}/HTK_TIMIT_WRD           # Working directory for particular script
if [ ! -d ${WORKDIR} ]; then               # If working directory doesn't exist, create it !
    mkdir -p ${WORKDIR}
fi

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

# Evaluate the models (takes a long time !)
#echo "Evaluating models..."
#source ${SCRIPT}/eval_mono.sh
#source ${SCRIPT}/eval_tri.sh

exit 0
