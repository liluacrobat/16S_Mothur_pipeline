#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=30000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="Mothur-pipeline"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=Mothur-pipeline.log
#SBATCH --mail-type=ALL

module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3

mothur "#make.contigs(file=plate_16S.files, bdiffs=1, pdiffs=2)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.fasta, processors=32)" > contig_summary.txt

mothur "#screen.seqs(fasta=plate_16S.trim.contigs.fasta, group=plate_16S.contigs.groups, maxambig=0, minlength=150, processors=32)"
mothur "#count.groups(group=plate_16S.contigs.good.groups)"

mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.fasta)"

mothur "#count.seqs(name=plate_16S.trim.contigs.good.names, group=plate_16S.contigs.good.groups)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, count=plate_16S.trim.contigs.good.count_table, processors=32)" > contig_filtered_summary.txt

mothur "#align.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, reference=/projects/academic/pidiazmo/16S_Database/Silva/silva_v132/silva.seed_v132.align)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, processors=32)">align_summary.txt

