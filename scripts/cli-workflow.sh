#!/bin/bash

## example of running the script
## ./cli-workflow.sh -f file.pdf -d folder
## User input PDF file

## Usage of the script
usage="Use the parameter -f for the path of pdf file (full path name) and -d for the name of the new directory that the results will be saved in. \n"

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
DATE=$(date +"%Y-%m-%d")

### assign a unique random tag to files.
id=$RANDOM

script_path="${BASH_SOURCE[0]}"
cd `dirname "$script_path"`
echo `dirname "$script_path"`

cd ../
mkdir -p $directory;
cd $directory

text_output=ocr-${id}.txt
touch $text_output


## From pdf to text

### break into single pages of images with ImageMagick
echo -e "conversion started \n"
convert -density 400 $pdf_file -quality 100 ${id}.png

### from images to text files

echo -e "OCR with tesseract started \n"
for f in ${id}*.png; do tesseract -l eng $f ${f%".png"}; done

### combine all texts to one

cat ${id}*.txt > $text_output

echo -e "text from $pdf_file is in $directory/$text_output \n"
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
