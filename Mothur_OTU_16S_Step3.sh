#!/bin/sh
cp plate_16S.OTU.txt plate_16S.OTU.raw.txt
cp plate_16S.OTU.biom plate_16S.OTU.raw.biom
rm plate_16S.OTU.biom
cp plate_16S.OTU.reformated.txt plate_16S.OTU.txt
conda activate qiime

biom convert -i plate_16S.OTU.txt -o plate_16S.OTU.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy

summarize_taxa.py -i plate_16S.OTU.biom -o tax_mapping_counts/ -L 2,3,4,5,6,7 -a
summarize_taxa.py -i plate_16S.OTU.biom -o tax_mapping_rel/ -L 2,3,4,5,6,7


