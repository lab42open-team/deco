#!/usr/bin/env Rscript
#
library(tidyverse)
library(jsonlite)
library(taxize)
library(worrms)

## Manual curation
manual_ipt <-readxl::read_excel("occurrence_Forbes_ipt.xls")

## NER

extract_associations <- read_delim("extract-forbes.tsv",delim="\t")

extract_organisms <- extract_associations %>% filter(`entity type`==-2) %>% distinct()

gnfinder_species <- jsonlite::read_json("gnfinder-forbes.json",simplifyVector = TRUE)

## Entity Mapping
#get_wormsid


## 
