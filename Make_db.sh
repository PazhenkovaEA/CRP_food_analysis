#!/bin/bash

# Usage: ./script_name.sh <marker> <primerF> <primerR> [-e <value>] [-l <value>] [-L <value>]

# Default values
error_rate=3
min_length=50
max_length=180

# Help message
function print_help() {
  echo "Usage: $0 <marker> <primerF> <primerR> [-e <value>] [-l <value>] [-L <value>]"
  echo
  echo "Arguments:"
  echo "  <marker>       Identifier for the marker (e.g., Mamm02)"
  echo "  <primerF>      Forward primer sequence"
  echo "  <primerR>      Reverse primer sequence"
  echo
  echo "Options:"
  echo "  -e <value>     Error rate (default: 3)"
  echo "  -l <value>     Minimum sequence length (default: 50)"
  echo "  -L <value>     Maximum sequence length (default: 180)"
  echo
  echo "Description:"
  echo "  This script runs a pipeline using OBITools for ecoPCR, filtering, and annotation."
  echo "  Input parameters include marker name, primer sequences, and optional thresholds."
  echo
  echo "Example:"
  echo "  $0 Mamm02 CGAGAAGACCCTRTGGAGCT CCGAGGTCRCCCCAACC -e 3 -l 50 -L 180"
}

# Parse arguments
if [[ $# -lt 3 ]]; then
  print_help
  exit 1
fi

marker=$1
primerF=$2
primerR=$3
shift 3

while [[ $# -gt 0 ]]; do
  case $1 in
    -e)
      error_rate=$2
      shift 2
      ;;
    -l)
      min_length=$2
      shift 2
      ;;
    -L)
      max_length=$2
      shift 2
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
done

# Paths and filenames
data_dir="/mnt/disk4/ncbi_filtered/base1/ncbi_last"
ec_pcr_output="${marker}_ncbi.ecopcr"
clean_fasta="${marker}_ncbi_clean.fasta"
uniq_fasta="${marker}_clean_uniq.fasta"
final_fasta="${marker}_clean_uniq_clean.fasta"
db_fasta="db_${marker}.fasta"

# Step 1: ecoPCR
singularity exec --bind /mnt/disk4:/mnt/disk4 obitools.simg \
  ecoPCR -d "$data_dir" -e "$error_rate" -l "$min_length" -L "$max_length" \
  "$primerF" "$primerR" > "$ec_pcr_output"

# Step 2: obigrep for species, genus, family
singularity exec --bind /mnt/disk4:/mnt/disk4 obitools.simg \
  obigrep -d "$data_dir" --require-rank=species --require-rank=genus --require-rank=family \
  "$ec_pcr_output" > "$clean_fasta"

# Step 3: obiuniq
singularity exec --bind /mnt/disk4:/mnt/disk4 obitools.simg \
  obiuniq -d "$data_dir" "$clean_fasta" > "$uniq_fasta"

# Step 4: obigrep for family
singularity exec --bind /mnt/disk4:/mnt/disk4 obitools.simg \
  obigrep -d "$data_dir" --require-rank=family "$uniq_fasta" > "$final_fasta"

# Step 5: obiannotate
singularity exec obitools.simg \
  obiannotate --uniq-id "$final_fasta" > "$db_fasta"

# Completion message
echo "Pipeline completed. Final database: $db_fasta"
