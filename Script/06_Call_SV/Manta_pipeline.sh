#!/bin/bash

tumor=1U
normal=1N
sample_prefix=1U
data_dir=/share/home/luoylLab/zengyuchen/PROJECT/CCGA_UBC/WGS_panbam
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Manta
currentdir=`pwd`

##设置Python2环境 !!!
source activate Python2
source /share/home/luoylLab/zengyuchen/biosoft/source_me

##echo '============1.run Manta ============'
/share/home/luoylLab/zengyuchen/biosoft/manta-1.6.0.centos6_x86_64/bin/configManta.py \
               --normalBam ${data_dir}/${normal}.cs.rmdup.sort.bam \
               --tumorBam /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/ProcessBAM/alignData/Urine_WGS/${tumor}.cs.rmdup.sort.bam \
               --referenceFasta /share/home/luoylLab/zengyuchen/genome/hg38full/hg38full.fa \
               --runDir ${currentdir}/${sample_prefix} 
${currentdir}/${sample_prefix}/runWorkflow.py -j 10 

##echo '============2.transfer INV =========='
gzip -d -c ${currentdir}/${sample_prefix}/results/variants/somaticSV.vcf.gz > ${currentdir}/${sample_prefix}/results/variants/somaticSV.vcf
/share/home/luoylLab/zengyuchen/biosoft/manta-1.6.0.centos6_x86_64/libexec/convertInversion.py /share/apps/softwares/samtools-1.11/bin/samtools /share/home/luoylLab/zengyuchen/genome/hg38full/hg38full.fa ${currentdir}/${sample_prefix}/results/variants/somaticSV.vcf > ${currentdir}/${sample_prefix}/results/variants/${sample_prefix}.sv.vcf 
 

##echo '===========3.filter pass==============='
awk -F "\t" 'BEGIN{OFS="\t"} $7 == "PASS" {print $0}' ${currentdir}/${sample_prefix}/results/variants/${sample_prefix}.sv.vcf > ${currentdir}/fin/${sample_prefix}.sv.manta.pass.vcf

if [ $? -eq 0 ]; then
      touch /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Manta/status/ok.manta.${tumor}.status
    else
      echo "manta failed" ${tumor}
    fi
