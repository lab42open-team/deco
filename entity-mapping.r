#!/usr/bin/env Rscript
#
library(tidyverse)
library(jsonlite)
library(taxize)
library(worrms)

## Manual curation
manual_ipt<-readxl::read_excel("occurrence_Forbes_ipt.xls") %>% select(scientificName, fieldNumber, catalogNumber, occurrenceID) %>% distinct()

## NER

extract_associations <- read_delim("extract-forbes.tsv",delim="\t")

extract_organisms <- extract_associations %>% filter(`entity type`==-2) %>% distinct()

gnfinder_organisms <- jsonlite::read_json("gnfinder-forbes.json",simplifyVector = TRUE)

gnfinder_vector <- unique(gnfinder_organisms[[2]][3])


gnfinder_species_vector <- gnfinder_vector %>% filter(grepl(x=name, pattern='\\w \\w'))


manual_ipt_species <- manual_ipt %>% filter(grepl(x=scientificName, pattern='\\w \\w'))

## Entity Mapping
#get_wormsid

# Precision - Recall

roc <- manual_ipt_species %>% mutate(gnfinder=(scientificName %in%gnfinder_vector$name)) %>% mutate(extract_species=(scientificName %in% extract_organisms$`tagged text`))
