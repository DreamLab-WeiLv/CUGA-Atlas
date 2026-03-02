#!/bin/bash
## Step1. get PASS vcf ##################################################################################################
ln -s /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/UBC/PASS/*.vcf /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/UBC/.
## Step1. get SV vcf ##################################################################################################
d <- read.table('~/Desktop/CUGA_669samples_SV.vcf',sep = "\t",header = T)
d1 <- d[,c(1,2,3,4,5,6,8,9,12)]
library(tidyr)
library(dplyr)
df <- d1 %>%
  mutate(sample = sub("_\\d+$", "", sample)) 
df$chrom1 <- gsub("chr","",df$chrom1)
df$chrom2 <- gsub("chr","",df$chrom2)
df$chrom1 <- as.integer(df$chrom1)
df$chrom2 <- as.integer(df$chrom2)
df <- na.omit(df)
dir.create('~/SV_input/')
setwd('~/SV_input/')
for (i in unique(df$sample)) {
  tmp <- df[df$sample==i,]
  write.table(tmp,paste0(i,".bedpe"),sep = "\t",quote = F,row.names = F)
}

## Step2. get input matrix ##################################################################################################
module load anaconda/4.12.0
conda activate /share/home/luoylLab/zengyuchen/.conda/envs/Sigpro
python3 get_SVmatrix_input.py  # for SV signature
python3 get_matrix.py # for SNV signature
python3 get_CNVmatrix_input.py  # for CNV signature


