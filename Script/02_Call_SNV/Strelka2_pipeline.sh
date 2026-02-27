#!/bin/bash

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/strelka2

sample_prefix=39
tumor=39T
normal=39B
currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/strelka2
data_dir=/share/home/luoylLab/zengyuchen/PROJECT/CCGA_UBC/WGS_panbam
normal_bam=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/ProcessBAM/alignData/1-88WGS/39B.cs.rmdup.sort.bam
ref=/share/home/luoylLab/zengyuchen/genome/hg38full/hg38full.fa
STRELKA_INSTALL_PATH=/share/home/luoylLab/zengyuchen/biosoft/strelka-2.9.10.centos6_x86_64
MANTA_ANALYSIS_PATH=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/strelka2

#configuration
${STRELKA_INSTALL_PATH}/bin/configureStrelkaSomaticWorkflow.py \
    --normalBam ${normal_bam}  \
    --tumorBam ${data_dir}/${tumor}.cs.rmdup.sort.bam \
    --referenceFasta ${ref} \
    --runDir ${currentdir}/${tumor}_TB


# execution on a single local machine with 20 parallel jobs
${currentdir}/${tumor}_TB/runWorkflow.py -m local -j 20


if [ $? -eq 0 ]; then
      touch ${currentdir}/status/ok.strelka2.${tumor}.status
    else
      echo "strelka2 failed" ${tumor}
    fi



