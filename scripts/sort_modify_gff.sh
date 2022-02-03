#! /bin/bash -l
#SBATCH -A snic2018-3-665
#SBATCH -p core -n 1
#SBATCH -t 00:10:00

### Usage: sort and modify GFF files produced with Geneious software
# $ for i in *.gff; do sbatch sort_modify_gff.sh $i; done

file=`echo $1 | sed 's/.gff//g'`

echo "##gff-version 3" > ${file}.sorted.modified.gff
grep -v "#" ${file}.gff | sort -k1,1 -k4,4n -k5,5n -t$'\t' >> ${file}.sorted.gff &&

modify_gff.pl ${file}.sorted.gff > ${file}.sorted.modified.gff &&

rm ${file}.sorted.gff
