#!/bin/sh
module load python/anaconda
mkdir sh
for f in *_R1_001.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b;
    done
cd sh

#chmod 777 *.sh

for f in $(ls *.sh);do sbatch $f;done

