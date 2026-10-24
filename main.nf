#!/usr/bin/env nextflow

include { FETCH_HMM } from './modules/fetch_hmm.nf'
include { HMMSEARCH } from './modules/hmmsearch.nf'

params {
    domains: Path = "${projectDir}/domains.csv"
    proteomes: Path
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

    publish:
    domtbl = HMMSEARCH.out.domtbl
}

output {
    domtbl { path 'hmmsearch' }
}
