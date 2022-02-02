#!/usr/bin/python3

"""
Process all RepeatMasker *.tbl files in a given directory and convert them into one table,
combining all files
python3 parse_repeatmasker_tbl.py path_to_directory path_to_output_file
"""

import pandas as pd
import os
import sys

def read_repeatmasker_tbl(file):
    repList = []
    with open(file, 'r') as fh:
        for l in fh:
            if l.startswith("file name:"):
                fileName = l.strip().split()[2]
                repList.append(fileName)
            elif l.startswith("total length:"):
                repList.append(l.strip().split()[2])
            elif l.startswith("SINEs:"):
                repList.append(l.strip().split()[1])
                repList.append(l.strip().split()[2])
            elif l.startswith("LINEs:"):
                repList.append(l.strip().split()[1])
                repList.append(l.strip().split()[2])
            elif l.startswith("LTR elements:"):
                repList.append(l.strip().split()[2])
                repList.append(l.strip().split()[3])
            elif l.startswith("DNA elements:"):
                repList.append(l.strip().split()[2])
                repList.append(l.strip().split()[3])
            elif l.startswith("Unclassified:"):
                repList.append(l.strip().split()[1])
                repList.append(l.strip().split()[2])
            elif l.startswith("Small RNA:"):
                repList.append(l.strip().split()[2])
                repList.append(l.strip().split()[3])
            elif l.startswith("Satellites:"):
                repList.append(l.strip().split()[1])
                repList.append(l.strip().split()[2])
            elif l.startswith("Simple repeats:"):
                repList.append(l.strip().split()[2])
                repList.append(l.strip().split()[3])
            elif l.startswith("Low complexity:"):
                repList.append(l.strip().split()[2])
                repList.append(l.strip().split()[3])
    return repList

def convert_to_df(directory):
    dirname = directory
    fileRepList = []

    # iterating over all files ending with *tbl
    for files in os.listdir(dirname):
        if files.endswith(".tbl"):
            path = dirname + files
            fileRepList.append(read_repeatmasker_tbl(path))
        else:
            continue
    
    # convert to dataframe
    header = ["File_name", "bp_total_length", "n_SINEs", "bp_SINEs", "nLINEs", "bp_LINEs", "n_LTR_elements", "bp_LTR_elements", "n_DNA_elements", "bp_DNA_elements", "n_Unclassified", "bp_Unclassified", "n_small_RNA", "bp_small_RNA", "n_Satellites", "bp_Satellites", "n_simple_repeats", "bp_simple_repeats", "n_low_complexity", "bp_low_complexity"]
    df = pd.DataFrame(fileRepList, columns=header)
    return df


indir = sys.argv[1] # path to input directory
outfile = sys.argv[2] # path to output file

# apply the above functions to the repeatmasker *tbl files to convert them into one dataframe
repDF = convert_to_df(indir)

# write the dataframe to a file
repDF.to_csv(outfile, index=None, sep=' ')