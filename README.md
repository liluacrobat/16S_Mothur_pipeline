# 16S_Mice_Mothur
Take JLT48 as an example
## Set path and extract samples 
```bash
mkdir fastq
cd fastq 
cp ../../JLT48/*.gz .
for x in $(ls *.gz); do gunzip $x;done
```
## Extract samples
```bash
mkdir fastq
cd fastq 
cp ../
```
## Create environment
```bash
module python/py38-anaconda-2020.11
conda create -c bioconda -m -p pyenvs/py35-snakemake python=3.5 pandas snakemake
```
## Step 1: Make contig and align sequences
```
module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3

cd fastq
mothur "#make.file(inputdir=., type=fastq, prefix=plate_16S)"
mothur "#make.contigs(file=plate_16S.files, bdiffs=1, pdiffs=2, processors=12)"
cd ..
mkdir Step1_make_contig
cd Step1_make_contig
mv ../fastq/*.logfile .
mv ../fastq/*.fasta .
mv ../fastq/*.qual .
mv ../fastq/*.report .
```
