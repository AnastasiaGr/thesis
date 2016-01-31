Workflow

-- Legacy code was run initially to create .....

-- Generated prompts file for train and test files
    python generate_prompts.py HTKTrain/TXT train_prompts.txt
    python generate_prompts.py HTKTest/TXT test_prompts.txt

    -- From train_prompts.txt: Deleted everywhere the two dasces, and replaced 'em with em.
    -- From test_prompts.txt: Deleted everywhere the two dasces

-- Generated word list from prompts
    python generate_wlist.py train_prompts.txt train_wlist.txt
    python generate_wlist.py test_prompts.txt test_wlist.txt


-- Create a dictionary (train_dict.txt) with all the words and its corresponding phonemes
   that are inside the wlist, and a list with the unique phonemes used (monophones0)

    Usage: HDMan [-Options] new_dict source_dict
    This causes HDMan read in the source dictionary source_dict and generate a new dictionary new_dict.

    HDMan -T 1 -n monophones0 -l logs/dlog.txt -w train_wlist.txt train_dict.txt timit_dict.txt
        -T 1                : turn on basic progress outputs
        -l logs/dlog.txt    : output log of operation
        -w [wordlist]       : Load the word list stored in file [wordlist].Only pronunciations for the words
                              in this list will be extracted from the source dictionaries
        -n [monophone]      : Output a list of all distinct phones encountered to file [monophone]
        Used script file timit_dict.txt.ded:
            AS sp           : add an sp phoneme to the end of each word
            RS cmu          : removes stress marks
            LP              : lowercase the phonemes
            LW              : lowercase the words

    -- Added extra phoneme "sil" to monophones0 and word "SILENCE sil" to train_dict.txt

-- Create the word level transcriptions of prompts (train_words.mlf)

    Usage: perl prompts2mlf mlf_output prompts_input
    perl prompts2mlf train_words.mlf train_prompts.txt

-- Create the phoneme level transcriptions of prompts (train_phones0.mlf)
    WITHOUT SP BETWEEN WORDS

    Usage: HLEd [-Options] edCmdFile labFiles
    This causes HLEd to be applied to each labFile in turn using the edit commands listed in edCmdFile. The labFiles
    may be master label files.

    HLEd -l '*' -d train_dict.txt -i  train_phones0.mlf mkphones0.led train_words.mlf
        -l '*'               : a label file named xxx to be prefixed by the pattern "*/xxx" in the output MLF file.
        -d [trained_dict]    : read a dictionary,use this for expanding labels when the EX command is used
        -i [phones0.mlf]     : output an mlf with the phone transitions
        Used script mkphones0.led (as edCmdFile):
             EX              : replaces each word in train_words.mlf by the corresponding pronunciation in the train_dict.txt
             IS sil sil      : add a 'sil' at the start and at the end of every phrase
             DE sp           : delete 'sp'


-- Create the phoneme level transcriptions of prompts (train_phones1.mlf)
    WITH SP BETWEEN WORDS

    HLEd -l '*' -d train_dict.txt -i  train_phones1.mlf mkphones1.led train_words.mlf

        Used script mkphones1.led (as edCmdFile):
             EX              : replaces each word in train_words.mlf by the corresponding pronunciation in the train_dict.txt
             IS sil sil      : add a 'sil' at the start and at the end of every phrase


-- Create the MFCC parameters

    Usage: HCopy -C config src.wav tgt.mfc
    OR   : HCopy -C config -S script
    By specifying an appropriate configuration file, HCopy is a speech coding tool.
    For example, if the configuration file config is set-up to convert waveform data to MFCC coefficients, it
    would parameterise the file waveform file src.wav, and store the result in tgt.mfc.

    HCopy -T 1 -C config_hcopy -S train_wav_mfc.scp
        -C [config]           :specify a configuration file name
        -S [script]           :specify a script file: a list of all source and target files

-- Create the HMM/hmm0
    -- Create the hmm0/proto (like the Speecho/proto but with the global means and variances(same 39 values at each state))
       and the hmm0/vFloors(sets a threshold in variances)
        Usage: HCompV [Options] [hmm] trainFiles ..

        HCompV -A -D -T 1 -C config_hcompv -f 0.01 -m -S train_mfc.scp -M HMM/hmm0 proto
            -A      : current command line arguments to be printed
            -D      : display configuration settings
            -T 1    : report basic progress
            -C [f]  : specify a configuration file
            -m      : update the means (except the variances)
            -f 0.01 : Create variance floor macros with values equal to 0.01 times the global variance
            -S      : specify a script file name (a list of train files)
            -M hmm0 : store output HMM macro model files in the directory hmm0

    -- Create hmm0/macros, hmm0/hmmdefs(one hmm for every phoneme)
        python generate_hmm0.py monophones_train_nosp.txt

-- Create the HMM/hmm1 (re-estimating the parameters)
        Usage: HERest [options] hmmList trainFile
        This causes the set of HMMs given in hmmList to be loaded. The given list of training files is then used to
        perform one re-estimation cycle. The list of training files can also be stored in a script file.

