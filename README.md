# CUGA-Atlas
The Chinese Urothelial Carcinoma Genome Atlas (CUGA) is a large, uniformly processed multi-omics resource centered on whole-genome sequencing of urothelial carcinoma. The dataset comprises whole-genome sequencing data from 605 patients, including 794 tumor samples with a mean coverage of 51×. Matched tumor–normal pairs are available for 497 patients, while an additional 108 tumor-only samples are included primarily for focal amplification analyses. Multi-regional sampling was performed in 66 patients, generating sequencing data from two to six spatially distinct tumor regions per case, enabling analysis of intratumoral heterogeneity and evolutionary trajectories. Tumor samples span multiple anatomical sites, including renal pelvis (213), ureter (140), bladder (438), urethra (1), and lymph node metastases (2). In addition, 167 preoperative urine samples collected within 1–3 days before surgery are available, supporting liquid biopsy–related analyses. Notably, 62% of the whole-genome sequencing data were newly generated in this project.

Beyond whole-genome sequencing, the dataset integrates additional omics layers for subsets of patients, including bulk RNA sequencing for 354 patients (mean 144 million clean reads), whole-exome sequencing for 226 patients at approximately 200× coverage, single-cell RNA sequencing for 31 patients, and digital whole-slide histopathology images for 492 patients. Clinical annotation includes a median diagnosis age of 68 years (range 31–93), a male predominance of 68%, and a balanced distribution between muscle-invasive (49%) and non–muscle-invasive disease (51%), with all samples obtained prior to systemic anticancer therapy. Collectively, CUGA represents one of the largest publicly available whole-genome–centered urothelial carcinoma datasets integrating genomic, transcriptomic, spatial, and pathological modalities, enabling comprehensive investigation of structural variation, ecDNA, noncoding drivers, tumor evolution, and tumor ecosystem states.

<img width="861" height="216" alt="截屏2026-02-25 14 08 12" src="https://github.com/user-attachments/assets/e798eafc-b41d-46e3-9bee-bae8882ca631" />

# Computational Environment

All analyses were performed using fixed software versions to ensure reproducibility.

## 🧰 Software and Computational Tools

