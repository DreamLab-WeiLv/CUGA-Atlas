library(ShatterSeek)
library(GenomicRanges)
library(dplyr)
library(tidyverse)
## CV.sample is a data.frame with colums: chr, start, end, total_cn
cnvdir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/duodian-WGS-0808/"
svdir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/duodian-WGS/results/transFormat/"
savedir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/Shatterseek/duodian-WGS/"
list=read.table("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/shell/linshi3",header = F)
for (i in list[,1]) {
  tryCatch({
  id = paste0(i)
  CV.sample = read.table(paste(cnvdir,i,"/",i,"_cnvkit_output/",i,".cs.rmdup.sort.call.cns",sep = ""),header = T)
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
  #过滤
  all_data = chromothripsis@chromSummary
  # create a column with the intrachromosomal SVs count for the cluster
  all_data$number_intrachromosomal_SVs = all_data %>% dplyr::select(number_DEL,number_DUP,number_h2hINV,number_t2tINV) %>% apply(1,sum)
  
  # 1st High Confidence filter
  filt1 = all_data$number_intrachromosomal_SVs >= 6
  filt2 = all_data$max_number_oscillating_CN_segments_2_states >= 7
  filt3 = all_data$pval_fragment_joins >= 0.05
  filt4 = (all_data$chr_breakpoint_enrichment <= 0.05) | (all_data$pval_exp_chr <= 0.05)
  HC1 = (filt1) & (filt2) & (filt3) & (filt4)
  HC1[is.na(HC1)] <- FALSE
  all_data$HC1 <- HC1
  
  # 2nd High Confidence filter
  filt1 = all_data$number_intrachromosomal_SVs >= 3
  filt2 = all_data$number_TRA >= 4
  filt3 = all_data$max_number_oscillating_CN_segments_2_states >= 7
  filt4 = all_data$pval_fragment_joins >= 0.05
  HC2 = (filt1) & (filt2) & (filt3) & (filt4)
  HC2[is.na(HC2)] <- FALSE
  all_data$HC2 <- HC2
  
  # 3rd High Confidence filter
  filt1 = all_data$clusterSize_including_TRA >= 40
  filt2 = all_data$pval_fragment_joins >= 0.05
  HC3gte40 = (filt1) & (filt2)
  HC3gte40[is.na(HC3gte40)] <- FALSE
  all_data$HC3gte40 <- HC3gte40
  
  # Low Confidence filter
  filt1 = all_data$number_intrachromosomal_SVs >= 6
  filt2 = (all_data$max_number_oscillating_CN_segments_2_states >= 4) & (all_data$max_number_oscillating_CN_segments_2_states <= 6)
  filt3 = all_data$pval_fragment_joins >= 0.05
  filt4 = (all_data$chr_breakpoint_enrichment <= 0.05) | (all_data$pval_exp_chr <= 0.05)
  LC1 = (filt1) & (filt2) & (filt3) & (filt4)
  LC1[is.na(LC1)] <- FALSE
  all_data$LC1 <- LC1
  
  # all_data$HCany if TRUE means a Chromothripsis event has occurred
  all_data$HCany <- all_data$HC1 | all_data$HC2 | all_data$HC3gte40
  write.table(all_data,
              paste(savedir,"St_",id,".txt",sep = ""),sep = "\t",quote = F,row.names = F)
  }, error = function(e) {
    print(paste("Error in column", i, ":", conditionMessage(e)))
  })
}
