#!/usr/bin/perl -w

# Name:     getEntities_EXTRACT_api
#
# Purpose:  Lightweight EXTRACT API client that demonstrates how to retrieve
#           the entities the tagger identifies in a given piece of text
#
# Input:    Tab-delimited file containing the text to be mined along with
#           source information; the colums are: resource:id	field	text
#
# Output:   Tab-delimited file with three columns, namely the tagged word in
#           the text
#           1) Tagged word in text
#           2) Term identifier
#           3) The complete text clause that was sent for tagging

# Author:   Evangelos Pafilis (pafilis@hcmr.gr)
#           Institute of Marine Biology Biotechnology and Aquaculture (IMBBC)
#           Hellenic Centre for Marine Research (HCMR)
#
# Created:  2017 Sept 28
# License:  2-clause BSD License
#
# Note:     comments on the EXTRACT API specifics are given in-line
#
# More:     https://doi.org/10.1101/078469
# FAQ:      https://extract.hcmr.gr , FAQ, purple section


use strict;
use warnings;
use LWP::Simple;
use Data::Dumper;
my $debug = 0;
my $sleep_seconds = 1;

die "Syntax: $0 <OTU_accession_isolationSource_publicationTitles.tsv>" unless scalar(@ARGV) eq 1;

## Jensenlab Tagger API URL and method
my $server = "http://tagger.jensenlab.org";
my $method = "GetEntities";
my $url = $server."/".$method;


## tagging GetEntities methods specifics
# supported entity types
#-1: PubChem Compound identifiers
#-2: NCBI Taxonomy entries
#-21: Gene Ontology biological process terms
#-22: Gene Ontology cellular component terms
#-23: Gene Ontology molecular function terms
#-25: BRENDA Tissue Ontology terms
#-26: Disease Ontology terms
#-27: Environment Ontology terms
my $entity_types="-27 -2 -25"; #(concatenate with " " to use multiple)
my $format = "tsv";
my $document = ""; # to be read from the input file

my $header_skipped = 0;
open TSV, "< $ARGV[0]" or die "Failed to read $ARGV[0]";
#there is no specific variable that stores the output; monitor print commands instead
while (my $entry = <TSV>) {
    #trim trailing new line
    $entry =~ s/\r|\n//g;

    #print new header line
    unless ( $header_skipped ) {
        print "tagged text"."\t"."entity type"."\t"."term id"."\n";
        $header_skipped = 1;
        next;
    }

    #get the extract tags via an HTTP post to the EXTRACT Tagger API
    $document    = $entry;
    my $ua       = LWP::UserAgent->new();
    my $response = $ua->post( $url, [ 'document' => $document, 'entity_types' => $entity_types, 'format' => $format ] );
    my $content  = $response->decoded_content();


    #produce output, the NCBI taxonomy identifier, pre-pend the NCBI: prefix
    my @retrieved_tags = split /\n/, $content;
    if ($debug) { print Dumper \@retrieved_tags; }
    foreach my $tag ( sort @retrieved_tags){
        my ($tagged_text, $type, $id) = split /\t/, $tag;

        if ($type eq "-2"){ #NCBI Taxonomy term
            print $tagged_text."\t".$type."\t"."NCBI:".$id."\n";
        }
        if ($type eq "-27"){ #ENVO term
            print $tagged_text."\t".$type."\t".$id."\n";
        }
        if ($type eq "-25"){ #Brenda term
            print $tagged_text."\t".$type."\t".$id."\n";
        }
    }
}
