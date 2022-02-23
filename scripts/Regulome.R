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

is_error=function(x){
   query= queryRegulome(query = x,  genomeAssembly = genomeAssembly,timeout=100000)
   if(length(query)==0){
     stop("error in querying this SNPs")
   }

 return(query)
}


 result = tryCatch({
       is_error(data)
        #query= queryRegulome(query = data,  genomeAssembly = genomeAssembly,timeout=100000)
     }, warning = function(w) {
       cat(" Warning \n")
       #query= data.frame(matrix(ncol = 35, nrow = 0))
       return (0)
    }, error = function(e) {
      cat("error when trying this SNP: ", data, " \n")
       #query= data.frame(matrix(ncol = 0, nrow = 0))
      return (0)
   })

if(is.list(result)){
   coordinates <- data.frame(matrix(ncol = 2, nrow = 0))
   colnames(coordinates)=c("lt","gte")


   alt_allele_freq= c("TOPMED", "1000Genomes", "ALSPAC", "GnomAD", "TWINSUK")
   alt_allele =  data.frame(matrix(ncol = 6, nrow = 0))
   colnames(alt_allele)= c("alt_allele",alt_allele_freq)


   rsids = data.frame(matrix(ncol = 1, nrow = 0))

   chrom= data.frame(matrix(ncol = 1, nrow = 0))

   ref_allele_freq= c("TOPMED", "1000Genomes", "ALSPAC", "GnomAD", "TWINSUK")
   ref_allele =  data.frame(matrix(ncol = 6, nrow = 0))
   colnames(ref_allele)= c("ref_allele",ref_allele_freq)

   maf= data.frame(matrix(ncol = 1, nrow = 0))

   final_names= c("start", "end",
   "alt_allele","alt_allele_TOPMED", "alt_allele_1000Genomes", "alt_allele_ALSPAC", "alt_allele_GnomAD", "alt_allele_TWINSUK",
   "rsid",
   "chrom",
   "ref_allele","ref_allele_TOPMED", "ref_allele_1000Genomes", "ref_allele_ALSPAC", "ref_allele_GnomAD", "ref_allele_TWINSUK",
   "maf"
   )


   nearby_snps=result[[data]]['nearby_snps']
   df_nearby_snps=nearby_snps$nearby_snps
   n=names(df_nearby_snps)


   iter=dim(df_nearby_snps)[1]
   for (j in 2:iter){
     #cat("j is :", j,"\n")
      #"coordinates"
      coor=df_nearby_snps["coordinates"][j,]
      coordinates=rbind(coordinates,coor[[1]],stringsAsFactors=FALSE)

      #"alt_allele_freq
      alt_vector=c()
      alt=names(df_nearby_snps["alt_allele_freq"][j,][[1]])
      #cat("\n")
      alt_vector=c(alt_vector,as.character(alt))
      freq =df_nearby_snps["alt_allele_freq"][j,]
      for (jj in 1:length(alt_allele_freq)){
           freq_=freq[[1]][[alt]][alt_allele_freq[jj]]
           #cat(alt, "-->", freq_ ,"...")
           alt_vector=c(alt_vector,as.character(freq_))
           unname(alt_vector)
           #cat(alt_vector,"\n")
      }
     unname(alt_vector)
     alt_allele=rbind(alt_allele,alt_vector,stringsAsFactors=FALSE)
     colnames(alt_allele)= c("alt_allele",alt_allele_freq)

    #"rsid"
    rsid=as.character(df_nearby_snps[["rsid"]][j][[1]])
    rsids=rbind(rsids, rsid,stringsAsFactors=FALSE)
    colnames(rsids)="rsids"

    #"chrom"
    chr=as.character(df_nearby_snps[["chrom"]][j][[1]])
    chrom=rbind(chrom, chr,stringsAsFactors=FALSE)
    colnames(chrom)="chrom"

    #"ref_allele_freq
    ref_vector=c()
    ref=names(df_nearby_snps["ref_allele_freq"][j,][[1]])
    ref_vector=c(ref_vector,as.character(ref))
    freq_ref =df_nearby_snps["ref_allele_freq"][j,]
    for (jj in 1:length(ref_allele_freq)){
       freq_ref_=freq_ref[[1]][[ref]][ref_allele_freq[jj]]
       ref_vector=c(ref_vector,as.character(freq_ref_))
       unname(ref_vector)
      }
    unname(ref_vector)
    ref_allele=rbind(ref_allele,ref_vector,stringsAsFactors=FALSE)
    colnames(ref_allele)= c("ref_allele",ref_allele_freq)


   #"maf"
   maf_=as.character(df_nearby_snps[["maf"]][j][[1]])
   maf=rbind(maf, maf_,stringsAsFactors=FALSE)
   colnames(maf)="maf"

  }

  final_data=cbind(coordinates,alt_allele,rsids,chrom,ref_allele,maf,stringsAsFactors=FALSE )
  colnames(final_data)=final_names


   output1=paste0(outdir,'/',"results_Regulome.txt",sep="")
   output2=paste0(outdir,'/',"results_Regulome_nearby_snps.txt",sep="")
   out=c("guery_coordinates","features","regulome_score","assembly")
   df=data.frame(nrow=1)
   for ( i in 1:length(out)){
      df=cbind(df, as.data.frame(result[[data]][out[i]]),stringsAsFactors=FALSE )
   }

   write.table(df[,2:dim(df)[2]], row.names=FALSE, file= output1, quote = TRUE, sep = "\t")
   write.table(as.data.frame(final_data), row.names=FALSE, file= output2, quote = TRUE, sep = "\t")
}else{
df=data.frame(error=data)
output1=paste0(outdir,'/',"results_Regulome.txt",sep="")
output2=paste0(outdir,'/',"results_Regulome_nearby_snps.txt",sep="")
write.table(df, row.names=FALSE, file= output1, quote = TRUE, sep = "\t")
write.table(df, row.names=FALSE, file= output2, quote = TRUE, sep = "\t")
}
