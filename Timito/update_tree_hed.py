import sys
"""
Author= Anastasia Grigoropoulou
Create the final tree
"""

""" add  at the top of tree.hed
RO 100.0 HMM/hmm12/stats

TR 0
"""

"""got quest.hed and copied its content at tree.hed"""

"""added at the end of tree.hed:
TR 1

AU "fulllist"
CO "tiedlist"

ST "trees"
"""


def main():
    if len(sys.argv) < 2:
        print "Usage: python update_tree_hed.py  txt_with_TB  txt_with_questions"
        print "  e.g. python update_tree_hed.py  tree.hed quest.hed"
        sys.exit(1)

    lines_tree = [open(sys.argv[1],"r").read().strip("\n").split("\n")][0]

    output = open(sys.argv[1], "w")
    output.write ("RO 100.0 HMM/hmm12/stats"+"\n"+"\n"+"TR 0"+"\n"+"\n")
    lines_quest = [open(sys.argv[2],"r").read().strip("\n").split("\n")][0]
    for l in lines_quest:
        output.write(l+"\n")
    for l in lines_tree:
        output.write(l+"\n")
    output.write ("TR 1"+"\n"+"\n"+"AU \"fulllist\""+"\n"+"CO \"tiedlist\""+"\n"+"\n" +"ST \"trees\""+"\n")
    output.close()

    print "tree created"
    return 0


if __name__ == "__main__":
    main()