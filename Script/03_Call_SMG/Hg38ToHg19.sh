#!/bin/bash
outdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/hg38To19
liftOver=/share/apps/softwares/liftOver/liftOver
hg38Tohg19=/share/apps/softwares/liftOver/hg38ToHg19.over.chain.gz
maf=/share/home/luoylLab/zengyuchen/PROJECT/CRC/maf/CRC336sams.coding.maf.gz ## maf file

sample_prefix=CRC336sams.coding  

sed -i 's/"//g' /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/12.MutSig/corrected/${sample_prefix}_mutsig.corrected.tsv

perl ToBed.pl ${maf} $outdir/${sample_prefix}.maf.hg38.bed 
$liftOver $outdir/${sample_prefix}.maf.hg38.bed $hg38Tohg19 $outdir/${sample_prefix}.maf.hg38Tohg19.bed $outdir/${sample_prefix}.maf.hg38Tohg19_unlifted.bed

perl NCBI_Build_change_hg19.pl $outdir/${sample_prefix}.maf.hg38Tohg19.bed ${maf} $outdir/${sample_prefix}.maf.hg19.gz

