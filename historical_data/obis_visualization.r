#!/usr/bin/env Rscript

library(tidyverse)


obis_datasets <- read_delim("obis_dataset_year.tsv", delim="\t", col_names=F)
colnames(obis_datasets) <- c("id","occurrences", "year")

ggplot()+
    geom_point(obis_datasets, mapping=aes(x=year, y=occurrences))+
    theme_bw()

ggsave("obis_datasets_year.png", plot = last_plot(), device = "png", dpi = 300)

obis_historic_datasets <- obis_datasets %>% filter(year<1960)


ggplot()+
    geom_point(obis_historic_datasets, mapping=aes(x=year, y=occurrences))+
    theme_bw()

ggsave("obis_historic_datasets_year.png", plot = last_plot(), device = "png", dpi = 300)
