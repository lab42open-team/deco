#!/bin/bash

cd ~/emodnet/

ls -1 *.txt | /data/textmining/tagger/tagcorpus --threads=8 --entities=/data/dictionary/prego_entities.tsv --names=/data/dictionary/prego_names.tsv --groups=/data/dictionary/prego_groups.tsv --stopwords=/data/dictionary/prego_global.tsv --types=emodnet_types.tsv --type-pairs=emodnet_type_pairs.tsv --documents=all-images.txt --out-matches=matches.tsv --out-pairs=pairs.tsv --out-segments=segments.tsv
