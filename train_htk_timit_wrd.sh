#!/usr/bin/env bash -ex

echo "Word-level speech recognition system trained using HTK on TIMIT corpus"
echo "Anastasia Grigoropoulou - 2015"

# Setting up the paths
TIMIT=$HOME/Desktop/thesis/TIMIT/TIMIT/
SAMPLES=$HOME/Desktop/thesis/HTK_Samples/
WORK_DIR=HTK_TIMIT_WRD`echo $* | tr -d ' '`
#mkdir -p $WORK_DIR
