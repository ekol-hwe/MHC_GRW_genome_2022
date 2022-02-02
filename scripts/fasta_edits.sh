#! /bin/bash

# Usage:
# $ for i in $(ls *fasta | sed 's/.fasta//g'); do bash fasta_edits.sh $i; done

filename=`basename $1`

awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' ${1}.fasta > ${filename}.upper.fasta &&
awk '/^>/ {$0=$1} 1' ${filename}.upper.fasta > ${filename}.upper.shortHeaders.fasta
