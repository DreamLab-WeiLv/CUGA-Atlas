## 01 get input for ISTAT analysis ====================================================================================================
library(readxl)
library(bedtoolsr)
sv <- readxl::read_xlsx("~/Desktop/all-CUGA-ecDNA/SV/Sv-hotspot.xlsx",sheet = 1)
library(dplyr)
library(tidyr)
sc <- readxl::read_xlsx("~/Desktop/all-CUGA-ecDNA/ecDNA/Focal-region.xlsx",sheet = 1)
colnames(sc)[2] <- "boundaries"
sc <- as.data.frame(sc)
sc_amp <- sc[sc$...3=="AMP",]
bed_data <- sc_amp %>%
  tidyr::extract(boundaries, 
          into = c("chrom", "start", "end"), 
          regex = "(.+):(.+)-(.+)", 
          remove = FALSE) %>%
  mutate(
    start = as.numeric(start) - 1, 
    end = as.numeric(end)
  ) %>%
  select(chrom, start, end, cytoband) 

# get bed files
sv_bed <- sv[,1:3]
sc_bed <- bed_data[,1:3]
class(sv_bed$End_bp) # numeric
class(sc_bed$start)
#devtools::install_github("PhanstielLab/bedtoolsr")
library(bedtoolsr)
overlap <- bt.intersect(sv_bed,sc_bed)
setwd("~/Desktop/all-CUGA-ecDNA/ecDNA/")
write.table(sv_bed,'SV_region_0210.bed',sep = '\t',quote = F,row.names = F,col.names = F)
write.table(sc_bed,'Focal_GISTIC_AMP_region.bed',sep = '\t',quote = F,row.names = F,col.names = F)
write.table(overlap,'SVnew_GISTICAMP_overlap.bed',sep = '\t',quote = F,row.names = F,col.names = F)

sort -k1,1V -k2,2n -k3,3n SV_region.bed > SV_region_sorted.bed
sort -k1,1V -k2,2n -k3,3n Focal_GISTIC_AMP_region.bed > Focal_GISTIC_AMP_region_sort.bed
sort -k1,1V -k2,2n -k3,3n SV_GISTIC_AMP_overlap.bed > SV_GISTIC_AMP_overlap_sort.bed
bedtools merge -i SV_region_sorted.bed > SV_region_sorted_merge.bed
bedtools merge -i Focal_GISTIC_AMP_region_sort.bed > Focal_GISTIC_AMP_region_sort_merge.bed
bedtools merge -i SV_GISTIC_AMP_overlap_sort.bed > SV_GISTIC_AMP_overlap_sort_merge.bed

## 02 Run ISTAT analysis ====================================================================================================
#!/bin/bash
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/SVnew_GISTIC_AMP
/share/home/luoylLab/zengyuchen/biosoft/ISTAT-1.0.0/bin/istat SV_region_sorted_merge.bed Focal_GISTIC_AMP_region_sort_merge.bed hg38_chrom_sizes.txt 10000 SVnew_GISTIC_AMP_overlap_10000_pval.txt p

## 03 Plot ISTAT results chrmosome bar  =====================================================================================
#!/bin/bash
module load anaconda/4.12.0
conda activate SVcaller
python /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/Plot/istat_overlap_karyogram_plot.py  ## istat_overlap_karyogram_plot.py need change the file name(in line 123/131/139/226)






