#!/usr/bin/env python

'''
 REQUIREMENTS: 
 'AA_DATA_REPO' environment variable: https://github.com/AmpliconSuite/AmpliconSuite-pipeline
 'CV_SRC' (cycleviz) environent variable: https://github.com/AmpliconSuite/CycleViz
 matplotlib
 numpy
 intervaltree


# please see comments below for things that must be changed to use the script.
'''

import argparse
from collections import defaultdict
import copy
import os
import sys

from ast import literal_eval as make_tuple
from intervaltree import IntervalTree
import matplotlib
matplotlib.use('Agg')  # this import must happen immediately after importing matplotlib
from matplotlib import pyplot as plt
from matplotlib import rcParams
from matplotlib.collections import LineCollection
from matplotlib.collections import PatchCollection
from matplotlib.font_manager import FontProperties
from matplotlib.patches import FancyBboxPatch
import matplotlib.patches as mpatches
import matplotlib.transforms as mtransforms
from matplotlib.path import Path
import numpy as np

rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = ['Arial']
matplotlib.rcParams['pdf.fonttype'] = 42

# replace as needed for GRCh38 or other ref
gfile = "/share/home/luoylLab/zengyuchen/biosoft/data_repo/GRCh38/Genes_hg38.gff"
#gfile = os.environ['AA_DATA_REPO'] + "/hg19/human_hg19_september_2011/Genes_July_2010_hg19.gff"
#structure_file = os.environ["CV_SRC"] + "/resources/hg19_structure.bed"
structure_file = "/share/home/luoylLab/zengyuchen/biosoft/CycleViz/resources/GRCh38_structure.bed" 

# this would be a file of oncogenes (one gene per line) 
combined_set = set()
with open("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/595cases/oncogene_list.txt") as infile:
    for line in infile:
        fields = line.rstrip().rsplit("\t")
        combined_set.add(fields[0])
        
print(len(combined_set))


# this function maps genes to locations
def parse_genes(gene_file, gset):
    print("reading " + gene_file)
    t = defaultdict(IntervalTree)
    seenNames = set()
    with open(gene_file) as infile:
        for line in infile:
            if line.startswith("#"):
                continue

            fields = line.rstrip().split()
            if not fields:
                continue

            chrom, s, e, strand = fields[0], int(fields[3]), int(fields[4]), fields[6]
            # parse the line and get the name
            propFields = {x.split("=")[0]: x.split("=")[1] for x in fields[-1].rstrip(";").split(";")}
            gname = propFields["Name"]
            is_other_feature = (gname.startswith("LOC") or gname.startswith("LINC") or gname.startswith("MIR"))
            if gname not in seenNames and gname in gset:
                seenNames.add(gname)
                t[chrom].addi(s,e, gname)

    print("read " + str(len(seenNames)) + " genes\n")
    return t

gtree = parse_genes(gfile, combined_set) 


# this code draws the karyotype plots. 
chrlist = []
chrlens = []
with open(structure_file) as infile:
    for line in infile:
        fields = line.rsplit("\t")
        chrlist.append(fields[0])
        chrlens.append(int(fields[2]))
        
chr_total_len = sum(chrlens)
spacing_prop = 0.01
n_entries = len(chrlist)
spacing = spacing_prop*chr_total_len
total_spacing = spacing*n_entries
plot_len = chr_total_len + total_spacing
height = 0.02*plot_len

# place each entry
chr_placements = [0]
for x in chrlens[:-1]:
    chr_placements.append(chr_placements[-1] + spacing + x) 
    
    
print(list(zip(chrlist,chr_placements)))

chrom_to_items = defaultdict(list)
#with open(os.environ["CV_SRC"] + "/resources/cytoBand_hg19_colored.bed") as infile:
with open("/share/home/luoylLab/zengyuchen/biosoft/CycleViz/resources/cytoBand_hg38_colored.bed") as infile:
    for line in infile:
        fields = line.rstrip().rsplit("\t")
        chrom_to_items[fields[0]].append((int(fields[1]), int(fields[2]), fields[4]))


# read the ecdna / oncogene / overlap regions

