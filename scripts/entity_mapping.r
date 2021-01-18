#!/usr/bin/env Rscript

## user arguments

# Packages
library(tidyverse)
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
    worms_status <- status_code(get_url)
    worms_content <- content(get_url)
    
    if (worms_status==200){

        return(worms_content)
    } else {

        return(worms_status)
    }
}

list_null <- function(x) {

    if (is.null(x)){
        return(NA)
    } else {
        return(x)
    }
}

worms_content <- list()

worms_df <- data.frame(matrix(data = NA,nrow= nrow(extract_org),ncol=28))

colnames(worms_df) <- c("AphiaID","url","scientificname","authority","status","unacceptreason","taxonRankID","rank","valid_AphiaID","valid_name","valid_authority","parentNameUsageID","kingdom","phylum","class","order","family","genus","citation","lsid","isMarine","isBrackish","isFreshwater","isTerrestrial","isExtinct","match_type","modified","ncbi")

for (i in seq(1,nrow(extract_org),by=1)){
    
    ncbi=as.character(extract_org[i,4])
    worms_df$ncbi[i] <- ncbi
    
    worms_content <- worms_api(ncbi)
    
    if (!is.numeric(worms_content)) {
             worms_content <- lapply(worms_content, list_null)
    }

    for (j in seq(1,27,by=1)) {

        if (!is.numeric(worms_content)) {
            
            worms_df[i,j] <- worms_content[[j]]

        } else {

            worms_df[i,j] <- worms_content
        }
    }

    Sys.sleep(0.5)
}


## Output

write_delim(worms_df, "../output/extract_organisms_worms.tsv", delim="\t", col_names=T)

## get worms id

#worms_id <- as.data.frame(get_wormsid(as.vector(gnfinder$X1),fuzzy=T, rows=1))

#for i in `cat file`; do curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=$i&rettype=docsum&retmode=text" | head -1 | sed -e 's/1. //g' | awk -F "\t" '{print '$i'"\t"$0}'; done;
#


# In order not to overload the E-utility servers, NCBI recommends that users post no more than three URL requests per second and limit large jobs to either weekends or between 9:00 PM and 5:00 AM Eastern time during weekdays. 
