#!/bin/bash
cat ~/ID/UTUC-RNA|while read i
do
echo "#!/bin/bash

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/02.RNA
workDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/02.RNA
sample_prefix=RNA-Seq-UTUC-${i}

##################################################
## 1. FastQC ##
fastqc=/share/apps/softwares/FastQC-0.11.7/fastqc
rawfq=~/PROJECT/UCGEIA/UTUC-RNA

\$fastqc -t 10 -o \${workDir}/qc1 \${rawfq}/\${sample_prefix}_1.fq.gz \${rawfq}/\${sample_prefix}_2.fq.gz
##################################################

## 2. Clean Data with Trim-galore ##
trim_galore=/share/apps/softwares/TrimGalore-0.6.7/trim_galore
cleanDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/02.RNA/clean/trim_galore

\${trim_galore} --paired -q 25 -j 4 --phred33 --length 20 --stringency 3 --gzip \\
 -o \$cleanDir \\
 \${rawfq}/\${sample_prefix}_1.fq.gz \\
 \${rawfq}/\${sample_prefix}_2.fq.gz

## 3. Check clean QC ##
\$fastqc -t 5 -o /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/02.RNA/clean/qc2/UCGEIA \$cleanDir/\${sample_prefix}_1_val_1.fq.gz \$cleanDir/\${sample_prefix}_2_val_2.fq.gz

## 4. STAR Alignment start! ##
alignDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/02.RNA/align/UTUC
mkdir -p \${alignDir}/${i}

/share/apps/softwares/STAR-2.7.10a/bin/Linux_x86_64_static/STAR \
 --readFilesCommand zcat \\
 --quantMode TranscriptomeSAM GeneCounts \\
 --twopassMode Basic \\
 --outSAMtype BAM SortedByCoordinate \\
 --outSAMunmapped None \\
 --genomeDir /share/home/luoylLab/zengyuchen/genome/STAR/STAR_static \\
 --readFilesIn \$cleanDir/\${sample_prefix}_1_val_1.fq.gz \$cleanDir/\${sample_prefix}_2_val_2.fq.gz \\
 --outFileNamePrefix \${alignDir}/${i}/\${sample_prefix} 

## 5.Run RSEM ##
RSEM=/share/apps/softwares/RSEM-1.3.3/bin
GTF=~/genome/gene_annotation_file/gencode.v34.annotation.gtf
Fasta=~/genome/hg38full/hg38full.fa
export PERL5LIB=/share/home/luoylLab/zengyuchen/.local/share/perl5:\$PERL5LIB
mkdir -p  \${workDir}/RSEM/out/UTUC/${i}


\${RSEM}/rsem-calculate-expression --forward-prob 0.5 \\
 --paired-end \\
 -p 12 --no-bam-output \\
 --bam \${alignDir}/${i}/\${sample_prefix}Aligned.toTranscriptome.out.bam \\
 ~/PROJECT/chromothripsis/02.RNA/RSEM/ref/human_gencode \\
 \${workDir}/RSEM/out/UTUC/${i}/${i}_rsem


if [ \$? -eq 0 ]; then
      touch \${workDir}/status/ok.RNAseq-UTUC-rsem.\${sample_prefix}.status
    else
      echo \"RNA failed\" \${sample_prefix}
    fi
">> RNA-UTUC_rsem_${i}.sh
done
