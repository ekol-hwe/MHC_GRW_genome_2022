#!/usr/bin/python3

"""
Analysis of BED files created from intersections of intergenic regions BED file with repeat element BED file and with LTR element BED file in which BED features were merged.

python3 repeats_ltr_per_intergenic_length.py intersection_repeats_intergenic.summary.bed intersection_ltr_intergenic.summary.bed
"""

import sys
import os
import pandas as pd


inrepeats=open(sys.argv[1], 'r')
inltr=open(sys.argv[2], 'r')
out=os.path.splitext(os.path.basename(sys.argv[1]))[0]
outfile=out + ".perc_repeat_ltr_per_intergenic.txt"

def create_list_of_lengths(file):
    """Split each line of the bed file and store lengths of intergenic region, lengths of repeats, repeat names, and percentage of repeats per intergenic region in a list"""
    lengthsList = [] # list of lists of intergenic and repeat lengths
    speciesNamesDict = {"HC": "Ccor", "JD": "Cmon", "ZF": "Tgut", "CH": "Ggal", "GRW": "Aaru"}
    for line in file:
        edited = line.strip().split("\t")
        repeatIntergenicLengthList = [] # list of species, intergenic region name, intergenic region length, total length of repeat elements in that intergenic region, % repeat coverage per intergenic region, names of repeats
        repeatIntergenicLengthList.append(edited[0]) # species 0
        inter_name = edited[1] + "_" + edited[2] + "_" + edited[3] # Contig name + start + end position of intergenic region
        repeatIntergenicLengthList.append(inter_name) # intergenic name 1 
        repeatIntergenicLengthList.append(int(edited[4])) # intergenic length 2 
        repeatLengthList = [ int(x) for x in edited[8].strip().split(",")] # sum up lengths of all repeat elements in that intergenic region
        repeatIntergenicLengthList.append(sum(repeatLengthList)) # total repeat element length 3
        percentage = int(repeatIntergenicLengthList[3]) / int(repeatIntergenicLengthList[2]) * 100
        repeatIntergenicLengthList.append(percentage) # percentage of repeat element per gene (length) 4
        repeatIntergenicLengthList.append(edited[7]) # repeat element types 5 

        lengthsList.append(repeatIntergenicLengthList) # add intergenic region list to list of lists
    fixedNamesList = [[speciesNamesDict.get(item,item) for item in repeatIntergenicLengthList] for repeatIntergenicLengthList in lengthsList]
    return fixedNamesList

repeatList = create_list_of_lengths(inrepeats)
ltrList = create_list_of_lengths(inltr) # index 3, 4, 5 for LTRs instead of all repeats

# convert to pandas dataframes for merging
repeatDF = pd.DataFrame(data=repeatList, columns=["species", "intergenic_region", "intergenic_region_length", "total_repeat_length", "percentage_repeat_per_intergenic_region_length", "repeat_types"])
ltrDF = pd.DataFrame(ltrList, columns=["species", "intergenic_region", "intergenic_region_length", "total_ltr_length", "percentage_ltr_per_intergenic_region_length", "ltr_types"])

# merge the two dataframes per species, gene, gene length and MHC class
mergedDF = repeatDF.merge(ltrDF, on=["species", "intergenic_region", "intergenic_region_length"])

# write dataframe to output file
mergedDF.to_csv(outfile, index=False, sep='\t')

inrepeats.close()
inltr.close()