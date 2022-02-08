# Repeat content in genes

This workflow was applied to each of the analyzed species (great 
reed warbler, hooded crow, jackdaw, zebra finch, chicken)

## General repeat content in genes and exons

### Intersect gene annotation GFF files with repeat element BED files

> !!! GFF files must have the same file names as the fasta 
  files and RepeatMasker output files for the following 
  `for` loops to work (e.g. `grw_mhcI.sorted.modified.gff` or 
  `hc_mhcI_II.sorted.modified.gff`)  

- Script: `bedtools_intersect.sh`

```
# Start the script with a for loop through the modified 
# GFF files for each species and genome region, specifying 
# the GFF, the repeat BED and output file on the command line

$ for i in $(ls *.sorted.modified.gff | sed 's/.sorted.modified.gff//g'); do bash bedtools_intersect.sh ${i}.sorted.modified.gff ${i}.upper.shortHeaders.fasta.rm.merged.bed ${i}.sorted.modified.intersect_repeats.gff; done
```

### Extract "exon" and "gene" features from the intersected GFF file

- Calculate gene lengths and add as extra column

- Script: `extract_exon_genes_from_intersect.sh`

```
# Start the script with a for loop through the intersected 
# GFF files for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intersect_repeats.gff); do bash extract_exon_genes_from_intersect.sh ${i}; done
```

### Merge features in extracted gene GFF files to obtain a summary per gene

- Script: `bedtools_merge_intersection_gene_gff.sh`

```
# Start the script with a for loop through the gene GFF files 
# for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intersect_repeats.genes.gff | sed 's/.gff//g'); bash bedtools_merge_intersection_gene_gff.sh ${i}.gff ${i}.summary.bed; done
```

### Merge features in extracted exon GFF files to obtain a summary per exon

- Script: `bedtools_merge_intersection_exon_gff.sh`

```
# Start the script with a for loop through the exon GFF files 
# for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intersect_repeats.exons.gff | sed 's/.gff//g'); bash bedtools_merge_intersection_exon_gff.sh ${i}.gff ${i}.summary.bed; done
```

### Add genes without repeat elements to the each of the merged summaries for genes

- Script: `add_genes_wo_repeats_summary.sh`

```
# Start the script with a for loop through the gene summary files 
# for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.gff | sed 's/.sorted.modified.gff//g'); do bash add_genes_wo_repeats_summary.sh ${i}.sorted.modified.gff ${i}.sorted.modified.intersect_repeats.genes.gff ${i}.sorted.modified.intersect_repeats.genes.summary.bed; done
```

- Keep the intermediate files *.sorted.modified.genes.length.bed
  for workflow 4

### Combine all results for repeat elements in genes for downstream analysis

- Concatenate all *.all_genes_summary.bed files for downstream analysis

```
# Assuming that the gene summary files start with the species
# abbreviations "ch", "grw", "hc", "jd", "zf", run the following 
# for loop through the abbreviations to add a column with the 
# respective species' abbreviation and the cat command to combine 
# the summary BED files into one file

for i in ch grw hc jd zf; do awk -v var="$i" '{ print var "\t" $0}' ${i}*all_genes.summary.bed > ${i}_temp.txt; done &&

cat *_temp.txt > CH_GRW_HC_JD_ZF.mhc_I_II.intersect_repeats.all_genes.summary.bed &&
rm *_temp.txt
```

#### Additional edits only for chicken

- The chicken GFF file has a slightly different format than
  the other GFF files used in this analysis with accession numbers
  instead of gene names

- Replace accession numbers with gene product names from the 
  chicken GFF file

```
# Get gene accession numbers from chicken GFF file for the MHC region
awk -F'\t' '{print $9}' ch_mhc.sorted.modified.gff | awk -F';' '{print $1}' | sed 's/Name=//g' > ch_mhc_gene_accessions.txt
  
# Extract product names from GFF file and create a lookup table
grep -f ch_mhc_gene_accessions.txt ch_mhc.sorted.modified.gff | awk -F'\t' '$3 == "CDS"' | awk -F'\t' '{print $9}' | awk -F';' '{print $2 ";" $8}' | sort -u > ch_mhc_gene_accessions_products_lookup_table.txt
```

- Script: `fix_chicken_gene_names.py`

