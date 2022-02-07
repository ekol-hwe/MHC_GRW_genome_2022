#! /bin/bash -l
#SBATCH -A snic2018-3-665
#SBATCH -p core -n 1
#SBATCH -t 00:30:00
 
### Usage:
# $ sbatch extract_intergenic_regions.sh [MHC_GENOMEFILE] [GENE_BED] [INTERGENIC_BED]
 
module load bioinfo-tools BEDTools/2.27.1
 
# create BED file from genomefile
awk -v OFS='\t' '{print $1, 0, $2}' ${1} > ${1}.bed &&
 
# subtract gene regions from genome BED
bedtools subtract -a ${1}.bed -b ${2} > ${3}