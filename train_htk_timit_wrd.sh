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

exec >& $0.log

echo "Started Preparing at `date`"


# TODO: Write TIMIT config

# TODO: Get files from TIMIT including WRD ones and make scripts to address them. For wavs, use HCopy to get MFCC

# TODO: Create list of monophones, wordlist, and build or get from TIMITDICT the word dictionary





exit 0
