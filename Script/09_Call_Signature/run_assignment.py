from SigProfilerAssignment import Analyzer as Analyze
#Analyze.denovo_fit(samples="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/SBS/CUGA_all669.SBS96.all",
#                   output="./zeng/SBS96_sig15",
#                   input_type="matrix",
#                   signatures="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/SigProfilerExtractor/CUGA669_SBS96_output_500/SBS96/All_Solutions/SBS96_15_Signatures/Signatures/SBS96_S15_Signatures.txt",
#                   genome_build="GRCh38")

import SigProfilerAssignment as spa

from SigProfilerAssignment import Analyzer as Analyze
Analyze.decompose_fit(samples="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/SBS/CUGA_all669.SBS96.all", 
                      output="./zeng/SBS96_sig15_cosmic",
                      input_type="matrix",
                      signatures="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/SigProfilerExtractor/CUGA669_SBS96_output_500/SBS96/All_Solutions/SBS96_15_Signatures/Signatures/SBS96_S15_Signatures.txt",
                      genome_build="GRCh38")
