# 16S_Mice_Mothur
Take plate JLT48 as an example.
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

## Step 1: make contigs
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
## Step 2: screen.seqs
The screen.seqs command enables you to keep sequences that fulfill certain user defined criteria. Furthermore, it enables you to cull those sequences not meeting the criteria from a names, group, contigsreport, alignreport and summary file. The group file is used to assign sequences to a specific group. It consists of 2 columns separated by a tab. The first column contains the sequence name. 

The length criteria can be determined as follows:
maxlength = sequence_length*2-20   
minimumlength=sequence_length-100
In the example, sequence_length=301.
```
mothur "#screen.seqs(fasta=plate_16S.trim.contigs.fasta, group=plate_16S.contigs.groups, maxambig=0, minlength=201, maxlength=582, processors=8)"
```
## Step 3: count.groups
Check how many reads are left per sample. The count.groups command counts sequences from a specific group or set of groups from the following file types: group, count or shared file.
```
mothur "#count.groups(group=plate_16S.contigs.good.groups)"
```
## Step 4: unique.seqs
The unique.seqs command returns only the unique sequences found in a fasta-formatted sequence file and a file that indicates those sequences that are identical to the reference sequence. Often times a collection of sequences will have a significant number of identical sequences. It sucks up considerable processing time to have to align, calculate distances, and cluster each of these sequences individually.
```
mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.fasta)"
```
## Step 5: count.seqs
This command counts the number of sequences represented by the representative sequence in a name file. If a group file is given, it will also provide the group count breakdown.
```
mothur "#count.seqs(name=plate_16S.trim.contigs.good.names, group=plate_16S.contigs.good.groups)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, count=plate_16S.trim.contigs.good.count_table, processors=8)" > contig_filtered_summary.txt
```
## Step 6: align.seqs
The align.seqs command aligns a user-supplied fasta-formatted candidate sequence file to a user-supplied fasta-formatted template alignment. The general approach is to i) find the closest template for each candidate using kmer searching, blastn, or suffix tree searching; ii) to make a pairwise alignment between the candidate and de-gapped template sequences using the Needleman-Wunsch, Gotoh, or blastn algorithms; and iii) to re-insert gaps to the candidate and template pairwise alignments using the NAST algorithm so that the candidate sequence alignment is compatible with the original template alignment. Make sure to download the latest version of these reference files (https://mothur.org/wiki/Silva_reference_files). The mothur developers have noticed some weird results using Silva v138/v138.1 of the SEED alignment relative to previous versions of the alignment. This is most likely because it is smaller than previous versions. Here we are sticking with the v132 version of the SEED database for alignments.
```
mothur "#align.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, reference=../silva.seed_v132/silva.seed_v132.align, processors=8)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, processors=8)">align_summary.txt
```




