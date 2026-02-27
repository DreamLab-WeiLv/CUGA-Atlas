#!/bin/bash

export AA_DATA_REPO=/share/home/luoylLab/zengyuchen/biosoft/data_repo
export AC_SRC=/share/home/luoylLab/zengyuchen/biosoft/AmpliconClassifier-1.0.0
currentdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA
input=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/Pick_Up_results/AC_all_CUGA/all_CUGA/all_CUGA_features_to_graph.txt

module load anaconda/4.12.0
conda activate SVcaller

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/Pick_Up_results/AC_all_CUGA/all_CUGA/
python ${AC_SRC}/feature_similarity.py --ref GRCh38 --feature_input ${input}

