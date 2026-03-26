############## Step1. Prepare oncodriveFML input files ###############################################################################
#!/bin/bash
zcat /share/home/luoylLab/liconghui/Bigqueue/Mutsig/hg38To19/coding_mutation.maf.hg19.gz | cut -f5,6,11,12,13  >input.txt

echo -e "CHROMOSOME\tPOSITION\tREF\tALT\tSAMPLE" > tmp && tail -n +2 input.txt >> tmp && sed -i 's/chr//g' tmp && \
grep -v -E "random|Un" tmp > tmp1 && \
gzip -c tmp1 > coding_paad.txt.gz && \
rm input.txt tmp tmp1

############## Step2. Run oncodriveFML ###############################################################################
#!/bin/bash
module load anaconda/4.12.0
conda activate oncodrivefml_env
cds_reion=~/cds.tsv.gz
/share/home/luoylLab/liconghui/.conda/envs/oncodrivefml_env/bin/oncodrivefml  -i coding_paad.txt.gz -e ${cds_region} --sequencing wes -o coding_wes --debug

