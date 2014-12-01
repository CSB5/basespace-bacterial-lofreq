#!/bin/bash

pushd $(dirname $0)

if [ ! -e bwamem_pe.sh ]; then
    wget --no-check-certificate -nd https://github.com/CSB5/misc-scripts/raw/master/bwamem_pe.sh || exit 1
fi
chmod +x bwamem_pe.sh

if [ ! -e bwa ]; then
    if [ ! -e bwa-0.7.10.tar.bz2 ]; then
        wget --no-check-certificate 'https://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.10.tar.bz2?r=&ts=1414401784&use_mirror=softlayer-sng' || exit 1
    fi
    tar xvfj bwa-0.7.10.tar.bz2 || exit 1
    pushd bwa-0.7.10
    make || exit 1
    cp bwa ..
    popd
    rm -rf bwa-0.7.10
fi


if [ ! -e picard ]; then
    if [ ! -e picard-tools-1.120.zip ]; then
        curl -L 'https://github.com/broadinstitute/picard/releases/download/1.120/picard-tools-1.120.zip' -o picard-tools-1.120.zip | exit 1
    fi
    unzip -f picard-tools-1.120.zip || exit 1
    ln -s picard-tools-1.120 picard || exit 1
fi

popd
