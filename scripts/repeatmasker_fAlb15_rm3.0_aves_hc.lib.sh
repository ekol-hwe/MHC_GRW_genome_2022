#! /bin/bash -l
#SBATCH -A snic2017-1-565
#SBATCH -p core -n 4
#SBATCH -t 1-00:00:00
#SBATCH -C usage_mail

# Usage:
# $ sbatch repeatmasker_fAlb15_rm3.0_aves_hc.lib.sh [EDITED_FASTA]

lib="fAlb15_rm3.0_aves_hc.lib" # path to repeat library

module load bioinfo-tools RepeatMasker/4.0.7
RepeatMasker -pa 4 -a -xsmall -gccalc -dir ./ -lib ${lib} ${1}
