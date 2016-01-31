import os
import itertools
import sys
"""
author  = Anastasia Grigoropoulou
Generate timit_train_wlist.txt
or: perl prompts2wlist train_prompts.txt timit_train_wlist.txt
"""

home = "/home/anastasia/Desktop/Speecho"


def main():
    if len(sys.argv) < 2:
        print "Usage: python generate_wlist.py prompts_file output"
        print "  e.g. python generate_wlist.py test_prompts.txt test_wlist.txt"
        sys.exit(1)
    prompts = open(sys.argv[1], "r")
    words = []
    lines = prompts.read().strip("\n").split("\n")
    for l in lines:
        w = filter(None, l.split(" "))
        words.append(w[1:])
    words = list(itertools.chain.from_iterable(words))
    words = list(set(words))
    words.append("SILENCE")
    words.remove("'em")
    words.append("\\'em")
    words.sort()


    output = open(sys.argv[2], "w")
    for w in words:
        output.write(w+"\n")
    output.close()

    print "Word list for file " + sys.argv[1] + " created successfully"
    return 0

if __name__ == "__main__":
    main()
