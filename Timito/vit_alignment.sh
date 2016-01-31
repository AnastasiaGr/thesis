#!/usr/bin/env bash

echo : "  --> vit_aligned.mlf"
HVite -A -D -T 1 -l '*' -o SWT -C config_hrest -H HMM/hmm7/macros -H HMM/hmm7/hmmdefs -i vit_aligned.mlf -m -t 250.0 150.0 1000.0 -y lab -a -I words.mlf -S train_mfc.scp train_dict.txt monophones1> logs/HVite_log

echo : "vit_aligned.mlf --> vit_aligned_new.mlf (replaced sil sp -->sil at start and end)"
python vit_aligned_fixed.py vit_aligned.mlf vit_aligned_new.mlf

echo : " Re-estimations "
HERest -A -D -T 1 -C config_hrest -I vit_aligned_new.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -v 0.01 -H HMM/hmm7/hmmdefs -H HMM/hmm7/macros -M HMM/hmm8 monophones1

echo : " Re-estimations"
HERest -A -D -T 1 -C config_hrest -I vit_aligned_new.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -v 0.01 -H HMM/hmm8/hmmdefs -H HMM/hmm8/macros -M HMM/hmm9 monophones1


# Testing
echo : " Create recout1.mlf"
HVite -H HMM/hmm9/macros -H HMM/hmm9/hmmdefs -S test_mfc.scp -l '*' -i recout1.mlf -w wordloop -p 0.0 -s 5.0 timit_dict.txt monophones1


echo: " See the results"
HResults -I mlf1_test monophones recout1.mlf