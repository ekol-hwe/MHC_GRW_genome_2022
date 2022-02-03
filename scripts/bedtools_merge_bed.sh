#! /bin/bash -l

### Usage:
# $ bash bedtools_merge_bed.sh [INPUT]

out=`echo $1 | sed 's/.bed//g'`

sort -k1,1 -k2,2n $1 > temp_bed

module load bioinfo-tools BEDTools/2.27.1
bedtools merge -i temp_bed -c 4 -o collapse > ${out}.merged.bed &&
rm temp_bed