# this is a bed file of all the ecDNA regions # 
ecregiond = defaultdict(list)
#with open("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/urine_tumor_FigureS13c/FigureS13c_tumor_sorted_merge.bed") as infile:
with open("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/SVnew_GISTIC_AMP/SV_region_sorted_merge.bed") as infile:
#with open("../../classification/combined_merged_flattened_ecdna_intervals.bed") as infile:
    for line in infile:
        fields = line.rstrip().rsplit()
        ecregiond[fields[0]].append((int(fields[1]), int(fields[2])))
        
# this is a bed file of all the oncogene genome regions #这个文件是所有oncogene的region文件!! 有ref文件嘛还是需要自己整理?
oncogened = defaultdict(list)
with open("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/SVnew_GISTIC_AMP/Focal_GISTIC_AMP_region_sort_merge.bed") as infile:
#with open("../../annotations/frankel_paulson_stachler_intervals.bed") as infile:
    for line in infile:
        fields = line.rstrip().rsplit()
        oncogened[fields[0]].append((int(fields[1]), int(fields[2])))
        
# this is a bed file of the overlap between ecDNA and oncogene regions . #这个是ecDNA和oncogene overlap regions的文件,是否有直接的文件，还是需要自己整理?
overlapd = defaultdict(list)
with open("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/SVnew_GISTIC_AMP/SVnew_GISTICAMP_overlap_sort_merge.bed") as infile:
#with open("../../ecDNA_fsp_overlap.bed") as infile:
    for line in infile:
        fields = line.rstrip().rsplit()
        overlapd[fields[0]].append((int(fields[1]), int(fields[2])))  

def add_fancy_patch_around(ax, bb, **kwargs):
    fancy = FancyBboxPatch((bb.xmin, bb.ymin), bb.width, bb.height,
                           fc=(0, 0, 0, 0), ec=(0.2, 0.2, 0.2, 1),
                           **kwargs)
    ax.add_patch(fancy)
    return fancy

'''
This code below draws the plots
'''

fig, ax = plt.subplots(figsize=(8, 3.25))

# draw karyogram
for chrom, s,l in zip(chrlist, chr_placements, chrlens):
    bb = mtransforms.Bbox([[s, 0], [s+l, height]])
    fancy = add_fancy_patch_around(ax, bb, boxstyle="round,rounding_size=12000000", linewidth=0.6)
    ax.text(s + l/2, height*1.2, chrom.lstrip("chr"), ha='center', fontsize=6)
    
for chrom, s in zip(chrlist, chr_placements):
    bandlist = chrom_to_items[chrom]
    for b in bandlist:
        ctup = make_tuple("".join(b[2].split()))   #index | other_value | color_tuple
        if any([x > 1 for x in ctup]):
            ctup = tuple([x/255.0 for x in ctup])
        
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,height*0.04), b[1]-b[0], height*0.915, 
                                        facecolor=ctup, edgecolor='none', zorder=-1))


# draw ecdna regions
fheight = height*1.1
for chrom, s in zip(chrlist, chr_placements):
    bandlist = ecregiond[chrom]
    for b in bandlist:
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,-1.5*height), b[1]-b[0], fheight, 
                                        facecolor='r', edgecolor='r', linewidth=0.2, zorder=-1))
        

        
# for chrom, s in zip(chrlist, chr_placements):
#     bandlist = ongened[chrom]
#     for b in bandlist:
#         offset = s + b[0]
#         ax.add_patch(mpatches.Rectangle((offset,(-2*height - fheight)), b[1]-b[0], fheight, facecolor='blue', 
#                                         edgecolor='blue', linewidth=0.1, zorder=-1))

# draw oncogene regions  
for chrom, s in zip(chrlist, chr_placements):
    bandlist = oncogened[chrom]
    for b in bandlist:
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,(-2*height - fheight)), b[1]-b[0], fheight, facecolor='blue', 
                                        edgecolor='blue', linewidth=0.2, zorder=-1))



# for chrom, s in zip(chrlist, chr_placements):
#     bandlist = all_ec_overlap[chrom]
#     for b in bandlist:
#         offset = s + b[0]
#         ax.add_patch(mpatches.Rectangle((offset,(-2.5*height - 2*fheight)), b[1]-b[0], fheight, facecolor='indigo', 
#                                         edgecolor='indigo', linewidth=0.1, zorder=-1))

# draw overlap regoins
for chrom, s in zip(chrlist, chr_placements):
    bandlist = overlapd[chrom]
    for b in bandlist:
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,(-2.5*height - 2*fheight)), b[1]-b[0], fheight, facecolor='purple', 
                                        edgecolor='purple', linewidth=0.2, zorder=-1))
    
        
