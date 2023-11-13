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

mothur "#screen.seqs(fasta=plate_16S.trim.contigs.good.unique.align, count=plate_16S.trim.contigs.good.count_table, summary=plate_16S.trim.contigs.good.unique.summary, start=6402, end=25292, maxhomop=10)"

mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align, count=plate_16S.trim.contigs.good.good.count_table)">align_filtered_summary.txt

mothur "#filter.seqs(fasta=plate_16S.trim.contigs.good.unique.good.align, vertical=T, trump=.)"
#
mothur "#unique.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.fasta, count=plate_16S.trim.contigs.good.good.count_table)"

mothur "#pre.cluster(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.count_table, diffs=2)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table)"

mothur "#chimera.uchime(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.count_table, dereplicate=t)"

mothur "#remove.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.fasta, accnos=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos)"
mothur "#summary.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, processors=12)">seqs_w_chimera_removed_summary.txt

mothur "#count.groups(count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table)"

REF_FA=/projects/academic/pidiazmo/16S_Database/HOMD_GTDB_Combined/GTDB_v202_HOMD_15_22_combined.fa
REF_TAX=/projects/academic/pidiazmo/16S_Database/HOMD_GTDB_Combined/GTDB_v202_HOMD_15_22_combined_02_17_2023.tax

mothur "#classify.seqs(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, reference=$REF_FA, taxonomy=$REF_TAX)"

mothur "#cluster(fasta=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table,method=agc,cutoff=0.03)"

mothur "#make.shared(list=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.list, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, label=0.03)"
mothur "#classify.otu(list=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.list, count=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, taxonomy=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.GTDB_v202_HOMD_15_22_combined_02_17_2023.wang.taxonomy, label=0.03)" #Taxonomy name depends on the database used
mothur "#make.biom(shared=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.shared,constaxonomy=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.cons.taxonomy)"

mkdir otu_table
cd otu_table
cp ../plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.biom .
module load qiime2
biom convert -i plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.biom -o plate_16S.OTU.txt --to-tsv --table-type "OTU table" --header-key taxonomy

sed -i '1d' plate_16S.OTU.txt

cd ..

mkdir core_files
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.list core_files/
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table core_files/
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.GTDB_v202_HOMD_15_22_combined_02_17_2023.wang.taxonomy core_files/
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.shared core_files/
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.cons.taxonomy core_files/
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.biom core_files/
cp plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta core_files/

mkdir core_files/logs
cp *.log core_files/logs/
cp *.txt core_files/logs/
cp *.logfile core_files/logs/
cp *.sh core_files/logs/
cp otu_table core_files/otu_table -r

