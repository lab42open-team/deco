#!/usr/bin/env Rscript

# Name:     entity mapping of the cli-workflow to Aphia Ids
#
# Purpose:  Demonstration of a Command Line Interface workflow for biodiversity data rescue. Starting from OCR and going to NER and Entity Mapping this workflow is extentable to other tools and scalable to big libraries with biodiversity scanned documents
#
# Input:    Random id and the outputs of the EXTRACT and gnfinder tools. The organisms that these tools find are translated to Aphia Ids of the WORMS database using its API
# 
# Output:   Two tsv files, one for EXTRACT and one for gnfinder, that contain all 27 different elements that describe each entity of the WORMS database when the status of the API call is 200. Otherwise the status is provided instead.
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
directory <- args[2]

# Packages
suppressPackageStartupMessages({
    library(tidyverse)
    library(httr)
})

# Load Custom Functions. Between each call of the api 0.5 second interval is set not to overload the servers of WORMS.
source("scripts/functions_entity_mapping.r")

## Input
extract_file <- read_delim(paste(directory,"/",random_id,"-extract.tsv",sep=""), delim="\t",col_names=T,col_types = cols()) %>% dplyr::filter(entity_type==-2) %>% mutate(ncbi_id=gsub('NCBI:','',term_id)) %>% distinct(.)

gnfinder <- read_delim(paste(directory,"/",random_id,"-gnfinder-species.tsv",sep=""), delim="\t",col_names=F,col_types = cols()) %>% distinct(.)

## Output of NCBI to worms id
extract_aphia_ids <- get_AphiaIDs_extract(extract_file$ncbi_id,"EXTRACT")

write_delim(extract_aphia_ids, paste(directory,"/",random_id,"-extract_organisms_worms.tsv",sep=""), delim="\t", col_names=T)

## Output of worms id from scientific names

gnfinder_names_url <- gsub(gnfinder$X1, pattern=" ", replacement="%20")

gnfinder_aphia_ids <- get_AphiaIDs_gnfinder(gnfinder_names_url)

write_delim(gnfinder_aphia_ids, paste(directory,"/",random_id,"-gnfinder_organisms_worms.tsv", sep=""), delim="\t", col_names=T)

# End of script
