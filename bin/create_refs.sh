#!/bin/bash

export PATH=$(dirname $0):$PATH
DEBUG=0
# see ftp://ftp.ncbi.nlm.nih.gov/genomes/Bacteria/
NCBI_GENOMES_DIR=/mnt/genomeDB/ncbi/genomes/Bacteria/
OUT_DIR=$(readlink -f $(dirname $0)/../refs/)
test -d $NCBI_GENOMES || exit 1
test -d $OUT_DIR || exit 1


usage() {
cat <<EOF
$(basename $0): Generate reference sequences in $OUT_DIR using $NCBI_GENOMES_DIR
  -f | --overwrite   overwrite existing entries in $OUT_DIR
  -h | --help        print this help
EOF
}
                
                
overwrite=0
while [ "$1" != "" ]; do
    case $1 in
        -f | --overwrite )
            overwrite=1
            ;;
        -h | --help )
            usage
            exit 0
            ;;
        * )
          echo "FATAL: unknown argument \"$1\""
          usage
          exit 1
    esac
    shift
done
                                                        
for specdir in $(ls -d $NCBI_GENOMES_DIR/*uid*); do
	outfa=$OUT_DIR/$(echo $specdir | awk -F/ '{sub("/$", ""); printf "%s_all.fa", $NF}');
	if [ -e $outfa ]; then
	    if [ $overwrite -eq 1 ]; then
            echo "Re-generating $outfa from $specdir" 1>&2
        else
            echo "Skipping existing $outfa" 1>&2
            continue
        fi
    else
        echo "Generating $outfa from $specdir" 1>&2
    fi

	cat $specdir/*fna > $outfa

	if [ $DEBUG -eq 1 ]; then
		echo "DEBUG exit" 1>&2
		break
	fi
done

find $OUT_DIR -name \*_all.fa -exec cat {} \; > $OUT_DIR/all_refs.fa
