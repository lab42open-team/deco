#!/bin/bash

# Name:     cli-workflow
#
# Purpose:  Demonstration of a Command Line Interface workflow for biodiversity data rescue. Starting from OCR and going to NER and Entity Mapping this workflow is extentable to other tools and scalable to big libraries with biodiversity scanned documents
#
# Input:    A pdf file located inside the repository.
#
# OCR Output:   Text file containg the contents of each page of the pdf as well as the individual pages.
# NER Output:
# EM Output:
#
# Author:   Savvas Paragkamian (s.paragkamian@hcmr.gr)
#           Institute of Marine Biology Biotechnology and Aquaculture (IMBBC)
#           Hellenic Centre for Marine Research (HCMR)
#
# Created:  12/01/2021
# License:  2-clause BSD License
#
# Note:     comments and specifics are given in-line and in README.md of the repository
#
## example of running the script
## ./scripts/cli-workflow.sh -f example-legacy-literature/reportofbritisha1843-appendix-1.pdf -d output

## Usage of the script
usage="Use the parameter -f for the path of pdf file (inside the repository) and -d for the name of the new directory that the results will be saved in.\nExample: ./scripts/cli-workflow.sh -f example-legacy-literature/reportofbritisha1843-appendix-1.pdf -d output \n"

## User input PDF file
while getopts "f:d:" option
do
   case "$option" in
      f)   pdf_file="${OPTARG}";;
      d)   directory="${OPTARG}";;
      ?|:)   echo -e "$usage" ; exit 1;;
      *)   echo -e "option ${OPTARG} unknown. \n$usage" ; exit 1 ;;
   esac
done

## Detect if no options were passed
if [ $OPTIND -eq 1 ]; 
    then echo -e "No options were passed. \n$usage "; exit 1; 
fi

## Detect if a single option is missing
if [ -z "${pdf_file}" ]; then
    echo -e "Option -f empty. $usage"; exit 1;
fi

if [ -z "${directory}" ]; then
    echo -e "Option -d empty. $usage"; exit 1;
fi

## Successful call of the script parameters
echo -e "data: $pdf_file \noutput directory: $directory \n"

## Creation of new directory for the outputs

time_start=`date +%s`
DATE=$(date +"%Y-%m-%d_%H-%M")

### assign a unique random tag to files.
id=$RANDOM

script_path="${BASH_SOURCE[0]}"
cd `dirname "$script_path"`

cd ../
mkdir -p $directory;
cd $directory

text_output=ocr-${id}.txt
touch $text_output

echo -e "workflow started on $DATE with id=$id\n"

## From pdf to text

### break into single pages of images with ImageMagick
echo -e "conversion started \n"
convert -density 400 ../$pdf_file -quality 100 ${id}.png

### from images to text files

echo -e "OCR with tesseract started \n"
for f in ${id}*.png; do tesseract -l eng $f ${f%".png"}; done

### combine all texts to one

cat ${id}*.txt > $text_output

echo -e "text from $pdf_file is in $directory/$text_output \n"

### NER

#### EXTRACT

echo -e "Now executing EXTRACT tool to detect organisms, environments and tissues. API is invoked, be sure to have a stable internet connection."

../scripts/getEntities_EXTRACT_api.pl $text_output > ${id}-extract.tsv

#### gnfinder

echo -e "Now executing gnfinder tool to detect organisms..."

gnfinder find $text_output > ${id}-gnfinder.json

more ${id}-gnfinder.json | jq '.names[] | {name: .name} | [.name] | @tsv' | sed 's/"//g' > ${id}-gnfinder-species.tsv

## Entity mapping
cd ../

echo -e "Now performing Entity Mapping of organisms to Aphia Ids... API is invoked, be sure to have a stable internet connection."

Rscript "scripts/entity_mapping.r" "$id" "$directory"
echo -e "Finished!"

## end of script
