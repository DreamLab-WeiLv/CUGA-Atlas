#!/bin/bash

cat file | while read -r a1 a2
do
normal=${a2}
tumor=${a1}
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/Annovar/GC_demo/${normal}-vs-${tumor}
awk -F "\t" 'BEGIN{OFS="\t"} NR==1 {print $0}' ${normal}-vs-${tumor}.hg38_multianno.txt > ${tumor}.title.txt
awk -F "\t" 'BEGIN{OFS="\t"} $131<=0.01 && $132<=0.01 || $22=="Conflicting_interpretations_of_pathogenicity" || $22=="Pathogenic" || $22=="Likely_pathogenic" {print $0}' ${normal}-vs-${tumor}.hg38_multianno.txt > ${normal}-vs-${tumor}.filtered.txt

cat ${tumor}.title.txt ${normal}-vs-${tumor}.filtered.txt > ${tumor}.filtered.txt
gzip ${tumor}.filtered.txt
mv ${tumor}.filtered.txt.gz ${normal}-vs-${tumor}.hg38_multianno.txt.gz
rm ${tumor}.title.txt
rm ${normal}-vs-${tumor}.filtered.txt
done
##gz结尾文件为过滤后的文件
