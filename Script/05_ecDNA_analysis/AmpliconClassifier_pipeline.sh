## 01 get input for AmpliconClassifier ####################################################################
#!/bin/bash
cd ~/PROJECT/chromothripsis/08.runAA/shell/input_tmp
cat ~/PROJECT/chromothripsis/08.runAA/shell/linshi|head -1|while read -r a1 a2
do
sh /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/shell/make_input.sh ~/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/GC_demo/${a1} ${a1} 
done

cat ./input_tmp/* > ./input_tmp/input_all

## 02 Run AmpliconClassifier ##############################################################################
#!/bin/bash

export AA_DATA_REPO=/share/home/luoylLab/zengyuchen/biosoft/data_repo
export AC_SRC=/share/home/luoylLab/zengyuchen/biosoft/AmpliconClassifier-1.0.0
currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA
input=~/PROJECT/chromothripsis/08.runAA/shell/input_tmp/input_all
sample=input ## output prefix name

module load anaconda/4.12.0
conda activate SVcaller

outdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/AC_results/${sample}
mkdir -p ${outdir}
python ${AC_SRC}/amplicon_classifier.py --ref GRCh38 --input ${input} --report_complexity --verbose_classification -o ${outdir}/${sample}

if [ $? -eq 0 ]; then
  touch /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/status/ok.runAC.status
else
  echo "runAC failed" 
fi


