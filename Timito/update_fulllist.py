__author__ = 'anastasia'
import sys
"""
Author = Anastasia Grigoropoulou
Create the final fulllist
"""
# cat triphones1 fulllist >> fulllist
# sort fulllist >> fulllist2
# uniq fulllist2 >> fulllist

def main():
        if len(sys.argv) < 2:
            print "Usage: python update_fulllist.py triphones_of_timit  triphones_of_train"
            print "  e.g. python update_fulllist.py fulllist triphones.txt"
            sys.exit(1)
        lines = [open(sys.argv[1], "r").read().strip("\n").split("\n")][0]
        lines_tr = [open(sys.argv[2], "r").read().strip("\n").split("\n")][0]
        for l in lines_tr:
            lines.append(l)
        lines.sort()
        lines = list(set(lines))

        output = open(sys.argv[1], "w")
        for l in lines:
            output.write(l + "\n")
        output.close()

        print "fulllist created"
        return 0


if __name__ == "__main__":
    main()