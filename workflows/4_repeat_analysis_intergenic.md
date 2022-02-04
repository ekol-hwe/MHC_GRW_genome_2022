# Repeat content in intergenic regions

This workflow was applied to each of the analyzed species (great 
reed warbler, hooded crow, jackdaw, zebra finch, chicken)

## General repeat content in intergenic regions

### Create BED files with intergenic regions

- Use BEDtools subtract to subtract the BED files with gene 
  locations (from `add_genes_wo_repeats_summary.sh` in workflow 
  3) from the genomefiles

- Script: `extract_intergenic_regions.sh`

```
# Start the script with a for loop through the genome file 
# files for each species and genome region, specifying 
# the genome file, the gene BED and the output file on the command line

$ for i in $(ls *.upper.shortHeaders.fasta.genomefile | sed 's/.upper.shortHeaders.fasta.genomefile//g'); do sbatch extract_intergenic_regions.sh ${i}.upper.shortHeaders.fasta.genomefile ${i}.sorted.modified.genes.length.bed ${i}.sorted.modified.intergenic.bed; done
```

### Intersect the intergenic region BED files with the repeat BED file

- Script: `bedtools_intersect.sh`

```
# Start the script with a for loop through the intergenic 
# region BED files for each species and genome region, specifying 
# the intergenic BED, the repeat BED and output file on the command line

$ for i in $(ls *.sorted.modified.intergenic.bed | sed 's/.sorted.modified.intergenic.bed//g'); do bash bedtools_intersect.sh ${i}.sorted.modified.intergenic.bed ${i}.upper.shortHeaders.fasta.rm.merged.bed ${i}.sorted.modified.intergenic.intersect_repeats.gff; done
```

### Merge features in intersection BED files to obtain a summary per intergenic region

- Script: `bedtools_merge_intersection_intergenic_bed.sh`

```
# Start the script with a for loop through the intersected GFF files 
# for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intergenic.intersect_repeats.gff | sed 's/.gff//g'); bash bedtools_merge_intersection_intergenic_bed.sh ${i}.gff ${i}.summary.bed; done
```

### Add intergenic regions without repeat elements

- Script: `add_intergenic_wo_repeats_summary.sh`

```
# Start the script with a for loop through the intergenic region
# summary files for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intergenic.bed | sed 's/.sorted.modified.intergenic.bed//g'); do bash add_intergenic_wo_repeats_summary.sh ${i}.sorted.modified.intergenic.bed ${i}.sorted.modified.intergenic.intersect_repeats.gff ${i}.sorted.modified.intergenic.intersect_repeats.summary.bed; done
```

### Combine all results for repeat elements in intergenic regions for downstream analysis

- Concatenate all *.intersect_repeats.all_intergenic.summary.length.bed files for downstream analysis

```
# Assuming that the intergenic summary files start with the species
# abbreviations "ch", "grw", "hc", "jd", "zf", run the following 
# for loop through the abbreviations to add a column with the 
# respective species' abbreviation and the cat command to combine 
# the summary BED files into one file

for i in ch grw hc jd zf; do awk -v var="$i" '{ print var "\t" $0}' ${i}*intersect_repeats.all_intergenic.summary.length.bed > ${i}_temp.txt; done &&

cat *_temp.txt > CH_GRW_HC_JD_ZF.mhc_I_II.intersect_repeats.all_intergenic.summary.length.bed &&
rm *_temp.txt
```

- Reformat the concatenated summary file

- Script: `repeats_per_intergenic_length.py`

```
# Run the script from the command line, specifying the
# concatenated summary file

$ python3 repeats_per_intergenic_length.py CH_GRW_HC_JD_ZF.mhc_I_II.intersect_repeats.all_intergenic.summary.length.bed
```

## LTR element content in intergenic regions

### Intersect the intergenic region BED file with the LTR BED file

- Script: `bedtools_intersect.sh`

```
# Start the script with a for loop through the intergenic region
# BED files for each species and genome region

$ for i in $(ls *.sorted.modified.intergenic.bed | sed 's/.sorted.modified.intergenic.bed//g'); do bash bedtools_intersect.sh ${i}.sorted.modified.intergenic.bed ${i}.upper.shortHeaders.fasta.rm.ltr.merged.bed ${i}.sorted.modified.intergenic.intersect_ltr.gff; done
```

### Merge features in intersection BED file to obtain a summary per intergenic region

Script: `bedtools_merge_intersection_intergenic_bed.sh`

```
# Start the script with a for loop through the intersected GFF files 
# for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intergenic.intersect_ltr.gff | sed 's/.gff//g'); bash bedtools_merge_intersection_intergenic_bed.sh ${i}.gff ${i}.summary.bed; done
```

### Add intergenic regions without repeat elements

Script: `add_intergenic_wo_repeats_summary.sh`

```
# Start the script with a for loop through the intergenic region
# summary files for each species and genome region on the command line

$ for i in $(ls *.sorted.modified.intergenic.bed | sed 's/.sorted.modified.intergenic.bed//g'); do bash add_intergenic_wo_repeats_summary.sh ${i}.sorted.modified.intergenic.bed ${i}.sorted.modified.intergenic.intersect_ltr.gff ${i}.sorted.modified.intergenic.intersect_ltr.summary.bed; done
```

### Combine all results for LTR elements in intergenic regions for downstream analysis

- Concatenate all *.intersect_ltr.all_intergenic.summary.length.bed files for downstream analysis

```
# Assuming that the intergenic summary files start with the species
# abbreviations "ch", "grw", "hc", "jd", "zf", run the following 
# for loop through the abbreviations to add a column with the 
# respective species' abbreviation and the cat command to combine 
# the summary BED files into one file

for i in ch grw hc jd zf; do awk -v var="$i" '{ print var "\t" $0}' ${i}*intersect_ltr.all_intergenic.summary.length.bed > ${i}_temp.txt; done &&

cat *_temp.txt > CH_GRW_HC_JD_ZF.mhc_I_II.intersect_ltr.all_intergenic.summary.length.bed &&
rm *_temp.txt
```

- Reformat the concatenated summary file

- Script: `repeats_ltr_per_intergenic_length.py`

```
# Run the script from the command line, specifying the
# concatenated summary files for all repeats and LTRs

$ python3 repeats_ltr_per_intergenic_length.py CH_GRW_HC_JD_ZF.mhc_I_II.intersect_repeats.all_intergenic.summary.length.bed CH_GRW_HC_JD_ZF.mhc_I_II.intersect_ltr.all_intergenic.summary.length.bed
```
