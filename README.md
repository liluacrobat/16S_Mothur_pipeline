# Mothur pipeline of clustering 16S rRNA sequences into OTUs
Take plate JLT48 as an example.
## Set path and extract samples 
Replace "dir2plate" with the absolute path to the folder of sequences.
```bash
mkdir fastq
cd fastq 
cp dir2plate/*.gz .
for x in $(ls *.gz); do gunzip $x;done
```
## Create environment
Build the environment of Mothur
```
conda create -c bioconda -m -p /projects/academic/pidiazmo/projectsoftwares/mothur/v1.44.3 python=2.7.5 pandas
conda install -c bioconda mothur=1.44.3
```
Once the environment is built, we can directly load it without building the environment every time.
For the ease of using, a module file (mothur/1.44.3.lua) is created:
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
The **make.contigs** command reads a forward fastq file and a reverse fastq file and outputs new fasta and report files.
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
The **screen.seqs** command enables you to keep sequences that fulfill certain user defined criteria. Furthermore, it enables you to cull those sequences not meeting the criteria from a names, group, contigsreport, alignreport and summary file. The group file is used to assign sequences to a specific group. It consists of 2 columns separated by a tab. The first column contains the sequence name. 

The length criteria can be determined as follows:
maxlength = sequence_length*2-20   
minimumlength=sequence_length-100
In the example, sequence_length=301.
```
mothur "#screen.seqs(fasta=plate_16S.trim.contigs.fasta, group=plate_16S.contigs.groups, maxambig=0, minlength=201, maxlength=582, processors=8)"
```
## Step 3: count.groups
Check how many reads are left per sample. The **count.groups** command counts sequences from a specific group or set of groups from the following file types: group, count or shared file.
```
mothur "#count.groups(group=plate_16S.contigs.good.groups)"
```
## Step 4: unique.seqs
The **unique.seqs** command returns only the unique sequences found in a fasta-formatted sequence file and a file that indicates those sequences that are identical to the reference sequence. Often times a collection of sequences will have a significant number of identical sequences. It sucks up considerable processing time to have to align, calculate distances, and cluster each of these sequences individually.
```
mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.fasta)"
```
## Step 5: count.seqs
The **count.seqs** command counts the number of sequences represented by the representative sequence in a name file. If a group file is given, it will also provide the group count breakdown.
```
mothur "#count.seqs(name=plate_16S.trim.contigs.good.names, group=plate_16S.contigs.good.groups)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, count=plate_16S.trim.contigs.good.count_table, processors=8)" > contig_filtered_summary.txt
```
## Step 6: align.seqs
The **align.seqs** command aligns a user-supplied fasta-formatted candidate sequence file to a user-supplied fasta-formatted template alignment. The general approach is to i) find the closest template for each candidate using kmer searching, blastn, or suffix tree searching; ii) to make a pairwise alignment between the candidate and de-gapped template sequences using the Needleman-Wunsch, Gotoh, or blastn algorithms; and iii) to re-insert gaps to the candidate and template pairwise alignments using the NAST algorithm so that the candidate sequence alignment is compatible with the original template alignment. Make sure to download the latest version of these reference files (https://mothur.org/wiki/Silva_reference_files). The mothur developers have noticed some weird results using Silva v138/v138.1 of the SEED alignment relative to previous versions of the alignment. This is most likely because it is smaller than previous versions. Here we are sticking with the v132 version of the SEED database for alignments.
```
mothur "#align.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, reference=../silva.seed_v132/silva.seed_v132.align, processors=8)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, processors=8)">align_summary.txt
```
## Step 7: screen.seqs
The **screen.seqs** command enables you to keep sequences that fulfill certain user defined criteria. Furthermore, it enables you to cull those sequences not meeting the criteria from a names, group, contigsreport, alignreport and summary file.
**start & end**
You may have noticed that when you make an alignment there are some sequences that do not align in the same region as most of the sequences that you are analyzing. Here we cull the sequences aligned to v3-v4 region.
**maxhomop**
While we don't necessarily know the longest acceptable homopolymer for a 16S rRNA gene, the max length of 31 is clearly a sequencing artifact. If you are interested in removing sequences with excessively long homopolymers, then you should use the maxhomop option.
```
mothur "#screen.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, summary=plate_16S.trim.contigs.good.unique.summary, start=6388, end=25316, maxhomop=8, processors=8)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align count=plate_16S.trim.contigs.good.good.count_table, processors=8)">align_filtered_summary.txt
```
## Step 8: filter.seqs
Next, we need to filter our alignment so that all of our sequences only overlap in the same region and to remove any columns in the alignment that don't contain data. We do this by running the filter.seqs command. **filter.seqs** removes columns from alignments based on a criteria defined by the user. For example, alignments generated against reference alignments (e.g. from RDP, SILVA, or greengenes) often have columns where every character is either a '.' or a '-'. These columns are not included in calculating distances because they have no information in them. By removing these columns, the calculation of a large number of distances is accelerated. Also, people also like to mask their sequences to remove variable regions using a soft or hard mask (e.g. Lane's mask). This type of masking is only encouraged for deep-level phylogenetic analysis, not fine level analysis such as that needed with calculating OTUs.
**vertical**
By default vertical option is set to T, and any column that only contains gap characters (i.e. '-' or '.') is ignored.
**trump**
The trump option will remove a column if the trump character is found at that position in any sequence of the alignment. You can use any character with the trump setting ('.', '-', 'N', etc). NOTE: having one or two sequences included that don't align with the bulk of your sequences may lead to all columns being removed by the trump option!

