# 16S_Mice_Mothur
Take JLT48 as an example
## Set path for samples
```bash
mkdir fastq
cd fastq 
cp ../../JLT48/*.gz .
for x in $(ls *.gz); do gunzip $s;done
```
## Extract samples
```bash
mkdir fastq
cd fastq 
cp ../
```
## Combine sample
```bash
module python/py38-anaconda-2020.11
conda create -c bioconda -m -p pyenvs/py35-snakemake python=3.5 pandas snakemake
```
