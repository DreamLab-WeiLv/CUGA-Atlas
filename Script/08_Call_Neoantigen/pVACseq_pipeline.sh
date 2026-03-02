#### Step1. Run HLAscan ################################################################################
#!/bin/bash
cat file | while read i a2
do
echo "#!/bin/bash
bam=~/PROJECT/chromothripsis/01.ProcessBAM/alignData/duodian-WGS/${i}.cs.rmdup.sort.bam
for gene in \`cut -f1 ~/PROJECT/chromothripsis/27.HLAscan/HLAtype\`
do
#bam
outdir=~/PROJECT/chromothripsis/27.HLAscan/HLA_res/duodian-WGS-0830
mkdir -p \${outdir}
/share/home/luoylLab/zengyuchen/biosoft/HLAscan/hla_scan_r_v2.1.4 -b \${bam} -v 38 -d /share/home/luoylLab/zengyuchen/biosoft/HLAscan/db/HLA-ALL.IMGT -g \${gene} >> \${outdir}/${i}.hla.txt 
done ">> ${i}.sh
done

#### Step2. Process HLAscan results ################################################################################
#!/bin/bash
cat file | while read i a1
do
id=${i}
hla=~/PROJECT/chromothripsis/27.HLAscan/HLA_res/duodian-WGS-0830/${id}.hla.txt
grep -A 5 'HLA-A' ${hla} |grep -A 2 'HLA-Types'|awk '{print $3}'|tail -2 >> HLA-tmp
grep -A 5 'HLA-B' ${hla} |grep -A 2 'HLA-Types'|awk '{print $3}'|tail -2 >> HLA-tmp
grep -A 5 'HLA-C' ${hla} |grep -A 2 'HLA-Types'|awk '{print $3}'|tail -2 >> HLA-tmp
cut -d: -f1,2 HLA-tmp > ${i}-HLA-tmp
paste -d '' name ${i}-HLA-tmp > ${i}-HLA-tmp-1
cat ${i}-HLA-tmp-1 | tr '\n' ',' > /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq/hlascan_HLA/duodian-WGS/${id}.pvac.hla.txt
sed -i '$ s/,$//' /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq/hlascan_HLA/duodian-WGS/${id}.pvac.hla.txt
rm ${i}-HLA-tmp
rm HLA-tmp
rm ${i}-HLA-tmp-1
done

#!/bin/bash
cat file | while read i a1
do
workdir=~/PROJECT/chromothripsis/17.pVACseq/hlascan_HLA/duodian-WGS
id=${i}
input_file=${workdir}/${i}.pvac.hla.txt
output_file=${workdir}/${id}.pvac.hla.txt

# 使用awk命令处理文件
awk 'BEGIN{FS=OFS=","} {for(i=1; i<=NF; i++) {if($i ~ /[0-9]/) printf("%s%s", $i, (i==NF?"":OFS))} printf("\n")}' ${input_file} > tmp_${i}
sed 's/,$//' tmp_${i} > ${output_file}
rm tmp_${i}
done

#### Step3. Run VEP annotation ################################################################################
#!/bin/bash
cat file | while read -r a1 a2
do
echo "#!/bin/bash

## Use VEP to annotate Mutect2 VCF file ##
module load anaconda/4.12.0
conda activate VEP
## Input somatic mutation vcf file (Mutect2/strelka2/MuSE)
# 01.Using the vcf-genotype-annotator to add genotype information to your VCF (strelka2 required!! Mutect2 no need~)
#conda activate pvactools
#vcf-genotype-annotator vcf sample_name 0/1 -o gt_annotated_vcf  (0/1 same with Mutect2)

# 02. Running VEP
outDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq/annotedVEP/duodian-WGS/${a1}
mkdir -p \${outDir}
id=${a1}
vep \\
  --input_file /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/duodian-WGS/PASS/sorted/\${id}.sorted.pass.fin.snp.indel.vcf \\
  --output_file \${outDir}/\${id}.sorted.pass.snp.indel.vep.vcf \\
  --format vcf --vcf --symbol --terms SO --tsl \\
  --hgvs --fasta /share/home/luoylLab/zengyuchen/genome/hg38full/hg38full.fa \\
  --offline --cache \\
  --plugin Downstream --plugin Wildtype --plugin Frameshift \\
  --dir_plugins ~/PROJECT/chromothripsis/17.pVACseq/vep/Plugins/ \\
  --pick  

  if [ \$? -eq 0 ]; then
        touch  /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq/status/ok.vep.\${id}.status
      else
        echo \"vep failed\" \${id}
      fi">> vep_${a1}.sh
done

#### Step3. Run pVACseq ################################################################################

#!/bin/bash
cat file | while read -r a1 a2
do
echo "#!/bin/bash

module load anaconda/4.12.0
conda activate pvactools
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq
workDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq

mkdir -p \${workDir}/results/UBC/${a1}
id=${a1}
hladir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq/hlascan_HLA/duodian-WGS
hlaid=${a1}
hlatype=\$(cat \${hladir}/\${hlaid}.pvac.hla.txt)
pvacseq run \${workDir}/annotedVEP/duodian-WGS/${a1}/\${id}.sorted.pass.snp.indel.vep.vcf \${id} \\
 \${hlatype} \\
 NetMHCpan NetMHC \\
 \${workDir}/results/duodian-WGS/${a1} \\
 --iedb-install-directory /share/home/luoylLab/zengyuchen/NetMHC
 if [ \$? -eq 0 ]; then
        touch  /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq/status/ok.pvac.\${id}.status
      else
        echo \"pvac failed\" \${id}
      fi
">> pvacseq-${a1}.sh
done

#### Step4. extra_pipetide_number in R ################################################################################
setwd("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/17.pVACseq/results/duodian-WGS")
dir='/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis//17.pVACseq/results/duodian-WGS/'
peptide_num = data.frame(SampleNames = as.character(),
                         number = as.numeric(),
                         stringsAsFactors = F)
list=read.table("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis//17.pVACseq/results/duodian-WGS/list",header = F)
for (i in list[,1]) {
  tryCatch({
  df = read.table(paste(dir,i,'/MHC_Class_I/',i,".all_epitopes.aggregated.tsv",sep = ""),header = T,sep = "\t")
  ft_df = df[df$IC50.MT < 500,]
  num_rows = nrow(ft_df)
  peptide_num = rbind(peptide_num, data.frame(
    SampleNames = i,
    number = num_rows))
 },error = function(e) {
    print(paste("Error in column", i , ":", conditionMessage(e)))
  })
}
write.table(peptide_num, "~/PROJECT/chromothripsis/17.pVACseq/results/duodian_059_069_peptide_num.txt",quote = F,sep = "\t",row.names = F)

#### Step5. merge all pipetide results in R ################################################################################
setwd('/share/home/luoylLab/chenc/17.pVACseq/results/')
dir="~/PROJECT/chromothripsis/17.pVACseq/results/UBC/"
merged_df <- data.frame()
names = read.table('~/PROJECT/chromothripsis/17.pVACseq/shell/linshi',header = F)
for (i in names[,1]) {
  dn = read.table(paste0(dir,i,"/MHC_Class_I/",i,'T.all_epitopes.aggregated.tsv'),sep = '\t',header = T) 
  dn = dn[,c('ID','Gene','Best.Peptide','IC50.MT')]
  dn$sample = i
  merged_df = rbind(merged_df,dn)
}
write.table(merged_df,'~/PROJECT/chromothripsis/17.pVACseq/results/181_182_peptide.tsv',sep = '\t',row.names = F,quote = F)


