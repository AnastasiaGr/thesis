import os
from collections import defaultdict

os.chdir('/Users/thrakar9/Desktop/thesis/')

train_file_list = [open('TRAINFILES').read().split('\n')][0][:-1]
test_file_list = [open('TESTFILES').read().split('\n')][0][:-1]

os.chdir('TIMIT/TIMIT')

for f in train_file_list:
    phn = [x.split(' ') for x in [open(f+'.PHN').read().split('\n')][0][:-1]]
    wrd = [x.split(' ') for x in [open(f+'.WRD').read().split('\n')][0][:-1]]

    lab_dict = defaultdict(list)

    for line in phn:
        lab_dict[int(line[0])].append(line[2])

    for line in wrd:
        lab_dict[int(line[0])].append(line[2])

    times = sorted(lab_dict.keys())
    labels = [lab_dict[x] for x in times]

    for i in xrange(len(times)-1):
        if len(labels[i]) == 2 and len(labels[i+1]) == 1:
            labels[i+1].append(labels[i][1])

    wrd_dict = defaultdict(list)
    for l in labels[1:]:
        wrd_dict[l[1]].append(l[0])

    # remove pauses
    # and add them as separate words

os.chdir('/Users/thrakar9/Desktop/thesis/')