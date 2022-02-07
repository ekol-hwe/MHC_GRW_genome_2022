#! /bin/bash -l

### Usage:
# bash extract_genes_wo_repeats_ltr_summary.sh [ALL_GENES_SORTED_GFF]

allgenes=`echo $1 | sed 's/.gff//g'`

# Extract "gene" features and calculate gene lengths for each feature from the modified and fixed GFF file with MHC gene annotations, add gene length as extra column, convert to bed format
awk -F'\t' '$3 == "gene" {print $0 "\t" $5-$4+1 }' ${allgenes}.gff | awk -F'\t' '{print $1 "\t" $4-1 "\t" $5 "\t" $9 "\t" $10}' > ${allgenes}.genes.length.bed
 
# Convert to summary format
awk -F'\t' '{print $1 "\t" $2 "\t" $3  "\t" $4 "\t" "NA" "\t" 0 "\t" $5}' ${allgenes}.genes.length.bed > ${allgenes}.intersect_ltr.all_genes.summary.bed