#!/bin/bash

module load anaconda/4.12.0
conda activate driverpower

driver_dir=/share/home/luoylLab/zengyuchen/biosoft/DriverPower-1.0.2
input=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/41.DriverPower/input/669samples_all_mutation_dupfromcase.tsv
outdir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/41.DriverPower/result
pre=669samples_all_mutation_dupfromcase

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/41.DriverPower

# Train response
python ${driver_dir}/script/prepare.py ${input} ${driver_dir}/data/train_elements.tsv.gz ${driver_dir}/data/callable.bed.gz train_${pre}.tsv
# Test response
python ${driver_dir}/script/prepare.py ${input} ${driver_dir}/data/test_elements.tsv ${driver_dir}/data/callable.bed.gz test_${pre}.tsv


mkdir -p ${outdir}/${pre}
driverpower model \
    --feature ${driver_dir}/data/train_feature.hdf5 \
    --response train_${pre}.tsv \
    --method GBM \
    --name tutorial \
    --modelDir ${outdir}/${pre}

driverpower infer \
    --feature ${driver_dir}/data/test_feature.hdf5 \
    --response test_${pre}.tsv \
    --model ${outdir}/${pre}/tutorial.GBM.model.pkl \
    --name 'DriverPower_burden' \
    --outDir ${outdir}/${pre}
