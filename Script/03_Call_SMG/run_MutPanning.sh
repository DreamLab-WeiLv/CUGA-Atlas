#!/bin/bash
conda activate /share/home/luoylLab/liconghui/.conda/envs/java

ff="/share/home/luoylLab/liconghui/Bigqueue/MutPanningV2-master/"
cd $ff

sed 's/chr//g' 669samples_coding_mutation.maf.hg19 > CUGA_Mutation_hg19.maf

java -Xmx8G -classpath $ff/commons-math3-3.6.1.jar:$ff/jdistlib-0.4.5-bin.jar:$ff MutPanning "CUGA_coding_dupfromcase/" "CUGA_Mutation_hg19.maf" "CUGA_coding_dupfromcase.txt" "Hg19/"
