mkdir trim9
for x in $(ls *.fastq);do /projects/academic/pidiazmo/projectsoftwares/fastx/bin/fastx_trimmer -f 9 -i $x -o trim9/$x;done
