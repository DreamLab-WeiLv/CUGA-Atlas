## ID83 signature
library(ICAMS)
library(mSigAct)
library(cosmicsig)
input_file <- "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/ID/CUGA_all669.ID83.all"
input_catalog <- ICAMS::ReadCatalog(file = input_file)
test_catalog <- input_catalog[, 442:457, drop = FALSE]
sigs <- ICAMS::ReadCatalog(file="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/SigProfilerExtractor/CUGA669_ID83_output_ID500/ID83/Suggested_Solution/COSMIC_ID83_Decomposed_Solution/Signatures/COSMIC_ID83_Signatures.txt")
result <- PresenceAttributeSigActivity(
        spectra=test_catalog,
        sigs=sigs,
        output.dir='ID',
        m.opts = DefaultManyOpts(spectra = test_catalog),
        num.parallel.samples = 2,
        mc.cores.per.sample = 10,
        seed = 123,
        drop.low.mut.samples = FALSE,
        save.files = TRUE
)
proposed_assignment <- t(result[["proposed.assignment"]])
write.csv(proposed_assignment,'ID/ID_proposed_assignment.csv',row.names=T)

## DBS78 signature
input_file <- "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/DBS/CUGA_all669.DBS78.all"
input_catalog <- ICAMS::ReadCatalog(file = input_file)
sigs <- ICAMS::ReadCatalog(file="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/SigProfilerExtractor/CUGA669_DBS78_output_500/DBS78/Suggested_Solution/COSMIC_DBS78_Decomposed_Solution/Signatures/COSMIC_DBS78_Signatures.txt")

result <- PresenceAttributeSigActivity(
        spectra=input_catalog,
        sigs=sigs,
        output.dir='DBS',
        num.parallel.samples = 2,
        mc.cores.per.sample = 10,
        seed = 123,
        save.files = TRUE
)
proposed_assignment <- t(result$proposed.assignment)
write.csv(proposed_assignment,'DBS/DBS_proposed_assignment.csv',row.names=T)

## SBS96 signature
input_file <- "/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/SBS/CUGA_all669.SBS96.all"
input_catalog <- ICAMS::ReadCatalog(file = input_file)

sigs <- ICAMS::ReadCatalog(file="/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/SigProfilerExtractor/CUGA669_SBS96_output_500/SBS96/Suggested_Solution/COSMIC_SBS96_Decomposed_Solution/Signatures/COSMIC_SBS96_Signatures.txt")

result <- PresenceAttributeSigActivity(
        spectra=input_catalog,
        sigs=sigs,
        output.dir='SBS',
        num.parallel.samples = 2,
        mc.cores.per.sample = 10,
        seed = 123,
        save.files = TRUE
)
proposed_assignment <- t(result$proposed.assignment)
write.csv(proposed_assignment,'SBS/all_proposed_assignment.csv',row.names=T)
