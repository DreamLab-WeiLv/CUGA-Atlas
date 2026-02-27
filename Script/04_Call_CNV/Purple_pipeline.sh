#!/bin/bash

cat ~/PROJECT/chromothripsis/04.Manta/shell/linshi|while read -r a1
do
echo "#!/bin/bash

module load anaconda/4.12.0
conda activate java_env
module load gcc/gcc-10.4
module load gdal-2.4.4


workdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/29.purple
tmp=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/29.purple/tmp
normal=${a2}
tumor=${a1}
reference_bam=~/PROJECT/chromothripsis/01.ProcessBAM/alignData/UBC/\${normal}.cs.rmdup.sort.bam
tumor_bam=~/PROJECT/chromothripsis/01.ProcessBAM/alignData/UBC/\${tumor}.cs.rmdup.sort.bam
outdir1=\${workdir}/amber/duodian-WGS/\${tumor}
mkdir -p \${outdir1}

# 01. Run amber #
java -Xmx32G -Djava.io.tmpdir=\${tmp} -cp ~/biosoft/purple/tools/amber.jar com.hartwig.hmftools.amber.AmberApplication \\
   -reference \${normal} -reference_bam \${reference_bam} \\
   -tumor \${tumor} -tumor_bam \${tumor_bam} \\
   -output_dir \${outdir1} \\
   -threads 10 \\
   -loci ~/../zengyuchen/biosoft/purple/resource/copy_number/GermlineHetPon.38.vcf.gz \\
   -ref_genome_version V38

# 02. Run cobalt #
cobalt=/share/home/luoylLab/zengyuchen/biosoft/purple/tools/cobalt.jar
outdir2=\${workdir}/cobalt/duodian-WGS/\${tumor}
GC_profile=/share/home/luoylLab/zengyuchen/biosoft/purple/resource/copy_number/GC_profile.1000bp.38.cnp
mkdir -p \${outdir2}

java -Djava.io.tmpdir=\${tmp} -jar -Xmx8G \${cobalt} \\
    -reference \${normal} -reference_bam \${reference_bam} \\
    -tumor \${tumor} -tumor_bam \${tumor_bam} \\
    -output_dir \${outdir2} \\
    -threads 10 \\
    -gc_profile \${GC_profile}
if [ \$? -eq 0 ]; then
      touch \${workdir}/status/ok.cobalt.\${tumor}.status
   else
      echo \"cobalt failed\" \${tumor}
    fi

# 03. Run purple #
purple=/share/home/luoylLab/zengyuchen/biosoft/purple/tools/purple.jar
ensemble_data=/share/home/luoylLab/zengyuchen/biosoft/purple/resource/common/ensembl_data
somatic_vcf=~/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/duodian-WGS/PASS/sorted/\${tumor}.sorted.pass.fin.snp.indel.vcf
ref=~/../zengyuchen/genome/hg38full/hg38full.fa
outdir3=\${workdir}/purple/duodian-WGS/\${tumor}
mkdir -p \${outdir3}

java -Djava.io.tmpdir=\${tmp} -jar \${purple} \\
   -reference \${normal} \\
   -tumor \${tumor} \\
   -amber \${outdir1} \\
   -cobalt \${outdir2} \\
   -gc_profile \${GC_profile} \\
   -ref_genome_version 38 \\
   -ref_genome \${ref} \\
   -ensembl_data_dir \${ensemble_data} \\
   -output_dir \${outdir3} \\
   -somatic_vcf \${somatic_vcf} \\
   -threads 10

if [ \$? -eq 0 ]; then
      touch \${workdir}/status/ok.purple.\${tumor}.status
   else
      echo \"purple failed\" \${tumor}
    fi ">> purple_${a1}.sh
done

