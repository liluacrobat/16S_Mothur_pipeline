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
Build the environment of Mothur
```
conda create -c bioconda -m -p /projects/academic/pidiazmo/projectsoftwares/mothur/v1.44.3 python=2.7.5 pandas
conda install -c bioconda mothur=1.44.3
```
Once the environment is built, we can directly load it without building the environment every time.
For the ease of using, a module file (mothur/1.44.3.lua)is created:
```
whatis([[ Mothur v1.44.3 ]])
prepend_path{"PATH","/projects/academic/pidiazmo/projectsoftwares/mothur/v1.44.3",delim=":",priority="0"}
prepend_path{"PATH","/projects/academic/pidiazmo/projectsoftwares/mothur/v1.44.3/blast/bin/",delim=":",priority="0"}
```
## Load environment
```
module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3
```
## Make files
Create the input files for make.contigs. Takes a input directory and creates a file containing the fastq or gz files in the directory.
The generated file may be named by the prefix. Depending on the version of Mothur, "paired" or "single" may be added to distingush the type of sequences.
```
mothur "#make.file(inputdir=., type=fastq, prefix=plate_16S)"
cp plate_16S.paired.files plate_16S.files
```

## Step 1: Make contigs
The make.contigs command reads a forward fastq file and a reverse fastq file and outputs new fasta and report files.
```
mothur "#make.contigs(file=plate_16S.files, bdiffs=1, pdiffs=2, processors=8)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.fasta, processors=8)" > contig_summary.txt
```
If the reverse sequences are in bad quality, trimming of the tail of the contigs may be necessary
```
mothur "#trim.seqs(fasta=plate_16S.trim.contigs.fasta, removelast=30, processors=8)"
#mothur "#summary.seqs(fasta=plate_16S.trim.contigs.trim.fasta, processors=8)" > trimming_summary.txt
```
## Step 2: Screen.seqs
The screen.seqs command enables you to keep sequences that fulfill certain user defined criteria. Furthermore, it enables you to cull those sequences not meeting the criteria from a names, group, contigsreport, alignreport and summary file. The group file is used to assign sequences to a specific group. It consists of 2 columns separated by a tab. The first column contains the sequence name. 

The length criteria can be determined as follows:
maxlength = sequence_length*2-20   
minimumlength=sequence_length-100
In the example, sequence_length=301.
```
mothur "#screen.seqs(fasta=plate_16S.trim.contigs.fasta, group=plate_16S.contigs.groups, maxambig=0, minlength=201, maxlength=582, processors=8)"
```

