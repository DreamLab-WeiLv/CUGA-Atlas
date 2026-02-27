#!/bin/bash
cat file |while read -r a1 a2 ## file has tumor and normal prefix
do
echo "#!/bin/bash

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge

tumor=${a1}
normal=${a2}

vcfDir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/GC_demo/PASS/

savedir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/Annovar/GC_demo/${a1}
mkdir -p \${savedir}
sample=\${tumor}

perl /share/home/luoylLab/zengyuchen/genome/annovar/table_annovar.pl \\
 \${vcfDir}/\${sample}.pass.fin.snp.indel.vcf \\   ## need change the filename
 /share/apps/softwares/annovar/humandb \\
 --outfile \${savedir}/\${tumor} \\
 --buildver hg38 \\
 --protocol refGene,ensGene,cytoBand,avsnp150,clinvar_20220320,cosmic70,dbnsfp42a,1000g2015aug_all,exac03,gnomad30_genome,gnomad_exome,icgc28 \\  ## could change the database or version
 --operation g,g,r,f,f,f,f,f,f,f,f,f \\
 --vcfinput \\
 --thread 6 \\
 --dot2underline \\
 --nastring . \\
 --remove
">> anno_${a1}.sh
done
