process PLOT_RATIOS {
    container 'python:3.12-slim'

    input:
    path counts
    val target
    val reference

    output:
    path "ratios.tsv", emit: ratios
    path "stress_families.svg", emit: svg

    script:
    """
    plot_ratios.py ${counts} ${target} ${reference}
    """
}
