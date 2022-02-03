#! /bin/bash -l
#SBATCH -A snic2018-3-665
#SBATCH -p core -n 1
#SBATCH -t 00:30:00
#SBATCH -M snowy

### Usage:
# $ sbatch extract_introns.sh [GFF] [GENOME_FILE]

filename=`echo ${1} | sed 's/.gff//g'`

module load bioinfo-tools BEDTools/2.27.1

grep -v "#" ${1} | sort -k1,1 -k4,4n -k5,5n -t$'\t' > ${filename}.sorted.gff &&

# get intergenic regions
bedtools complement -i ${filename}.sorted.gff -g ${2} > ${filename}.intergenic.bed &&

# extract exon regions
awk -F"\t" '{if ($3 == "exon") print $1, $4-1, $5}' ${filename}.sorted.gff > ${filename}.exon.bed &&
sed -i 's/ /\t/g' ${filename}.exon.bed &&

# get introns
bedtools complement -i <(cat ${filename}.exon.bed ${filename}.intergenic.bed | sort -k1,1 -k2,2n) -g ${2} > ${filename}.intron.bed &&

# remove intermediate files
rm ${filename}.sorted.gff
rm ${filename}.intergenic.bed
rm ${filename}.exon.bed
