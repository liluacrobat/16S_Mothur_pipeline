#!/bin/bash -l
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --cluster=ub-hpc
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=120G
#SBATCH --job-name="Mothur"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=Mothur-pipeline.log
#SBATCH --mail-type=ALL

mkdir Mothur_processing
cd /projects/academic/pidiazmo/Projects/RT2977_MgPreventive/fastq

for x in $(ls *.gz); do gunzip $x;done

## Trime is optional
mkdir trimmed
for x in $(ls *_R1_001.fastq);do /projects/academic/pidiazmo/projectsoftwares/fastx/bin/fastx_trimmer -f 2 -i $x -o trimmed/$x;done
for x in $(ls *_R2_001.fastq);do /projects/academic/pidiazmo/projectsoftwares/fastx/bin/fastx_trimmer -f 2 -i $x -o trimmed/$x;done
cd ..

cd Mothur_processing # should have link to all fastq files

# Use ln -s ../fastq/*.fastq .   if no trimming
ln -s ../fastq/trimmed/*.fastq .

MOTHURPATH='/projects/academic/pidiazmo/projectsoftwares/mothur/v1.48.1'
$MOTHURPATH/mothur "#make.file(inputdir=., type=fastq, prefix=plate_16S)"

cd ..
