# Mothur pipeline of clustering 16S rRNA sequences into OTUs
```
for x in (ls *.fastq);do /projects/academic/pidiazmo/projectsoftwares/fastx/bin/fastx_trimmer -f 15 -i $x -o trim15/$x 
```
## Specific steps
### Run in CCR
Use sbatch XXXX.sh to submit the job
The head of the shell file could be:
```
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
```
More details: https://ubccr.freshdesk.com/support/solutions/articles/13000076253-requesting-specific-hardware-in-batch-jobs.
### Load environment
```
module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3
```
### Screen sequence quality and make a list of sequence files
Trimming is optional.
```
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

```

### Step 2: Processing until alignment
```
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

## Step 1
MOTHURPATH='/projects/academic/pidiazmo/projectsoftwares/mothur/v1.48.1'
# Making contigs
$MOTHURPATH/mothur "#make.contigs(file=plate_16S.files, bdiffs=1, pdiffs=2)"
#Output File Names:
#plate_16S.trim.contigs.fasta
#plate_16S.scrap.contigs.fasta
#plate_16S.contigs_report
#plate_16S.contigs.count_table

$MOTHURPATH/mothur "#count.groups(count=plate_16S.contigs.count_table)" > contig_group.txt
#Output File Names:
#plate_16S.contigs.count.summary

# Summarizing the contigs
$MOTHURPATH/mothur "#summary.seqs(fasta=plate_16S.trim.contigs.fasta, processors=12)" > contig_summary.txt

# Filtering by length
$MOTHURPATH/mothur "#screen.seqs(fasta=plate_16S.trim.contigs.fasta, maxambig=0, minlength=150, processors=12)"
#Output File Names:
#plate_16S.trim.contigs.good.fasta
#plate_16S.trim.contigs.bad.accnos

# Merge contigs to unique sequences
$MOTHURPATH/mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.fasta,count=plate_16S.contigs.count_table)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.fasta
#plate_16S.trim.contigs.good.count_table

$MOTHURPATH/mothur "#count.groups(count=plate_16S.trim.contigs.good.count_table)" >  filter1_contig_group.txt
#Output File Names:
#plate_16S.trim.contigs.good.count.summary

# Summarizing the contigs after filtering
$MOTHURPATH/mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, count=plate_16S.trim.contigs.good.count_table, processors=12)" > contig_filtered_summary.txt

# Align contigs to the 16S reference
$MOTHURPATH/mothur "#align.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, reference=/projects/academic/pidiazmo/16S_Database/Silva/silva_v132/silva.seed_v132.align)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.align
#plate_16S.trim.contigs.good.unique.align_report
#plate_16S.trim.contigs.good.unique.flip.accnos

# Summarizing alignment
$MOTHURPATH/mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, processors=12)">align_summary.txt

```
### Step 2: Mothur processing
Modify start and end parameter based on alignment_summary obtained from step 1
```
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

MOTHURPATH='/projects/academic/pidiazmo/projectsoftwares/mothur/v1.48.1'

## Step 2
$MOTHURPATH/mothur "#screen.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, summary=plate_16S.trim.contigs.good.unique.summary, start=6389, end=25300, maxhomop=10)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.summary
#plate_16S.trim.contigs.good.unique.good.align
#plate_16S.trim.contigs.good.unique.bad.accnos
#plate_16S.trim.contigs.good.good.count_table

# Summarizing sequences filted by alignment
$MOTHURPATH/mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align, count=plate_16S.trim.contigs.good.good.count_table)">align_filtered_summary.txt

# Remove redundant bases
$MOTHURPATH/mothur "#filter.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align, vertical=T, trump=.)"
#Output File Names:
#plate_16S.filter
#plate_16S.trim.contigs.good.unique.good.filter.fasta

# Remove redundancy across sequences induced by trimming the ends
$MOTHURPATH/mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.fasta, count=plate_16S.trim.contigs.good.good.count_table)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.fasta
#plate_16S.trim.contigs.good.unique.good.filter.count_table

# Pre-clustering
$MOTHURPATH/mothur "#pre.cluster(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.count_table, diffs=2)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.map

$MOTHURPATH/mothur "#count.groups(count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table)" >  precluster_group.txt

$MOTHURPATH/mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table)" > precluster_summary.txt

# Chimera removal
$MOTHURPATH/mothur "#chimera.uchime(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table, dereplicate=t)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.chimeras

$MOTHURPATH/mothur "#remove.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, accnos=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta

$MOTHURPATH/mothur "#remove.seqs(count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table, accnos=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.count_table



mv plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.count_table plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table

$MOTHURPATH/mothur "#count.groups(count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table)" >  Chimera_removal_group.txt


$MOTHURPATH/mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, processors=12)">seqs_w_chimera_removed_summary.txt

REF_FA=/projects/academic/pidiazmo/16S_Database/HOMD/eHOMD15.23/HOMD_16S_rRNA_RefSeq_V15.23.fasta
REF_TAX=/projects/academic/pidiazmo/16S_Database/HOMD/eHOMD15.23/HOMD_16S_rRNA_RefSeq_V15.23.mothur.nameChanged.taxonomy

$MOTHURPATH/mothur "#classify.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, reference=$REF_FA, taxonomy=$REF_TAX)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.nameChanged.wang.taxonomy
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.nameChanged.wang.tax.summary

$MOTHURPATH/mothur "#cluster(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table,method=agc,cutoff=0.03)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.list

$MOTHURPATH/mothur "#make.shared(list=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.list, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, label=0.03)"
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.mothurGroup.count_table
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.shared

# Assign taxonomy
$MOTHURPATH/mothur "#classify.otu(list=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.list, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, taxonomy=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.nameChanged.wang.taxonomy, label=0.03)" #Taxonomy name depends on the database used
#Output File Names:
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.cons.taxonomy
#plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.cons.tax.summary

$MOTHURPATH/mothur "#make.biom(shared=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.shared,constaxonomy=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.cons.taxonomy)"

mkdir otu_table

cd otu_table
cp ../plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.biom .
module load gcc/11.2.0  openmpi/4.1.1
module load biom-format/2.1.12
biom convert -i plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.biom -o plate_16S.OTU.txt --to-tsv --table-type "OTU table" --header-key taxonomy
sed -i '1d' plate_16S.OTU.txt
cd ..

mkdir core_files
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.list core_files/.
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table core_files/.
cp *.taxonomy core_files/.
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.shared core_files/.
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.biom core_files/.
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta core_files/.

mkdir core_files/logs
cp *.summary core_files/logs/.
cp *.log core_files/logs/.
cp *.txt core_files/logs/.
cp *.logfile core_files/logs/.
cp *.sh core_files/logs/.
mv otu_table core_files/.

```

### Step 3: summarize the table into different levels using Matlab and QIIME
In matlab run main_reorganize_tax.m to reformate the taxonomy name, then use QIIME to summarize the table into different levels
```
module load R/3.1.2
module load qiime/1.9.1

cp plate_16S.OTU.txt plate_16S.OTU.raw.txt
cp plate_16S.OTU.biom plate_16S.OTU.raw.biom
rm plate_16S.OTU.biom
cp plate_16S.OTU.reformated.txt plate_16S.OTU.txt

biom convert -i plate_16S.OTU.txt -o plate_16S.OTU.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy

summarize_taxa.py -i plate_16S.OTU.biom -o tax_mapping_counts/ -L 2,3,4,5,6,7 -a
summarize_taxa.py -i plate_16S.OTU.biom -o tax_mapping_rel/ -L 2,3,4,5,6,7
```
