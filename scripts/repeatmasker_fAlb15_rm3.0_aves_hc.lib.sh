#! /bin/bash -l
#SBATCH -A snic2017-1-565
#SBATCH -p core -n 4
#SBATCH -t 1-00:00:00
#SBATCH -C usage_mail

### Repeat mask MHC regions and remaining genome separately from each other, 
# using a manually curated repeat library for birds

# Usage:
# $ for i in $(ls *.upper.shortHeaders.fasta); do sbatch repeatmasker_fAlb15_rm3.0_aves_hc.lib.sh $i; done

lib="fAlb15_rm3.0_aves_hc.lib"

module load bioinfo-tools RepeatMasker/4.0.7
RepeatMasker -pa 4 -a -xsmall -gccalc -dir ./ -lib ${lib} ${1}
