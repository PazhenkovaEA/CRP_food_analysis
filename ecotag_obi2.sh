#!/bin/bash

# Usage: script.sh <marker> <library> <filter_length> <database>
# Example: ./script.sh Mamm02 DAB128 45 ./DB/db_Mamm02_genbank249.fasta

# Input arguments
MARKER=$1
LIBRARY=$2
FILTER_LENGTH=$3
DATABASE=$4

# Define paths
INPUT_FASTA="./${LIBRARY}/${MARKER}_${LIBRARY}_grep_clean.fasta"
CLEAN_FASTA="./${LIBRARY}/${MARKER}_${LIBRARY}_clean.fasta"
GREP_CLEAN_FASTA="./${LIBRARY}/${MARKER}_${LIBRARY}_grep_clean1.fasta"
ECOTAG_FASTA="./${LIBRARY}/${MARKER}_${LIBRARY}_ecotag.fas"
ANNOTATED_FASTA="./${LIBRARY}/${MARKER}_${LIBRARY}_ecotag_annot.fas"
ANNOTATED_TAB="./${LIBRARY}/${MARKER}_${LIBRARY}_ecotag_annot.tab"
FINAL_TAB="./${LIBRARY}/${MARKER}_${LIBRARY}_${MARKER}.tab"

# Run obigrep
obigrep -l "$FILTER_LENGTH" "$INPUT_FASTA" --fasta-output > "$CLEAN_FASTA"

# Run obiannotate
obiannotate -R "COUNT:count" "$CLEAN_FASTA" > "$GREP_CLEAN_FASTA"

# Run ecotag
ecotag -d /mnt/disk4/ncbi_filtered/base1/ncbi_last -R "$DATABASE" -r "$GREP_CLEAN_FASTA" > "$ECOTAG_FASTA"

# Run obiannotate for taxonomy annotation
obiannotate --delete-tag=father --delete-tag=fathers --delete-tag=clean "$ECOTAG_FASTA" | \
obiannotate -d /mnt/disk4/ncbi_filtered/base1/ncbi_last -S path:'":".join([str(x[3])+"@"+taxonomy.getRank(x[0]) for x in taxonomy.parentalTreeIterator(taxid)][::-1])' \
> "$ANNOTATED_FASTA"

# Convert to table format
obitab -o "$ANNOTATED_FASTA" > "$ANNOTATED_TAB"

# Clean up tab file
sed 's/MERGED_//g' "$ANNOTATED_TAB" > "$FINAL_TAB"

echo "Processing complete. Output saved in $FINAL_TAB"