HERest -A -D -T 1 -C config_hrest -I train_phones0.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm0/macros -H HMM/hmm0/hmmdefs -M HMM/hmm1 monophones_train_nosp.txt
        -t          : Set the pruning threshold [start, step, max]
        -H mmf      : Load HMM macro model file mmf
        -I mlf      : This loads the master label file mlf
        -S script   : A list with all the training files
        -M hmm1     : store output HMM macro model files in the directory hmm1

-- Create the HMM/hmm2 (re-estimating the parameters)

HERest -A -D -T 1 -C config_hrest -I train_phones0.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm1/macros -H HMM/hmm1/hmmdefs -M HMM/hmm2 monophones_train_nosp.txt

-- Create the HMM/hmm3 (re-estimating the parameters)

HERest -A -D -T 1 -C config_hrest -I train_phones0.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm2/macros -H HMM/hmm2/hmmdefs -M HMM/hmm3 monophones_train_nosp.txt

-- Create the HMM/hmm4 (adding the 'sp' 3-state model)

Add to the /HMM/hmm3/hmmdefs the 'sp' phoneme, which has 3 states :

    copy and paste the “sil” model and rename the new one “sp”
    remove state 2 and 4 from new “sp” model (i.e. keep 'centre state' of old “sil” model in new “sp” model)
    change <NUMSTATES> to 3
    change <STATE> to 2
    change <TRANSP> to 3
    change matrix in <TRANSP> to 3 by 3 array
    change numbers in matrix as follows:

 0.0 1.0 0.0
 0.0 0.9 0.1
 0.0 0.0 0.0


-- Create HMM/hmm5 (Adding the 'silst' state)
the emmiting state of 'sp' becomes tieded to the centre state of the 'sil' and  a new state called  'silst'is created,
which is shared by the phonemes 'sp'[2] and 'sil'[3].

    Usage: HHEd [options] edCmdFile hmmList
 where edCmdFile is a text file containing a sequence of edit commands and hmmList defines the set of HMMs to be edited

    HHEd -A -D -T 1 -H HMM/hmm4/macros -H HMM/hmm4/hmmdefs -M HMM/hmm5 sil.hed monophones0

    Used: sil.hed
        AT 2 4 0.2 {sil.transP}
        AT 4 2 0.2 {sil.transP}
        AT 1 3 0.3 {sp.transP}
        TI silst {sil.state[3],sp.state[2]}

-- Create the HMM/hmm6 (reestimating the parameters with 'sp', 'sil' and 'silst')

HERest -C config_hrest  -I train_phones1.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm5/macros -H  HMM/hmm5/hmmdefs -M HMM/hmm6 monophones0
#13 warnings
-- Create the HMM/hmm7 (reestimating the parameters)

HERest -C config_hrest  -I train_phones1.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm6/macros -H  HMM/hmm6/hmmdefs -M HMM/hmm7 monophones0
#13 warnings

-- Create a new phone level transcription file (aligned mlf) based on viterbi aligning

    Usage: HVite [options] dictFile hmmList testFiles

HVite -A -D -T 1 -l '*' -o SWT -b SILENCE -C config_hrest -H HMM/hmm7/macros -H HMM/hmm7/hmmdefs -i aligned.mlf -m -t 250.0 150.0 1000.0 -y lab -a -I train_words.mlf -S train_mfc.scp train_dict.txt monophones0> logs/HVite_log

       -l '*': Setting the option -l '*' will cause a label file named xxx to be prefixed by the pattern "*/xxx" in the output MLF file.
       -o SWT: Choose how the output labels should be formatted
                S: remove scores from output label. By default scores will be set to the total likelihood of the segment
                T: Do not include times in output label files
                W Do not include words in output label files when performing state or model alignment
       -b s  : Use s as the sentence boundary during alignment
       -H mmf: Load HMM macro model file mmf
       -i s  : Output transcriptions to MLF s
       -m    : During recognition keep track of model boundaries
       -t f [i l] : If the alignment fails at the initial pruning threshold f, then the threshold will by increased by i
                    and the alignment will be retried. This procedure is repeated until the alignment succeeds
                    or the threshold limit l is reached
       -y lab : This sets the extension for output label files to lab
       -a     : Perform alignment. HVite will load a label file and create an alignment network for each test file
       -I mlf : This loads the master label file mlf
       -S script: A list with all the training files
       -i     : Output transcriptions to MLF
       HVite_log

# 17 tokens not survived

s0063, s0113, s0149, 0172, s0671, s0722, s0842, s1059, s1164, s1239, s1244, s1331, s1755, s1793, s1809, s1831

        -- !!! REMOVED the 17 examples from the train_mfc.scp

-- Create HMM/hmm8 (reestimating the parameters)

HERest -C config_hrest -I aligned.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm7/macros -H HMM/hmm7/hmmdefs -M HMM/hmm8 monophones0

