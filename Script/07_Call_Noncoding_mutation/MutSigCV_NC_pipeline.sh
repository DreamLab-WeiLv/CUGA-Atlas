## prepare input for MutsigCV-NC in R ########################################################################
d <- read.table("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/hg38To19/669samples_all_mutation_dupfromcase.maf.hg19.gz",sep="\t",header=T)
d1 <- d[,c(5,6,11,12,13)]
colnames(d1) <- c("Chromosome","Start_position","Reference_Allele","Tumor_Seq_Allele2","Tumor_Sample_Barcode")
d1$Chromosome <- gsub('chr','',d1$Chromosome)
write.table(d1,"/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Noncoding-Driver/input/669samples_all_mutation_dupfromcase.mutation",sep="\t",quote=F,row.names=F)

## run MutSigCV-NC ###########################################################################################
#!/bin/bash

maf=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Noncoding-Driver/input/669samples_all_mutation_dupfromcase_mutsigcv.mutation
for ele in enhancers gc_pc.3utr gc_pc.5utr lncrna lncrna.prom mirna.mat mirna.pre promcore promoters smallrna.ncrna TFBS  
do
out=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Noncoding-Driver/MutSigCV-NC/669samples_all_mutation_dupfromcase/${ele}
mkdir -p ${out}
module load anaconda/4.12.0 
conda activate SVcaller

MCRROOT=/share/home/luoylLab/zengyuchen/biosoft/MatlabMCR/v901
export LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64
cd /share/home/luoylLab/zengyuchen/biosoft/getzlab-PCAWG-MutSig2CV_NC-master/

bin/MutSig2CV_NC $maf $out run/params/Bladder-TCC_${ele}.params.txt

cd ${out}
python /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Noncoding-Driver/shell/NCmatDump.py results.mat > out.xls
done

