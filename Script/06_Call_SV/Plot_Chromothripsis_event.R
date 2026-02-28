library(ShatterSeek)
library(GenomicRanges)
library(dplyr)
library(tidyverse)
library(gridExtra)
library(cowplot)
## CV.sample is a data.frame with colums: chr, start, end, total_cn
cnvdir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/11.CNVkit/duodian-WGS/"
svdir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/duodian-WGS/results/transFormat/"
savedir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/Shatterseek/Plot/"
list=read.table("~/PROJECT/chromothripsis/20.Merge_SV/shell/linshi1",header = F)
for (i in list[,1]) {
  tryCatch({
  id = paste0(i)
  CV.sample = read.table(paste(cnvdir,i,"/",i,".cs.rmdup.sort.call.cns",sep = ""),header = T)
  SV.sample = read.table(paste(svdir,"mergeSV_",id,".trans.sv.vcf",sep = ""),header = T)
  chromlist = c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8",
                "chr9","chr10","chr11","chr12","chr13","chr14","chr15",
                "chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX")  # 过滤掉其他染色体
  SV.sample=SV.sample %>%
    filter(SV.sample$chrom1%in%chromlist) #过滤chrY及chrU
  SV.sample=SV.sample %>%
    filter(SV.sample$chrom2%in%chromlist)
  CV.sample=CV.sample %>%
    filter(CV.sample$chromosome%in%chromlist)
  SV.sample[,1] = str_replace(SV.sample$chrom1,"chr","")
  SV.sample[,4] = str_replace(SV.sample$chrom2,"chr","")
  CV.sample[,1] = str_replace(CV.sample$chromosome,"chr","") # 去除"chr"
  SV.sample = na.omit(SV.sample)

  SV_data <- SVs(chrom1=as.character(SV.sample$chrom1),
                 pos1=as.numeric(SV.sample$start1),
                 chrom2=as.character(SV.sample$chrom2),
                 pos2=as.numeric(SV.sample$start2),
                 SVtype=as.character(SV.sample$svclass),
                 strand1=as.character(SV.sample$strand1),
                 strand2=as.character(SV.sample$strand2))
  CN_data <- CNVsegs(chrom=as.character(CV.sample$chromosome),
                     start=CV.sample$start,
                     end=CV.sample$end,
                     total_cn=CV.sample$cn)
  chromothripsis <- shatterseek(SV.sample=SV_data,
                                     seg.sample=CN_data,
                                     genome="hg38")
  chrom_1 <- 
  #chrom_2 <- "chr11"
  New_name <- i
  plots_1 <- plot_chromothripsis(ShatterSeek_output = chromothripsis, 
                                 chr = chrom_1, sample_name= New_name, genome="hg38")
  plots_1 <- arrangeGrob(plots_1[[1]],
                          plots_1[[2]],
                          plots_1[[3]],
                          plots_1[[4]],
                        nrow=4,ncol=1,heights=c(0.2,.6,.3,.4))
  p <- plot_grid(plots_1)

  pdf(paste0(savedir,id,"_",chrom_1,'.pdf'),width=6)
  print(p)
  dev.off()
}, error = function(e) {
    print(paste("Error in column", i, ":", conditionMessage(e)))
  })
}
