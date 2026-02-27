# dndscv install and test ! #
library(devtools)
#install_github("im3sanger/dndscv")
library(dndscv)
library(data.table)
# For Hg19 version ###########################################################################################################################
df <- fread('~/Desktop/HIM-CRC/CRC336sams.coding.maf.hg19.gz',sep = "\t",header = T)
df_1 = df[,c(13,5,6,11,12)]
library(tidyverse)
colnames(df_1) = c("sampleID","chr","pos","ref","mut")
df_1$chr = str_replace(df_1$chr,"chr","")
res <- dndscv(df_1)
             # max_muts_per_gene_per_sample = 10,
              #max_coding_muts_per_sample = 8000)
sel_cv <- res$sel_cv
genes <- sel_cv[,c("gene_name","qglobal_cv")]
signif_genes = sel_cv[sel_cv$qglobal_cv<0.1, c("gene_name","qglobal_cv")]
###############################################################################################################################################

# For Hg38 version ###########################################################################################################################
load("/Users/edcee/Desktop/染色体碎裂ecDNA_UBC/R\ script/covariates_hg19_hg38_epigenome_pcawg.rda")
df = read.table("~/Desktop/duodian-WGS_coding.maf.gz",sep = "\t",header = T)
df_1 = df[,c(13,5,6,11,12)]
colnames(df_1) = c("sampleID","chr","pos","ref","mut")
df_1$chr = str_replace(df_1$chr,"chr","")
test = dndscv(df_1, refdb = "/Users/edcee/Desktop/染色体碎裂ecDNA_UBC/R\ script/RefCDS_human_GRCh38_GencodeV18_recommended.rda", cv = covs)
sel_cv = test$sel_cv
###############################################################################################################################################

