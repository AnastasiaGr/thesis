import os
import re
import sys
"""
author = Anastasia Grigoropoulou
Generate train_prompts.txt
"""

home = "/home/anastasia/Desktop/Speecho"


def main():    # TODO : na mporw na dialegw liga arxeia
    if len(sys.argv) < 2:
        print "Usage: python generate_prompts.py txt_files_dir output"
        print "  e.g. python generate_prompts.py HTKTest/TXT test_prompts.txt"
        sys.exit(1)

    os.chdir(home)
    output = open(sys.argv[2], "w")
    os.chdir(sys.argv[1])
    filenames = [f for f in os.listdir(".")]
    filenames.sort()
    for filename in filenames:
        words = open(filename, "r").read().strip(" ").split(' ')
        sentence = filename[:-4] + " " + " ".join(words[2:])
        sentence = re.sub('[\".,:;?!]', ' ', sentence)
        output.write(sentence.lower())
    output.close()

    print sys.argv[2] + " created successfully"
    return 0

if __name__ == "__main__":
    main()
