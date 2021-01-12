#!/bin/bash

## example of running the script
## ./cli-workflow.sh -f file.pdf -d folder
## User input PDF file

## Usage of the script
usage="Use the parameter -f for the pdf file (full name) and -d for the name of the new directory that the results will be saved in. \n"

while getopts "f:d:" option
do
   case "$option" in
      f)   PDF_FILE="${OPTARG}";;
      d)   DIRECTORY="${OPTARG}";;
      ?|:)   echo -e "$usage" ; exit 1;;
      *)   echo -e "option ${OPTARG} unknown. \n$usage" ; exit 1 ;;
   esac
done


## Detect if no options were passed
if [ $OPTIND -eq 1 ]; 
    then echo -e "No options were passed. \n$usage "; exit 1; 
fi

## Detect if a single option is missing
if [ -z "${PDF_FILE}" ]; then
    echo -e "Option -f empty. $usage"; exit 1;
fi

if [ -z "${DIRECTORY}" ]; then
    echo -e "Option -d empty. $usage"; exit 1;
fi

## Successful call of the script parameters
echo "The file: $PDF_FILE will be processed for species and environments and the output will be saved in the directory: $DIRECTORY"

## OCR
#convert -density 400 legacy-literature.pdf -quality 100 legacy-literature.png
#
#for f in *.png; do tesseract -l eng $f ${f%".png"}; done
#
#cat *.txt >> legacy-literature.txt
#
### NER
#### EXTRACT
#
#./getEntities_EXTRACT_api.pl legacy-literature.txt > legacy-literature-extract.tsv
#
#### gnfinder
#
#
#gnfinder find legacy-literature.txt > legacy-literature-gnfinder.json
#
#more legacy-literature-gnfinder.json | jq '.names[] | {name: .name} | [.name] | @tsv' | sed 's/"//g' > legacy-literature-gnfinder-species.tsv

## Entity mapping
