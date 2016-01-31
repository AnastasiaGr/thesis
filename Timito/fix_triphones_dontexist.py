
"""
    author : Anastasia Grigoropoulou
    This code is written to fix the error
    ERROR [+8231]  GetHCIModel: Cannot find hmm [t-]ey1[+t/]
"""
"""ftiaxnw ena kainourio leksiko xwris tis lekseis pou periexoun ta fwnimata gia ta opoia yparxei lathos"""
f = open("timit_dict_changed.txt","r")
lines = f.readlines()
f.close()
f = open("timit_dict_changed.txt","w")
for line in lines:
  	if (" ao " not in line) or (" ao" not in line):
    		f.write(line)
f.close()

""" ftiaxnw mia kainouria lista leksewn pou den perilamvanei tis parapanw lekseis"""

os.chdir(THRAS_ANAS)
output = open("timit_wlist_changed.txt","w")
f = open("timit_dict_changed.txt","r")
lines = f.read().strip("\n").split("\n")
for l in lines:
	words= l.strip(" ").split(" ")
	output.write(words[0]+ "\n")

output.close()


"""ksanaftiaxnw to wordloop"""
HBuild timit_wlist_changed.txt wordloop_changed

"""ksanatrexw tin entoli"""
HVite -H HMM/hmm15/macros -H HMM/hmm15/hmmdefs -S test_mfc.scp -l '*' -i recout2.mlf -w wordloop_changed -p 0.0 -s 5.0 timit_dict_changed.txt tiedlist