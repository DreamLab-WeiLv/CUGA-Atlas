# CUGA-Atlas
The Chinese Urothelial Carcinoma Genome Atlas (CUGA) is a large, uniformly processed multi-omics resource centered on whole-genome sequencing of urothelial carcinoma. The dataset comprises whole-genome sequencing data from 605 patients, including 794 tumor samples with a mean coverage of 51×. Matched tumor–normal pairs are available for 497 patients, while an additional 108 tumor-only samples are included primarily for focal amplification analyses. Multi-regional sampling was performed in 66 patients, generating sequencing data from two to six spatially distinct tumor regions per case, enabling analysis of intratumoral heterogeneity and evolutionary trajectories. Tumor samples span multiple anatomical sites, including renal pelvis (213), ureter (140), bladder (438), urethra (1), and lymph node metastases (2). In addition, 167 preoperative urine samples collected within 1–3 days before surgery are available, supporting liquid biopsy–related analyses. Notably, 62% of the whole-genome sequencing data were newly generated in this project.

Beyond whole-genome sequencing, the dataset integrates additional omics layers for subsets of patients, including bulk RNA sequencing for 354 patients (mean 144 million clean reads), whole-exome sequencing for 226 patients at approximately 200× coverage, single-cell RNA sequencing for 31 patients, and digital whole-slide histopathology images for 492 patients. Clinical annotation includes a median diagnosis age of 68 years (range 31–93), a male predominance of 68%, and a balanced distribution between muscle-invasive (49%) and non–muscle-invasive disease (51%), with all samples obtained prior to systemic anticancer therapy. Collectively, CUGA represents one of the largest publicly available whole-genome–centered urothelial carcinoma datasets integrating genomic, transcriptomic, spatial, and pathological modalities, enabling comprehensive investigation of structural variation, ecDNA, noncoding drivers, tumor evolution, and tumor ecosystem states.

<img width="861" height="216" alt="截屏2026-02-25 14 08 12" src="https://github.com/user-attachments/assets/e798eafc-b41d-46e3-9bee-bae8882ca631" />

# Computational Environment

All analyses were performed using fixed software versions to ensure reproducibility.

## Software List

<details>
<summary><strong>Click to expand full software list</strong></summary>

