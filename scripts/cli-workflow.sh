#!/usr/bin/bash

## OCR
convert -density 400 legacy-literature.pdf -quality 100 legacy-literature.png

for f in *.png; do tesseract -l eng $f ${f%".png"}; done

cat *.txt >> legacy-literature.txt

## NER
### EXTRACT

./getEntities_EXTRACT_api.pl legacy-literature.txt > legacy-literature-extract.tsv

### gnfinder


gnfinder find legacy-literature.txt > legacy-literature-gnfinder.json

more legacy-literature-gnfinder.json | jq '.names[] | {name: .name} | [.name] | @tsv' | sed 's/"//g' > legacy-literature-gnfinder-species.tsv

## Entity mapping


