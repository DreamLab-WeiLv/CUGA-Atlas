## Read maf file(hg19 version) #####
d <- read.table("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/hg38To19/669samples_all_mutation_dupfromcase.maf.hg19.gz",sep="\t",header=T) 
## Select ("Chromosome","Start_Position","End_Position","Reference_Allele","Tumor_Seq_Allele1","Tumor_Sample_Barcode") column
d1 <- d[,c(5,6,7,11,12,13)]
## Change the column names
colnames(d1) <- c("chr","pos1","pos2","ref","alt","patient")
write.table(d1,"/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Noncoding-Driver/input/669samples_all_mutation_dupfromcase_hg19_activate.mutation",sep="\t",quote=F,row.names=F)

## Run ActiveDriveWGS
library("ActiveDriverWGS")
args <- commandArgs(trailingOnly=TRUE)

mutations <- read.table("~/PROJECT/chromothripsis/Noncoding-Driver/input/669samples_all_mutation_dupfromcase_hg19_dup_rmchr.activate.mutation",header = T,colClasses=c("character","numeric","numeric","character","character","character"))
elements <- read.table("~/PROJECT/chromothripsis/Noncoding-Driver/element/element_gc19_lncrna_prom.bed" , header=T, colClasses=c("character","numeric","numeric","character"))
result <- ActiveDriverWGS(mutations, elements, sites = NULL, window_size = 50000,
                         filter_hyper_MB = 30, recovery.dir = "recover_lncrna_prom", mc.cores = 2)  ## need change the region file "recover_lncrna_prom" for other non-coding region
write.table(result, file=args[1], sep="\t", col.names=T, row.names=F, quote=F)

