# simplify TCGA data download workflow
##------------------------------------
# Typical Cohorts Structure

# Given GBM as an example: <https://xenabrowser.net/datapages/?cohort=TCGA%20Glioblastoma%20(GBM)>
# Cohorts
#       Copy Number
#           gistic2
#           gistic2 thresholded
#       Copy Number Segments
#           After remove germline cnv
#           Before remove germline cnv
#       DNA Methylation
#           Methylation27k
#           Methylation450k
#       Exon Expression RNAseq
#           IlluminaHiSeq
#       Gene Expression Array
#           AffyU133a (always change)
#       Gene Expression RNAseq
#           IlluminaHiSeq
#           IlluminaHiSeq pancan normalized
#           IlluminaHiSeq percentile
#       miRNA Mature Strand Expression RNAseq
#           IlluminaHiseq
#       PARADIGM Pathway Activity
#           expression
#           expression (array) + CNV
#           expression + CNV
#           exprssion (array)
#       Phenotype
#           Phenotypes
#       Protein Expression RPPA
#           RPPA
#           RPPA (replicate-base normalization)
#       Somatic Mutation (SNPs and small INDELs)
#           broad
#           ucsc automated
#       Somatic non-silent mutation (gene-level)
#           broad
#           PANCAN AWG
#           ucsc automated
#       Transcription factor regulatory impact
#           Agilent, by RABIT
#           HiSeqV2, by RABIT
#           U133A, by RABIT

##' @title Easily Download TCGA Data by Several Options
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param project
##' @param data_category
##' @param data_type
##' @param file_type
##' @import dplyr
##' @export
tcgaEasyQuery = function(project=NULL, data_category = NULL, data_type = NULL, file_type = NULL){
    tcga = UCSCXenaTools::XenaData %>% filter(XenaHostNames == "TCGA")


}

tcgaEasyDownload = function(){

}

##' @title TCGA Available Data Projects and Data Categories
##' @description The function show available TCGA projects, data categories.
##' This include basic data struction provided by TCGA data on Xena.
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param which default is 'all', should be one of \code{c("all", "project", "data category",)}.
tcgaAvailData = function(which = c("all", "project", "data category")){
    which = match.arg(which)
    tcga = UCSCXenaTools::XenaData %>% filter(XenaHostNames == "TCGA")
    projects = unique(tcga$XenaCohorts)
    data_categories = c("Gene Level Copy Number", "Copy Number Segments", "DNA Methylation",
                        "Exon Expression RNAseq", "Gene Expression Array", "Gene Expression RNAseq",
                        "miRNA Mature Strand Expression RNAseq", "PARADIGM Pathway Activity",
                        "Phenotype", "Protein Expression RPPA", "Somatic Mutation",
                        "Gene Somatic Non-silent Mutation", "Transcription Factor Regulatory Impact")

    if(which == "all"){
        res = list()
        res$projects = projects
        res$data_categories = data_categories
        message("There are ", length(projects), " projects in TCGA on Xena,")
        message("  which include ", length(data_categories), " categories of data")
        res
    }else if(which == "project"){
        projects
    }else if(which == "data category"){
        data_categories
    }else{
        message("Find nothing, aborting...")
    }
}


.decodeDataType = function(XenaData = UCSCXenaTools::XenaData, Target = "TCGA"){
    ob = XenaData %>%  filter(XenaHostNames == Target)

    if(Target == "TCGA"){
        ob %>%
            mutate(DataType = case_when(
                grepl("Gistic2_CopyNumber_Gistic2_all_data_by_genes", XenaDatasets) ~ "Gene Level Copy Number",
                grepl("SNP6_genomicSegment", XenaDatasets) ~ "Copy Number Segments",
                grepl("HumanMethylation", XenaDatasets) ~ "DNA Methylation",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "Exon Expression RNAseq",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "Gene Expression Array",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "Gene Expression RNAseq",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "miRNA Mature Strand Expression RNAseq",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "Phenotype",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "Protein Expression RPPA",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "Somatic Mutation",
                grepl("HiSeqV2_exon", XenaDatasets) ~ "Gene Somatic Non-silent Mutation",
                grepl("RABIT", XenaDatasets) ~ "Transcription Factor Regulatory Impact"
            ))
    }
}
