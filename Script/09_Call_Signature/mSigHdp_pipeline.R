library(ICAMS)
library(mSigHdp)
library(cosmicsig)

## DBS signature #####
input_catalog = ICAMS::ReadCatalog(file = '/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669_0513/output/DBS/CUGA_all669.DBS78.all')
output_home <- '/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/mSigHdp/new/DBS'
mSigHdp::RunHdpxParallel(input.catalog      = input_catalog,
                         ground.truth.sig   = cosmicsig::COSMIC_v3.2$signature$GRCh38$ID,
                         out.dir            = output_home,
                         CPU.cores          = 2,
                         num.child.process  = 2,
                         seedNumber         = 123,
                         K.guess            = 20,
                         burnin.checkpoint  = TRUE,
                         burnin             = 100,
                         burnin.multiplier  = 2,
                         post.n             = 5,
                         post.space         = 5,
                         multi.types        = FALSE,
                         overwrite          = TRUE,
                         gamma.alpha        = 1,
                         gamma.beta         = 20,
                         cos.merge          = 0.90,
                         confident.prop     = 0.6)

## ID signature #####
input_catalog = ICAMS::ReadCatalog(file = '/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669_0513/output/ID/CUGA_all669.ID83.all')
output_home <- '/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/mSigHdp/new/ID'
mSigHdp::RunHdpxParallel(input.catalog      = input_catalog,
                         ground.truth.sig   = cosmicsig::COSMIC_v3.2$signature$GRCh38$ID,
                         out.dir            = output_home,
                         CPU.cores          = 2,
                         num.child.process  = 2,
                         seedNumber         = 123,
                         K.guess            = 20,
                         burnin.checkpoint  = TRUE,
                         burnin             = 100,
                         burnin.multiplier  = 2,
                         post.n             = 5,
                         post.space         = 5,
                         multi.types        = FALSE,
                         overwrite          = TRUE,
                         gamma.alpha        = 1,
                         gamma.beta         = 20,
                         cos.merge          = 0.90,
                         confident.prop     = 0.6)

## SBS signature #####
input_catalog = ICAMS::ReadCatalog(file = '/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669_0513/output/SBS/CUGA_all669.SBS96.all')
output_home <- '/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/mSigHdp/new/SBS'
#extract_components_from_clusters <- hdpx:::extract_components_from_clusters
mSigHdp::RunHdpxParallel(input.catalog      = input_catalog,
                         ground.truth.sig   = cosmicsig::COSMIC_v3.2$signature$GRCh38$ID,
                         out.dir            = output_home,
                         CPU.cores          = 2,
                         num.child.process  = 2,
                         seedNumber         = 123,
                         K.guess            = 20,
                         burnin.checkpoint  = TRUE,
                         burnin             = 100,
                         burnin.multiplier  = 2,
                         post.n             = 5,
                         post.space         = 5,
                         multi.types        = FALSE,
                         overwrite          = TRUE,
                         gamma.alpha        = 1,
                         gamma.beta         = 20,
                         cos.merge          = 0.90,
                         confident.prop     = 0.6)
