#! /bin/bash -l

### Usage: Merge features in GFF files containing intersections of genes with repeat elements to create summaries
# $ bash bedtools_merge_intersection_gene_gff.sh [INPUT] [MERGED]

module load bioinfo-tools BEDTools/2.27.1
bedtools merge -i $1 -c 9,13,14,15 -o distinct,collapse,collapse,distinct > $2

