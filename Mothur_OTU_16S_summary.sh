#!/bin/sh
module load qiime2

biom convert -i plate_16S.OTU.org.txt -o plate_16S.OTU.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy

summarize_taxa.py -i plate_16S.OTU.biom -o tax_mapping_counts/ -L 2,3,4,5,6,7 -a
summarize_taxa.py -i plate_16S.OTU.biom -o tax_mapping_rel/ -L 2,3,4,5,6,7


