#!/usr/bin/env Rscript

## user arguments

# Packages
library(tidyverse)
library(httr)

# Load Custom Functions
source('functions_entity_mapping.r')

## Input
gnfinder <- read_delim("../output/30815-gnfinder-species.tsv", delim="\t",col_names=F)
extract_file <- read_delim("../output/30815-extract.tsv", delim="\t",col_names=T) %>% filter(entity_type==-2) %>% mutate(ncbi_id=gsub('NCBI:','',term_id))


extract_aphia_ids <- get_AphiaIDs("EXTRACT",head(extract_file$ncbi_id))

# Output of NCBI to worms id

write_delim(worms_df, "../output/extract_organisms_worms.tsv", delim="\t", col_names=T)

## get worms id from scientific names

gnfinder_names_url <- gsub(gnfinder$X1, pattern=" ", replacement="%20")




#worms_id <- as.data.frame(get_wormsid(as.vector(gnfinder$X1),fuzzy=T, rows=1))

#for i in `cat file`; do curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=$i&rettype=docsum&retmode=text" | head -1 | sed -e 's/1. //g' | awk -F "\t" '{print '$i'"\t"$0}'; done;
#


