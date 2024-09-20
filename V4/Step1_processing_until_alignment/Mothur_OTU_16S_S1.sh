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
