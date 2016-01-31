#!/usr/bin/env bash

cat HMM/hmm1/hmmdefs/* > HMM/hmm1/hmmdefs_c

HERest -A -D -T 1 -C config_hrest -I phones.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -v 0.01 -H HMM/hmm1/hmmdefs_c -M HMM/hmm2 monophones

HERest -A -D -T 1 -C config_hrest -I phones.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -v 0.01 -H HMM/hmm2/hmmdefs_c -M HMM/hmm3 monophones

HERest -A -D -T 1 -C config_hrest -I phones.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -v 0.01 -H HMM/hmm3/hmmdefs_c -M HMM/hmm4 monophones

"Testing"
HVite -H HMM/hmm14/macros -H HMM/hmm4/hmmdefs -S test_mfc.scp -l '*' -i recout.mlf -w wordloop -p 0.0 -s 5.0 timit_dict.txt monophones

HResults -I mlf1_test monophones recout.mlf