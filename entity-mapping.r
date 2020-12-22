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

gnfinder_species <- jsonlite::read_json("gnfinder-forbes.json",simplifyVector = TRUE)

gnfinder_species_vector <- unique(gnfinder_species[[2]][3])



## Entity Mapping
#get_wormsid

# Precision - Recall

roc <- manual_ipt %>% mutate(gnfinder=(scientificName %in%gnfinder_species_vector$name)) %>% mutate(extract_species=(scientificName %in% extract_organisms$`tagged text`))