```
# Update the summary file with gene product names for chicken 
# based on the lookup table

$ python3 fix_chicken_gene_names.py ch_mhc_gene_accessions_products_lookup_table.txt CH_GRW_HC_JD_ZF.mhc_I_II.intersect_repeats.all_genes.summary.bed
```


### Reformat the concatenated and updated summary file

- Script: `repeats_per_gene_length.py`

```
# Run the script from the command line, specifying the
# concatenated summary file

$ python3 repeats_per_gene_length.py CH_GRW_HC_JD_ZF.mhc_I_II.intersect_repeats.all_genes.summary.bed
```


## General repeat content in introns

### Create a genome file from each fasta file of genome regions for each species

- Script: `create_genomefile.sh`

```
# Start the script with a for loop through the different 
# fasta files

$ for i in $(ls *.upper.shortHeaders.fasta); do sbatch create_genomefile.sh $i; done
```

### Create a BED file with the coordinates of all introns per genome region and species

- Script: `extract_introns.sh`

```
# Start the script with a for loop through the modified 
# GFF files for each species and genome region, specifying 
# the GFF and genome file on the command line

$ for i in $(ls *.sorted.modified.gff | sed 's/.sorted.modified.gff//g'); do sbatch extract_introns.sh ${i}.sorted.modified.gff ${i}.upper.shortHeaders.fasta.genomefile; done
```

### Intersect the intron BED file with the repeat element BED file

- Script: `bedtools_intersect.sh`

```
# Start the script with a for loop through the intron 
# BED files for each species and genome region, specifying 
# the intron BED, the repeat BED and output file on the command line

$ for i in $(ls *.sorted.modified.introns.bed | sed 's/.sorted.modified.introns.bed//g'); do bash bedtools_intersect.sh ${i}.sorted.modified.introns.bed ${i}.upper.shortHeaders.fasta.rm.merged.bed ${i}.sorted.modified.introns.intersect_repeats.bed
```

### Intersect intron intersection BED with genes GFF 

- Results in information about which intron belongs to which gene

- Script: `bedtools_intersect_genes_introns.sh`

```
# Start the script with a for loop through the modified 
# GFF files for each species and genome region, specifying 
# the intron intersection BED and the output file on the command line

$ for i in $(ls *.sorted.modified.gff | sed 's/.sorted.modified.gff//g'); do sbatch bedtools_intersect_genes_introns.sh ${i}.sorted.modified.gff ${i}.sorted.modified.introns.intersect_repeats.bed ${i}.sorted.modified.introns.intersect_repeats.intersect_genes.gff
```

### Merge features in intersected intron/gene GFF files to obtain a summary per intron

- Script: `bedtools_merge_intersection_intron_gff.sh`

```
# Start the script with a for loop through the intron GFF files 
# for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.introns.intersect_repeats.intersect_genes.gff | sed 's/.gff//g'); bash bedtools_merge_intersection_intron_gff.sh ${i}.gff ${i}.summary.bed; done
```

## LTR element content in genes

### Extract LTR elements from repeat BED files

- LTR elements are extracted from repeat BED files, resulting 
  in one LTR element per line

```
# Start the script with a for loop through the RepeatMasker BED files
# for each species and genome region

$ for i in $(ls *.upper.shortHeaders.fasta.rm.bed | sed 's/.bed//g'); do awk '$4 ~ /LTR/ { print }' ${i}.bed > ${i}.ltr.bed; done
```

### Merge LTR BED files

- In some cases, repeat elements might overlap with each other.
  For correct LTR length calculation, the BED files are thus merged 
  before further processing

- Script: `bedtools_merge_bed.sh`

```
# Start the script with a for loop through the RepeatMasker BED files
# for each species and genome region

$ for i in $(ls *.upper.shortHeaders.fasta.rm.ltr.bed | sed 's/.bed//g'); do bash bedtools_merge_bed.sh $i; done
```

### Intersect GFF files with merged LTR BED files

> !!! GFF files must have the same file names as the fasta 
  files and RepeatMasker output files for the following 
  `for` loops to work (e.g. `grw_mhcI.sorted.modified.gff` or 
  `hc_mhcI_II.sorted.modified.gff`)  

- Script: `bedtools_intersect.sh`

