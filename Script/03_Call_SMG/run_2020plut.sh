#!/bin/bash
## install 2020plut-1.2.3 and need conda env which had snakemake
cd /share/home/luoylLab/zengyuchen/biosoft/2020plus-1.2.3

## ref need hg19 !!!
snakemake -s  Snakefile pretrained_predict -p -w 1000 --cores 1 \
 --config mutations="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/hg38To19/output.maf.hg19.gz" output_dir="output_hg19" trained_classifier="data/2020plus_10k.Rdata"  
