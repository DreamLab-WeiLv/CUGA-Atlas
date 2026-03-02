from SigProfilerMatrixGenerator.scripts import SVMatrixGenerator as sv
#input_dir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/shell/input_SV/"
#input_dir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/shell/SV_input_sigprofiler/"
#input_dir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/shell/SV_input_sigprofiler_manta_669"
#input_dir="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/shell/SV_input_sigprofiler_lumpy_669"
input_dir="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/shell/SV_input_sigprofiler_svaba_669"
output_dir = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/CUGA669_SV_svaba"
project = "CUGA_SV_669_svaba"
sv.generateSVMatrix(input_dir, project, output_dir)

