#!/bin/bash

cat file|while read -r a1 a2
do
# !!! 01. Merge Mutect2 and strelka2 Indel vcf #
cd ~/PROJECT/28.SNVmerge
sample=${a1}
Mutect2Dir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk/FinalVCF/INDEL/
Mutect2Vcf=${Mutect2Dir}/${sample}.m2.SplitMulti.indel.vcf
strelka2Dir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/10.strelka2/FinalVCF/SNP/GC_demo
strelka2Vcf=${strelka2Dir}/${sample}.indel.vcf.gz

mkdir -p ~/PROJECT/chromothripsis/28.SNVmerge/MergeIndel/GC_demo
bedtools intersect -u -a ${Mutect2Vcf} -b ${strelka2Vcf} > MergeIndel/duodian-WGS/${sample}_merge.indel.vcf

# 02. Merge Indel and SNP vcf ##
snp=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk/FinalVCF/SNP/GC_demo/${sample}.m2.SplitMulti.snp.vcf
mergeIndel=~/PROJECT/chromothripsis/28.SNVmerge/MergeIndel/duodian-WGS/${sample}_merge.indel.vcf

cat ${snp} ${mergeIndel} > ~/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/duodian-WGS-tmp/${sample}.fin.snp.indel.vcf
# 03. Filter PASS
gatk=/share/apps/softwares/gatk-4.2.5.0/gatk
ref=~/genome/GRCh38.p13/GRCh38.p13.genome.fa
unpassDir=~/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/

mkdir -p ~/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/GC_demo/PASS
${gatk} --java-options "-Xmx40G -Djava.io.tmdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk/tmp" SelectVariants -R ${ref} -V ${unpassDir}/${sample}.fin.snp.indel.vcf --exclude-filtered -O ${unpassDir}/PASS/${sample}.pass.fin.snp.indel.vcf
done


