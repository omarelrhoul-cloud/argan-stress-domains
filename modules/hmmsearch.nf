process HMMSEARCH {
    tag "${species}"
    container 'staphb/hmmer:3.4'
    cpus 2

    input:
    tuple val(species), path(proteome)
    path hmms

    output:
    tuple val(species), path("${species}.domtbl"), emit: domtbl

    script:
    """
    cat ${hmms} > stress_domains.hmm
    hmmsearch --cut_ga --cpu ${task.cpus} --noali \
        --domtblout ${species}.domtbl -o /dev/null \
        stress_domains.hmm ${proteome}
    """
}
