#!/usr/bin/env Rscript

library(tidyverse)
library(ROCR)
library(jsonlite)
library(taxize)
library(worrms)

## Manual curation
manual_ipt<-readxl::read_excel("../example-legacy-literature/reportofbritisha1843-appendix-1_ipt.xls") %>% select(scientificName, fieldNumber, catalogNumber, occurrenceID) %>% distinct()

## NER

extract_associations <- read_delim("../output/30815-extract.tsv",delim="\t")

extract_organisms <- extract_associations %>% filter(entity_type==-2) %>% distinct()

gnfinder_organisms <- jsonlite::read_json("../output/30815-gnfinder.json",simplifyVector = TRUE)

gnfinder_vector <- as_tibble(unique(gnfinder_organisms[[2]][3]))

gnfinder_species_vector <- gnfinder_vector %>% filter(grepl(x=name, pattern='\\w \\w'))

manual_ipt_species <- manual_ipt %>% distinct(scientificName) %>% filter(grepl(x=scientificName, pattern='\\w \\w'))

## Entity Mapping
#get_wormsid

# Recall

recall_species <- manual_ipt_species %>% mutate(gnfinder=as.numeric(scientificName %in% gnfinder_vector$name)) %>% mutate(extract_species=as.numeric(scientificName %in% extract_organisms$tagged_text))

recall_species_gnfinder <- sum(recall_species$gnfinder)/(sum(recall_species$gnfinder)+nrow(filter(recall_species, gnfinder==0)))

recall_species_extract <- sum(recall_species$extract_species)/(sum(recall_species$extract_species)+nrow(filter(recall_species, extract_species==0)))

# Precision

precision_gnfinder_species <- gnfinder_species_vector %>% mutate(scientificName=(name %in% manual_ipt_species$scientificName)) %>% group_by(scientificName) %>% summarise(precision=n()) %>% pivot_wider(names_from=scientificName,values_from=precision) %>% mutate(precision=`TRUE`/(`TRUE`+`FALSE`))


#We can later transform them to names by :
#1. download the ttps://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
#
#```
#wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
#```
#2. use the node.dmp (we need the tax id and rank id columns) and names.dmp (we need the tax id and names in text)
#3. change the delimiter from \t|\t to \t
#
#```
#more nodes.dmp | sed 's/:ctrl-v-tab:\|//g' > nodes_tab.tsv
#
#more names.dmp | sed 's/:ctrl-v-tab:\|//g' > names_tab.tsv
#```
#4. merge the node.dmp and names.dmp based on the first column
#
#```
#awk -F'\t' 'FNR==NR{a[$1]=$3;next} ($1 in a) {print $1,a[$1],$2}' nodes_tab.tsv names_tab.tsv > ncbi_nodes_names.tsv
#```
#5. Remove the NCBI prefix of EXTRACT 
#6. Merge the files
## Precision Recall Curve
#ggplot()+
#  geom_line(data = df_roc_bet, aes(x = V1,y = V2, color="GNfinder" ))+
#  scale_colour_manual(values = c("GNfinder"="red"), name="Methods")+
#  ggtitle("Precision Recall Curve")+
#  labs(x="Recall", y="Precision")+
#  theme_bw()+
#  coord_fixed(ratio = 1)+
#  theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank())


