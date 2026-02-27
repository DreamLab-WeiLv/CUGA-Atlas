#!/bin/bash
cat file | while read -r a1 a2
do
echo "#!/bin/bash
module load anaconda/4.12.0
conda activate facet

tumor=${a1}
normal=${a2}
workdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets
tumorbam=~/PROJECT/chromothripsis/01.ProcessBAM/alignData/HB/\${tumor}.cs.rmdup.sort.bam
normalbam=~/PROJECT/chromothripsis/01.ProcessBAM/alignData/HB/\${normal}.cs.rmdup.sort.bam
dbSNP=\${workdir}/ref/dbsnp_151.common.hg38.vcf.gz
mkdir -p \${workdir}/results/HB/\${tumor}

cnv_facets.R -t \${tumorbam} -n \${normalbam} -u -vcf \${dbSNP} -o \${workdir}/results/HB/\${tumor}/\${tumor}


if [ \$? -eq 0 ]; then
      touch  \${workdir}/status/ok.facets.\${tumor}.status
    else
      echo \"facets failed\" \${tumor}
    fi" >> facet_${a1}.sh
done

