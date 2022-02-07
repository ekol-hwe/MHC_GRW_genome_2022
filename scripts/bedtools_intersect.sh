#! /bin/bash -l

### Usage (only sorted and merged files):
# $ bash bedtools_intersect.sh [GENE_GFF] [REPEAT_BED] [INTERSECT_GFF]

module load bioinfo-tools BEDTools/2.27.1
bedtools intersect -wo -a $1 -b $2 > $3
