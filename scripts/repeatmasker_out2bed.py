#!/usr/bin/python

"""
$ python repeatmasker_out2bed.py repeatmasker.fasta.out repeatmasker.fasta.bed
"""


import sys

with open(sys.argv[1], 'r') as f, open(sys.argv[2], 'w') as b:
    for line in f:
        edited = line.strip().split()
        if len(edited) > 6 and edited[0].isdigit():
            start = str(int(edited[5]) - 1)
            b.write(edited[4] + "\t" + start + "\t" + edited[6] + "\t" + edited[10] + "\n")