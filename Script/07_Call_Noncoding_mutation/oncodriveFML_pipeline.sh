############## Step1. Prepare oncodriveFML input files ###############################################################################
library(tidyverse)
library(dplyr)
raw_input <- read.table("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/hg38To19/UC_Combine448.maf.hg19.gz",header = T,sep = "\t")
onco_input <- as.data.frame(matrix(nrow = nrow(raw_input),ncol = 5)) 
colnames(onco_input) <- c("CHROMOSOME", "POSITION", "REF", "ALT", "SAMPLE")
#input raw info
onco_input[,1] <- raw_input[,5]
onco_input[,2] <- raw_input[,6]
onco_input[,3] <- raw_input$Reference_Allele
onco_input[,4] <- raw_input$Tumor_Seq_Allele2
onco_input[,5] <- raw_input$Tumor_Sample_Barcode
#process infomation
onco_input[,1] = str_replace(onco_input[,1],"chr","") #remove chr
#output oncodriveFML-inputfile
write.table(onco_input,"/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/14.OncodriveFML/input/UC_Combine448.hg19.maf", quote = F, row.names = F, sep = "\t")

############## Step2. Run oncodriveFML ###############################################################################

#!/bin/bash

module load anaconda/4.12.0
conda activate oncodrive

input=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/14.OncodriveFML/input/UC_Combine448.hg19.maf.gz

region=~/PROJECT/chromothripsis/14.OncodriveFML/example/hg19_region/02_promoters_splice_sites_10bp.regions
conf=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/14.OncodriveFML/example/hg19_region/PanCanAtlas.conf
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/14.OncodriveFML

oncodrivefml -i ${input} -e ${region} --type noncoding --sequencing wgs --output UC448_promoter



