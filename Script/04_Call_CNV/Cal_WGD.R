setwd("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/")
wdir="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/HB/"
# 读入一个样本名称文本 list
list <- read.table("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/HB/id",header = F)
# 22条染色体长度总和
total_chrlen <- as.numeric(248956422+242193529+198295559+190214555+181538259+170805979+
                             159345973+145138636+138394717+135086622+133797422+133275309+
                             114364328+107043718+101991189+90338345+83257441+80373285+
                             58617616+64444167+46709983+50818468)
# 新建一个空白数据框 res
res <- data.frame(SampleName = character(), WGD = numeric(), stringsAsFactors = F)
for (i in list[,1]) {
  id = paste(i,sep="")
  df <- read.table(paste(wdir,id,"/",id,".vcf.gz",sep = ""),header = F)
  df_2 <- strsplit(as.character(df$V8),";")
  df_2 <- as.data.frame(do.call(rbind,df_2))
  colnames(df) <- c("CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO")
  df_3 <- cbind(df,df_2) #V12为Total_cn, V13为minor_cn
  library(tidyverse)
  df_3$V12 <- as.numeric(str_replace(df_3$V12,"TCN_EM=",""))
  df_3$V13 <- as.numeric(str_replace(df_3$V13,"LCN_EM=",""))
  df_3$V13[is.na(df_3$V13)] <- 0 # 若minor_cn=NA，那么用0取代
  df_3$major_cn <- df_3$V12-df_3$V13 # 得到minor_cn and major_cn
  # 过滤chrX and chrY
  df_4 <- subset(df_3, grepl("^chr([1-9]|1[0-9]|2[0-2])$",CHROM))
  df_4$V2 <- as.numeric(str_replace(df_4$V2,"SVLEN=",""))
  # cal WGD 
  wgd <- sum(df_4$V2[df_4$major_cn >=2]) / total_chrlen
  # write results
  res <- rbind(res, data.frame(SampleName = i, WGD = wgd))
}
# 指定一个输出文件名称路径
write.table(res, file = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/WGD-HB.txt",sep = "\t",quote = F, row.names = F, col.names = T)
