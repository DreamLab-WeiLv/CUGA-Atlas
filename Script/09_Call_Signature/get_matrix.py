from SigProfilerMatrixGenerator.scripts import SigProfilerMatrixGeneratorFunc as matGen
matrices = matGen.SigProfilerMatrixGeneratorFunc("CUGA_all669", "GRCh38", "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669_0513",plot=True, exome=False, bed_file=None, chrom_based=False, tsb_stat=False, seqInfo=False, cushion=100)

