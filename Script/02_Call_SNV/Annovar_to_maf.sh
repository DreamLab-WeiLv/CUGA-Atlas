#!/bin/bash
indir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/Annovar/GC_demo  ## ANNOVAR result dir

vs_list=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/Annovar/GC_demo/list ## ANNOVAR result dir filename list

outdir1=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/maf/GC_demo.coding.maf.gz ## output name of MAF(coding) file
outdir2=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/maf/GC_demo.maf.gz ## output name of MAF(allmutation) file

perl maf.pl $vs_list $indir $outdir2 hg38_multianno.txt.gz
perl maf.coding.pl $vs_list $indir $outdir1 hg38_multianno.txt.gz

