#!/bin/bash

module load anaconda/4.12.0
conda activate SVcaller

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/11.CNVkit
currentdir=`pwd`

sample_prefix=10
tumor_bam=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/Bca_WGS/10T.cs.rmdup.sort.bam
normal_bam=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/Bca_WGS/10N.cs.rmdup.sort.bam
ref=/share/home/luoylLab/zengyuchen/genome/hg38full/hg38full.fa
annotate_file=/share/home/luoylLab/zengyuchen/genome/hg38full/refFlat.txt

cnvkit.py batch ${tumor_bam} -n ${normal_bam} -m wgs -f ${ref} -p 20 --annotate ${annotate_file} -d ${currentdir}/${sample_prefix}

if [ $? -eq 0 ]; then
      touch ${currentdir}/status/ok.cnvkit.${sample_prefix}.status
    else
      echo "cnvkit failed" ${sample_prefix}
    fi






