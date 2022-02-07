#! /bin/bash -l

### Usage: BED file from intersection of full GFF file with repeat BED file, containing gene, CDS, mRNA and exon features
# $ bash extract_exon_genes_from_intersect.sh [FULL_INTERSECT_GFF]

file=`echo $1 | sed 's/.gff//g'`

# extract exon features
grep "exon" ${file}.gff > ${file}.exons.gff

# extract gene features, add column with gene length to the end
awk -F'\t' '$3 == "gene" {print $0 "\t" $5-$4+1 }' ${file}.gff > ${file}.genes.gff
