set.seed(80)
library(maftools)
#clinical information containing survival information and histology.This is optional
setwd("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/maf")
gatk_Bca_mut <- read.maf(maf="669samples_coding_0511_dupfromcase.maf.tsv.gz",verbose=FALSE)  ## read maf file as input 
vc_nonSyn <- c("Missense_Mutation", 
               "Nonsense_Mutation", 
               "Frame_Shift_Ins", 
               "Frame_Shift_Del", 
               "In_Frame_Ins", 
               "In_Frame_Del", 
               "Splice_Site", 
               "ncRNA_exonic",  
               "unknown",       
               "upstream;downstream",
               "upstream")  # 添加自定义分类/可根据需要添加其他分类

mutsig.corrected = prepareMutSig(maf = gatk_Bca_mut)
write.table(mutsig.corrected, file = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/corrected/669samples_coding_0511_dupfromcase_mutsig.corrected.tsv",sep = "\t",col.names = F, row.names=F)
