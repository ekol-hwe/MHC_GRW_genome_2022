#!/usr/bin/python3

"""
Replace accession numbers with gene product names in place in the repeat analysis summary file
$ python3 fix_chicken_gene_names.py look_up_table path_to_summary_file
"""

import sys
import fileinput

acc=open(sys.argv[1] , 'r') # open the lookup table
bed=sys.argv[2] # path to summary file

nameDict = {}
for i in acc:
    i = i.rstrip()
    name = i.rstrip().split(";")
    nameDict[name[0]] = i
  
for line in fileinput.input(bed, inplace=True):
    line = line.rstrip()
    if not line:
        continue
    for f_key, f_value in nameDict.items():
        if f_key in line:
            line = line.replace(f_key, f_value)
    print(line)