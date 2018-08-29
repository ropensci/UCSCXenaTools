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

tcgaEasyQuery = function(){

}

tcgaEasyDownload = function(){

}