ax.set_aspect(1.0)
plt.axis('off')
ax.set_xlim(-spacing, plot_len+spacing)
ax.set_ylim(-5*height, height*1.2)
#plt.savefig("alltumor_urine_SL_overlaps.png",bbox_inches='tight', dpi=300)
#plt.savefig("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/Focal_SV/SV_Focal.pdf", bbox_inches='tight')
plt.savefig("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/AA_1.3.r6/STAT_Figure/SVnew_GISTIC_AMP/SV_GISTIC_AMP.pdf", bbox_inches='tight')





'''
The code below will draw this plot for one chromosome only (chr17 by default)
'''

chrlist = []
chrlens = []

# change to hg38 as needed
with open(structure_file) as infile:
    for line in infile:
        fields = line.rsplit("\t")
        if fields[0] != "chr17":
            continue
            
        chrlist.append(fields[0])
        chrlens.append(int(fields[2]))
        
chr_total_len = chrlens[chrlist.index('chr17')]
spacing_prop = 0.01
n_entries = 1
spacing = spacing_prop*chr_total_len
total_spacing = spacing*n_entries
plot_len = chr_total_len + total_spacing
height = 0.02*plot_len

# place each entry
chr_placements = [0]
    
    
print(list(zip(chrlist,chr_placements)))


fig, ax = plt.subplots(figsize=(8, 4.25))

# plt.subplots_adjust(bottom=0.15, wspace=0.05)

for chrom, s, l in zip(chrlist, chr_placements, chrlens):
    bb = mtransforms.Bbox([[s, 0], [s+l, height]])
    fancy = add_fancy_patch_around(ax, bb, boxstyle="round,rounding_size=800000", linewidth=0.6)
    ax.text(s + l/2, height*1.2, chrom.lstrip("chr"), ha='center', fontsize=6)
    
for chrom, s in zip(chrlist, chr_placements):
    bandlist = chrom_to_items[chrom]
    for b in bandlist:
        ctup = make_tuple("".join(b[2].split()))   #index | other_value | color_tuple
        if any([x > 1 for x in ctup]):
            ctup = tuple([x/255.0 for x in ctup])
        
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,height*0.04), b[1]-b[0], height*0.915, 
                                        facecolor=ctup, edgecolor='none', zorder=-1))


# ecdna regions
fheight = height*1.1
for chrom, s in zip(chrlist, chr_placements):
    bandlist = ecregiond[chrom]
    for b in bandlist:
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,-1.5*height), b[1]-b[0], fheight, 
                                        facecolor='r', edgecolor='r', linewidth=0.2, zorder=-1))
        
for chrom, s in zip(chrlist, chr_placements):
    bandlist = oncogened[chrom]
    for b in bandlist:
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,(-2*height - fheight)), b[1]-b[0], fheight, facecolor='blue', 
                                        edgecolor='blue', linewidth=0.2, zorder=-1))
        genes = sorted([x.data for x in gtree[chrom][b[0]:b[1]]])
        print(genes)
        print("")
        if len(genes) > 1:
            genestring = "\n".join(genes)
        else:
            genestring = genes[0]
            
        mult=3
        # can remove, this just spreads some of the names for readability
        ha='center'
        if genestring == "ERBB2":
#             mult=3.5
            ha='center'
        elif genestring == "CDK12":
            ha='right'
        
        ax.text(offset + (b[1]-b[0])/2.0, (-3.5*height - mult*fheight), genestring, ha=ha, fontsize=5, 
                rotation=45, va='bottom')
        

for chrom, s in zip(chrlist, chr_placements):
    bandlist = overlapd[chrom]
    for b in bandlist:
        offset = s + b[0]
        ax.add_patch(mpatches.Rectangle((offset,(-2.5*height - 2*fheight)), b[1]-b[0], fheight, facecolor='purple', 
                                        edgecolor='purple', linewidth=0.2, zorder=-1))
    
        
ax.set_aspect(1.0)
plt.axis('off')
ax.set_xlim(-spacing, plot_len+spacing)
ax.set_ylim(-5*height, height*1.2)
#plt.savefig("chr17_linear_ecdna_overlaps.png",bbox_inches='tight', dpi=300)
#plt.savefig("chr17_linear_ecdna_overlaps.pdf", bbox_inches='tight')
