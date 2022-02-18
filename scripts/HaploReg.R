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

gwas_summary=args[1]
outdir=args[2]
ldThresh= args[3] #0.8
ldPop= args[4]     # {"AFR", "AMR", "ASN", "EUR"}
epi= args[5]   # {"vanilla", "imputed", "methyl"}
cons= args[6]     # {"gerp",  "siphy","both"}
genetypes= args[7]  # {"gencode", "refseq"}


library(haploR)
df <- read.table(gwas_summary,  header=T)
data= as.character(df[,1])
names(data)=as.character(df[,1])
#query=queryHaploreg(query = data , study = NULL, ldThresh = ldThresh, ldPop = ldPop, epi = epi, cons = cons, genetypes = genetypes,timeout=100000)
# file = NULL,
#url = "https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php",
#timeout = 10, encoding = "UTF-8", verbose = FALSE)

#results=data.frame(query)
nRsids= length(data)
df <- data.frame(matrix(ncol = 35, nrow = 0))
error=c()
for (i in 1:nRsids){
     result = tryCatch({
        query=queryHaploreg(query = data[i] , study = NULL, ldThresh = ldThresh, 
        ldPop = ldPop, epi = epi, cons = cons, genetypes = genetypes,timeout=100000)
     }, warning = function(w) {
       cat(" Warning \n")
       query= data.frame(matrix(ncol = 35, nrow = 0))
       return (query)
    }, error = function(e) {
      cat("error when trying this SNP: ", data[i], " \n") 
       query= data.frame(matrix(ncol = 35, nrow = 0))
        return (query)
   })
 if(dim(result)[1]>0){
 df=rbind(df, as.data.frame(result),stringsAsFactors=FALSE)
}else{error=c(error,data[i])}
}

output=paste0(outdir,'/',"results_haploR.txt",sep="")

write.table(as.data.frame(df), row.names=FALSE, file= output, quote = TRUE, sep = "\t")

errors=paste0(outdir,'/',"Errors_haploR.txt",sep="")
df_errors <- data.frame(matrix(ncol = 0, nrow = length(errors))
if(dim(df_errors)[1]>0){
 df_errors=cbind(df_errors, errors,stringsAsFactors=FALSE)
 }
 
write.table(as.data.frame(df_errors), row.names=FALSE, file= errors, quote = TRUE, sep = "\t")

