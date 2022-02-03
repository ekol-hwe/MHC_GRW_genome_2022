#! /bin/bash -l
#SBATCH -A snic2018-3-665
#SBATCH -p core -n 1
#SBATCH -t 00:30:00

### Usage: move to output directory and run
# $ sbatch create_genomefile.sh [GENOME_FASTA]

module load bioinfo-tools samtools/1.8

samtools faidx ${1} &&
cut -f1,2 ${1}.fai > ${1}.genomefile
