#!/bin/bash

cat file|while read -r a1 a2
do

workdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV
SURVIVOR=/share/home/luoylLab/zengyuchen/biosoft/SURVIVOR/Debug/SURVIVOR
id=${a1}

delly=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/03.Delly/fin/HB/${id}.delly.sv.vcf
manta=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/04.Manta/fin/HB/${id}.manta.sv.pass.vcf
svaba=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/06.SvABA/out_vcf/HB/${id}.svaba.sv.vcf
svabaindel=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/06.SvABA/out_indel/HB/${id}.svaba.indel.vcf
lumpy=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/07.lumpy/out_vcf/HB/lumpy_${id}.sv.vcf

mkdir -p ${workdir}/HB/results

cp ${delly} delly_${id}.sv.ft.vcf
cp ${manta} manta_${id}.sv.vcf
cp ${svaba} svaba_${id}.sv.vcf
cp ${svabaindel} svaba_${id}.indel.vcf
cp ${lumpy} lumpy_${id}.sv.vcf

ls delly_${id}.sv.ft.vcf manta_${id}.sv.vcf svaba_${id}.sv.vcf svaba_${id}.indel.vcf lumpy_${id}.sv.vcf  > ${workdir}/HB/${id}.txt

${SURVIVOR} merge ${workdir}/HB/${id}.txt 1000 2 1 1 0 30 ${workdir}/HB/results/mergeSV_${id}.sv.vcf

rm delly_${id}.sv.ft.vcf
rm manta_${id}.sv.vcf
rm svaba_${id}.sv.vcf
rm svaba_${id}.indel.vcf
rm lumpy_${id}.sv.vcf
done

