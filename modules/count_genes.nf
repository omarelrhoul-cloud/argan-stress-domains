process COUNT_GENES {
    tag "${species}"
    container 'python:3.12-slim'

    input:
    tuple val(species), path(domtbl), path(proteome)
    path domains

    output:
    path "${species}.counts.tsv", emit: counts

    script:
    """
    count_genes.py ${species} ${domtbl} ${proteome} ${domains} > ${species}.counts.tsv
    """
}
