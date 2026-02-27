#!/bin/bash

#run MutSigCV
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig
dir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig
MutSigCV=/share/home/luoylLab/zengyuchen/biosoft/MutSigCV_1.41/run_MutSigCV.sh
MatlabMCR=/share/home/luoylLab/zengyuchen/biosoft/MatlabMCR/v901
exome_coverage=/share/home/luoylLab/zengyuchen/biosoft/MutSigCV_1.41/Dependent/exome_full192.coverage.txt
gene_covariates=/share/home/luoylLab/zengyuchen/biosoft/MutSigCV_1.41/Dependent/gene.covariates.txt
mutation_file=/share/home/luoylLab/zengyuchen/biosoft/MutSigCV_1.41/Dependent/mutation_type_dictionary_file.txt
chr_hg19=/share/home/luoylLab/zengyuchen/biosoft/MutSigCV_1.41/Dependent/chr_files_hg19

sample_prefix=CRC336sams.coding ## the same as hg38tohg19.sh
maf=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/${sample_prefix}_mutsig.hg19.corrected.tsv

perl shell/corrected.pl ${dir}/corrected/${sample_prefix}_mutsig.corrected.tsv ${dir}/hg38To19/${sample_prefix}.maf.hg19.gz ${dir}/${sample_prefix}_mutsig.hg19.corrected.tsv

sh ${MutSigCV} ${MatlabMCR} ${maf} ${exome_coverage} ${gene_covariates} results/${sample_prefix} ${mutation_file} ${chr_hg19}



