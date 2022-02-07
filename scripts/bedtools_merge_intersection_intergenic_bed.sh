#! /bin/bash -l

### Usage: Merge features in BED files containing intersections of intergenic regions with repeat elements to create summaries
# $ bash bedtools_merge_intersection_intergenic_bed.sh [INPUT] [MERGED]

module load bioinfo-tools BEDTools/2.27.1
bedtools merge -i $1 -c 1,2,3,4,5,6,7,8 -o distinct,distinct,distinct,collapse,collapse,collapse,collapse,collapse > $2

