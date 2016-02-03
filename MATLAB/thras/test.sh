#!usr/bin/env bash

HVite -A -T 1 -t 250.0 -C configCROSS -H MMF -i $1_recout.mlf -w wdnet_bigram -p -1.0 -s 4.0 dict_train tiedlist $1.MFC
HResults -A -T 1 -t tiedlist $1_recout.mlf > $1_results.txt