```
# Start the script with a for loop through the modified 
# GFF files for each species and genome region, specifying 
# the GFF, the repeat BED and output file on the command line

$ for i in $(ls *.sorted.modified.gff | sed 's/.sorted.modified.gff//g'); do bash bedtools_intersect.sh ${i}.sorted.modified.gff ${i}.upper.shortHeaders.fasta.rm.ltr.merged.bed ${i}.sorted.modified.intersect_ltr.gff; done
```

> Note that none of the LTR elements in chicken and zebra 
  finch overlap with a gene

### Extract "gene" features from intersected GFF file

- Calculate gene lengths and add as extra column

- Script: `extract_exon_genes_from_intersect.sh`

```
# Start the script with a for loop through the intersected 
# GFF files for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intersect_ltr.gff); do bash extract_exon_genes_from_intersect.sh ${i}; done
```

### Merge features in intersection GFFs to obtain a summary per gene

- Script: `bedtools_merge_intersection_gene_gff.sh`

```
# Start the script with a for loop through the gene GFF files 
# for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intersect_ltr.genes.gff | sed 's/.gff//g'); bash bedtools_merge_intersection_gene_gff.sh ${i}.gff ${i}.summary.bed; done
```

### Add genes without LTR elements to the merged GFF summary for genes

- Run for Hooded crow, jackdaw and warbler

- Script: `add_genes_wo_repeats_summary.sh`

```
# Start the script with a for loop through the gene summary files 
# for Hooded crow, jackdaw and warbler and genome region on the command line
# (modify according to file names)

$ for i in $(ls *.sorted.modified.gff | sed 's/.sorted.modified.gff//g'); do bash add_genes_wo_repeats_summary.sh ${i}.sorted.modified.gff ${i}.sorted.modified.intersect_ltr.genes.gff ${i}.sorted.modified.intersect_ltr.genes.summary.bed; done
```

- In chicken and zebra finch, none of the genes contains LTR elements

- The GFF file was therefore converted to the *genes.summary.bed format 
  for further processing

- Script: `extract_genes_wo_repeats_ltr_summary.sh`

```
# Start the script with a for loop through the gene summary files 
# for chicken and zebra finch and genome region on the command line
# (modify according to file names)

$ for i in $(ls *.sorted.modified.gff); do bash extract_genes_wo_repeats_ltr_summary.sh $i; done
```

### Combine all results for repeat elements in genes for downstream analysis

- Concatenate all *.all_genes_summary.bed files for downstream analysis

```
# Assuming that the gene summary files start with the species
# abbreviations "ch", "grw", "hc", "jd", "zf", run the following 
# for loop through the abbreviations to add a column with the 
# respective species' abbreviation and the cat command to combine 
# the summary BED files into one file

for i in ch grw hc jd zf; do awk -v var="$i" '{ print var "\t" $0}' ${i}*ltr.all_genes.summary.bed > ${i}_ltr.temp.txt; done &&

cat *_ltr.temp.txt > CH_GRW_HC_JD_ZF.mhc_I_II.intersect_ltr.all_genes.summary.bed &&
rm *_ltr.temp.txt
```

#### Additional edits only for chicken

- The chicken GFF file has a slightly different format than
  the other GFF files used in this analysis with accession numbers
  instead of gene names

- Replace accession numbers with gene product names from the 
  chicken GFF file

- Script: `fix_chicken_gene_names.py`

```
# Update the summary file with gene product names for chicken 
# based on the lookup table that was created above

$ python3 fix_chicken_gene_names.py ch_mhc_gene_accessions_products_lookup_table.txt CH_GRW_HC_JD_ZF.mhc_I_II.intersect_ltr.all_genes.summary.bed
```

### Reformat the concatenated and updated summary file

- Script: `repeats_ltr_per_gene_length.py`

- Requires python 3.7.6 and pandas 1.2.3

```
# Run the script from the command line, specifying the
# concatenated summary files for all repeats and LTRs

$ python3 repeats_ltr_per_gene_length.py CH_GRW_HC_JD_ZF.mhc_I_II.intersect_repeats.all_genes.summary.bed CH_GRW_HC_JD_ZF.mhc_I_II.intersect_ltr.all_genes.summary.bed
```


