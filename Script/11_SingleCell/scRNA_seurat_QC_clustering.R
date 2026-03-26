library(Seurat)
library(dplyr)
library(DoubletFinder)
library(harmony)

setwd('~/PROJECT/raw_rds')
data <- read.table('samples.tsv', header = FALSE, sep = '\t')

process_sample <- function(file_path) {
  message("Processing: ", file_path)
  
  obj <- readRDS(file_path)
  
  # QC
  obj[["percent.mt"]] <- PercentageFeatureSet(obj, pattern = "^MT-")
  obj <- subset(obj, subset = nFeature_RNA > 200 & 
                  nFeature_RNA < 6000 & 
                  percent.mt < 25)
  
  # Initial preprocessing and clustering
  obj <- obj %>%
    NormalizeData() %>%
    FindVariableFeatures(nfeatures = 2000) %>%
    ScaleData() %>%
    RunPCA(npcs = 30, verbose = FALSE) %>%
    FindNeighbors(obj, dims = 1:30) %>%
    FindClusters(resolution = 0.1)
  
  # DoubletFinder
  sweep.res <- paramSweep_v3(obj, PCs = 1:30, sct = FALSE)
  sweep.stats <- summarizeSweep(sweep.res, GT = FALSE)
  bcmvn <- find.pK(sweep.stats)
  
  pK <- bcmvn$pK[which.max(bcmvn$MeanBC)]
  pK <- as.numeric(as.character(pK))
  
  homotypic.prop <- modelHomotypic(obj$seurat_clusters)
  
  nExp <- round(0.08 * ncol(obj))   
  nExp.adj <- round(nExp * (1 - homotypic.prop))
  
  obj <- doubletFinder_v3(obj,PCs = 1:30,pN = 0.25,pK = pK,nExp = nExp.adj)
  
  # 
  df_col <- grep("DF.classifications", colnames(obj@meta.data), value = TRUE)
  obj$doublet_info <- obj@meta.data[[df_col]]
  
  obj <- subset(obj, subset = doublet_info == "Singlet")
  
  return(obj)
}


sclist <- lapply(data$V1, process_sample)

seurat_data <- Reduce(function(x, y) merge(x, y), sclist)

# clustering
seurat_data <- seurat_data %>%
  NormalizeData() %>%
  FindVariableFeatures(nfeatures = 2000) %>%
  ScaleData() %>%
  RunPCA(npcs = 30, verbose = FALSE) %>%
  RunUMAP(dims = 1:30) %>%
  FindNeighbors(dims = 1:30) %>%
  FindClusters(resolution = 0.1)

saveRDS(seurat_data, 'all.rds')

# marker
pan_marker <- c("VWF","PECAM1","ENG","CDH5",
                "DCN","ACTA2","COL1A1","COL1A2",
                "CD68","LYZ","CD163","CD14",
                "CD79A","CD79B","MS4A1","MZB1",
                "CD2","CD3D","CD3E","NKG7","GZMA",
                "EPCAM","KRT18","KRT7","KRT19")

p1 <- DimPlot(seurat_data, reduction = "umap",
              group.by = "orig.ident", raster = TRUE) +
  theme(legend.position = "none")

p2 <- DotPlot(seurat_data, features = pan_marker,
              group.by = "seurat_clusters") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

##################################################
## subtype reclustering（Harmony）
seurat_data <- readRDS('B.rds')

seurat_data <- seurat_data %>%
  NormalizeData() %>%
  FindVariableFeatures(nfeatures = 2000) %>%
  ScaleData() %>%
  RunPCA(npcs = 30, verbose = FALSE) %>%
  RunHarmony("orig.ident") %>%
  RunUMAP(reduction = "harmony", dims = 1:30) %>%
  FindNeighbors(reduction = "harmony", dims = 1:30) %>%
  FindClusters(resolution = 1)

# marker
seurat.markers <- FindAllMarkers(
  seurat_data,
  only.pos = TRUE,
  min.pct = 0.25,
  logfc.threshold = 0.25
)