| Software | Version | Function | URL |
|----------|----------|----------|-----|
| FastQC | v0.11.7 | Raw sequencing data quality control | https://github.com/s-andrews/FastQC |
| fastp | v0.23.2 | Adapter trimming and read filtering | https://github.com/OpenGene/fastp |
| BWA | v0.7.17 | Alignment of WGS/WES reads to GRCh38 | https://github.com/lh3/bwa |
| GATK | v4.2.5.0 | Duplicate marking, variant processing, mitochondrial variant calling | https://gatk.broadinstitute.org/hc/en-us |
| SAMtools | v1.11 | BAM sorting, indexing and coverage statistics | https://github.com/samtools/samtools |
| MuTect2 | v4.2.5.0 | Somatic SNV detection | https://gatk.broadinstitute.org/hc/en-us/articles/360037593851-Mutect2 |
| Strelka2 | v2.9.10 | Somatic indel detection | https://github.com/Illumina/strelka |
| BEDTools | v2.30.0 | Variant merging and genomic interval operations | https://github.com/arq5x/bedtools2 |
| ANNOVAR | annovar20200608 | Functional annotation of somatic variants | https://annovar.openbioinformatics.org/en/latest/ |
| OncoKB annotator | v3.3.2 | Clinical annotation of oncogenic alterations | https://github.com/oncokb/oncokb-annotator |
| 20/20+ | v1.2.3 | Coding driver gene identification | https://github.com/KarchinLab/2020plus |
| MutSigCV | v1.41 | Detection of significantly mutated genes | https://github.com/genepattern/MutSigCV |
| dNdScv | v0.1.0 | dN/dS-based positive selection analysis | https://github.com/im3sanger/dndscv |
| MutPanning | v2 | Detection of cancer driver genes | https://github.com/vanallenlab/MutPanningV2 |
| OncodriveFML | v2.2.0 | Functional impact–based driver discovery (coding and noncoding) | https://github.com/bbglab/oncodrivefml |
| MutSig2CV_NC | v2.0 | Noncoding driver detection | https://github.com/broadinstitute/getzlab-PCAWG-MutSig2CV_NC |
| ActiveDriverWGS | v1.2.1 | Regulatory element driver discovery | https://github.com/reimandlab/ActiveDriverWGSR |
| DriverPower | v1.0.2 | Statistical driver discovery framework | https://github.com/smshuai/DriverPower |
| SigProfilerMatrixGenerator | v1.2.31 | Construction of mutational matrices (SBS, DBS, ID, SV, CNV) | https://github.com/SigProfilerSuite/SigProfilerMatrixGenerator |
| SigProfilerExtractor | v1.1.23 | De novo mutational signature extraction | https://github.com/SigProfilerSuite/SigProfilerExtractor |
| mSigHdp | v2.1.2 | Independent mutational signature validation | https://github.com/steverozen/mSigHdp |
| MSA | v2.0 | Mutational signature activity attribution | https://gitlab.com/s.senkin/MSA |
| FACETS | v0.5.14 | Allele-specific copy-number and purity/ploidy estimation | https://github.com/mskcc/facets |
| GISTIC | v2.0.23 | Identification of recurrent focal and arm-level CNAs | https://github.com/broadinstitute/gistic2 |
| CNVKit | v0.9.10 | Detection of focal copy-number alterations | https://github.com/etal/cnvkit |
| AmpliconArchitect | v1.3.r6 | Reconstruction of amplicon structures | https://github.com/virajbdeshpande/AmpliconArchitect |
| AmpliconClassifier | v1.0.0 | Classification of amplification topology (ecDNA, BFB, etc.) | https://github.com/AmpliconSuite/AmpliconClassifier |
| AmpliconSuite-pipeline | v1.0.0 | Integrated ecDNA reconstruction workflow | https://github.com/AmpliconSuite/AmpliconSuite-pipeline |
| Manta | v1.6.0 | Somatic structural variant detection | https://github.com/Illumina/manta |
| LUMPY | v0.2.13 | Structural variant detection | https://github.com/arq5x/lumpy-sv |
| SvABA | v1.1.0 | Local assembly–based SV detection | https://github.com/walaj/svaba |
| DELLY | v1.1.3 | Structural variant detection | https://github.com/dellytools/delly |
| SURVIVOR | v1.0.7 | Integration of multi-caller SV results | https://github.com/fritzsedlazeck/SURVIVOR |
| ShatterSeek | v1.1 | Chromothripsis detection | https://github.com/parklab/ShatterSeek |
| maftools | v2.14.0 | Mutation visualization (rainfall plots, etc.) | https://github.com/PoisonAlien/maftools |
| TrimGalore | v0.6.7 | RNA-seq adapter trimming | https://github.com/FelixKrueger/TrimGalore |
| STAR | v2.7.10a | RNA-seq alignment | https://github.com/alexdobin/STAR |
| RSEM | v1.3.3 | Transcript quantification | https://github.com/deweylab/RSEM |
| sva | v3.46.0 | Batch effect correction (ComBat-seq) | https://github.com/jtleek/sva |
| PyTorch | 2.1.0 | Deep learning model implementation | https://pytorch.org |
| Python | v3.8.20 | Programming language environment | https://www.python.org |
| sambamba | v0.7.0 | BAM sorting (scRNA-seq preprocessing) | https://github.com/biod/sambamba |
| Seurat | v5.1.0 | scRNA-seq normalization, clustering, visualization | https://github.com/satijalab/seurat |
| DoubletFinder | v2.0.3 | Doublet detection in scRNA-seq | https://github.com/chris-mcginnis-ucsf/DoubletFinder |
| inferCNV | v1.18.1 | CNV inference at single-cell level | https://github.com/broadinstitute/infercnv |
| CytoTRACE2 | v1.0.0 | Cellular potency inference | https://github.com/digitalcytometry/cytotrace2 |
| ComplexHeatmap | v2.25.2 | Heatmap visualization | https://github.com/jokergoo/ComplexHeatmap |
| clusterProfiler | v4.10.1 | GO enrichment analysis | https://github.com/YuLab-SMU/clusterProfiler |
| QuPath | v0.5.1 | Multiplex IF image analysis | https://qupath.github.io/ |
| Harmony | v1.2.4 | Batch correction for scRNA-seq | https://github.com/pardeike/Harmony |
| torchvision | 0.16.0 | Image transformations and augmentations | https://pytorch.org |
| timm | 1.0.15 | Pre-trained vision model backbones | https://github.com/huggingface/pytorch-image-models |
| nystrom-attention | 0.0.14 | Efficient self-attention implementation | https://github.com/lucidrains/nystrom-attention |
| TRIDENT | Original implementation | Automated WSI preprocessing | https://github.com/mahmoodlab/TRIDENT |
| CONCH | Original implementation | Vision-language foundation model | https://huggingface.co/MahmoodLab/CONCH |
| DeepCUGA | 1 | Core genotype-phenotype mapping algorithm | https://github.com/xxx |
| NumPy | 1.24.4 | Numerical computation | https://numpy.org |
| pandas | 2.0.3 | Data management | https://pandas.pydata.org |
| Scikit-learn | 1.3.2 | Performance metrics and model evaluation | https://scikit-learn.org |
| SciPy | 1.10.1 | Statistical analysis | https://scipy.org |
| h5py | 3.11.0 | Patch feature storage | https://h5py.org |
| OpenSlide-Python | 1.4.0 | Whole slide image reading | https://openslide.org |
| OpenCV-Python | 4.11.0 | Image preprocessing | https://opencv.org |
| Pillow (PIL) | 10.4.0 | Image loading and manipulation | https://pypi.org/project/pillow |
| Matplotlib | 3.7.5 | Plot generation | https://matplotlib.org |
| TensorBoard | 2.14.0 | Training monitoring | https://tensorflow.org/tensorboard |
| NVIDIA RTX 4090 GPU | 24GB | Deep learning hardware accelerator | https://nvidia.com |
| CUDA Toolkit | 12.1 | GPU computing platform | https://developer.nvidia.com/cuda-toolkit |
| cuDNN | 8.9.2 | GPU-accelerated deep learning primitives | https://developer.nvidia.com/cudnn |

</details>








# Data
We hope that the CUGA dataset will be a valuable resource for the urothelial carcinoma research community.

If you have requests for raw data, processed or downstream data, or require any additional information or assistance, please feel free to contact: Dr. Wei Lv (wei_lv2024@163.com or lvwei@him.cas.cn)
