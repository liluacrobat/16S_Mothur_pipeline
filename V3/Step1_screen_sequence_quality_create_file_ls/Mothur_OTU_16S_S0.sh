#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=30000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="Mothur-S0"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=Mothur-S0.log
#SBATCH --mail-type=ALL

mkdir Mothur_processing
cd fastq
for x in $(ls *.gz); do gunzip $x;done

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/minion
mkdir fastqc
fastqc -o fastqc *.fastq
cd fastqc
multiqc .
cd ..

module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3
mothur "#make.file(inputdir=., type=fastq, prefix=plate_16S)"
cd ..
cd Mothur_processing
ln -s ../fastq/*.fastq .
cd ..
