#!/usr/bin/env Rscript

library(tidyverse)
library(ROCR)
library(jsonlite)
library(taxize)
library(worrms)

## Manual curation
manual_ipt<-readxl::read_excel("occurrence_Forbes_ipt.xls") %>% select(scientificName, fieldNumber, catalogNumber, occurrenceID) %>% distinct()

## NER

extract_associations <- read_delim("extract-forbes.tsv",delim="\t")

extract_organisms <- extract_associations %>% filter(`entity type`==-2) %>% distinct()

gnfinder_organisms <- jsonlite::read_json("gnfinder-forbes.json",simplifyVector = TRUE)

gnfinder_vector <- as_tibble(unique(gnfinder_organisms[[2]][3]))


gnfinder_species_vector <- gnfinder_vector %>% filter(grepl(x=name, pattern='\\w \\w'))


manual_ipt_species <- manual_ipt %>% distinct(scientificName) %>% filter(grepl(x=scientificName, pattern='\\w \\w'))

## Entity Mapping
#get_wormsid

# Precision - Recall

recall_species <- manual_ipt_species %>% mutate(gnfinder=as.numeric(scientificName %in% gnfinder_vector$name)) %>% mutate(extract_species=as.numeric(scientificName %in% extract_organisms$`tagged text`))

precision_gnfinder_species <- gnfinder_species_vector %>% mutate(scientificName=(name %in% manual_ipt_species$scientificName))

recall_species_gnfinder <- sum(recall_species$gnfinder)/(sum(recall_species$gnfinder)+nrow(filter(recall_species, gnfinder==0)))

recall_species_extract <- sum(recall_species$extract_species)/(sum(recall_species$extract_species)+nrow(filter(recall_species, extract_species==0)))



## Precision Recall Curve
#ggplot()+
#  geom_line(data = df_roc_bet, aes(x = V1,y = V2, color="GNfinder" ))+
#  scale_colour_manual(values = c("GNfinder"="red"), name="Methods")+
#  ggtitle("Precision Recall Curve")+
#  labs(x="Recall", y="Precision")+
#  theme_bw()+
#  coord_fixed(ratio = 1)+
#  theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank())


