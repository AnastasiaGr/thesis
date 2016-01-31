#!/usr/bin/env bash

echo "Workflow 4: train_mfc.scp + config_hinit +proto + phones.mlf --> HMM/hmm0/ [phonemes]"

while read phoneme; do
    echo "Creating HMM for phoneme" $phoneme
    HInit -S train_mfc.scp -C config_hinit -v 0.01 -M HMM/hmm0/hmmdefs -o $phoneme -I phones.mlf -l $phoneme proto
    HRest -S train_mfc.scp -C config_hinit -v 0.01 -M HMM/hmm1/hmmdefs -I phones.mlf HMM/hmm0/hmmdefs/$phoneme
done <monophones




