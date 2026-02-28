#!/bin/bash

sample_prefix=1U
ref=/share/home/luoylLab/zengyuchen/genome/hg38full/hg38full.fa
data_dir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/ProcessBAM/alignData/Urine_WGS
tumor=1U
normal=1N
source activate SVcaller
mkdir -p /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/SvABA/${sample_prefix}
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/SvABA/${sample_prefix}

svaba run -t ${data_dir}/${tumor}.cs.rmdup.sort.bam -n /share/home/luoylLab/zengyuchen/PROJECT/CCGA_UBC/WGS_panbam/${normal}.cs.rmdup.sort.bam -a ${sample_prefix} -p 20 -D /share/home/luoylLab/zengyuchen/genome/dbsnp_indel.vcf -a somatic_run -G ${ref}

if [ $? -eq 0 ]; then
  touch /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/SvABA/status/ok.svaba.${sample_prefix}.status
else
  echo "svaba failed" ${sample_prefix}
fi

