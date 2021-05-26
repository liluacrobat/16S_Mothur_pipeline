#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="Mothur-__SAMPLE_ID__"
#SBATCH --output=Mothur-__SAMPLE_ID__.log

module load mothur

echo '--------------------'
echo 'Summarizing sequencing qualities ...'
START=`date +%s`

mothur "#make.contigs(ffastq=__SAMPLE_ID___L001_R1_001.fastq, rfastq=__SAMPLE_ID___L001_R2_001.fastq, bdiffs=1, pdiffs=2, processors=12)"
END=`date +%s`
ELAPSED=$(( $END - $START ))
echo 'Summarizing sequencing qualities takes $ELAPSED s'

