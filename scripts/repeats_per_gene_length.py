#!/usr/bin/python3

"""
Analysis of BED file created from intersections of gene GFF file with repeat element bed file in which bed features were merged.

$ python3 repeats_per_gene_length.py intersection_repeats_genes_merged.bed
"""

import sys
import os


infile=open(sys.argv[1], 'r')
out=os.path.splitext(os.path.basename(sys.argv[1]))[0]
outfile=open(out + ".perc_repeat_per_gene.txt", 'w')

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

finalList = create_list_of_lengths(infile)

# write percentage repeats per gene to output file
outfile.write("species" + "\t" + "gene_name" + "\t" + "gene_length" + "\t" + "total_repeat_length" + "\t" + "percentage_repeat_per_gene_length" + "\t" + "repeat_types" + "\t" + "MHC_class" + "\n")
for gene in finalList:
    line ="\t".join([ str(x) for x in gene ])
    outfile.write(line + "\n")

infile.close()
outfile.close()
