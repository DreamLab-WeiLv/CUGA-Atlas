from SigProfilerMatrixGenerator.scripts import CNVMatrixGenerator as scna
file_type = "FACETS"
input_file = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/25.Facets/results/seg_tsv/CUGA_all669_facet_seg_forSiginput.tsv"
output_path = "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/CNV_FACET_669/"
project = "FACETS_test"
scna.generateCNVMatrix(file_type, input_file, project, output_path)


