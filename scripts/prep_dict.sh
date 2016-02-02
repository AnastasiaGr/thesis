#!/usr/bin/env bash

# This script prepares the pronunciation dictionary by merging TIMITDIC.TXT and cmu.txt
# TIMITDIC.TXT is in the default path inside TIMIT directory (TIMIT/TIMIT/DOC)
# cmu.txt is put in the same location for simplicity
# it was downloaded from http://www.speech.cs.cmu.edu/cgi-bin/cmudict, version 0.7b
# and subsequently renamed to cmu.txt
#
# NOTE: Had to fix a line in cmu.txt with unrecognizable characters!
#
# Copyright 2016 by Anastasia Grigoropoulou

PROJECT=$HOME/Desktop/thesis/
CONFIG=${PROJECT}/configs/
SCRIPT=${PROJECT}/scripts/
DICT=${PROJECT}/dicts/
TIMITDOC=${PROJECT}/TIMIT/TIMIT/DOC/

# Firstly, prepare TIMITDIC.TXT and cmu.txt in correct format for HTK

(tail -n +15 ${TIMITDOC}/TIMITDIC.TXT) | sed 's/[;\.\-]//' | sed '/^$/d' | sed 's/^ //' | sed "s/\///;s/\///" > TIMITDIC.TXT
sed "s/'em/\\\'em/"  TIMITDIC.TXT | sed "s/~v_past//;s/~v_pres//;s/~adj//;s/~v//;s/~pres//;s/~past//" | sed "s/[1-3]//g" | sort > timit_dict
rm -f TIMITDIC.TXT

(tail -n +137 ${TIMITDOC}/cmu.txt) | sed '/^[{}]/ d' | sed '/_/ d' | sed 's/\([0-9]\)//' | sed 's/[()0-9.]//g' > cmu_dict
rm -f cmu.txt

# Then create concatenated dictionary
cat cmu_dict timit_dict > dict_temp
tr '[:upper:]' '[:lower:]' < dict_temp | sort -u > ${DICT}/cmu_timit_dict
rm -f dict_temp cmu_dict timit_dict