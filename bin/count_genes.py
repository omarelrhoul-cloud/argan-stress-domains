#!/usr/bin/env python3
"""Count the genes carrying each stress-related Pfam domain family."""
import csv
import re
import sys

species, domtbl, proteome, domains_csv = sys.argv[1:5]


def gene_id(protein_id):
    """Argan isoforms: SIDSPI01_000001-T1 -> SIDSPI01_000001."""
    return re.sub(r"-T\d+$", "", protein_id)


# Pfam accession -> family, in the order of domains.csv
acc2family = {}
families = []
with open(domains_csv) as f:
    for row in csv.DictReader(f):
        acc2family[row["pfam_id"]] = row["family"]
        if row["family"] not in families:
            families.append(row["family"])

# Total number of genes in the proteome
all_genes = set()
with open(proteome) as f:
    for line in f:
        if line.startswith(">"):
            all_genes.add(gene_id(line[1:].split()[0]))

# Genes carrying at least one domain of each family
hits = {fam: set() for fam in families}
with open(domtbl) as f:
    for line in f:
        if line.startswith("#"):
            continue
        cols = line.split()
        acc = cols[4].split(".")[0]          # PF00847.27 -> PF00847
        hits[acc2family[acc]].add(gene_id(cols[0]))

print("species\tfamily\tn_genes\ttotal_genes")
for fam in families:
    print(f"{species}\t{fam}\t{len(hits[fam])}\t{len(all_genes)}")
