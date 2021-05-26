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
## Load environment
```
module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3
```