In this command trump=. will remove any column that has a "." character, which indicates missing data. The vertical=T option will remove any column that contains exclusively gaps.
```
mothur "#filter.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align, vertical=T, trump=., processors=8)"
```
## Step 9: unique.seqs
Get the unique sequences after alignment.
```
mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.fasta, count=plate_16S.trim.contigs.good.good.count_table)"
```
## Step 10: pre.cluster
The **pre.cluster** command implements a pseudo-single linkage algorithm with the goal of removing sequences that are likely due to pyrosequencing errors.
The final step we can take to reduce our sequencing error is to use the pre.cluster command to merge sequence counts that are within 2 bp of a more abundant sequence. As a rule of thumb we use a difference of 1 bp per 100 bp of sequence length. This implementation of the command will split the sequences by group and then within each group it will pre-cluster those sequences that are with 1 or 2 bases of a more abundant sequence. 
```
mothur "#pre.cluster(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.count_table, diffs=2, processors=8)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table)"
```
## Step 11: chimera.uchime
The **chimera.uchime** command reads a fasta file and reference file and outputs potentially chimeric sequences.
**dereplicate**
The dereplicate parameter can be used when checking for chimeras by group. If the dereplicate parameter is false, then if one group finds the sequence to be chimeric, then all groups find it to be chimeric, default=f. The default setting is a bit aggressive since we’ve seen rare sequences get flagged as chimeric when they’re the most abundant sequence in another sample. It is suggested to set dereplicate=t.
```
mothur "#chimera.uchime(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table, dereplicate=t, processors=8)"
```
## Step 12: remove.seqs
The **remove.seqs** command takes a list of sequence names and either a fastq, fasta, name, group, list, count or align.report file to generate a new file that does not contain the sequences in the list. Here this command is used to removed chimaeric reads.
```
mothur "#remove.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, accnos=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, processors=8)">seqs_w_chimera_removed_summary.txt
```
## Step 13: count.groups
Need to count the sequences in the file obtained after chimaera removal, to see how many we have left.
```
mothur "#count.groups(count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table)"
```
## Step 14: classify.seqs
Set path to the reference database
```
REF_FA=Greengene/13.8/gg_13_8_99.fasta
REF_TAX=Greengene/13.8/gg_13_8_99.gg.tax
```
Choose one way to assign taxonomy to the sequences: RDP or nearest neighbor (NN).

Classify sequences using RDP classifier:
```
mothur "#classify.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, reference=$REF_FA, taxonomy=$REF_TAX, cutoff=80)"
```
Classify sequences using NN classifier:
```
mothur "#classify.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, reference=$REF_FA, taxonomy=$REF_TAX, method=knn, numwanted=1)"
```
## Step 15: OTU clustering
Now we have a couple of options for clustering sequences into OTUs. For a dataset with a small number of unique sequences, we can do the traditional approach using **dist.seqs** and **cluster**:
```
mothur "#dist.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta, cutoff=0.03)"
mothur "#cluster(column=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.dist, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table)"
```
The alternative is to use **cluster.split** command. In this approach, the taxonomic information is used to split the sequences into bins and then cluster within each bin.  Please replace "plate_16S.taxonomy" with the taxonomy file generated in Step 14.
** cluster**
The cluster parameter allows you to indicate whether you want to run the clustering or just split the distance matrix, default=T. The cluster=f option is used with the file option. This can be helpful when you have a large dataset that you may be able to use all your processors for the splitting step, but have to reduce them for the cluster step due to RAM constraints. 
```
mothur "#cluster.split(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table, taxonomy=plate_16S.taxonomy, splitmethod=classify, taxlevel=4, cutoff=0.03,cluster=f, processors=8)
mothur "#cluster.split(file=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.file, processors=4)"
```
## Step 16: make.shared



