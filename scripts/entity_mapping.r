#!/usr/bin/env Rscript

## user arguments

# Packages
library(tidyverse)
library(httr)

## Input
gnfinder <- read_delim("../output/30815-gnfinder-species.tsv", delim="\t",col_names=F)
extract <- read_delim("../output/30815-extract.tsv", delim="\t",col_names=T)
extract_org <- extract %>% filter(entity_type==-2) %>% mutate(ncbi_id=gsub('NCBI:','',term_id))

## get worms id from ncbi id

## function to call the worms API based on a NCBI Taxonomy id

worms_api <- function(tool,name_id){
    
    if (tool=="EXTRACT") {

        ## worms API based on NCBI ids
        url <- paste("http://www.marinespecies.org/rest/AphiaRecordByExternalID/",name_id,"?type=ncbi",sep="")

    } else if (tool=="gnfinder") {
        
        ## worms API based on names
        url <- paste("https://www.marinespecies.org/rest/AphiaRecordsByNames?scientificnames[]=",name_id,"&like=false&marine_only=false",sep="")
    } else {
        print("Please choose between 'EXTRACT' and 'gnfinder' for the worms API")
        break
    }

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

# function to remove NULL values from the list
list_null <- function(x) {

    if (is.null(x)){
        return(NA)
    } else {
        return(x)
    }
}

vector_ids <- extract_org[,4]
worms_content <- list()

worms_df <- data.frame(matrix(data = NA,nrow= lenght(vector_ids),ncol=28))

colnames(worms_df) <- c("AphiaID","url","scientificname","authority","status","unacceptreason","taxonRankID","rank","valid_AphiaID","valid_name","valid_authority","parentNameUsageID","kingdom","phylum","class","order","family","genus","citation","lsid","isMarine","isBrackish","isFreshwater","isTerrestrial","isExtinct","match_type","modified","id")

for (i in seq(1,length(vector_ids),by=1)){
    
    id_query=as.character(vector_ids[i])
    worms_df$id[i] <- id_query
    
    worms_content <- worms_ncbi_api(id_query)
    
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

## Output of NCBI to worms id

write_delim(worms_df, "../output/extract_organisms_worms.tsv", delim="\t", col_names=T)

## get worms id from scientific names

gnfinder_names_url <- gsub(gnfinder$X1, pattern=" ", replacement="%20")




#worms_id <- as.data.frame(get_wormsid(as.vector(gnfinder$X1),fuzzy=T, rows=1))

#for i in `cat file`; do curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=$i&rettype=docsum&retmode=text" | head -1 | sed -e 's/1. //g' | awk -F "\t" '{print '$i'"\t"$0}'; done;
#


