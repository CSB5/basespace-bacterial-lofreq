#!/bin/bash

OUT_DIR=$(readlink -f $(dirname $0)/../refs/)

NCBI_GENOMES_DIR=/mnt/genomeDB/ncbi/genomes/Bacteria/
test -d $NCBI_GENOMES || exit 1

for fa in $(ls $OUT_DIR/*all.fa); do
#cat <<EOF
    bwa index $fa >/dev/null && samtools faidx $fa >/dev/null;
#EOF
done
