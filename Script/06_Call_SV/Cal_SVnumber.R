setwd("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV")
# 获取目标文件夹中的所有文件
file_path <- "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/duodian-WGS/results"  # 替换为你的目标文件夹路径
file_list <- list.files(file_path,pattern = "*.vcf")

# 创建空的数据框来存储文件名和行数
res <- data.frame(SampleName = character(), SVnumber = integer(), stringsAsFactors = FALSE)

# 循环读取文件并统计行数
for (file_name in file_list) {
  file_full_path <- file.path(file_path, file_name)
#  comment_lines <- sum(grepl("^#", lines,perl = TRUE))  # 计算以"#"开头的注释行数：当前已计算得知为59
  line_count <- length(readLines(file_full_path)) - 59
  
  # 将文件名和行数添加到数据框中
  res <- rbind(res, data.frame(File = file_name, Line_Count = line_count, stringsAsFactors = FALSE))
}

# 打印结果数据框
write.table(res, "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/20.Merge_SV/duodian-WGS-Urine/duodian-WGS_final_SVnumber.txt",quote = F,sep = "\t",row.names = F)
