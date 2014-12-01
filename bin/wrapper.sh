#!/bin/bash

export PATH=$(dirname $0):$PATH
export PICARD_DIR=$(dirname $0)/picard
if [ ! -d $PICARD_DIR ]; then
	echo "FATAL: expected $PICARD_DIR doesn't exist" 1>&2
	exit 1
fi
LF=lofreq
BWAMEM_PE_SH=bwamem_pe.sh

usage() {
cat <<EOF
$(basename $0): Wrapper for running 'Bacterial LoFreq'
    -f | --ref     : reference
    -1 | --fq1     : first fastq file
    -2 | --fq2     : second fastq file
    -o | --outpref : output prefix
    -l | --bed     : bed file (optional)
EOF
}
                
                
if ! which $LF >/dev/null; then
	echo "FATAL: $LF not found" 1>&2
	exit 1
fi
if ! which $BWAMEM_PE_SH >/dev/null; then
	echo "FATAL: $BWAMEM_PE_SH not found or not executable (PATH is $PATH)" 1>&2
	exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        -f | --ref )
            shift
            ref=$1
            ;;
        -t | --threads )
            shift
            threads=$1
            ;;
        -1 | --fq1 )
            shift
            fq1=$1
            ;;
        -2 | --fq2 )
            shift
            fq2=$1
            ;;
        -o | --outpref )
            shift
            outpref=$1
            ;;
        -l | --bed )
            shift
            bed=$1
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

# check arguments
test -z "$ref" && exit 1
test -z "$fq1" && exit 1
test -z "$fq2" && exit 1
test -z "$outpref" && exit 1
for f in "$ref" "$fq1" "$fq2"; do
    if [ ! -e "$f" ]; then
        echo "FATAL: $f doesn't exist" 1>&2
        exit 1
    fi
done
if [ ! -z "$bed" ]; then
	if [ ! -e "$bed" ]; then
		echo "FATAL: bed-file $bed doesn't exist" 1>&2
		exit 1
	fi
fi

raw_bam=${outpref}.bam
vcf=${outpref}.vcf
bam=${outpref}.bam
$BWAMEM_PE_SH -f $ref -1 $fq1 -2 $fq2 -o $outpref -t $threads || exit 1
samtools index $bam
bed_arg=""
if [ ! -z "$bed" ]; then
	bed_arg="-l $bed"
fi
$LF call --verbose --call-indels -f $ref $bam -o ${vcf} $bed_arg || exit 1



