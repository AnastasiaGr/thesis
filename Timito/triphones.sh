#!/usr/bin/env bash

echo : " mktri.led, vit_aligned_new.mlf --> triphones.txt , triphones.mlf "
HLEd -n triphones.txt -l '*' -i triphones.mlf mktri.led vit_aligned_new.mlf

echo : "maketrihed --> mktri.hed"
perl maketrihed monophones1 triphones.txt


echo : " create hmm10"
HHEd -H HMM/hmm9/macros -H HMM/hmm9/hmmdefs -M HMM/hmm10 mktri.hed monophones1


echo : "Re-estimations"
HERest -C config_hrest -I triphones.mlf -t 250.0 150.0 1000.0 -s HMM/hmm11/stats -S train_mfc.scp -H HMM/hmm10/macros -H HMM/hmm10/hmmdefs -M HMM/hmm11 triphones.txt

# A LOT OF WARNINGS (~1000)

echo : "Re-estimations"
HERest -C config_hrest -I triphones.mlf -t 250.0 150.0 1000.0 -s HMM/hmm12/stats -S train_mfc.scp -H HMM/hmm11/macros -H HMM/hmm11/hmmdefs -M HMM/hmm12 triphones.txt

# A LOT OF WARNINGS (~1000)

"------------------- Tied State Triphones -----------------------"

echo : "triphone.ded, timit_dict.txt.ded , timit_dict.txt --> fulllist, triphones_dict.txt "
HDMan -b sp -n fulllist -g triphone.ded -l logs/trilog.txt triphones_dict.txt timit_dict.txt

echo : " fulllist, triphones.txt --> update the fulllist"
python update_fulllist.py fulllist triphones.txt

# do i have to remove the sp from monophones1 here?
echo : "mkclscript.prl --> create tree.hed"
perl mkclscript.prl TB 350 monophones1>> tree.hed

echo : " tree.hed, quest.hed --> tree.hed updated "
python update_tree_hed.py tree.hed quest.hed

echo : " triphones.txt, tree.hed, hmm12 --> tiedlist, trees, hmm13"
HHEd -H HMM/hmm12/macros -H HMM/hmm12/hmmdefs -M HMM/hmm13 tree.hed  triphones.txt>HMM/hmm13log.txt

echo : " Re-estimations"
HERest -C config_hrest -I triphones.mlf -s HMM/hmm14/stats -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm13/macros -H HMM/hmm13/hmmdefs -M HMM/hmm14 tiedlist

# 9 WARNINGS
#WARNING [-2331]  UpdateModels: ow[37] copied: only 2 egs
#k-t+l[115] copied: only 0 egs
#g-iy+s[132] copied: only 0 egs
#ae-d+ow[175] copied: only 2 egs
#k-ao+sh[181] copied: only 2 egs
#ih-d+aa[191] copied: only 1 egs
#uw-n+ey[197] copied: only 0 egs
#ih-n+ey[209] copied: only 0 egs
#r-ae+d[225] copied: only 0 egs

echo : " Re-estimations"
HERest -C config_hrest -I triphones.mlf -s HMM/hmm15/stats -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm14/macros -H HMM/hmm14/hmmdefs -M HMM/hmm15 tiedlist

# 9 WARNINGS

" ---------------------- Testing ----------------- "
#fix_triphones_dontexist.py
echo : " recout2.mlf"
#HVite -H HMM/hmm15/macros -H HMM/hmm15/hmmdefs -S test_mfc.scp -l '*' -i recout2.mlf -w wordloop -p 0.0 -s 5.0 timit_dict.txt tiedlist
HVite -H HMM/hmm15/macros -H HMM/hmm15/hmmdefs -S test_mfc.scp -l '*' -i recout2.mlf -w wordloop_changed -p 0.0 -s 5.0 timit_dict_changed.txt tiedlist

HResults -I mlf1_test1.mlf tiedlist recout2.mlf

