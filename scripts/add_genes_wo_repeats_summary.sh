#! /bin/bash -l

### Usage:
# $ bash add_genes_wo_repeats_summary.sh [ALL_GENES_SORTED_GFF] [INTERSECTION_GENES_GFF] [REPEAT_GENES_SUMMARY_BED]

allgenes=`echo $1 | sed 's/.gff//g'`
intersection=`echo $2 | sed 's/.gff//g'`
summary=`echo $3 | sed 's/.genes.summary.bed//g'`

# Extract "gene" features and calculate gene lengths for each feature from the modified and fixed GFF file with MHC gene annotations, add gene length as extra column, convert to bed format
awk -F'\t' '$3 == "gene" {print $0 "\t" $5-$4+1 }' ${allgenes}.gff | awk -F'\t' '{print $1 "\t" $4-1 "\t" $5 "\t" $9 "\t" $10}' > ${allgenes}.genes.length.bed
 
# Convert intersection GFF to BED format
awk -F'\t' '{print $1 "\t" $4-1 "\t" $5 "\t" $9}' ${intersection}.gff | sort -k1,1 -k2,2n -u > ${intersection}.bed

# Extract all genes without repeat elements, convert to summary format
grep -v -f ${intersection}.bed ${allgenes}.genes.length.bed | awk -F'\t' '{print $1 "\t" $2 "\t" $3  "\t" $4 "\t" "NA" "\t" 0 "\t" $5}' > ${allgenes}.genes.length.noRepeats.summary.bed
 
# Concatenate and sort to get summary file with all genes
cat ${allgenes}.genes.length.noRepeats.summary.bed ${summary}.genes.summary.bed | sort -k1,1 -k2,2n > ${summary}.all_genes.summary.bed
