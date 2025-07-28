# CRP_food_analysis
Scripts for the bioinformatics analysis of the sequence data and food sample composition based on DNA metabarcoding.

## Create reference database.
The script requires OBITools2 Singularity container (https://github.com/Grelot/bioinfo_singularity_recipes/tree/master) and NCBI database, converted to the ecopcrDB format. These two pathes are hard-coded and must be changed within the script.

Example of usage:
 ./Make_db.sh Tele04 GTGCCAGCCACCGCGGTT GTGGGGTATCTAATCCCAGTTTG -e 3 -l 100 -L 300
 
 Arguments: Marker name, primerF, primerR, number of errors allowed, minimum length, max length.
 
## Demuptiplex reads

Requires OBITools3 installed and activated.

Example of usage:
python obitools3_metabar.py --project=./DAB192 --library=DAB192 --reads1=./DAB192/ReadsF.fastq.gz --reads2=./ReadsR.fastq.gz --primers=./primers_tags/primersMetabar.csv 

## Taxa identification

Requires OBITools2 installed and activated.

Example of usage:
./ecotag_obi2.sh Tele04 DAB192 90 db_Tele04.fasta

## Filtering

R Markdown file "1_report_Mamm02_templ.Rmd" can serve as a template for filtering procedure.

