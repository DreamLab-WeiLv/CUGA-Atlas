#!/bin/bash

tumor=63T
normal=63N
data_dir=/share/home/luoylLab/zengyuchen/PROJECT/CCGA_UBC/WGS_panbam

source activate Python2

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/prepare
currentdir=`pwd`

echo '============1. Align the tumor data==============='

echo '===========2. Extract the tumor discordant paired-end alignments.======='
samtools view -b -F 1294 ${data_dir}/addLB/${tumor}.cs.rmdup.sort.bam > ${currentdir}/${tumor}.discordants.unsorted.bam
samtools sort -@ 12 -o ${currentdir}/${tumor}.discordants.bam ${currentdir}/${tumor}.discordants.unsorted.bam

echo '============3. Extract the tumor split-read alignments================='

samtools view -h ${data_dir}/addLB/${tumor}.cs.rmdup.sort.bam \
    | /share/home/luoylLab/zengyuchen/biosoft/lumpy_scripts/extractSplitReads_BwaMem -i stdin \
    | samtools view -Sb - \
    > ${currentdir}/${tumor}.splitters.unsorted.bam
samtools sort -@ 12 -o ${currentdir}/${tumor}.splitters.bam ${currentdir}/${tumor}.splitters.unsorted.bam

echo '==============4.Align the normal data========================='

echo '==============5. Extract the normal discordant paired-end alignments.================'
samtools view -b -F 1294 ${data_dir}/${normal}.cs.rmdup.sort.bam > ${currentdir}/${normal}.discordants.unsorted.bam
samtools sort -@ 12 -o ${currentdir}/${normal}.discordants.bam ${currentdir}/${normal}.discordants.unsorted.bam

echo '==============6. Extract the normal split-read alignments========================'
samtools view -h ${data_dir}/${normal}.cs.rmdup.sort.bam \
    | /share/home/luoylLab/zengyuchen/biosoft/lumpy_scripts/extractSplitReads_BwaMem -i stdin \
    | samtools view -Sb - \
    >${currentdir}/${normal}.splitters.unsorted.bam
samtools sort -@ 12 -o ${currentdir}/${normal}.splitters.bam ${currentdir}/${normal}.splitters.unsorted.bam

echo '==============7.run_lumpy============================'

lumpyexpress \
    -B ${data_dir}/addLB/${tumor}.cs.rmdup.sort.bam,${data_dir}/${normal}.cs.rmdup.sort.bam \
    -S ${currentdir}/${tumor}.splitters.bam,${currentdir}/${normal}.splitters.bam \
    -D ${currentdir}/${tumor}.discordants.bam,${currentdir}/${normal}.discordants.bam \
    -o /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/out_vcf/1-88/lumpy_${tumor}.vcf

echo '==============8. Run svtyper ========================'
svtyper \
-B /share/home/luoylLab/zengyuchen/PROJECT/CCGA_UBC/WGS_panbam/addLB/${tumor}.cs.rmdup.sort.bam,/share/home/luoylLab/zengyuchen/PROJECT/CCGA_UBC/WGS_panbam/${normal}.cs.rmdup.sort.bam \
-l /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/json/${tumor}.bam.json \
-i /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/out_vcf/1-88/lumpy_${tumor}.vcf > /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/out_vcf/1-88/lumpy_${tumor}.sv.vcf


if [ $? -eq 0 ]; then
      touch /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/status/ok.svtyper.${tumor}.status
    else
      echo "svtyper failed" ${tumor}
    fi

rm -rf /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/prepare/${normal}.discordants.unsorted.bam
rm -rf /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/prepare/${tumor}.discordants.unsorted.bam
rm -rf /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/prepare/${normal}.splitters.unsorted.bam
rm -rf /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/lumpy/prepare/${tumor}.splitters.unsorted.bam






