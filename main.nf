#!/usr/bin/env nextflow

include { FETCH_HMM } from './modules/fetch_hmm.nf'
include { HMMSEARCH } from './modules/hmmsearch.nf'
include { COUNT_GENES } from './modules/count_genes.nf'
include { PLOT_RATIOS } from './modules/plot_ratios.nf'

params {
    domains: Path = "${projectDir}/domains.csv"
    proteomes: Path
    target: String = 'argan'
    reference: String = 'arabidopsis'
}

workflow {

    main:
    // 1. Un profil HMM par domaine du CSV, vérifié
    domains_ch = channel.fromPath(params.domains)
        .splitCsv(header: true)
        .map { row -> tuple(row.pfam_id, row.pfam_name) }
    FETCH_HMM(domains_ch)

    // 2. Une boîte [espèce, protéome] par ligne de la liste des protéomes
    proteomes_ch = channel.fromPath(params.proteomes)
        .splitCsv(header: true)
        .map { row -> tuple(row.species, file(row.fasta)) }

    // 3. Chercher tous les domaines dans chaque protéome
    HMMSEARCH(proteomes_ch, FETCH_HMM.out.hmm.collect())

    // 4. Compter les gènes par famille, puis tout réunir dans un seul tableau
    COUNT_GENES(HMMSEARCH.out.domtbl.join(proteomes_ch), file(params.domains))
    counts_ch = COUNT_GENES.out.counts.collectFile(name: "gene_counts.tsv", keepHeader: true, skip: 1)

    // 5. Rapport normalisé + graphique
    PLOT_RATIOS(counts_ch, params.target, params.reference)

    publish:
    domtbl = HMMSEARCH.out.domtbl
    counts = counts_ch
    ratios = PLOT_RATIOS.out.ratios
    figure = PLOT_RATIOS.out.svg
}

output {
    domtbl { path 'hmmsearch' }
    counts { path '.' }
    ratios { path '.' }
    figure { path '.' }
}
