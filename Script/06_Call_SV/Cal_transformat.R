##将SURVIVIOR结果转化为统一格式
library(tidyverse)
library(stringr)
library(dplyr)
library(hash)

dir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/HB/results/"
##======================= xunhuan ==============================================
list=read.table("~/PROJECT/chromothripsis/20.Merge_SV/shell/linshi",header = F)
for (i in list[,1]) {
  id = paste0(i)
  df = read.table(paste(dir,"mergeSV_",id,".sv.vcf",sep=""),header = F)
  df = df[,-c(9:ncol(df))]
  colnames(df)=c("CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO")
  df_1 = strsplit(as.character(df$INFO),';') 
  df_1 = as.data.frame(do.call(rbind,df_1)) #分割出FORMAT列
  df = cbind(df,df_1)#合并分割出的列，形成新的数据框
  colnames(df) <- c("CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO","SUPP","SUPP_VEC","SVLEN",
                    "SVTYPE","SVMETHOD","CHROM2","POS2","CIPOS","CIEND","STRANDS")
  
  df_nw = as.data.frame(matrix(nrow = nrow(df),ncol = 12)) #创建空白数据框
  colnames(df_nw)=c("chrom1","start1","end1","chrom2","start2","end2","sv_id",
                    "strand1","strand2","svclass","svmethod","rowid") #给数据框命名列名
  #设置svmethod，并提取突变类型
  df_nw$svclass = df$SVTYPE
  df_nw$svclass = gsub("SVTYPE=","",df_nw$svclass)
  #获得chrom2信息，加在df最后一列
  df$chrom2 = df$CHROM2
  df$chrom2 = gsub("CHR2=","",df$chrom2)
  #设置染色体大小比较顺序
  shunxu = hash('chr1'=1,'chr2'=2,'chr3'=3,'chr4'=4,'chr5'=5,'chr6'=6,'chr7'=7,'chr8'=8,'chr9'=9,
                'chr10'=10,'chr11'=11,'chr12'=12,'chr13'=13,'chr14'=14,'chr15'=15,'chr16'=16,
                'chr17'=17,'chr18'=18,'chr19'=19,'chr20'=20,'chr21'=21,'chr22'=22,'chrX'=23,
                'chrY'=24,'chrM'=25,'chr26'=26)
  #把非字典中的染色体改为chr26
  for (i in 1:nrow(df)) {
    if (df[i,1]%in%keys(shunxu)=="FALSE") {
      df[i,1]=c("chr26")
    } 
  }
  for (j in 1:nrow(df)) {
    if (df[j,]$chrom2%in%keys(shunxu)=="FALSE") {
      df[j,]$chrom2=c("chr26")
    }
  }
  
  #设置TRA行和非TRA行
  noBND=c(which(ifelse(df_nw[,10]=="TRA",1,0)==0)) #定义非TRA的行
  yesBND=c(which(ifelse(df_nw[,10]=="TRA",1,0)==1)) #定义TRA的行
  #先填入非TRA的chrom1和chrom2,start1，start2,end1,end2,id信息
  df_nw[noBND,]$chrom1 = df[noBND,]$CHROM
  df_nw[noBND,]$chrom2 = df[noBND,]$CHROM
  df_nw[noBND,]$start1 = df[noBND,]$POS
  df_nw[noBND,]$end1 = df[noBND,]$POS+1
  df_nw[noBND,]$start2 = df[noBND,]$POS2
  df_nw[noBND,]$start2 = as.numeric(gsub("END=","",df_nw[noBND,]$start2))
  df_nw[noBND,]$end2 = as.numeric(df_nw[noBND,]$start2)+1
  df_nw[noBND,]$sv_id = df[noBND,]$ID
  df_nw[yesBND,]$sv_id = df[yesBND,]$ID 
  
  df$STRANDS = gsub("STRANDS=","",df$STRANDS)
  #判断非TRA的strand1，strand2信息
  for (strand2 in noBND) {
    if (df_nw[strand2,10]=="DEL") {
      df_nw[strand2,8] = "+"
      df_nw[strand2,9] = "-"
    }else if (df_nw[strand2,10]=="DUP") {
      df_nw[strand2,8] = "-"
      df_nw[strand2,9] = "+"
    }else{
      next
    }
  }
  yesINV=c(which(ifelse(df_nw[,10]=="INV",1,0)==1)) #定义INV的行
  df_nw[yesINV,]$strand1= substring(df[yesINV,]$STRANDS,1,1)
  df_nw[yesINV,]$strand2= substring(df[yesINV,]$STRANDS,2,2)
  #判断TRA的信息
  for (chrom in yesBND) {
    if(shunxu[[df[chrom,]$chrom2]] < shunxu[[df[chrom,1]]]) {
      df_nw[chrom,1] = df[chrom,]$chrom2
      df_nw[chrom,4] = df[chrom,1]
    }else if (shunxu[[df[chrom,]$chrom2]] >= shunxu[[df[chrom,1]]]) {
      df_nw[chrom,1] = df[chrom,1]
      df_nw[chrom,4] = df[chrom,]$chrom2
    }else{
      next}
  }
  
  for (pos1 in yesBND) {
    if(shunxu[[df[pos1,]$chrom2]] < shunxu[[df[pos1,1]]]) {
      df_nw[pos1,2] = df[pos1,]$POS2
      df_nw[pos1,5] = df[pos1,2]
    }else if (shunxu[[df[pos1,]$chrom2]] >= shunxu[[df[pos1,1]]]) {
      df_nw[pos1,2] = df[pos1,2]
      df_nw[pos1,5] = df[pos1,]$POS2
    }else{
      next}
  }
  
  df_nw$start1 = as.numeric(gsub("END=","",df_nw$start1))
  df_nw$start2 = as.numeric(gsub("END=","",df_nw$start2))
  df_nw[yesBND,3] = df_nw[yesBND,2]+1
  df_nw[yesBND,6] = df_nw[yesBND,5]+1
  
  for (strand in yesBND) {
    if(shunxu[[df[strand,]$chrom2]] < shunxu[[df[strand,1]]]) {
      df_nw[strand,8] = substring(df[strand,]$STRANDS,2,2)
      df_nw[strand,9] = substring(df[strand,]$STRANDS,1,1)
    }else if (shunxu[[df[strand,]$chrom2]] >= shunxu[[df[strand,1]]]) {
      df_nw[strand,8] = substring(df[strand,]$STRANDS,1,1)
      df_nw[strand,9] = substring(df[strand,]$STRANDS,2,2)
    }else{
      next}
  }
  
  #添加svmethod、rowid信息
  df_nw$svmethod = c("SURVIVOR")
  df_nw[,12] = paste(id,"_",c(row.names(df_nw)),sep = "")
  
  #写出文件
  write.table(df_nw,
              file = paste(dir,"transFormat/mergeSV_",id,".trans.sv.vcf",sep=""),sep="\t",quote=F,row.names = F)
}

