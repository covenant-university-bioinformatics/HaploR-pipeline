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

   alt_allele =  data.frame(matrix(ncol = 2, nrow = 0))
   colnames(alt_allele)= c("alt_allele","alt_allele_freq")


   rsids = data.frame(matrix(ncol = 1, nrow = 0))

   chrom= data.frame(matrix(ncol = 1, nrow = 0))

   ref_allele =  data.frame(matrix(ncol = 2, nrow = 0))
   colnames(ref_allele)= c("ref_allele","ref_allele_freq")

   maf= data.frame(matrix(ncol = 1, nrow = 0))

   final_names= c("start", "end",
   "alt_allele","alt_allele_freq",
   "rsid",
   "chrom",
   "ref_allele","ref_allele_freq",
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

      ##"alt_allele_freq
      alt_vector=c()
      alt=names(df_nearby_snps["alt_allele_freq"][j,][[1]])
      if(length(alt)>=1){
        alt_collapse=paste(alt, collapse=";")
        }else{
            alt_collapse=paste("NA", collapse=";");
      }
    
 
      alt_vector=c(alt_vector,as.character(alt_collapse))
      alt_freq=c()
      freq =df_nearby_snps["alt_allele_freq"][j,]
      if (length(alt)==0){
          f=paste0(freq[[1]],":",'NA')
          alt_freq=c(alt_freq, f)
          alt_freq=paste0(alt_freq, collapse=";")
          alt_vector=c(alt_vector,as.character(alt_freq))
      }else{
         for(k in 1:length(alt)){
            alt_query=alt[k];
            n_f= names(freq[[1]][[alt_query]])
            for(kk in 1:length(n_f)){
               n_f_query=n_f[kk]
               f1=unname(freq[[1]][[alt_query]][n_f_query])
               f=paste0(n_f_query,'(',alt_query,')',":",f1)
               alt_freq=c(alt_freq, f)
               alt_freq=paste0(alt_freq, collapse=";")
                }
                 
         }#for
        alt_vector=c(alt_vector,as.character(alt_freq))
        
      }#else
      unname(alt_vector)
      alt_allele=rbind(alt_allele,alt_vector,stringsAsFactors=FALSE)
      colnames(alt_allele)= c("alt_allele","alt_allele_freq")
      
    #ref_allele_freq
      ref_vector=c()
      ref=names(df_nearby_snps["ref_allele_freq"][j,][[1]])
      if(length(ref)>=1){
        ref_collapse=paste(ref, collapse=";")
        }else{
            ref_collapse=paste("NA", collapse=";");
      }


      ref_vector=c(ref_vector,as.character(ref_collapse))
      ref_freq=c()
      freq_ref =df_nearby_snps["ref_allele_freq"][j,]
      if (length(ref)==0){
          f=paste0(freq_ref[[1]],":",'NA')
          ref_freq=c(ref_freq, f)
          ref_freq=paste0(ref_freq, collapse=";")
          ref_vector=c(ref_vector,as.character(ref_freq))
    
          }else{
           for(k in 1:length(ref)){
               ref_query=ref[k];
               n_f= names(freq_ref[[1]][[ref_query]])
            for(kk in 1:length(n_f)){
               n_f_query=n_f[kk]
               f1=unname(freq_ref[[1]][[ref_query]][n_f_query])
               f=paste0(n_f_query,'(',ref_query,')',":",f1)
               ref_freq=c(ref_freq, f)
               ref_freq=paste0(ref_freq, collapse=";")
                }
                
           
         }#for
       ref_vector=c(ref_vector,as.character(ref_freq)) #--->
       #cat (ref_vector,"\n")
      }#else
      unname(ref_vector)
      ref_allele=rbind(ref_allele,ref_vector,stringsAsFactors=FALSE)
      colnames(ref_allele)= c("ref_allele","ref_allele_freq")
   
   
   
    #"rsid"
    rsid=as.character(df_nearby_snps[["rsid"]][j][[1]])
    rsids=rbind(rsids, rsid,stringsAsFactors=FALSE)
    colnames(rsids)="rsids"

    #"chrom"
    chr=as.character(df_nearby_snps[["chrom"]][j][[1]])
    chrom=rbind(chrom, chr,stringsAsFactors=FALSE)
    colnames(chrom)="chrom"


   #"maf"
   maf_=as.character(df_nearby_snps[["maf"]][j][[1]])
   maf=rbind(maf, maf_,stringsAsFactors=FALSE)
   colnames(maf)="maf"

  }

  final_data=cbind(coordinates,alt_allele,rsids,chrom,ref_allele,maf,stringsAsFactors=FALSE )
  colnames(final_data)=final_names
  #final_data=cbind(coordinates,maf,ref_allele,stringsAsFactors=FALSE )

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