| No. | Software | Version | Function | URL |
|-----|----------|----------|----------|-----|
| 1 | FastQC | v0.11.7 | Raw sequencing data quality control | https://github.com/s-andrews/FastQC |
| 2 | fastp | v0.23.2 | Adapter trimming and read filtering | https://github.com/OpenGene/fastp |
| 3 | BWA | v0.7.17 | Alignment of WGS/WES reads to GRCh38 | https://github.com/lh3/bwa |
| 4 | GATK | v4.2.5.0 | Duplicate marking, variant processing, mitochondrial variant calling | https://gatk.broadinstitute.org/hc/en-us |
| 5 | SAMtools | v1.11 | BAM sorting, indexing and coverage statistics | https://github.com/samtools/samtools |
| 6 | MuTect2 | v4.2.5.0 | Somatic SNV detection | https://gatk.broadinstitute.org/hc/en-us/articles/360037593851-Mutect2 |
| 7 | Strelka2 | v2.9.10 | Somatic indel detection | https://github.com/Illumina/strelka |
| 8 | BEDTools | v2.30.0 | Variant merging and genomic interval operations | https://github.com/arq5x/bedtools2 |
| 9 | ANNOVAR | annovar20200608 | Functional annotation of somatic variants | https://annovar.openbioinformatics.org/en/latest/ |
| 10 | OncoKB annotator | v3.3.2 | Clinical annotation of oncogenic alterations | https://github.com/oncokb/oncokb-annotator |
| 11 | 20/20+ | v1.2.3 | Coding driver gene identification | https://github.com/KarchinLab/2020plus |
| 12 | MutSigCV | v1.41 | Detection of significantly mutated genes | https://github.com/genepattern/MutSigCV |
| 13 | dNdScv | v0.1.0 | dN/dS-based positive selection analysis | https://github.com/im3sanger/dndscv |
| 14 | MutPanning | v2 | Detection of cancer driver genes | https://github.com/vanallenlab/MutPanningV2 |
| 15 | OncodriveFML | v2.2.0 | Functional impact–based driver discovery (coding and noncoding) | https://github.com/bbglab/oncodrivefml |
| 16 | MutSig2CV_NC | v2.0 | Noncoding driver detection | https://github.com/broadinstitute/getzlab-PCAWG-MutSig2CV_NC |
| 17 | ActiveDriverWGS | v1.2.1 | Regulatory element driver discovery | https://github.com/reimandlab/ActiveDriverWGSR |
| 18 | DriverPower | v1.0.2 | Statistical driver discovery framework | https://github.com/smshuai/DriverPower |
| 19 | MutationTimeR | v1.0.2 | Clonal timing of somatic mutations | https://github.com/gerstung-lab/MutationTimeR |
| 20 | PURPLE | v3.7 | Estimation of tumor purity, ploidy and mutation clonality | https://github.com/hartwigmedical/hmftools |
| 21 | SigProfilerMatrixGenerator | v1.2.31 | Construction of mutational matrices | https://github.com/SigProfilerSuite/SigProfilerMatrixGenerator |
| 22 | SigProfilerExtractor | v1.1.23 | De novo mutational signature extraction | https://github.com/SigProfilerSuite/SigProfilerExtractor |
| 23 | SigProfilerAssignment | v0.2.0 | Attribution of COSMIC mutational signatures | https://github.com/AlexandrovLab/SigProfilerAssignment |
| 24 | mSigHdp | v2.1.2 | Independent mutational signature validation | https://github.com/steverozen/mSigHdp |
| 25 | MSA | v2.0 | Mutational signature activity attribution | https://gitlab.com/s.senkin/MSA |
| 26 | FACETS | v0.5.14 | Allele-specific copy-number and purity/ploidy estimation | https://github.com/mskcc/facets |
| 27 | GISTIC | v2.0.23 | Identification of recurrent focal and arm-level CNAs | https://github.com/broadinstitute/gistic2 |
| 28 | CNVKit | v0.9.10 | Detection of focal copy-number alterations | https://github.com/etal/cnvkit |
| 29 | AmpliconArchitect | v1.3.r6 | Reconstruction of amplicon structures | https://github.com/virajbdeshpande/AmpliconArchitect |
| 30 | AmpliconClassifier | v1.0.0 | Classification of amplification topology | https://github.com/AmpliconSuite/AmpliconClassifier |
| 31 | AmpliconSuite-pipeline | v1.0.0 | Integrated ecDNA reconstruction workflow | https://github.com/AmpliconSuite/AmpliconSuite-pipeline |
| 32 | Manta | v1.6.0 | Somatic structural variant detection | https://github.com/Illumina/manta |
| 33 | LUMPY | v0.2.13 | Structural variant detection | https://github.com/arq5x/lumpy-sv |
| 34 | SvABA | v1.1.0 | Local assembly–based SV detection | https://github.com/walaj/svaba |
| 35 | DELLY | v1.1.3 | Structural variant detection | https://github.com/dellytools/delly |
| 36 | SURVIVOR | v1.0.7 | Integration of multi-caller SV results | https://github.com/fritzsedlazeck/SURVIVOR |
| 37 | iSTAT | v1.0 | Statistical analysis of genomic interval overlap | https://github.com/shahab-sarmashghi/ISTAT |
| 38 | ShatterSeek | v1.1 | Chromothripsis detection | https://github.com/parklab/ShatterSeek |
| 39 | maftools | v2.14.0 | Mutation visualization | https://github.com/PoisonAlien/maftools |
| 40 | TrimGalore | v0.6.7 | RNA-seq adapter trimming | https://github.com/FelixKrueger/TrimGalore |
| 41 | STAR | v2.7.10a | RNA-seq alignment | https://github.com/alexdobin/STAR |
| 42 | RSEM | v1.3.3 | Transcript quantification | https://github.com/deweylab/RSEM |
| 43 | sva | v3.46.0 | Batch effect correction (ComBat-seq) | https://github.com/jtleek/sva |
| 44 | phangorn | v2.12.1 | Phylogenetic reconstruction | https://cran.r-project.org/web/packages/phangorn/index.html |
| 45 | ape | v5.8.1 | Phylogenetic analysis | https://cran.r-project.org/package=ape |
| 46 | ggtree | v3.16.3 | Phylogenetic tree visualization | https://bioconductor.org/packages/ggtree |
| 47 | PyTorch | 2.1.0 | Deep learning framework | https://pytorch.org |
| 48 | Python | v3.8.20 | Programming language environment | https://www.python.org |
| 49 | sambamba | v0.7.0 | BAM processing | https://github.com/biod/sambamba |
| 50 | Seurat | v5.1.0 | scRNA-seq analysis | https://github.com/satijalab/seurat |
| 51 | DoubletFinder | v2.0.3 | Doublet detection | https://github.com/chris-mcginnis-ucsf/DoubletFinder |
| 52 | inferCNV | v1.18.1 | CNV inference at single-cell level | https://github.com/broadinstitute/infercnv |
| 53 | CytoTRACE2 | v1.0.0 | Cellular potency inference | https://github.com/digitalcytometry/cytotrace2 |
| 54 | ComplexHeatmap | v2.25.2 | Heatmap visualization | https://github.com/jokergoo/ComplexHeatmap |
| 55 | clusterProfiler | v4.10.1 | GO enrichment analysis | https://github.com/YuLab-SMU/clusterProfiler |
| 56 | QuPath | v0.5.1 | Image analysis | https://qupath.github.io/ |
| 57 | Harmony | v1.2.4 | Batch correction | https://github.com/pardeike/Harmony |
| 58 | kBET | v0.99.6 | Batch effect evaluation | https://github.com/theislab/kBET |
| 59 | PISA | v0.2 | scRNA-seq processing | https://github.com/shiquan/PISA |
| 60 | NMF (R package) | v0.28 | Matrix factorization | https://cran.r-project.org/package=NMF |
| 61 | torchvision | 0.16.0 | Image transformations | https://pytorch.org/vision/stable/index.html |
| 62 | timm | 1.0.15 | Vision model backbones | https://github.com/huggingface/pytorch-image-models |
| 63 | nystrom-attention | 0.0.14 | Efficient attention | https://github.com/lucidrains/nystrom-attention |
| 64 | TRIDENT | Original implementation | WSI preprocessing | https://github.com/mahmoodlab/TRIDENT |
| 65 | CONCH | Original implementation | Vision-language model | https://huggingface.co/MahmoodLab/CONCH |
| 66 | DeepCUGA | 1 | Genotype–phenotype mapping model | This study |
| 67 | NumPy | 1.24.4 | Numerical computing | https://numpy.org |
| 68 | pandas | 2.0.3 | Data handling | https://pandas.pydata.org |
| 69 | Scikit-learn | 1.3.2 | Model evaluation | https://scikit-learn.org/stable |
| 70 | SciPy | 1.10.1 | Scientific computing | https://scipy.org |
| 71 | h5py | 3.11.0 | Data storage | https://h5py.org |
| 72 | OpenSlide-Python | 1.4.0 | WSI reading | https://openslide.org |
| 73 | OpenCV-Python | 4.11.0 | Image processing | https://opencv.org |
| 74 | Pillow (PIL) | 10.4.0 | Image manipulation | https://pypi.org/project/pillow |
| 75 | Matplotlib | 3.7.5 | Plotting | https://matplotlib.org |
| 76 | TensorBoard | 2.14.0 | Training monitoring | https://tensorflow.org/tensorboard |
| 77 | NVIDIA RTX 4090 GPU | 24GB | Hardware accelerator | https://nvidia.com |
| 78 | CUDA Toolkit | 12.1 | GPU computing | https://developer.nvidia.com/cuda-toolkit |
| 79 | cuDNN | 8.9.2 | Deep learning acceleration | https://developer.nvidia.com/cudnn |
| 80 | R | v4.1.2 | Statistical computing and visualization | https://www.r-project.org/ |
| 81 | GraphPad Prism | v9.5.1 | Statistical analysis and visualization | https://www.graphpad.com/ |








# Data
We hope that the CUGA dataset will be a valuable resource for the urothelial carcinoma research community.

If you have requests for raw data, processed or downstream data, or require any additional information or assistance, please feel free to contact: Dr. Wei Lv (wei_lv2024@163.com or lvwei@him.cas.cn)
