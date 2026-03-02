#!/bin/bash
## Step1. get PASS vcf ##################################################################################################
ln -s /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/28.SNVmerge/MergeSnpIndel/UBC/PASS/*.vcf /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/UBC/.
## Step2. get input matrix ##################################################################################################
module load anaconda/4.12.0
conda activate /share/home/luoylLab/zengyuchen/.conda/envs/Sigpro
python3 get_SVmatrix_input.py  # for SV signature
python3 get_matrix.py # for SNV signature
python3 get_CNVmatrix_input.py  # for CNV signature


