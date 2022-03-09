# Gene predictions on contigs with MHC-associated genes in other passerines

This workflow describes how gene annotations were made on contigs with MHC-associated genes in hooded crow, jackdaw and in zebra finch assemblies

## Gene prediction with augustus

Use augustus version 3.2.3 with chicken parameters on sequences in each assembly known to contain genes of interest. These contigs are:

Hooded Crow - 000220F, 000247F, 000278F
 
Jackdaw - 000195F, 000214F, 000245F, 000277F, 000380F

Zebra finch - MUGN01000057.1, MUGN01000310.1, MUGN01000910.1, MUGN01001045.1

```
augustus --strand=both --gff3=on --species=chicken <MHC sequences species>  >  <species>.gff 
```

## Functional annotation of gene models 

Extract protein sequences for each gene model using the `getAnnoFasta.pl` script that comes with augustus. Use blastp to search the protein of each gene against vertebrate swissprot proteins (N=86131,downloaded 20211118). For each gene we will pick the top hit

```
prefixes=$(ls *.gff | sed 's/.gff//')
for prefix in $prefixes
do
getAnnoFasta.pl $prefix.gff
blastp -num_threads 2 -query $prefix.aa -db swissprot_vertebrata_20211118.prot.fasta -evalue 1e-5 -outfmt 6 > $prefix.swissprot.blast.out
cat $prefix.swissprot.blast.out |  sort -u -k1,1 | cut -f1-2 | sed 's/[|]/\t/g;s/_/\t/g' | cut -f1,4 >  $prefix.swissprot.blast.filt.summary.out
done
```

Use the `change_gene_names_aug_models_gff3.pl` script to change names of the gene models based on the blast results. As input to the script we will use the original gff file and a tab-delimited list containing the old augustus and new swissprot-based gene name. Genes without any blast hits will be filtered out.

```
change_gene_names_aug_models_gff3.pl --aug_gff augustus_HC_MHCI_TRIM_TAP_contigs.mod.gff --name_list HC_new_gene_names.txt > augustus_HC_MHCI_TRIM_TAP_contigs.mod.renamed.gff
change_gene_names_aug_models_gff3.pl --aug_gff augustus_JD_MHCI_core_TRIM_TAP_contigs.mod.gff --name_list JD_new_gene_names.txt > augustus_JD_MHCI_core_TRIM_TAP_contigs.mod.renamed.gff
change_gene_names_aug_models_gff3.pl --aug_gff augustus.ZF_MHC_region_ab-nihitio-only.gff --name_list ZF_new_gene_names.txt > augustus.ZF_MHC_region_ab-nihitio-only.renamed.gff
```

