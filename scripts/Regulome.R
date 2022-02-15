# /usr/bin/env Rscript
# To run it
###Rscript --vanilla z_estimates.R $gwas_summary

# test if there is at least one argument: if not, return an error
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("Please check your input file", call.=FALSE)
}

#install.packages("haploR", dependencies = TRUE)

#ldThresh: LD threshold, r2 (select NA to only show query variants). Default: 0.8.
#ldPop: 1000G Phase 1 population for LD calculation.  Can be: "AFR", "AMR", "ASN". Default: "EUR".
#epi: Source for epigenomes.  Possible values: ‘vanilla’ for ChromHMM (Core 15-state model); ‘imputed’ for ChromHMM (25-state model using 12 imputed marks); ‘methyl’ for
#H3K4me1/H3K4me3 peaks; ‘acetyl’ for H3K27ac/H3K9ac peaks. Default: ‘vanilla’.
#cons: Mammalian conservation algorithm.  Possible values: ‘gerp’ for GERP, ‘siphy’ for SiPhy-omega, ‘both’ for both. Default: ‘siphy’.
#genetypes: Show position relative to. Possible values: ‘gencode’ for Gencode genes; ‘refseq’ for RefSeq genes; ‘both’ for both. Default: ‘gencode’.
#url: HaploReg url address.  Default: <https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php>
#timeout: A ‘timeout’ parameter for ‘curl’. Default: 100
#encoding: sets the ‘encoding’ for correct retrieval web-page content. Default: ‘UTF-8’
## https://cran.r-project.org/web/packages/haploR/vignettes/haplor-vignette.html

data=args[1]
outdir=args[2]
genomeAssembly=  args[3]   # {GRCh37 , RCh38}

library(haploR)
query2= queryRegulome(query = data,  genomeAssembly = genomeAssembly)

#A data frame (table) OR a list with the following items: - guery_coordinates - features - regulome_score - variants - nearby_snps - assembly
output2=paste0(outdir,'/',"results_Regulome.txt",sep="")
capture.output(query2, file=output2,row.names=F)
