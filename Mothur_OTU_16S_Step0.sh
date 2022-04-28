mkdir Mothur_processing
cd fastq
for x in $(ls *.gz); do gunzip $x;done

module use /projects/academic/pidiazmo/projectmodules
module load mothur/1.44.3
mothur "#make.file(inputdir=., type=fastq, prefix=plate_16S)"
cd ..
cd Mothur_processing
ln -s ../fastq/*.fastq .
cd ..
