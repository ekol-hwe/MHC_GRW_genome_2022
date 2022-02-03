#! /bin/bash -l
#SBATCH -A snic2018-3-665
#SBATCH -p core -n 1
#SBATCH -t 00:30:00

### Usage: Merge features in GFF files containing intersections of exons with repeat elements to create summaries
# $ sbatch bedtools_merge_intersection_exon_gff.sh [INPUT] [MERGED]

module load bioinfo-tools BEDTools/2.27.1
bedtools merge -i $1 -c 9,13,14 -o distinct,collapse,collapse > $2

