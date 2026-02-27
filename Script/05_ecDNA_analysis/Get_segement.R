setwd('/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/Pick_Up_results/AC_all_CUGA/all_CUGA/all_CUGA_classification_bed_files')
fin <- data.frame()
file_list <- as.data.frame(list.files(getwd()))
for (file in file_list[,1]) {
  tryCatch({
    d <- read.table(paste0(getwd(),"/",file), sep = '\t',header = F)
    tmp <- strsplit(file, "_")
    selected_elements <- tmp[[1]][1:(length(tmp[[1]]) - 3)]
    sample <- paste(selected_elements, collapse = '_')
    d$SampleName <- sample
    selected_elements2 <- tmp[[1]][(length(tmp[[1]]) - 2):(length(tmp[[1]]) - 1)]
    feature <- paste(selected_elements2,collapse = '_')
    d$Feature <- feature
    fin <- rbind(fin,d)
  }, error = function(e) {
    print(paste("Error in column", file, ":", conditionMessage(e)))
  })
}
fin$Length <- as.numeric(fin$V3) - as.numeric(fin$V2)
library(dplyr)
fin <- fin %>%
  group_by(SampleName,Feature) %>%
  mutate(sum_length = sum(Length))
fin <- as.data.frame(fin)
t <- read.table('/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/08.runAA/Pick_Up_results/AC_all_CUGA/all_CUGA/all_CUGA_feature_basic_properties.tsv',sep='\t',header=T)
fin$tmp <- paste(fin$SampleName,fin$Feature,fin$sum_length,sep = "_")
t$tmp <- paste(t$feature_ID,t$captured_region_size_bp,sep = "_")
match_rows <- match(fin$tmp, t$tmp)  
matched <- ifelse(match_rows > 0, t[match_rows, ]$max_feature_CN, NA)  
write.table(fin,'~/PROJECT/chromothripsis/08.runAA/Pick_Up_results/AC_all_CUGA/all_CUGA/all_CUGA_segcn.txt',sep='\t',quote=F,row.names = F)

