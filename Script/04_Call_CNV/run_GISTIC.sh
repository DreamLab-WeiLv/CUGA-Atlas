#!/bin/bash

## 01 get segment file from CNVKit results
module load anaconda/4.12.0
conda activate SVcaller
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/11.CNVkit
currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/11.CNVkit/duodian-WGS
savedir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/15.GISTIC2/segment/CUGA/CNVkit/
mkdir -p $savedir
cat /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/11.CNVkit/duodian-WGS/list | while read i
do
sample_prefix=${i}
cnvkit.py export seg ${currentdir}/${i}/${i}.cs.rmdup.sort.call.cns -o ${savedir}/${i}.seg
done

## 01.2 get segment file from FACET results  (in R)
#Facets output transfer to segment for GISTIC !
library(tidyverse)
dir="~/PROJECT/chromothripsis/25.Facets/results/duodian-WGS/"
namelist=read.table("~/PROJECT/chromothripsis/25.Facets/results/duodian-WGS/id1",header=F)
savedir="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/15.GISTIC2/segment/CUGA/Facets/WGS/"
b <- read.table('/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/diplogR_duodian-WGS-final_0830.txt',sep = '\t',header = T)
for (i in namelist[,1]) {
df <- read.table(paste(dir,i,"/",i,".vcf.gz",sep=""),header = F)
df <- df %>%
  separate(V8, into = c("SVtype", "SVlen","End","Num_Mark","Nhet","Cnlr_median","Maf_R",
                        "Segcluster","Cnlr_median_cluster","Maf_R_cluster","CF_EM","TCN_EM","LCN_EM","CNV_ANN"), sep = ";")
# segment format:
#(1) Sample      (sample name)
#(2) Chromosome      (chromosome number)
#(3) Start Position      (segment start position, in bases)
#(4) End Position      (segment end position, in bases)
#(5) Num Markers      (number of markers in segment)
#(6) Seg.CN      (log2() -1 of copy number)
id <- paste0(i)
df$Sample = paste(i)
df$Cnlr_median <- as.numeric(str_replace(df$Cnlr_median,"CNLR_MEDIAN=",""))
df$End <- as.numeric(str_replace(df$End,"END=",""))
df$Num_Mark <- as.numeric(str_replace(df$Num_Mark,"NUM_MARK=",""))
df_nw = df[,c(22,1,2,10,11,13)]
colnames(df_nw) = c("Sample","Chromosome","Start","End","Num_Markers","Seg.CN")
df_nw$Seg.CN <- df_nw$Seg.CN - b[grepl(id,b$SampleName),2]
write.table(df_nw,paste(savedir,i,".seg",sep=""),sep="\t",row.names=F,quote=F)
}

## 02 run GISTIC !! ======####################################################
cat group |head -1|while read i
do
echo -e "#!/bin/bash

module load anaconda/4.12.0
conda activate SVcaller
cd /share/home/luoylLab/zengyuchen/biosoft/GISTIC2

currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/15.GISTIC2
GISTIC=/share/home/luoylLab/zengyuchen/biosoft/GISTIC2/gistic2
ref=/share/home/luoylLab/zengyuchen/biosoft/GISTIC2/refgenefiles/hg38.UCSC.add_miR.160920.refgene.mat

#marker_file=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/CNVkit/seg_file/hg_marker_file.txt
savedir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/15.GISTIC2/results/${i}
mkdir -p \${savedir}

seg_file=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/15.GISTIC2/segment/Facets/duodian-WGS/duodian-WGS.seg

\${GISTIC} -b \${savedir} \\
	  -seg \${seg_file} \\
	  -refgene \${ref} \\
	  -conf 0.9 \\
	  -maxseg 20000 \\
	  -genegistic 1 \\
	  -gcm extreme \\
	  -armpeel 1 \\
	  -rx 1 -savegene 1 -broad 1 -brlen 0.5

if [ \$? -eq 0 ]; then
      touch \${currentdir}/status/ok.gistic_dipLogR.status
    else
      echo \"gistic2 failed\"
    fi ">> sb_gistic_${i}.sh
done





