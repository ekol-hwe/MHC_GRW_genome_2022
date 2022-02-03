#! /bin/bash -l
#SBATCH -A snic2018-3-665
#SBATCH -p core -n 1
#SBATCH -t 00:30:00

### Usage: Merge features in BED files containing intersections of introns (intersected with genes) with repeat elements to create summaries
# $ sbatch bedtools_merge_intersection_intron_gff.sh [INPUT] [MERGED]

module load bioinfo-tools BEDTools/2.27.1
bedtools merge -i $1 -c 9,14,15,16 -o distinct,collapse,collapse,collapse > $2

