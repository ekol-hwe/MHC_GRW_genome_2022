# RepeatMasker

This workflow was applied to each of the analyzed species (great 
reed warbler, hooded crow, jackdaw, zebra finch, chicken)

## Fasta file preparations

- Each reference genome was prepared for RepeatMasker by turning all 
  bases were to upper case and by shortening fasta headers (text after 
  first whitespace was removed)

Script: `fasta_edits.sh`

```
# start the script with a for loop through the fasta files

$ for i in $(ls *fasta | sed 's/.fasta//g'); do bash fasta_edits.sh $i; done
```

- From each edited reference genome, MHC-I scaffolds/contigs, MHC-IIB 
  scaffolds/contigs, MHC-I+MHC-IIB scaffolds/contigs, and the rest of 
  the genome were extracted in fasta format

Script: `extract_contigs.sh`

```
# Add the path to the reference genome to the script and start the script
# with a for loop through the files listing the contigs for the different
# MHC regions and the remaining genome

$ for i in $(ls *txt | sed 's/.txt//g'); do bash extract_contigs.sh $i; done
```

## RepeatMasker

- RepeatMasker was run for each fasta file using a library of published,
  manually curated repeats (fAlb15_rm3.0_aves_hc.lib; provided by A. Suh) 
  containing Repbase repeats (Bao et al. 2015), repeats from chicken and 
  zebra finch (Hillier et al. 2004; Warren et al. 2010) and curated repeats 
  from hooded crow and flycatcher (Vijay et al. 2016; Suh et al. 2018)

Script: `repeatmasker_fAlb15_rm3.0_aves_hc.lib.sh`

```
# Start the script with a for loop through the different fasta files

$ for i in $(ls *.upper.shortHeaders.fasta); do sbatch repeatmasker_fAlb15_rm3.0_aves_hc.lib.sh $i; done
```

## Combine RepeatMasker results from all species and genome regions

- A python script was run to combine all RepeatMasker results tables
- The script requires the *.tbl files to be located in a specific directory, 
  to process them and writes the output to a whitespace-separated table
- Requires python 3.7.6 and pandas 1.2.3

Script: `parse_repeatmasker_tbl.py`

```
$ python3 parse_repeatmasker_tbl.py passerine_tbl/ passerines.txt
```
