#!/usr/bin/env Rscript

## user arguments

# Packages
library(tidyverse)
library(httr)

# Load Custom Functions
source('functions_entity_mapping.r')

## Input
rms_content)
gnfinder <- read_delim("../output/30815-gnfinder-species.tsv", delim="\t",col_names=F)
extract_file <- read_delim("../output/30815-extract.tsv", delim="\t",col_names=T) %>% filter(entity_type==-2) %>% mutate(ncbi_id=gsub('NCBI:','',term_id))


# Output of NCBI to worms id
extract_aphia_ids <- get_AphiaIDs_extract(head(extract_file$ncbi_id))

write_delim(extract_aphia_ids, "../output/extract_organisms_worms.tsv", delim="\t", col_names=T)

## Output of worms id from scientific names

gnfinder_names_url <- gsub(gnfinder$X1, pattern=" ", replacement="%20")

gnfinder_aphia_ids <- get_AphiaIDs_gnfinder(gnfinder_names_url)


write_delim(gnfinder_aphia_ids, "../output/gnfinder_organisms_worms.tsv", delim="\t", col_names=T)
