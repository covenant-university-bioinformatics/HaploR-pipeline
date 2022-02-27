#!/usr/bin/env bash
set -x;
#bindir is path in container
bindir="/app/pipeline_scripts"
type_of_analysis=$1 #{'HaploReg', "Regulome"}
outdir=$2
if [[ $type_of_analysis = "HaploReg" ]]; then
gwas_summary=$3
ldThresh=$4 #0.8
ldPop=$5    # {"AFR", "AMR", "ASN", "EUR"}
epi=$6  # {"vanilla", "imputed", "methyl"} ---> Default "vanilla"
cons=$7    # {"gerp",  "siphy","both"} ---> Default   "both"
genetypes=$8  #{'gencode', 'refseq'}

Rscript --vanilla ${bindir}/HaploReg.R $gwas_summary \
$outdir \
$ldThresh \
$ldPop \
$epi \
$cons \
$genetypes
#./haploR.sh HaploReg ourdir_HaploReg small_data.txt 0.8 AFR vanilla both gencode
elif [[ $type_of_analysis = "Regulome" ]]; then
  SNP=$2
  outdir=$3
  genomeAssembly=$4   # {GRCh37 , RCh38}

  Rscript --vanilla ${bindir}/Regulome.R $SNP  $outdir  $genomeAssembly
#./haploR.sh  Regulome rs1279474447 outdir_Regulome 37
fi







# [1] "chr"                         "pos_hg38"
# [3] "r2"                          "D'"
# [5] "is_query_snp"                "rsID"
# [7] "ref"                         "alt"
# [9] "AFR"                         "AMR"
# [11] "ASN"                         "EUR"
# [13] "GERP_cons" X                   "SiPhy_cons" X
# [15] "Chromatin_States"            "Chromatin_States_Imputed"
# [17] "Chromatin_Marks"             "DNAse"
# [19] "Proteins"                    "eQTL"
# [21] "gwas"                        "grasp"
# [23] "Motifs"                      "GENCODE_id"
# [25] "GENCODE_name"                "GENCODE_direction"
# [27] "GENCODE_distance"            "RefSeq_id"
# [29] "RefSeq_name"                 "RefSeq_direction"
# [31] "RefSeq_distance"             "dbSNP_functional_annotation"
# [33] "query_snp_rsid"              "Promoter_histone_marks"
# [35] "Enhancer_histone_marks"
