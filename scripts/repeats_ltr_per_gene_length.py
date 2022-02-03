#!/usr/bin/python3

"""
Analysis of BED files created from intersections of gene GFF file with repeat element bed file and with LTR element bed file in which bed features were merged.

$ python3 repeats_ltr_per_gene_length.py intersection_repeats.all_genes.summary.bed intersection_ltr.all_genes.summary.bed
"""

import sys
import os
import pandas as pd


inrepeats=open(sys.argv[1], 'r')
inltr=open(sys.argv[2], 'r')
out=os.path.splitext(os.path.basename(sys.argv[1]))[0]
outfile=out + ".perc_repeat_ltr_per_gene.txt"

def create_list_of_lengths(file):
    """Split each line of the bed file and store lengths of gene, lengths of repeats, repeat names, MHC class, and percentage of repeats per gene in a list"""
    lengthsList = [] # list of lists of gene and repeat lengths
    speciesNamesDict = {"HC": "Ccor", "JD": "Cmon", "ZF": "Tgut", "CH": "Ggal", "GRW": "Aaru"}
    for line in file:
        edited = line.strip().split("\t")
        repeatGeneLengthList = [] # list of species, gene name, gene length, total length of repeat elements in that gene, % repeat coverage per gene, names of repeats, MHC class
        repeatGeneLengthList.append(edited[0]) # species 0
        repeatGeneLengthList.append(edited[4]) # gene name 1 
        repeatGeneLengthList.append(int(edited[7])) # gene length 2 
        repeatLengthList = [ int(x) for x in edited[6].strip().split(",")]
        repeatGeneLengthList.append(sum(repeatLengthList)) # total repeat element length 3
        percentage = int(repeatGeneLengthList[3]) / int(repeatGeneLengthList[2]) * 100
        repeatGeneLengthList.append(percentage) # percentage of repeat element per gene (length) 4
        repeatGeneLengthList.append(edited[5]) # repeat element types 5 
        if "MHCIIB" in edited[4]:
            repeatGeneLengthList.append("MHCIIB") # MHC class 6
        elif "hb2l" in edited[4]:
            repeatGeneLengthList.append("MHCIIB")
        elif "class II" in edited[4]:
            repeatGeneLengthList.append("MHCIIB")
        elif "MHCIIA" in edited[4]:
            repeatGeneLengthList.append("MHCIIA")
        elif "MHCI" in edited[4]:
            repeatGeneLengthList.append("MHCI")
        elif "ha1f" in edited[4]:
            repeatGeneLengthList.append("MHCI")
        elif "class I" in edited[4]:
            repeatGeneLengthList.append("MHCI")
        else:
            repeatGeneLengthList.append("notMHC")
        lengthsList.append(repeatGeneLengthList) # add gene list to list of lists
    fixedNamesList = [[speciesNamesDict.get(item,item) for item in repeatGeneLengthList] for repeatGeneLengthList in lengthsList]
    return fixedNamesList

repeatList = create_list_of_lengths(inrepeats)
ltrList = create_list_of_lengths(inltr) # index 3, 4, 5 for LTRs instead of all repeats

# convert to pandas dataframes for merging
repeatDF = pd.DataFrame(data=repeatList, columns=["species", "gene_name", "gene_length", "total_repeat_length", "percentage_repeat_per_gene_length", "repeat_types", "MHC_class"])
ltrDF = pd.DataFrame(ltrList, columns=["species", "gene_name", "gene_length", "total_ltr_length", "percentage_ltr_per_gene_length", "ltr_types", "MHC_class"])

# merge the two dataframes per species, gene, gene length and MHC class
mergedDF = repeatDF.merge(ltrDF, on=["species", "gene_name", "gene_length", "MHC_class"])

# write dataframe to output file
mergedDF.to_csv(outfile, index=False, sep='\t')

inrepeats.close()
inltr.close()