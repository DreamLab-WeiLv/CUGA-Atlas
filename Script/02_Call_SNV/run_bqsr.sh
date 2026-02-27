#!/bin/bash
cat file|while read a1
do
echo "#!/bin/bash

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk
currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk
data_dir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/GC_demo
gatk=/share/apps/softwares/gatk-4.2.5.0/gatk
ref=/share/home/luoylLab/zengyuchen/genome/GRCh38.p13/GRCh38.p13.genome.fa
dbsnp=/share/database/genomics-public-data/snp/hg38/dbsnp_146.hg38.vcf.gz
dbsnp1000G=/share/home/luoylLab/zengyuchen/genome/gatk/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
dbindel1000G=/share/home/luoylLab/zengyuchen/genome/gatk/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
bqsrDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/09.gatk/bqsr/GC_demo

sample_prefix=BN_${a1}
mkdir -p \${bqsrDir}
## 01. Running BQSR
\${gatk} --java-options \"-Xmx40G -XX:ParallelGCThreads=20 -Djava.io.tmpdir=\${currentdir}/tmp\" BaseRecalibrator \\
        -R \${ref} \\
        -I \${data_dir}/\${sample_prefix}.cs.rmdup.sort.bam \\
        -O \${bqsrDir}/\${sample_prefix}.recal_data.table \\
        --known-sites \${dbsnp} \\
        --known-sites \${dbsnp1000G} \\
        --known-sites \${dbindel1000G}

\${gatk} --java-options \"-Xmx40G -XX:ParallelGCThreads=20 -Djava.io.tmpdir=\${currentdir}/tmp\" ApplyBQSR \\
        -R \${ref} \\
        -I \${data_dir}/\${sample_prefix}.cs.rmdup.sort.bam \\
        -O \${bqsrDir}/\${sample_prefix}.cs.rmdup.sort.bqsr.bam \\
        --bqsr-recal-file \${bqsrDir}/\${sample_prefix}.recal_data.table

  if [ \$? -eq 0 ]; then
        touch  \${currentdir}/bqsr/status/ok.gatk.bqsr.\${sample_prefix}.status
      else
        echo \"gatk bqsr failed\" \${sample_prefix}
      fi

">>bqsr_${a1}.sh
done
