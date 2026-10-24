#!/usr/bin/env bash
# Download the two proteomes used by the pipeline into data/
set -euo pipefail
mkdir -p data

# Argania spinosa (= Sideroxylon spinosum), phased T2T assembly (Zenodo record 16017913)
curl -L -o /tmp/argan_annotation.zip \
  "https://zenodo.org/api/records/16017913/files/2.Sideroxylon_spinosum_functional_annotation.zip/content"
unzip -o -j /tmp/argan_annotation.zip "*/Sideroxylon_spinosum.proteins.fa" -d data/
rm /tmp/argan_annotation.zip

# Arabidopsis thaliana, UniProt reference proteome UP000006548 (one protein per gene)
curl -L -o data/arabidopsis.proteins.fa.gz \
  "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000006548/UP000006548_3702.fasta.gz"
gunzip -f data/arabidopsis.proteins.fa.gz

grep -c ">" data/*.fa
