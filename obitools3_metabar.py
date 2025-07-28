import click
import os
import pandas as pd

@click.command()
@click.option("--project", help="Path to project folder")
@click.option("--library", help="Library name")
@click.option("--reads1", help="Forward .fastq reads. Filename, should be located in Project folder")
@click.option("--reads2", help="Reverse .fastq reads. Filename, should be located in Project folder")
@click.option("--primers", help="Primers for each locus, path to .csv file")


# before run the script, activate an environment: . ~/obitools3/obi3-env/bin/activate
def main(project, library, reads1, reads2, primers):
    #os.chdir(project)
    #"project" is a folder and "library" is an Illumina run name. Obi3 DMS will be named as "library"
    if not os.path.isfile(f"{project}/ngsfilters/{library}.ngsfilter"):
        print("ngsfilter file is not found.\n"
              f"File must be located in {project}/ngsfilters. Check create_ngsfilter.py output.")
        exit()
    print(f"Importing {reads1} to database")
    os.system(f"obi import --fastq-input {reads1} {project}/{library}/reads1")
    print(f"Importing {reads2} to database")
    os.system(f"obi import --fastq-input {reads2} {project}/{library}/reads2")
    # ADD a quality check for .ngsfilter file!

    # 3. Align paired-end reads and filter out unaligned reads
    os.system(f"obi alignpairedend -R {project}/{library}/reads2 {project}/{library}/reads1 {project}/{library}/aligned_reads")
    print(f"Alignment complete. Filter out unaligned sequences")
    
    
    os.system(f"obi stats -a {project}/{library}/aligned_reads")
    os.system(f"obi grep -p \"sequence['score_norm'] > 0.4\" {project}/{library}/aligned_reads {project}/{library}/good_sequences")
    # 4. Add ngsfilter to database and apply it to reads
    os.system(f"obi import --ngsfilter {project}/ngsfilters/{library}.ngsfilter {project}/{library}/ngsfilter")
    os.system(f"obi ngsfilter -t {project}/{library}/ngsfilter -u  {project}/{library}/unidentified_sequences {project}/{library}/good_sequences {project}/{library}/identified_sequences")
    
    primernames = pd.read_csv(primers)
    primernames = primernames[["locus", "primerF", "primerR"]].drop_duplicates()
    for loci in primernames.iloc[:, 0]:
        print(f"Proceeding locus {loci}")
        os.system(f"obi grep -a experiment:{loci} {project}/{library}/identified_sequences  {project}/{library}/{loci}")  # Split data
        os.system(f"obi uniq -m sample {project}/{library}/{loci} {project}/{library}/{loci}_uniq")  # Remove PCR duplicates
        os.system(f"obi annotate -k COUNT -k MERGED_sample --length {project}/{library}/{loci}_uniq {project}/{library}/{loci}_cleaned_metadata_sequences")
        os.system(f"obi grep -p \"sequence['COUNT']>1 and sequence['seq_length']>10\" {project}/{library}/{loci}_cleaned_metadata_sequences {project}/{library}/{loci}_denoised_sequences")
        os.system(f"obi clean -s MERGED_sample -r 0.5 -H {project}/{library}/{loci}_denoised_sequences {project}/{library}/{loci}_cleaned_sequences")
        os.system(f"obi export --fasta-output -o {project}/{loci}_{library}_grep_clean.fasta {project}/{library}/{loci}_cleaned_sequences")
    

if __name__ == '__main__':
    main()
