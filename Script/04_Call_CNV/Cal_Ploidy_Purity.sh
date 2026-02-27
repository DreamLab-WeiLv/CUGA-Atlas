#!/bin/bash
## Get Purity and Ploidy
output=~/PROJECT/chromothripsis/25.Facets/results/dipLogR_duodian-WES31.txt
echo -e "SampleName\tdipLogR" > $output
cat /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/duodian-WES/id2|while read -r i a
do
workdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/duodian-WES
vcf=${workdir}/${i}/${i}.vcf.gz
dip=$(less -S $vcf | grep "^##dipLogR" | cut -d "=" -f 2)

# Print values to text file
echo -e "${i}\t${dip}">> $output
done 

output=~/PROJECT/chromothripsis/25.Facets/results/Ploidy_duodian-WGS-final_0830.txt
echo -e "SampleName\tPurity\tPloidy" > $output
cat /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/duodian-WES/id2|while read -r i a
do
workdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/duodian-WES
vcf=${workdir}/${i}/${i}.vcf.gz

purity=$(less -S $vcf | grep "^##purity" | cut -d "=" -f 2)
ploidy=$(less -S $vcf | grep "^##ploidy" | cut -d "=" -f 2)

# Print values to text file
echo -e "${i}\t${purity}\t${ploidy}">> $output
done 
