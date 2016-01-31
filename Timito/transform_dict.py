import re

f = open("TIMITDIC.TXT", "r")
lines = f.read().strip("\n").split("\n")
lines = filter(None, lines)  # remove empty lines
lines = filter(lambda x: x[0] != ';', lines)  # remove comment lines

for i in range(len(lines)):
    l = lines[i]
    if l[0] == '\'' or l[0] == '-':
        l = l[1:]
    l = re.sub('[12/\.]', '', l)
    l = re.sub('~.*?(?= )', '', l)
    lines[i] = l

lines.append("lined   l ay n d")
lines.append("bourgeoisie  b uh r zh w aa z iy")
lines.append("simmered  s ih m axr d")
lines.append("teeny  t iy n iy")
lines.append("SILENCE sil")
lines.append("\"'em\" ax m")
lines = list(set(lines))  # Sorts, and removes duplicates from list
lines.sort()

# write list to file
output = open("timit_dict.txt", "w")
for l in lines:
    output.write(l + "\n")
output.close()
