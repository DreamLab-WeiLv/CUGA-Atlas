#!/bin/bash

cat GC_demo|head -1|while read -r a1 a2 a3 a4
do
echo "#!/bin/bash

tumor=${a1}
normal=${a2}
currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA
cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA
source /share/home/luoylLab/zengyuchen/biosoft/source_me
module load anaconda/4.12.0
conda activate SVcaller

export MOSEKLM_LICENSE_FILE=/share/home/luoylLab/zengyuchen/biosoft/mosek  ## important!! need check the lisence !!!
export AA_DATA_REPO=/share/home/luoylLab/zengyuchen/biosoft/data_repo
export AA_SRC=/share/home/luoylLab/zengyuchen/biosoft/AmpliconArchitect-1.3.r6/src
export PATH=/share/home/luoylLab/zengyuchen/biosoft/mosek/8/tools/platform/linux64x86/bin:\$PATH
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/share/home/luoylLab/zengyuchen/biosoft/mosek/8/tools/platform/linux64x86/bin
export AC_SRC=/share/home/luoylLab/zengyuchen/biosoft/AmpliconClassifier-1.0.0

tumor_bam=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/GC_demo/\${tumor}.cs.rmdup.sort.bam
normal_bam=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/01.ProcessBAM/alignData/GC_demo/\${normal}.cs.rmdup.sort.bam
#tumor_bam=/share/ztron/fastq/temp/${a1}/${a3}.mm2.sortdup.bqsr.bam
#normal_bam=/share/ztron/fastq/temp/${a2}/${a4}.mm2.sortdup.bqsr.bam
cnv=/share/home/luoylLab/zengyuchen/.conda/envs/SVcaller/bin/cnvkit.py
savedir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/GC_demo
mkdir -p \${savedir}
##run PrepareAA
# Paired samples
python3 /share/home/luoylLab/zengyuchen/biosoft/AmpliconSuite-pipeline-1.0.0/PrepareAA.py -s \${tumor} -t 20 --ref GRCh38 --sorted_bam \${tumor_bam} --normal_bam \${normal_bam} --cnvkit_dir \${cnv} -o \${savedir}/\${tumor} 

# Unpaired samples
#python3 /share/home/luoylLab/zengyuchen/biosoft/AmpliconSuite-pipeline-1.0.0/PrepareAA.py -s \${tumor} -t 10 --ref GRCh38 --sorted_bam \${tumor_bam} --cnvkit_dir \${cnv} -o \${savedir}/\${tumor}

# Change cngain and cnsize 
#python3 /share/home/luoylLab/zengyuchen/biosoft/AmpliconSuite-pipeline-1.0.0/PrepareAA.py -s \${tumor} -t 10 --ref GRCh38 --sorted_bam \${tumor_bam} --cngain 3 --cnsize_min 10000 --cnvkit_dir \${cnv} -o \${savedir}/\${tumor}

## run AA
python3 /share/home/luoylLab/zengyuchen/biosoft/AmpliconArchitect-1.3.r6/src/AmpliconArchitect.py --bed \${savedir}/\${tumor}/\${tumor}_AA_CNV_SEEDS.bed --bam \${tumor_bam} --out \${savedir}/\${tumor}/\${tumor} --ref GRCh38


if [ \$? -eq 0 ]; then
  touch \${currentdir}/status/ok.aa.r6.\${tumor}.status
else
  echo \"AA failed\" \${tumor}
fi
">>aa_${a1}.sh
done

