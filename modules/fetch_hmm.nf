process FETCH_HMM {
    tag "${pfam_id}"
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(pfam_id), val(pfam_name)

    output:
    path "${pfam_id}.hmm", emit: hmm

    script:
    """
    curl -s "https://www.ebi.ac.uk/interpro/api/entry/pfam/${pfam_id}/?annotation=hmm" | gunzip > ${pfam_id}.hmm
    found=\$(grep -m1 '^NAME' ${pfam_id}.hmm | awk '{print \$2}')
    if [ "\$found" != "${pfam_name}" ]; then
        echo "ERREUR : ${pfam_id} s'appelle '\$found' dans Pfam, pas '${pfam_name}'" >&2
        exit 1
    fi
    """
}
