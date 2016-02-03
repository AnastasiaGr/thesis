#!/usr/bin/env bash

# This script builds the word list, augmented dictionary and network we need for recognition
# It is using the prompts from TIMIT to generate a language model (bigram).
#
# Copyright 2016 by Anastasia Grigoropoulou

# Firstly create a dictionary with a sp short pause after each word, this is
# so when we do the phone alignment from the word level MLF, we get
# the sp phone in between the words.
PROJECT=$HOME/Desktop/thesis
CONFIG=${PROJECT}/configs
SCRIPT=${PROJECT}/scripts
DICT=${PROJECT}/dicts
LOG=${PROJECT}/logs
LMODEL=${PROJECT}/models
TIMITDOC=${PROJECT}/timit_lm/timit_lm/DOC
WORKDIR=${PROJECT}/HTK_TIMIT_WRD

HDMAn -A -T 1 -g ${CONFIG}/add_sp.ded ${DICT}/cmu_timit_dict_sp ${DICT}/cmu_timit_dict > ${LOG}/log.build_lm

# We need a dictionary that has the word "silence" with the mapping to the sil phone
cat ${DICT}/cmu_timit_dict_sp > dict_temp
echo "silence sil" >> dict_temp
sort dict_temp > ${DICT}/cmu_timit_dict_sp_sil
rm -f dict_temp

#Uncomment to include Include prompts
#rm -f prompts_wlist
#python ${SCRIPT}/generate_wlist.py ${TIMITDOC}/PROMPTS.TXT temp_wlist
#tr '[:upper:]' '[:lower:]' < temp_wlist > temp_wlist2
#sed 's/[.,:;!\"\?]//g' temp_wlist2 | sed '/-/d'| sed '/semicolon/d;/promptstxt/d;/timit_lm/d' |sort -u > prompts_wlist
#rm -f temp_wlist temp_wlist2

echo "A" > prompts_wlist

# Generate wordlist from the ones the HLEd used to create the MLFs
cat ${DICT}/TRAINwordlist ${DICT}/TESTwordlist > mlf_wlist

(cat prompts_wlist mlf_wlist) | sort -u > wordlist_temp
(tr '[:lower:]' '[:upper:]' < wordlist_temp) | sort -u > ${DICT}/wordlist
rm -f prompts_wlist mlf_wlist wordlist_temp


# We need sentence start and end symbols which match the WSJ
# standard language model and produce no output symbols.
rm -f ${DICT}/dict
echo "<s> [] sil" > ${DICT}/dict
echo "</s> [] sil" >> ${DICT}/dict

# Add pronunciations for each word in wordlist from dictionary
HDMAn -A -T 1 -w ${DICT}/wordlist -l log dict_temp ${DICT}/cmu_timit_dict_sp >> ${LOG}/log.build_lm
cat dict_temp >> ${DICT}/dict
rm -f dict_temp log

# Append start/end symbols in wlist
cat ${DICT}/wordlist > wl_temp
echo "<s>" >>  wl_temp
echo "</s>" >> wl_temp
sort -u wl_temp > ${DICT}/wordlist
rm -f wl_temp

# The HTK tools maintain a cumulative word map to which every new word is added and assigned a unique id.
# This means that you can add future $ n$-gram files without having to rebuild existing ones so long as you start
# from the same word map, thus ensuring that each id remains unique. The side effect of this ability is that LGPREP
# always expects to be given a word map, so to prepare the first $ n$-gram file (also referred to elsewhere as a `gram'
# file) you must pass an empty word map file.

LNewMap -A -T 1 -f WFC TIMIT ${LMODEL}/empty.wmap >> ${LOG}/log.build_lm

rm -rf ${LMODEL}/text0
mkdir -p ${LMODEL}/text0
LGPrep -A -T 1 -a 100000 -b 200000 -d ${LMODEL}/text0 -n 4 -s "Timit prompts" ${LMODEL}/empty.wmap ${PROJECT}/HTK_Samples/LMTutorial/train/*.txt >> ${LOG}/log.build_lm

rm -rf ${LMODEL}/text1
mkdir -p ${LMODEL}/text1
LGCopy -T 1 -b 200000 -d ${LMODEL}/text1/ ${LMODEL}/text0/wmap ${LMODEL}/text0/gram.* >> ${LOG}/log.build_lm

rm -rf ${LMODEL}/timit_lm
mkdir -p ${LMODEL}/timit_lm
LSubset -T 1 -a 7000 ${LMODEL}/text0/wmap ${DICT}/wordlist ${LMODEL}/timit_lm/timit.wmap >> ${LOG}/log.build_lm

LFoF -T 1 -n 4 -f 32 ${LMODEL}/timit_lm/timit.wmap ${LMODEL}/timit_lm/timit.fof ${LMODEL}/text1/data.* >> ${LOG}/log.build_lm

LBuild -T 1 -n 1 ${LMODEL}/timit_lm/timit.wmap ${LMODEL}/timit_lm/ug ${LMODEL}/text1/data.* >> ${LOG}/log.build_lm

LBuild  -T 1 -t ${LMODEL}/timit_lm/timit.fof -c 2 1 -n 2 -l ${LMODEL}/timit_lm/ug ${LMODEL}/timit_lm/timit.wmap ${LMODEL}/timit_lm/bg ${LMODEL}/text1/data.* >> ${LOG}/log.build_lm

LBuild -T 1 -c 3 1 -n 3 -l ${LMODEL}/timit_lm/bg ${LMODEL}/timit_lm/timit.wmap ${LMODEL}/timit_lm/tg ${LMODEL}/text1/data.* >> ${LOG}/log.build_lm

LPlex -n 2 -n 3 -t ${LMODEL}/timit_lm/tg ${PROJECT}/HTK_Samples/LMTutorial/test/red-headed_league.txt >> ${LOG}/log.build_lm

LBuild -C ${CONFIG}/config.lbuild -T 1 -t ${LMODEL}/timit_lm/timit.fof -c 2 1 -c 3 1 -x -n 3 ${LMODEL}/timit_lm/timit.wmap ${LMODEL}/timit_lm/tgc ${LMODEL}/text1/data.* >> ${LOG}/log.build_lm

LPlex -c 2 2 -c 3 2 -T 1 -u -n 3 -t ${LMODEL}/timit_lm/tgc ${PROJECT}/HTK_Samples/LMTutorial/test/red-headed_league.txt  >> ${LOG}/log.build_lm

HLMCopy -A -T 1 -f TEXT ${LMODEL}/timit_lm/tgc ${LMODEL}/timit_lm/rtg >> ${LOG}/log.build_lm

sed -i .b "s/'EM/\\\'EM/" ${LMODEL}/timit_lm/ug
rm -f ${LMODEL}/timit_lm/ug.b

HBuild -T 1 -n ${LMODEL}/timit_lm/ug -u '!!UNK' -s '<s>' '</s>' -z ${DICT}/wordlist ${LMODEL}/timit_lm/wdnet_ug >> ${LOG}/log.build_lm

# Building bigram language model with HLStats to compare
rm -rf ${LMODEL}/mlf
mkdir ${LMODEL}/mlf
HLStats -A -T 1 -b ${LMODEL}/mlf/bigfn -o -s '<s>' '</s>' -I ${WORKDIR}/TRAINWord.mlf ${DICT}/wordlist >> ${LOG}/log.build_lm

HBuild -T 1 -n ${LMODEL}/mlf/bigfn -u '!!UNK' -s '<s>' '</s>' -z ${DICT}/wordlist ${LMODEL}/mlf/wdnet_bigram >> ${LOG}/log.build_lm

