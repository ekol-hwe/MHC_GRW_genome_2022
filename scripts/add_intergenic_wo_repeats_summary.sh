#! /bin/bash -l
### Usage:
# $ bash add_intergenic_wo_repeats_summary.sh [INTERGENIC_BED] [INTERSECTION_INTERGENIC_BED] [REPEAT_INTERGENIC_SUMMARY_BED]

all=`echo $1 | sed 's/.bed//g'`
intersection=`echo $2 | sed 's/.bed//g'`
summary=`echo $3 | sed 's/.intergenic.summary.bed//g'`

# Extract all intergenic regions without repeat elements, convert to summary format
awk -F'\t' 'BEGIN {OFS = FS} {print $1, $2, $3}' ${intersection}.bed > ${intersection}.regions.bed &&
grep -v -f ${intersection}.regions.bed ${all}.bed | awk -F'\t' 'BEGIN {OFS = FS} {print $1, $2, $3, $1, $2, $3, $1, "0", "0", "NA", "0"}' > ${all}.noRepeats.summary.bed &&

# Concatenate and sort to get summary file with all intergenic regions
cat ${all}.noRepeats.summary.bed ${summary}.intergenic.summary.bed | sort -k1,1 -k2,2n > ${summary}.all_intergenic.summary.bed &&

# Calculate intergenic region lengths for each feature in the intergenic regions bed file, add length as extra column
awk -F'\t' 'BEGIN {OFS = FS} {print $1, $2, $3, $3-$2, $8, $9, $10, $11 }' ${summary}.all_intergenic.summary.bed > ${summary}.all_intergenic.summary.length.bed