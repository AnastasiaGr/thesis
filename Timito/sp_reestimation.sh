#!/usr/bin/env bash

cat HMM/hmm4/hmmdefs_c HMM/hmm4/hmm_sp > HMM/hmm4/hmmdefs

HHEd -A -D -T 1 -H HMM/hmm4/macros -H HMM/hmm4/hmmdefs -M HMM/hmm5 sil.hed monophones1

HERest -S train_mfc.scp -C config_hrest -I phones1.mlf -t 250.0 150.0 1000.0 -H HMM/hmm5/macros -H HMM/hmm5/hmmdefs -M HMM/hmm6 monophones1

HERest -S train_mfc.scp -C config_hrest -I phones1.mlf -t 250.0 150.0 1000.0 -H HMM/hmm6/macros -H HMM/hmm6/hmmdefs -M HMM/hmm7 monophones1


#HBuild timit_wlist.txt wordloop

#HVite -T 1 -H HMM/hmm7/macros -H HMM/hmm7/hmmdefs -S test_mfc.scp -l '*' -i recout.mlf -w wordloop -p 0.0 -s 5.0 timit_dict.txt monophones1
