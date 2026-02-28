#!/bin/bash

tumor=1U
normal=1N
data_dir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/ProcessBAM/alignData/Urine_WGS
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Delly
currentdir=`pwd`

source activate SVcaller
source /share/home/luoylLab/zengyuchen/biosoft/source_me

##echo '====== 1. delly call ========================================
delly call -o ${currentdir}/calls/${tumor}.sv.bcf -g /share/home/luoylLab/zengyuchen/genome/hg38full/hg38full.fa\
   ${data_dir}/${tumor}.cs.rmdup.sort.bam \
   /share/home/luoylLab/zengyuchen/PROJECT/CCGA_UBC/WGS_panbam/${normal}.cs.rmdup.sort.bam

##echo '====== 2. get tsvfile ========================================
echo -e "${tumor}\ttumor\n${normal}\tcontrol" > ${currentdir}/tsv_file/${tumor}.sample.tsv 

##echo '====== 3. delly filter ========================================
delly filter -f somatic -o ${currentdir}/filter/${tumor}.sv.ft.bcf \
   -s ${currentdir}/tsv_file/${tumor}.sample.tsv \
   ${currentdir}/calls/${tumor}.sv.bcf

##echo '====== 4. transfer to vcf ========================================
/share/apps/softwares/bcftools-1.11/bin/bcftools view ${currentdir}/filter/${tumor}.sv.ft.bcf > ${currentdir}/results/${tumor}.sv.delly.ft.vcf

##echo '====== 5. delly filter pass ========================================
file_list=`ls /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Delly/results`
for i in ${file_list}
do
awk -F "\t" 'BEGIN{OFS="\t"} $7 == "PASS" {print $0}' /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Delly/results/${i} > /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Delly/fin/${i}
done

if [ $? -eq 0 ]; then
      touch /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Delly/status/ok.delly.${tumor}.status
    else
      echo "delly failed" ${tumor}
    fi
