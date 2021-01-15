#!/usr/bin/env Rscript

## user arguments

## Packages
library(tidyverse)
library(taxize)
library(worrms)
library(httr)

## Input
gnfinder <- read_delim("../output/30815-gnfinder-species.tsv", delim="\t",col_names=F)
extract <- read_delim("../output/30815-extract.tsv", delim="\t",col_names=T)
extract_org <- extract %>% filter(entity_type==-2) %>% mutate(ncbi_id=gsub('NCBI:','',term_id))

## get worms id from ncbi id

worms_api <- function(ncbi_id){
    url <- paste("http://www.marinespecies.org/rest/AphiaRecordByExternalID/",ncbi_id,"?type=ncbi",sep="")
    get_url <- GET(url)
    message_for_status(get_url)

}


## get worms id

worms_id <- as.data.frame(get_wormsid(as.vector(gnfinder$X1),fuzzy=T, rows=1))

#for i in `cat file`; do curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=$i&rettype=docsum&retmode=text" | head -1 | sed -e 's/1. //g' | awk -F "\t" '{print '$i'"\t"$0}'; done;
#


# In order not to overload the E-utility servers, NCBI recommends that users post no more than three URL requests per second and limit large jobs to either weekends or between 9:00 PM and 5:00 AM Eastern time during weekdays. 
