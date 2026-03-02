### 先运行 SigProfilerExtractor,再运行SigProfilerAssignment得到cosmic signature特征
#!/bin/bash

module load anaconda/4.12.0
conda activate /share/home/luoylLab/zengyuchen/.conda/envs/Sigpro
python run_assignment.py

# 定义要循环的签名数量列表
sig_numbers=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)  # 根据你的实际需求修改

# 基础路径模板
base_signatures_path="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/SigProfilerExtractor/CUGA669_SBS96_output_500/SBS96/All_Solutions/SBS96_%d_Signatures/Signatures/SBS96_S%d_Signatures.txt" ## 这里替换不同类型的Signature文件夹路径
base_output_path="./zeng/SBS96_sig%d_cosmic"

# 循环每个签名数量
for num in "${sig_numbers[@]}"; do
    signatures=$(printf "$base_signatures_path" $num $num)
    output=$(printf "$base_output_path" $num)
    
    # 打印参数
    echo "====================================="
    echo "开始运行：签名数量=$num, output=$output"
    echo "====================================="
    
    python sig_decompose.py "$output" "$signatures"
    
    # 检查运行状态
    if [ $? -eq 0 ]; then
        echo "✅ 签名数量$num 运行成功"
    else
        echo "❌ 签名数量$num 运行失败"
        # exit 1  # 可选：失败退出
    fi
done

echo "🎉 所有签名数量的任务运行完成！"


