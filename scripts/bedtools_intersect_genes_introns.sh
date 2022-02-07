#! /bin/bash -l
#SBATCH -A snic2018-3-665
#SBATCH -p core -n 1
#SBATCH -t 00:30:00

### Usage (only sorted and merged files):
# $ sbatch bedtools_intersect_genes_introns.sh [GFF] [INTRON_INTERSECT_BED] [INTRON_GENE_INTERSECT_GFF]

# Extract gene features from original GFF
file=`echo $1 | sed 's/.gff//g'`
awk -F'\t' '$3 == "gene" {print $0 "\t" $5-$4+1 }' ${file}.gff > ${file}.genes.gff

module load bioinfo-tools BEDTools/2.27.1
bedtools intersect -wo -a ${file}.genes.gff -b $2 | sort -k1,1 -k4,4n -k5,5n -k11,11n -k12,12n > $3
