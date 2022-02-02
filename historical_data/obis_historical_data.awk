#! /usr/bin/gawk -f
#
###############################################################################
# script name: obis_historical_data.awk
# developed by: Savvas Paragkamian
# framework: EMODnet WP4
###############################################################################
# GOAL:
# Aim of this script is to export the number of occurrence records of each OBIS
# dataset and the year of the publication.
###############################################################################
#
# usage: ./obis_historical_data.awk obis_occurrence202105181955.csv \
#           obis_dataset_year.tsv
#
###############################################################################
#
#

#

BEGIN{

FS=","

}
(NR>1 && length($8)!=0){
dataset_id_occurrences[$2]++
dataset_id_year[$2]=$8
}
END{
for (i in dataset_id_occurrences){

    print i "\t" dataset_id_occurrences[i] "\t" dataset_id_year[i]

    }
}
