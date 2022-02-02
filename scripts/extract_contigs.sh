#! /bin/bash

## Usage: loop through files listing contigs from different MHC regions or the rest of the genome.
# $ for i in $(ls *txt | sed 's/.txt//g'); do bash extract_contigs.sh $i; done

ref="" # enter path to reference fasta file

module load bioinfo-tools seqtk/1.2-r101

seqtk subseq ${ref}.fasta ${1}.txt > ${1}.fasta