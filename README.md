# Workflow for legacy literature annotation EMODnet

Legacy literature contains valuable information about biodiversity. Dedicated workflows are needed in order to extract this information and transform it in structured data format. This is process is a multiple step process requiring many tools and interdisciplinary knowledge. In 2015, a [workshop](httpse//riojournal.com/articles.php?journal_name=rio&id=10445) was help in [HCMR](https://www.hcmr.gr/en/) to standardise this process. 

## Scan to pdf

Scanning expedition reports, research articles and books has been well underway.

## Single page PNG

```
convert test.pdf test/images.png
```

## OCR

```
for f in *.png; do tesseract -l eng $f ${f%".png"}; done
```

Then we can combine all the pages into one txt document

```
cat *.txt >> all.txt
```

## EXTRACT species and environments and tissues

```
./getEntities_EXTRACT_api.pl tool-testing-template.txt > tool-template-extract.tsv
```

## gnfinder


```
gnfinder find tool-testing-template.txt > tool-testing-gnfinder.json
```

This command line tool returns a json file that has 2 arrays, metadata and names.

To extract the names

```
more tool-template-gnfinder.json | jq '.names[] | {name: .name}'

more tool-template-gnfinder.json | jq '.names[] | {name: .name} | [.name] | @tsv' | sed 's/"//g' > tool-template-gnfinder-species.tsv
```

