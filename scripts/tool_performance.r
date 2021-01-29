##!/usr/bin/env Rscript

# Name:     tool performance script of the cli-workflow
#
# Purpose:  Demonstration of a Command Line Interface workflow for biodiversity data rescue. Starting from OCR and going to NER and Entity Mapping this workflow is extentable to other tools and scalable to big libraries with biodiversity scanned documents
#
# Input:    Random id, the outputs of the EXTRACT and gnfinder tools and the results of the cli-workflow. In order to perform the evaluation the manual cutation file is needed as well to compare.
# 
# Output:   one file with the results.
#
# Author:   Savvas Paragkamian (s.paragkamian@hcmr.gr)
#           Institute of Marine Biology Biotechnology and Aquaculture (IMBBC)
#           Hellenic Centre for Marine Research (HCMR)
#
# Created:  12/01/2021
# License:  2-clause BSD License

## user arguments

args <- commandArgs(trailingOnly=TRUE)
random_id <- args[1]
random_id <- 16272

directory <- args[2]
directory <- "output"

# packages
library(tidyverse)
library(jsonlite)

source("functions_entity_mapping.r")
# Data input

## Manual curation
manual_ipt <- readxl::read_excel("../example-legacy-literature/reportofbritisha1843-appendix-1_ipt.xls", col_names=T) %>% select(scientificName,scientificNameID, fieldNumber, catalogNumber, occurrenceID) %>% distinct() %>% mutate(aphia_id=gsub(scientificNameID,pattern="urn:lsid:marinespecies.org:taxname:",replace=""))

manual_ipt_species <- manual_ipt %>% distinct(scientificName) %>% dplyr::filter(grepl(x=scientificName, pattern='\\w \\w'))

manual_ipt_aphia_id <- manual_ipt %>% distinct(aphia_id)
### DO not run
## Output of worms API to get the records associated with arphia ids
extract_aphia_ids <- get_AphiaIDs_extract(manual_ipt_aphia_id$aphia_id,"aphia_id")

write_delim(extract_aphia_ids, "ipt_organisms_worms.tsv", delim="\t", col_names=T)

## NER and Entity Mapping files load

### EXTRACT
extract_associations <- read_delim(paste("../",directory,"/",random_id,"-extract.tsv",sep=""),delim="\t")

extract_organisms <- extract_associations %>% dplyr::filter(entity_type==-2) %>% distinct()
extract_organisms_worms <- read_delim(paste("../",directory,"/",random_id,"-extract_organisms_worms.tsv",sep=""),delim="\t")

### gnfinder
gnfinder_organisms <- jsonlite::read_json(paste("../",directory,"/",random_id,"-gnfinder.json",sep=""),simplifyVector = TRUE)

gnfinder_vector <- as_tibble(unique(gnfinder_organisms[[2]][3]))

gnfinder_species_vector <- gnfinder_vector %>% dplyr::filter(grepl(x=name, pattern='\\w \\w'))

gnfinder_organisms_worms <- read_delim(paste("../",directory,"/",random_id,"-gnfinder_organisms_worms.tsv",sep=""),delim="\t")

# Recall

## Recall with aphia Ids from Worms

recall_aphia_id <- manual_ipt_aphia_id %>% mutate(gnfinder=as.numeric(aphia_id %in% gnfinder_organisms_worms$AphiaID)) %>% mutate(extract_species=as.numeric(aphia_id %in% extract_organisms_worms$AphiaID))

recall_aphia_id_gnfinder <- sum(recall_aphia_id$gnfinder)/(sum(recall_aphia_id$gnfinder)+nrow(dplyr::filter(recall_aphia_id, gnfinder==0)))

recall_aphia_id_extract <- sum(recall_aphia_id$extract_species)/(sum(recall_aphia_id$extract_species)+nrow(dplyr::filter(recall_aphia_id, extract_species==0)))

## Recall in species
recall_species <- manual_ipt_species %>% mutate(gnfinder=as.numeric(scientificName %in% gnfinder_vector$name)) %>% mutate(extract_species=as.numeric(scientificName %in% extract_organisms$tagged_text))

recall_species_gnfinder <- sum(recall_species$gnfinder)/(sum(recall_species$gnfinder)+nrow(dplyr::filter(recall_species, gnfinder==0)))

recall_species_extract <- sum(recall_species$extract_species)/(sum(recall_species$extract_species)+nrow(dplyr::filter(recall_species, extract_species==0)))

# Precision

## Precision with Aphia Ids

## Precision in species
precision_gnfinder_species <- gnfinder_species_vector %>% mutate(scientificName=(name %in% manual_ipt_species$scientificName)) %>% group_by(scientificName) %>% summarise(precision=n()) %>% pivot_wider(names_from=scientificName,values_from=precision) %>% mutate(precision=`TRUE`/(`TRUE`+`FALSE`))

precision_extract_species <- extract_organisms %>% distinct(tagged_text) %>% mutate(scientificName=(tagged_text %in% manual_ipt_species$scientificName)) %>% group_by(scientificName) %>% summarise(precision=n()) %>% pivot_wider(names_from=scientificName,values_from=precision) %>% mutate(precision=`TRUE`/(`TRUE`+`FALSE`))


# Steps to get the names of species from NCBI ids using ftp download files from NCBI. Attention for big files >818M.
#We can later transform them to names by :
#1. download the ttps://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
#
#```
#wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
#```
#2. use the node.dmp (we need the tax id and rank id columns) and names.dmp (we need the tax id and names in text)
#3. change the delimiter from \t|\t to \t
#
#```
#more nodes.dmp | sed 's/:ctrl-v-tab:\|//g' > nodes_tab.tsv
#
#more names.dmp | sed 's/:ctrl-v-tab:\|//g' > names_tab.tsv
#```
#4. merge the node.dmp and names.dmp based on the first column
#
#```
#awk -F'\t' 'FNR==NR{a[$1]=$3;next} ($1 in a) {print $1,a[$1],$2}' nodes_tab.tsv names_tab.tsv > ncbi_nodes_names.tsv
#```
#5. Remove the NCBI prefix of EXTRACT 
#6. Merge the files
