#!/bin/bash
cat /share/home/luoylLab/zengyuchen/PROJECT/Circular_Cloud/12.HNSC-YT/HNSC-test-BN/list|while read -r a1
do
echo "#!/bin/bash
sample_id=${a1}

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM
currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM
datadir=/share/home/luoylLab/zengyuchen/PROJECT/Circular_Cloud/12.HNSC-YT/HNSC-test-BN/${a1}/
ref=/share/home/luoylLab/zengyuchen/genome/GRCh38.p13/GRCh38.p13.genome.fa
source /share/home/luoylLab/zengyuchen/biosoft/source_me
savedir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/HNSC
mkdir -p \${savedir}
#QC
/share/apps/softwares/FastQC-0.11.7/fastqc -o \${currentdir}/qcReport -t 10 \${datadir}/${a1}_1.fq.gz \${datadir}/${a1}_2.fq.gz
#fastp
/share/apps/softwares/fastp-0.23.2/fastp -w 20 -z 6 -i \${datadir}/${a1}_R1.fq.gz -o \${currentdir}/cleanData/\${sample_id}_1.clean.fq.gz -I \${datadir}/${a1}_R2.fq.gz -O \${currentdir}/cleanData/\${sample_id}_2.clean.fq.gz

#bwa
cleandir=\${currentdir}/cleanData
/share/apps/softwares/bwa-0.7.17/bwa mem -t 20 -K 100000000 -R \"@RG\tID:\${sample_id}\tSM:\${sample_id}\tLB:lib\${sample_id}\tPL:illumina\" -Y \${ref} \${cleandir}/\${sample_id}_1.clean.fq.gz \${cleandir}/\${sample_id}_2.clean.fq.gz \
| samtools view -@ 20 -1 - > \${savedir}/\${sample_id}.cs.bam

/share/apps/softwares/gatk-4.2.5.0/gatk --java-options \"-Djava.io.tmpdir=/share/home/luoylLab/zengyuchen/TMP -Xmx30G\" MarkDuplicates --INPUT \${savedir}/\${sample_id}.cs.bam --OUTPUT \${savedir}/\${sample_id}.cs.rmdup.bam --METRICS_FILE metrics/\${sample_id}.metrics --VALIDATION_STRINGENCY SILENT --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 --ASSUME_SORT_ORDER \"queryname\" 

samtools sort -@ 20 -o \${savedir}/\${sample_id}.cs.rmdup.sort.bam \${savedir}/\${sample_id}.cs.rmdup.bam
samtools index -@ 20 \${savedir}/\${sample_id}.cs.rmdup.sort.bam

if [ \$? -eq 0 ]; then
      touch \${currentdir}/status/ok.bwa.\${sample_id}.status
   else
      echo \"bwa failed\" \${sample_id}
    fi
rm -rf \${savedir}/\${sample_id}.cs.bam
rm -rf \${savedir}/\${sample_id}.cs.rmdup.bam
">>probam_${a1}.sh
done
