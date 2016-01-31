#!/usr/bin/env bash

echo "Starting data preparation..."
rm -f wordlist
rm -f monophones
rm -f wordlist1
rm -f monophones1
rm -f phones.mlf
rm -f words.mlf


echo "Workflow 1: WRD -> words.mlf -> wordlist"
HLEd -n wordlist_us -l '*' -i words.mlf -G TIMIT words.led HTKTrain/WRD/*
sort wordlist_us > wordlist
rm wordlist_us

echo "Workflow 2: PHN -> phones.mlf -> monophones"
HLEd -n monophones_us -l '*' -i phones.mlf -G TIMIT phones.led HTKTrain/PHN/*
sort monophones_us > monophones
rm monophones_us


echo "Workflow 3: TIMITDIC.TXT + train_prompts.txt -> train_dict.txt + monophones1 +  wordlist1"
python generate_wlist.py train_prompts.txt wordlist1_us
sort wordlist1_us > wordlist1
rm wordlist1_us
rm -f timit_dict.txt
python transform_dict.py
HDMan -n monophones1_us -l log -w wordlist1 train_dict.txt timit_dict.txt
sort monophones1_us > monophones1
rm monophones1_us

echo "Total number of words:"
wc -l wordlist
wc -l wordlist1

echo "Total number of phonemes:"
wc -l monophones
wc -l monophones1

if cmp --silent monophones monophones1; then
   echo "No discrepancy in monophones... deleting monophones1"
fi

cmp --silent wordlist wordlist1 || echo "WORDS ARE DIFFERENT"

rm -f phones1.mlf
HLEd -l '*' -d train_dict.txt -i  phones1.mlf mkphones1.led words.mlf
