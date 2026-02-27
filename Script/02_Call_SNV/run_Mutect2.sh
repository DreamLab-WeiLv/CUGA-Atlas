#!/bin/bash
cat file|while read -r a1 a2
do
echo "#!/bin/bash

currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk
gatk=/share/apps/softwares/gatk-4.2.5.0/gatk
ref=/share/home/luoylLab/zengyuchen/genome/GRCh38.p13/GRCh38.p13.genome.fa
data_dir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/GC_demo
data_dir2=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/GC_demo
dbsnp=/share/database/genomics-public-data/snp/hg38/dbsnp_146.hg38.vcf.gz
dbsnp1000G=/share/home/luoylLab/zengyuchen/genome/gatk/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
dbindel1000G=/share/home/luoylLab/zengyuchen/genome/gatk/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
Germline_Resource=/share/home/luoylLab/zengyuchen/genome/gatk/broad_ref_hg38/somatic-hg38_af-only-gnomad.hg38.vcf.gz
PoN_db=/share/database/gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz
bqsrDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk/bqsr/GC_demo

normal=${a2}
tumor=${a1}
outDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk/Mutect2/GC_demo/\${tumor}
mkdir -p \${bqsrDir}

echo '========02. Call mutect2 somatic=============='
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk
mkdir -p \${outDir}

\${gatk} --java-options \"-Xmx30G -XX:ParallelGCThreads=20 -Djava.io.tmpdir=\${currentdir}/tmp\" Mutect2 \\
  -R \${ref} \\
  -I \${bqsrDir}/\${tumor}.cs.rmdup.sort.bqsr.bam \\
  -tumor \${tumor} \\
  -I \${bqsrDir}/\${normal}.cs.rmdup.sort.bqsr.bam \\
  -normal \${normal} \\
  --germline-resource \${Germline_Resource} \\
  -max-mnp-distance 0  \\
  -L chr1 -L chr2 -L chr3 -L chr4 -L chr5 -L chr6 -L chr7 -L chr8 -L chr9 -L chr10 -L chr11 -L chr12 -L chr13 -L chr14 -L chr15 -L chr16 -L chr17 -L chr18 -L chr19 -L chr20 -L chr21 -L chr22 -L chrX -L chrY \\
   -O \${outDir}/\${tumor}.unfilter.vcf.gz

\${gatk} --java-options \"-Xmx30G -XX:ParallelGCThreads=20 -Djava.io.tmpdir=\${currentdir}/tmp\" FilterMutectCalls \\
  -R \${ref} \\
  -V \${outDir}/\${tumor}.unfilter.vcf.gz \\
  -O \${outDir}/\${tumor}.filter.vcf.gz 

### 03. Split muti-allelic sites

\${gatk} --java-options \"-Xmx30G -XX:ParallelGCThreads=20 -Djava.io.tmpdir=\${currentdir}/tmp\" LeftAlignAndTrimVariants \\
 -V \${outDir}/\${tumor}.filter.vcf.gz \\
 -R \${ref} \\
 -no-trim true --split-multi-allelics true \\
 -O \${outDir}/\${tumor}.filter.m2.SplitMulti.vcf

### 04. Sprate SNP and INDEL
snpdir=\${currentdir}/FinalVCF/SNP/GC_demo
indeldir=\${currentdir}/FinalVCF/INDEL/GC_demo
mkdir -p \${snpdir}
mkdir -p \${indeldir}

\${gatk} --java-options \"-Xmx30G -XX:ParallelGCThreads=10 -Djava.io.tmpdir=\${currentdir}/tmp\" SelectVariants \\
 -V \${outDir}/\${tumor}.filter.m2.SplitMulti.vcf \\
 -R \${ref} \\
 --select-type-to-include SNP \\
 -O \${snpdir}/\${tumor}.m2.SplitMulti.snp.vcf

\${gatk} --java-options \"-Xmx30G -XX:ParallelGCThreads=10 -Djava.io.tmpdir=\${currentdir}/tmp\" SelectVariants \\
 -V \${outDir}/\${tumor}.filter.m2.SplitMulti.vcf \\
 -R \${ref} \\
 --select-type-to-include INDEL \\
 -O \${indeldir}/\${tumor}.m2.SplitMulti.indel.vcf

if [ \$? -eq 0 ]; then
      touch  \${currentdir}/status/ok.Mutect.\${tumor}.status
    else
      echo \"Mutect failed\" \${tumor}
    fi
">>Mutect2_${a1}.sh 
done
