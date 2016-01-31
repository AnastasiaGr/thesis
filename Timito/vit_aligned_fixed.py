import sys, itertools, re

__author__ = 'anastasia'

home = "/home/anastasia/Desktop/Speecho"


def main():
    if len(sys.argv) < 2:
        print "Usage: python vit_aligned_fixed.py vit_aligned_mlf_old vit_aligned_new "
        print "  e.g. python vit_aligned_fixed.py vit_aligned.mlf vit_aligned_new.mlf  "
        sys.exit(1)

    f = open("vit_aligned.mlf", "r")
    lines = f.read().strip("\n").split("\n")

    for i in range(0, len(lines), 1):
        if lines[i] == 'sil' and lines[i+1] == 'sp':
            lines.pop(i+1)

    for i in range (0,len(lines),1):
        if lines[i] == 'sp' and lines[i+1] == 'sil':
            lines.pop(i)

    output = open("vit_aligned_new.mlf", "w")
    for l in lines:
        output.write(l + "\n")
    output.close()


    return 0

if __name__ == "__main__":
    main()






