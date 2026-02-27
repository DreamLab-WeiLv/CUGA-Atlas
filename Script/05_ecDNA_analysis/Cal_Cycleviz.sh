## 01 get cycle input for with CAMPER ######################################################################
#!/bin/bash
module load anaconda/4.12.0
conda activate SVcaller

savedir=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/CycleViz/GC_demo
mkdir -p $savedir
## input.txt format : ####
# sampleAAdir/sample_amplicon2_cycles.txt sampleAAdir/sample_amplicon2_graph.txt  sample (need Tab split!!)
##########################

cat input.txt|head -1|while read -r a1 a2 a3
do
graph_data=${a2}
cd $savedir
~/biosoft/AmpliconSuite-pipeline/scripts/CAMPER.py --graph ${graph_data} --runmode bulk 
done

## 02 Plot Cycle by CycleViz ######################################################################
#!/bin/bash
module load anaconda/4.12.0
conda activate SVcaller
CV_SRC=/share/home/luoylLab/zengyuchen/biosoft/CycleViz

cd /share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/CycleViz/GC_demo

# Cycles file
cycles_data=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/CycleViz/GC_demo/L4MLA0802333-C2512_amplicon1_candidate_cycles.txt
# Cycles number
cycle=1 ## choose one cycle ID

# Graph files
graph_data=/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/GC_demo/L4MLA0802333-C2512/L4MLA0802333-C2512_amplicon1_graph.txt

# Output sample name
sample=C2512

## (Option) select target gene name for show (default is BUSHMAN genelist)############################
gene_list_file=~/PROJECT/chromothripsis/08.runAA/shell/gene_list_file
######################################################################################################
# Run !!----
${CV_SRC}/CycleViz.py --ref GRCh38 --cycles_file ${cycles_data} --gene_subset_file ${gene_list_file} --cycle ${cycle} -g ${graph_data} --rotate_to_min --figure_size_style normal --outname ${sample} ## Own genelist
${CV_SRC}/CycleViz.py --ref GRCh38 --cycles_file ${cycles_data} --gene_subset_file "BUSHMAN" --cycle ${cycle} -g ${graph_data} --rotate_to_min --figure_size_style normal --outname ${sample} ## BUSHMAN

