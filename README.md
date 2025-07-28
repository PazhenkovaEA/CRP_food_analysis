# CRP_food_analysis
Scripts for the bioinformatics analysis of the sequence data and food sample composition based on DNA metabarcoding.

## Create reference database.
The script requires OBITools2 Singularity container (https://github.com/Grelot/bioinfo_singularity_recipes/tree/master) and NCBI database, converted to the ecopcrDB format. These two pathes are hard-coded and must be changed within the script.

Example of usage:
 ./Make_db.sh Tele04 GTGCCAGCCACCGCGGTT GTGGGGTATCTAATCCCAGTTTG -e 3 -l 100 -L 300
 
 Arguments: Marker name, primerF, primerR, number of errors allowed, minimum length, max length.
 