-- Create HMM/hmm9 (reestimating the parameters)

HERest -C config_hrest -I aligned.mlf -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm8/macros -H HMM/hmm8/hmmdefs -M HMM/hmm9 monophones0

-- Create the triphone level transcription (triphones.mlf) and a list of all the triphones (triphones.txt)

        HLEd -n triphones.txt -l '*' -i triphones.mlf mktri.led aligned.mlf

        Used: mktri.led
                WB sp  : defines the sp as word boundary
                WB sil : defines the sil as word boundary
                TC     : make the transcriptions with triphones

-- Create mktri.hed (commands to tie the transitions matrices of the same phones)
        e.g. TI T_ax {(*-ax+*,ax+*,*-ax).transP}

       perl maketrihed monophones0 triphones.txt

-- Create HMM/hmm10

    HHEd -H HMM/hmm9/macros -H HMM/hmm9/hmmdefs -M HMM/hmm10 mktri.hed monophones0

--  Create HMM/hmm11

     HERest -C config_hrest -I triphones.mlf -t 250.0 150.0 1000.0 -s HMM/hmm11/stats -S train_mfc.scp -H HMM/hmm10/macros -H HMM/hmm10/hmmdefs -M HMM/hmm11 triphones.txt

        !!! ~200  WARNINGS like: WARNING [-2331]  UpdateModels: el-ax+z[5255] copied: only 1 egs
           (see HMM/hmm11/stats)

-- Create HMM/hmm12

      HERest -C config_hrest -I triphones.mlf -t 250.0 150.0 1000.0 -s HMM/hmm12/stats -S train_mfc.scp -H HMM/hmm11/macros -H HMM/hmm11/hmmdefs -M HMM/hmm12 triphones.txt

        !!! Same Warnings (see HMM/hmm12/stats)

-- Create a list with all the triphones (fulllist) and a dictionary with all the words and their
   triphone transitions (dict-tri)

      Usage: HDMan [-Options] new_dict source_dict
      This causes HDMan read in the source dictionary source_dict and generate a new dictionary new_dict.

      HDMan -b sp -n fulllist -g triphone.ded -l logs/trilog.txt dict-tri timit_dict.txt


      -b sp                 : Define sp to be a word boundary symbol.
      -n [fullist]          : Output a list of all distinct phones encountered to file [fulllist]
      -g f                  : File f holds the global edit script
      -l logs/trilog.txt    : output log of operation
            Used triphone.ded as global edit script:
                TC          : make the transitions with triphones
            The script timit_dict.txt.ded automatically used:
                AS sp
                RS cmu
                MP sil sil sp
                LP
                LW

-- Update the list of all the triphones (fulllist)

    python update_fulllist.py fulllist triphones.txt


-- Create tree.hed (at this step it has only the TBs)

    perl mkclscript.prl TB 350 monophones_train_nosp.txt >> tree.hed

-- Update tree.hed

    python update_tree_hed.py tree.hed quest.hed

-- Create HMM/hmm13, tiedlist and trees

    HHEd -H HMM/hmm12/macros -H HMM/hmm12/hmmdefs -M HMM/hmm13 tree.hed  triphones.txt>HMM/hmm13log.txt
        Log file: HMM/hmm13log.txt

-- Create HMM/hmm14 (reestimating the parameters)

    HERest -C config_hrest -I triphones.mlf -s HMM/hmm14/stats -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm13/macros -H HMM/hmm13/hmmdefs -M HMM/hmm14 tiedlist

    !!! A lot of WARNINGS like: WARNING [-2331]  UpdateModels: ae-r+ae[255] copied: only 0 egs

-- Create HMM/hmm15 (reestimating the parameters)

    HERest -C config_hrest -I triphones.mlf -s HMM/hmm15/stats -t 250.0 150.0 1000.0 -S train_mfc.scp -H HMM/hmm14/macros -H HMM/hmm14/hmmdefs -M HMM/hmm15 tiedlist

    !!! Same warnings

#################################### EVALUATION ########################################


-- Create the word level transcriptions of test_prompts.txt (test_words.mlf)

    HLEd -l '*' -i mlf1_test1.mlf -G TIMIT Timito/words.led Speecho/HTKTest/WRD/*
    or
    perl prompts2mlf test_words.mlf test_prompts.txt

-- Create the mfcc parameters

     HCopy -T 1 -C config_test -S test_wav_mfc.scp

-- Create wordloop (a network in which each word has equal probability)

    HBuild timit_wlist.txt wordloop

-- Create recout.mlf (the word transcription file of test_prompts outputed by the hmm)

    HVite -H HMM/hmm15/macros -H HMM/hmm15/hmmdefs -S test_mfc.scp -l '*' -i recout.mlf -w wordloop -p 0.0 -s 5.0 timit_dict.txt tiedlist

-- See the results
HResults -I test_words.mlf tiedlist recout.mlf













