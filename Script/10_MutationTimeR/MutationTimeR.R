args = commandArgs(trailingOnly=TRUE)
library(MutationTimeR)
library(openxlsx)
vcf <- readVcf(args[1], genome="GRCh38")
bb <- MutationTimeR:::loadBB(args[2])
purityPloidy <- read.table(args[3], header=TRUE, sep="\t")
sample <- args[4]
print(sample)
purityPloidyss = purityPloidy[purityPloidy$sample==sample, ]
purity <- purityPloidyss$purity
bb$clonal_frequency <- purity

gender='female'
if (purityPloidyss$gender == "Male"){
  gender='male'
}
isWgd=FALSE
if (purityPloidyss$isWgd > 0.5){
  isWgd=TRUE
}

print(c(sample, gender, purity, isWgd))

mt <- mutationTime(vcf, bb, n.boot=1000, gender=gender, isWgd=isWgd)

write.table(table(mt$V$CLS), file=paste(sample,"classifyMutations.txt",sep="."), sep="\t", col.names=T, row.names=F, quote=F)

info(header(vcf)) <- rbind(info(header(vcf)),MutationTimeR:::mtHeader())
info(vcf) <- cbind(info(vcf), mt$V)
MutationTimeR:::writeVcf(vcf, paste(sample, "info.vcf",sep="."))

mcols(bb) <- cbind(mcols(bb),mt$T)
write.table(bb[,-5], file=paste(sample, "bb.txt",sep="."), sep="\t", col.names=T, row.names=F, quote=F)

#Rscript MutationTimeR.R sample.vcf sample_GRanges.txt WGS_purity.txt sample