# MHC exon annotation

This script is used to create a GFF file from a tabular blast output file for the MHC genes class I, class II alpha and beta.

## File preparation

### Blastn short

The subject for the blast search is the assembly (in this example **mhc_contigs.fasta**). The MHC exon sequences (class I, class II alpha and beta) used as query come from Sanger sequencing (in this example **GRW_MHCI_exon_1-8_UTR_clone_cN2.fasta**). here the blast version was used was blast+ 2.6.0.

```
# create the blast database
# blast+ 2.6.0
makeblastdb -in mhc_contigs.fasta -dbtype nucl

# run blastn short
blastn -task blastn-short -db mhc_contigs.fasta -query GRW_MHCI_exon_1-8_UTR_clone_cN2.fasta -Out blastn-short_exons_mhc1_eval_e-02.tab -evalue 1e-02 -outfmt '6 qseqid sseqid qlen length qstart qend sstart send pident evalue sframe'
```

### Sort

The tabular output file needs to be sorted.

`sort -k2,2 -k7,7n blastn-short_exons_mhc1_eval_e-02.tab > sort_blastn-short_exons_mhc1_eval_e-02.tab`

## Run the script

`./make_gff_from_blast_hits.pl sort_blastn-short_exons_mhc1_eval_e-02.tab sort_blastn-short_exons_mhc1_eval_e-05.gff 10000`
