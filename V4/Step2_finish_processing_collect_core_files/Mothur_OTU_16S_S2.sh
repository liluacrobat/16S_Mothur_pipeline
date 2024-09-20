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

$MOTHURPATH/mothur "#make.biom(shared=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.shared,constaxonomy=plate_16S.trim.contigs.good.unique.good.filter.unique.precluster.pick.agc.0.03.cons.taxonomy,output=simple)"

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
