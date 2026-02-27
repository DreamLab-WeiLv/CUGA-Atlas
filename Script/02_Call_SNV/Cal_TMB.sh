#!/bin/bash

maf=GC_demo.coding.maf.gz  ## maf file
sample=GC_demo.coding  ## output prefix
ref=/share/home/luoylLab/zengyuchen/genome/GRCh38.p13/GRCh38.p13.genome.fa ## reference 

perl ToBed_SBS.pl ../maf/${maf} ${sample}_coding.bed
perl GetContexts.pl $ref ${sample}_coding.bed ${sample}_coding_SBS_contexts.txt
perl Add_APOBEC.pl ${sample}_coding_SBS_contexts.txt ../maf/${maf} ../maf/${sample}.coding.APOBEC.tsv
perl TMB_Stat.pl ../maf/${sample}.coding.APOBEC.tsv ../maf/${sample}.coding.SomaticMutationsPerMb.tsv 
