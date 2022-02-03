#! /bin/bash

## Usage: loop through files listing contigs from different MHC regions or the rest of the genome.
# $ for i in $(ls *txt | sed 's/.txt//g'); do bash extract_contigs.sh $i; done

ref="" # enter full path to reference fasta file *.upper.shortHeaders.fasta, i.e. after running fasta_edits.sh (conversion to upper case, fasta header shortening)

module load bioinfo-tools seqtk/1.2-r101

seqtk subseq ${ref} ${1}.txt > ${1}.upper.shortHeaders.fasta