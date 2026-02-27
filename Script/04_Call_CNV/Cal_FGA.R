# FACETS vcf文件计算adjusted FGA值(Fraction of genome altered)
setwd("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results")
wdir="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/HB/"
list=read.table("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/HB/id",header = F)

library(tidyverse)
total_chrlen <- as.numeric(248956422+242193529+198295559+190214555+181538259+170805979+
                             159345973+145138636+138394717+135086622+133797422+133275309+
                             114364328+107043718+101991189+90338345+83257441+80373285+
                             58617616+64444167+46709983+50818468)
res <- data.frame(SampleName = character(), adjustedFGA = numeric(), stringsAsFactors = F)

for (i in list[,1]) {
  id=paste(i,sep="")
  df <- read.table(paste(wdir,id,'/',id,".vcf.gz",sep = ""),header = F)
  df <- df %>%
  separate(V8, into = c("SVtype", "SVlen","End","Num_Mark","Nhet","Cnlr_median","Maf_R",
                        "Segcluster","Cnlr_median_cluster","Maf_R_cluster","CF_EM","TCN_EM",
                        "LCN_EM","CNV_ANN"), sep = ";")
  df$Cnlr_median <- as.numeric(str_replace(df$Cnlr_median,"CNLR_MEDIAN=",""))
  df$SVlen <- as.numeric(str_replace(df$SVlen,"SVLEN=",""))
  df_1 <- subset(df, !(V1 %in% c("chrX","chrY"))) #过滤除了chrX和chrY的行
#  df_1 <- subset(df_1, V7 %in% c("PASS"))
  df_1$TCN_EM <- as.numeric(str_replace(df_1$TCN_EM,"TCN_EM=",""))
  Mcn <- as.numeric(names(table(df_1$TCN_EM))[which.max(table(df_1$TCN_EM))])
  df_2 <- subset(df_1,!(TCN_EM %in% Mcn))
  FGA <- sum(df_2$SVlen[abs(df_2$Cnlr_median) > 0.2]) / total_chrlen
  res <- rbind(res, data.frame(SampleName = i, adjustedFGA = FGA))
}
write.table(res, file = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/FGA-HB.txt", sep = "\t", quote = F, row.names = F, col.names = T)


