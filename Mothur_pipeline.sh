#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --job-name="Mothur"
#SBATCH --output=Mothur.log

module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3

REF_FA=Greengene/13.8/gg_13_8_99.fasta
REF_TAX=Greengene/13.8/gg_13_8_99.gg.tax

cd fastq
#mothur "#make.file(inputdir=., type=fastq, prefix=plate_16S)"
#cp plate_16S.paired.files plate_16S.files
mothur "#make.contigs(file=plate_16S.files, bdiffs=1, pdiffs=2, processors=8)"
cd ..
mkdir Step1_make_contig
cd Step1_make_contig
mv ../fastq/*.logfile .
mv ../fastq/*.fasta .
mv ../fastq/*.report .
mv ../fastq/*.groups .
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.fasta, processors=8)" > contig_summary.txt
cd ..
## Optional if the header of reverse sequences are in low quality
#mkdir Trimming
#cd Trimming
#ln -s ../Step1_make_contig/plate_16S.trim.contigs.fasta .
#mothur "#trim.seqs(fasta=plate_16S.trim.contigs.fasta, removelast=30, processors=8)"
#mothur "#summary.seqs(fasta=plate_16S.trim.contigs.trim.fasta, processors=8)" > trimming_summary.txt
#cd ..
#cd Step1_make_contig
#rm plate_16S.trim.contigs.fasta
#cp ../Trimming/plate_16S.trim.contigs.trim.fasta plate_16S.trim.contigs.fasta
#cp ../Trimming/trimming_summary.txt .
#cd ..
mkdir Step2_screen_seqs
cd Step2_screen_seqs
ln -s ../Step1_make_contig/plate_16S.trim.contigs.fasta .
ln -s ../Step1_make_contig/plate_16S.contigs.groups .
# maxlength = sequence_length*2-20   minimumlength=sequence_length-100, here sequence_length=301
mothur "#screen.seqs(fasta=plate_16S.trim.contigs.fasta, group=plate_16S.contigs.groups, maxambig=0, minlength=201, maxlength=582, processors=8)"
cd ..
mkdir Step3_count_groups
cd Step3_count_groups
ln -s ../Step2_screen_seqs/plate_16S.contigs.good.groups .
mothur "#count.groups(group=plate_16S.contigs.good.groups)"
cd ..
mkdir Step4_unique_seqs
cd Step4_unique_seqs
ln -s ../Step2_screen_seqs/plate_16S.trim.contigs.good.fasta .
mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.fasta)"
cd ..
mkdir Step5_count_seqs
cd Step5_count_seqs
ln -s ../Step3_count_groups/plate_16S.contigs.good.groups .
ln -s ../Step4_unique_seqs/plate_16S.trim.contigs.good.unique.fasta .
ln -s ../Step4_unique_seqs/plate_16S.trim.contigs.good.names .
mothur "#count.seqs(name=plate_16S.trim.contigs.good.names, group=plate_16S.contigs.good.groups)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, count=plate_16S.trim.contigs.good.count_table, processors=8)" > contig_filtered_summary.txt
cd ..
mkdir Step6_align_seqs
cd Step6_align_seqs
ln -s ../Step4_unique_seqs/plate_16S.trim.contigs.good.unique.fasta .
ln -s ../Step5_count_seqs/plate_16S.trim.contigs.good.count_table .
mothur "#align.seqs(fasta=plate_16S.trim.contigs.good.unique.fasta, reference=../silva.seed_v132/silva.seed_v132.align, processors=32)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, processors=8)">align_summary.txt
cd ..
mkdir Step7_screen_seqs
ln -s ../Step6_align_seqs/plate_16S.trim.contigs.good.unique.align .
ln -s ../Step5_count_seqs/plate_16S.trim.contigs.good.count_table .
ln -s ../Step6_align_seqs/plate_16S.trim.contigs.good.unique.summary .
mothur "#screen.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, summary=plate_16S.trim.contigs.good.unique.summary, start=6388, end=25316, maxhomop=8, processors=8)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align count=plate_16S.trim.contigs.good.good.count_table, processors=8)">align_filtered_summary.txt
cd ..
mkdir Step8_filter_seqs
ln -s ../Step7_screen_seqs/plate_16S.trim.contigs.good.unique.good.align
mothur "#filter.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align, vertical=T, trump=., processors=8)"
cd ..
mkdir Step9_unique_seqs
ln -s ../Step8_filter_seqs/plate_16S.trim.contigs.good.unique.good.filter.fasta .
ln -s ../Step8_filter_seqs/plate_16S.trim.contigs.good.good.count_table .
mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.fasta, count=plate_16S.trim.contigs.good.good.count_table)"
cd ..
mkdir Step10_pre_cluster
ln -s ../Step9_unique_seqs/plate_16S.trim.contigs.good.unique.good.filter.unique.fasta .
ln -s ../Step9_unique_seqs/plate_16S.trim.contigs.good.unique.good.filter.count_table
mothur "#pre.cluster(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.count_table, diffs=2, processors=8)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table)"
cd ..
mkdir Step11_chimera_uchime
ln -s ../Step10_pre_cluster/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta .
ln -s ../Step10_pre_cluster/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table .
mothur "#chimera.uchime(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table, dereplicate=t, processors=8)"
cd ..
mkdir Step12_remove_seqs
ln -s ../Step11_chimera_uchime/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta .
ln -s ../Step11_chimera_uchime/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos .
mothur "#remove.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, accnos=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, processors=8)">seqs_w_chimera_removed_summary.txt
cd ..
mkdir Step13_count_groups
ln -s ../Step12_remove_seqs/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table .
mothur "#count.groups(count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table)"
cd ..
mkdir Step14_classify_seqs_RDP
ln -s ../Step12_remove_seqs/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta .
mothur "#classify.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, reference=$REF_FA, taxonomy=$REF_TAX, cutoff=80)"
cd ..
mkdir Step14_classify_seqs_NN
ln -s ../Step12_remove_seqs/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta .
mothur "#classify.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, reference=$REF_FA, taxonomy=$REF_TAX, method=knn, numwanted=1)"
cd ..
mkdir Step15_clustering
ln -s ../Step12_remove_seqs/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta .
ln -s ../Step12_remove_seqs/plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table .
mothur "#dist.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta, cutoff=0.03)"
mothur "#cluster(column=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.dist, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table)"
cd ..
#mkdir Step16_make_shared
#ln -s ../Step15_clustering/
#mothur "#make.shared(list=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.an.unique_list.list, count=example_R2_001.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table, label=0.03)"
#


