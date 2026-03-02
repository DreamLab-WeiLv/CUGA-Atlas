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



