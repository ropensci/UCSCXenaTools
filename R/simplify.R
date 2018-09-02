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
##' @param data_type
##' @param file_type
##' @import dplyr
##' @export
tcgaEasyQuery = function(project=NULL, data_type = NULL, file_type = NULL){
    tcga = UCSCXenaTools::XenaData %>% filter(XenaHostNames == "TCGA")


}

tcgaEasyDownload = function(){

}

# tcgaAvailData = function(which = c("all", "project", "data category")){
#     which = match.arg(which)
#     tcga = UCSCXenaTools::XenaData %>% filter(XenaHostNames == "TCGA")
#     projects = unique(tcga$XenaCohorts)
#     data_categories = c("Gene Level Copy Number", "Copy Number Segments", "DNA Methylation",
#                         "Exon Expression RNAseq", "Gene Expression Array", "Gene Expression RNAseq",
#                         "miRNA Mature Strand Expression RNAseq", "PARADIGM Pathway Activity",
#                         "Phenotype", "Protein Expression RPPA", "Somatic Mutation",
#                         "Gene Somatic Non-silent Mutation", "Transcription Factor Regulatory Impact")
#
#     if(which == "all"){
#         res = list()
#         res$projects = projects
#         res$data_categories = data_categories
#         message("There are ", length(projects), " projects in TCGA on Xena,")
#         message("  which include ", length(data_categories), " categories of data")
#         res
#     }else if(which == "project"){
#         projects
#     }else if(which == "data category"){
#         data_categories
#     }else{
#         message("Find nothing, aborting...")
#     }
# }


.decodeDataType = function(XenaData = UCSCXenaTools::XenaData, Target = c("TCGA", "UCSC_Public", "GDC", "ICGC", "Toil", "Treehouse")){
    # This TCGA include TCGA PANCAN dataset
    if("TCGA" %in% Target){
        Target = c(Target, "PanCancer")
    }

    ob = XenaData %>%  filter(XenaHostNames %in% Target)

    if("TCGA" %in% Target){
        # decode DataType
        ob %>%
            mutate(DataType = case_when(
                grepl("Gistic2_CopyNumber_Gistic2", XenaDatasets) ~ "Gene Level Copy Number",
                grepl("PANCAN_Genome_Wide_SNP_6_whitelisted.gene.xena", XenaDatasets) ~ "Gene Level Copy Number", # pancan
                grepl("SNP6", XenaDatasets) ~ "Copy Number Segments",
                grepl("PANCAN_Genome_Wide_SNP_6_whitelisted.xena", XenaDatasets) ~ "Copy Number Segments", # pancan
                grepl("HumanMethylation", XenaDatasets) ~ "DNA Methylation",
                grepl("MethylMix", XenaDatasets) ~ "DNA Methylation",
                grepl("HiSeq.*_exon", XenaDatasets) ~ "Exon Expression RNAseq",
                grepl("GA_exon", XenaDatasets) ~ "Exon Expression RNAseq",
                grepl("GAV2_exon", XenaDatasets) ~ "Exon Expression RNAseq",
                grepl("AgilentG", XenaDatasets) ~ "Gene Expression Array",
                grepl("HT_HG-U133A", XenaDatasets) ~ "Gene Expression Array",
                grepl("GA$", XenaDatasets) ~ "Gene Expression RNAseq",
                grepl("GAV2$", XenaDatasets) ~ "Gene Expression RNAseq",
                grepl("HiSeq$", XenaDatasets) & ! grepl("RABIT", XenaDatasets) ~ "Gene Expression RNAseq",
                grepl("HiSeqV2$", XenaDatasets) ~ "Gene Expression RNAseq",
                grepl("HiSeqV2_PANCAN$", XenaDatasets) ~ "Gene Expression RNAseq",
                grepl("HiSeqV2_percentile$", XenaDatasets) ~ "Gene Expression RNAseq",
                grepl("EB\\+\\+AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena", XenaDatasets) ~ "Gene Expression RNAseq", # pancan
                grepl("miRNA", XenaDatasets) ~ "miRNA Mature Strand Expression RNAseq",
                grepl("pancanMiRs_EBadjOnProtocolPlatformWithoutRepsWithUnCorrectMiRs", XenaDatasets) ~ "miRNA Mature Strand Expression RNAseq", # pancan
                grepl("Pathway_Paradigm", XenaDatasets) ~ "PARADIGM Pathway Activity",
                grepl("erge_merged_reals", XenaDatasets) ~ "PARADIGM Pathway Activity", # pancan
                grepl("clinicalMatrix", XenaDatasets) ~ "Phenotype",
                grepl("Survival_SupplementalTable_S1_20171025_xena_sp", XenaDatasets) ~ "Phenotype", # pancan
                grepl("Subtype_Immune_Model_Based.txt", XenaDatasets) ~ "Phenotype", # pancan
                grepl("TCGASubtype.20170308.tsv", XenaDatasets) ~ "Phenotype", # pancan
                grepl("TCGA_phenotype_denseDataOnlyDownload.tsv", XenaDatasets) ~ "Phenotype", # pancan
                grepl("gene_expression_subtype", XenaDatasets) ~ "Phenotype", # OV
                grepl("RPPA", XenaDatasets) ~ "Protein Expression RPPA",
                grepl("mutation_", XenaDatasets) & !endsWith(XenaDatasets, "gene") ~ "Somatic Mutation",
                grepl("mc3.v0.2.8.PUBLIC.xena", XenaDatasets) ~ "Somatic Mutation", # pancan
                grepl("mutation($|(.*_gene$))", XenaDatasets) ~ "Gene Somatic Non-silent Mutation",
                grepl("mc3.v0.2.8.PUBLIC.nonsilentGene.xena", XenaDatasets) ~ "Gene Somatic Non-silent Mutation", # pancan
                grepl("RABIT", XenaDatasets) ~ "Transcription Factor Regulatory Impact",
                grepl("iCluster", XenaDatasets) ~ "iCluster",
                grepl("Pancan12_GenePrograms_drugTargetCanon_in_Pancan33.tsv", XenaDatasets) ~ "Signatures", # pancan
                grepl("TCGA.HRD_withSampleID.txt", XenaDatasets) ~ "Signatures", # pancan
                grepl("TCGA_pancancer_10852whitelistsamples_68ImmuneSigs.xena", XenaDatasets) ~ "Signatures", # pancan
                grepl("StemnessScores_DNAmeth_20170210.tsv", XenaDatasets) ~ "Signatures", # pancan
                grepl("StemnessScores_RNAexp_20170127.2.tsv", XenaDatasets) ~ "Signatures" # pancan
            )) -> ob

        # decode file type
        ob %>%
            mutate(FileType = case_when(
                DataType == "Gene Level Copy Number" & grepl("Gistic2_all_data_by_genes", XenaDatasets) ~ "Gistic2",
                DataType == "Gene Level Copy Number" & grepl("Gistic2_all_thresholded.by_genes", XenaDatasets) ~ "Gistic2 thresholded",
                DataType == "Gene Level Copy Number" & grepl("PANCAN_Genome_Wide_SNP_6_whitelisted.gene.xena", XenaDatasets) ~ "Tumor copy number",


                DataType == "Copy Number Segments" & grepl("SNP6_genomicSegment", XenaDatasets) ~ "Before remove germline cnv",
                DataType == "Copy Number Segments" & grepl("SNP6_nocnv_genomicSegment", XenaDatasets) ~ "After remove germline cnv",
                DataType == "Copy Number Segments" & grepl("PANCAN_Genome_Wide_SNP_6_whitelisted.xena", XenaDatasets) ~ "After remove germline cnv",


                DataType == "DNA Methylation" & grepl("HumanMethylation27", XenaDatasets) ~ "Methylation27K",
                DataType == "DNA Methylation" & grepl("HumanMethylation450", XenaDatasets) ~ "Methylation450K",
                DataType == "DNA Methylation" & grepl("oneoff_TCGA_LGG_MethylMix", XenaDatasets) ~ "MethylMix",


                DataType == "Exon Expression RNAseq" & grepl("GA_exon", XenaDatasets) ~ "IlluminaGA RNASeq",
                DataType == "Exon Expression RNAseq" & grepl("GAV2_exon", XenaDatasets) ~ "IlluminaGA RNASeqV2",
                DataType == "Exon Expression RNAseq" & grepl("HiSeq_exon", XenaDatasets) ~ "IlluminaHiSeq RNASeq",
                DataType == "Exon Expression RNAseq" & grepl("HiSeqV2_exon", XenaDatasets) ~ "IlluminaHiSeq RNASeqV2",


                DataType == "Gene Expression Array" & grepl("AgilentG4502A", XenaDatasets) ~ "Agilent 244K Microarray",
                DataType == "Gene Expression Array" & grepl("HT_HG-U133A", XenaDatasets) ~ "Affymetrix U133A Microarray",

                DataType == "Gene Expression RNAseq" & endsWith(XenaDatasets, "GA") ~ "IlluminaGA RNASeq",
                DataType == "Gene Expression RNAseq" & endsWith(XenaDatasets, "GAV2") ~ "IlluminaGA RNASeqV2",
                DataType == "Gene Expression RNAseq" & endsWith(XenaDatasets, "HiSeq") ~ "IlluminaHiSeq RNASeq",
                DataType == "Gene Expression RNAseq" & endsWith(XenaDatasets, "HiSeqV2") ~ "IlluminaHiSeq RNASeqV2",
                DataType == "Gene Expression RNAseq" & endsWith(XenaDatasets, "HiSeqV2_PANCAN") ~ "IlluminaHiSeq RNASeqV2 pancan normalized",
                DataType == "Gene Expression RNAseq" & endsWith(XenaDatasets, "HiSeqV2_percentile") ~ "IlluminaHiSeq RNASeqV2 in percentile rank",


                DataType == "miRNA Mature Strand Expression RNAseq" & endsWith(XenaDatasets, "miRNA_GA_gene") ~ "IlluminaGA RNASeq",
                DataType == "miRNA Mature Strand Expression RNAseq" & endsWith(XenaDatasets, "miRNA_HiSeq_gene") ~ "IlluminaHiSeq RNASeq",
                DataType == "miRNA Mature Strand Expression RNAseq" & grepl("pancanMiRs_EBadjOnProtocolPlatformWithoutRepsWithU", XenaDatasets) ~ "Batch effects normalized",


                DataType == "PARADIGM Pathway Activity" & grepl("merge_merged_reals", XenaDatasets) ~ "Platform-corrected PANCAN12 dataset",
                DataType == "PARADIGM Pathway Activity" & endsWith(XenaDatasets, "Pathway_Paradigm_mRNA") ~ "Use only Microarray",
                DataType == "PARADIGM Pathway Activity" & endsWith(XenaDatasets, "Pathway_Paradigm_mRNA_And_Copy_Number") ~ "Use Microarray plus Copy Number",
                DataType == "PARADIGM Pathway Activity" & endsWith(XenaDatasets, "Pathway_Paradigm_RNASeq") ~ "Use only RNASeq",
                DataType == "PARADIGM Pathway Activity" & endsWith(XenaDatasets, "Pathway_Paradigm_RNASeq_And_Copy_Number") ~ "Use RNASeq plus Copy Number",


                DataType == "Phenotype" & endsWith(XenaDatasets, "clinicalMatrix") ~ "Clinical Information",
                DataType == "Phenotype" & grepl("Survival_SupplementalTable_S1_20171025_xena_sp", XenaDatasets) ~ "Clinical Information",
                DataType == "Phenotype" & grepl("gene_expression_subtype", XenaDatasets) ~ "Gene Expression Subtype",
                DataType == "Phenotype" & grepl("Subtype_Immune_Model_Based", XenaDatasets) ~ "Immune Model Based Subtype",
                DataType == "Phenotype" & grepl("TCGASubtype", XenaDatasets) ~ "TCGA Molecular Subtype",
                DataType == "Phenotype" & grepl("TCGA_phenotype_denseDataOnlyDownload", XenaDatasets) ~ "TCGA Sample Type and Primary Disease",

                DataType == "Protein Expression RPPA" & endsWith(XenaDatasets, "RPPA") ~ "RPPA",
                DataType == "Protein Expression RPPA" & endsWith(XenaDatasets, "RPPA") ~ "RPPA normalized by RBN",
                DataType == "Protein Expression RPPA" & grepl("TCGA-RPPA-pancan-clean", XenaDatasets) ~ "RPPA pancan normalized",


                DataType == "Somatic Mutation" & grepl("mc3.v0.2.8.PUBLIC.xena", XenaDatasets) ~ "MC3 Public Version",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_bcgsc") ~ "bcgsc automated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_bcm") ~ "bcm automated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_bcm_solid") ~ "bcm SOLiD",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_broad") ~ "broad automated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_curated_bcm") ~ "bcm curated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_curated_bcm_solid") ~ "bcm SOLiD curated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_curated_broad") ~ "broad curated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_curated_wustl") ~ "wustl curated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_ucsc_maf") ~ "ucsc automated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_wustl") ~ "wustl automated",
                DataType == "Somatic Mutation" & endsWith(XenaDatasets, "mutation_wustl_hiseq") ~ "wustl hiseq automated",


                DataType == "Gene Somatic Non-silent Mutation" & endsWith(XenaDatasets, "mutation") ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Gene Somatic Non-silent Mutation" & grepl("iCluster", XenaDatasets) ~ NA,


                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Transcription Factor Regulatory Impact" & grepl("iCluster", XenaDatasets) ~ NA,


                DataType == "iCluster" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "iCluster" & grepl("iCluster", XenaDatasets) ~ NA,


                DataType == "Signatures" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Signatures" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Signatures" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Signatures" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Signatures" & grepl("iCluster", XenaDatasets) ~ NA,
                DataType == "Signatures" & grepl("iCluster", XenaDatasets) ~ NA

            ))
    }
}

#
# ob1 = sub("TCGA.*/(.*)", "\\1", ob$XenaDatasets) %>% table() %>% names() -> uniqueDatasets
# ob1 = tibble(XenaDatasets = uniqueDatasets)
# grep("gene_expression_subtype", ob$XenaDatasets, value = TRUE)

# > dput(ob2)
ob2 = structure(list(XenaDatasets = c("ACC_clinicalMatrix", "AgilentG4502A_07_1",
                                "AgilentG4502A_07_2", "AgilentG4502A_07_3", "BLCA_clinicalMatrix",
                                "BRCA_clinicalMatrix", "broad.mit.edu_PANCAN_Genome_Wide_SNP_6_whitelisted.gene.xena",
                                "broad.mit.edu_PANCAN_Genome_Wide_SNP_6_whitelisted.xena", "CESC_clinicalMatrix",
                                "CHOL_clinicalMatrix", "COAD_clinicalMatrix", "COADREAD_clinicalMatrix",
                                "DLBC_clinicalMatrix", "EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena",
                                "ESCA_clinicalMatrix", "FPPP_clinicalMatrix", "GA", "GA_exon",
                                "GAV2", "GAV2_exon", "GBM_clinicalMatrix", "GBMLGG_clinicalMatrix",
                                "Gistic2_CopyNumber_Gistic2_all_data_by_genes", "Gistic2_CopyNumber_Gistic2_all_thresholded.by_genes",
                                "HiSeq", "HiSeq_exon", "HiSeqV2", "HiSeqV2_exon", "HiSeqV2_PANCAN",
                                "HiSeqV2_percentile", "HNSC_clinicalMatrix", "HT_HG-U133A", "HumanMethylation27",
                                "HumanMethylation450", "jhu-usc.edu_PANCAN_HumanMethylation450.betaValue_whitelisted.tsv.synapse_download_5096262.xena",
                                "KICH_clinicalMatrix", "KIRC_clinicalMatrix", "KIRP_clinicalMatrix",
                                "LAML_clinicalMatrix", "lat.vars.iCluster.redo.tumor", "LGG_clinicalMatrix",
                                "LIHC_clinicalMatrix", "LUAD_clinicalMatrix", "LUNG_clinicalMatrix",
                                "LUSC_clinicalMatrix", "mc3.v0.2.8.PUBLIC.nonsilentGene.xena",
                                "mc3.v0.2.8.PUBLIC.xena", "merge_merged_reals", "MESO_clinicalMatrix",
                                "miRNA_GA_gene", "miRNA_HiSeq_gene", "mutation", "mutation_bcgsc",
                                "mutation_bcgsc_gene", "mutation_bcm", "mutation_bcm_gene", "mutation_bcm_solid",
                                "mutation_bcm_solid_gene", "mutation_broad", "mutation_broad_gene",
                                "mutation_curated_bcm", "mutation_curated_bcm_gene", "mutation_curated_bcm_solid",
                                "mutation_curated_bcm_solid_gene", "mutation_curated_broad",
                                "mutation_curated_broad_gene", "mutation_curated_wustl", "mutation_curated_wustl_gene",
                                "mutation_ucsc_maf", "mutation_ucsc_maf_gene", "mutation_wustl",
                                "mutation_wustl_gene", "mutation_wustl_hiseq", "mutation_wustl_hiseq_gene",
                                "oneoff_TCGA_LGG_MethylMix", "OV_clinicalMatrix", "PAAD_clinicalMatrix",
                                "Pancan12_GenePrograms_drugTargetCanon_in_Pancan33.tsv", "pancanMiRs_EBadjOnProtocolPlatformWithoutRepsWithUnCorrectMiRs_08_04_16.xena",
                                "Pathway_Paradigm_mRNA", "Pathway_Paradigm_mRNA_And_Copy_Number",
                                "Pathway_Paradigm_RNASeq", "Pathway_Paradigm_RNASeq_And_Copy_Number",
                                "PCPG_clinicalMatrix", "PRAD_clinicalMatrix", "RABIT/pancan/RABIT_pancan.HiSeq",
                                "RABIT/pancan/RABIT_pancan.HiSeq.V2", "RABIT/separate_processed/RABIT_BLCA.HiSeq",
                                "RABIT/separate_processed/RABIT_BLCA.HiSeq.V2", "RABIT/separate_processed/RABIT_BRCA.Agilent",
                                "RABIT/separate_processed/RABIT_BRCA.HiSeq", "RABIT/separate_processed/RABIT_BRCA.HiSeq.V2",
                                "RABIT/separate_processed/RABIT_CESC.HiSeq.V2", "RABIT/separate_processed/RABIT_COAD.Agilent",
                                "RABIT/separate_processed/RABIT_COAD.HiSeq.V2", "RABIT/separate_processed/RABIT_GBM.Agilent",
                                "RABIT/separate_processed/RABIT_GBM.HiSeq.V2", "RABIT/separate_processed/RABIT_GBM.U133A",
                                "RABIT/separate_processed/RABIT_HNSC.HiSeq", "RABIT/separate_processed/RABIT_HNSC.HiSeq.V2",
                                "RABIT/separate_processed/RABIT_KICH.HiSeq.V2", "RABIT/separate_processed/RABIT_KIRC.HiSeq",
                                "RABIT/separate_processed/RABIT_KIRC.HiSeq.V2", "RABIT/separate_processed/RABIT_KIRP.HiSeq.V2",
                                "RABIT/separate_processed/RABIT_LIHC.HiSeq", "RABIT/separate_processed/RABIT_LIHC.HiSeq.V2",
                                "RABIT/separate_processed/RABIT_LUAD.HiSeq", "RABIT/separate_processed/RABIT_LUAD.HiSeq.V2",
                                "RABIT/separate_processed/RABIT_LUSC.HiSeq", "RABIT/separate_processed/RABIT_LUSC.HiSeq.V2",
                                "RABIT/separate_processed/RABIT_OV.Agilent", "RABIT/separate_processed/RABIT_OV.U133A",
                                "RABIT/separate_processed/RABIT_PRAD.HiSeq.V2", "RABIT/separate_processed/RABIT_READ.Agilent",
                                "RABIT/separate_processed/RABIT_READ.HiSeq.V2", "RABIT/separate_processed/RABIT_STAD.HiSeq",
                                "RABIT/separate_processed/RABIT_THCA.HiSeq.V2", "RABIT/separate_processed/RABIT_UCEC.GA",
                                "RABIT/separate_processed/RABIT_UCEC.GA.V2", "RABIT/separate_processed/RABIT_UCEC.HiSeq.V2",
                                "READ_clinicalMatrix", "RPPA", "RPPA_RBN", "SARC_clinicalMatrix",
                                "SKCM_clinicalMatrix", "SNP6_genomicSegment", "SNP6_nocnv_genomicSegment",
                                "STAD_clinicalMatrix", "StemnessScores_DNAmeth_20170210.tsv",
                                "StemnessScores_RNAexp_20170127.2.tsv", "Subtype_Immune_Model_Based.txt",
                                "Survival_SupplementalTable_S1_20171025_xena_sp", "TCGA_OV_gene_expression_subtype",
                                "TCGA_PanCan33_iCluster_k28_tumor", "TCGA_pancancer_10852whitelistsamples_68ImmuneSigs.xena",
                                "TCGA_phenotype_denseDataOnlyDownload.tsv", "TCGA-RPPA-pancan-clean.xena",
                                "TCGA.HRD_withSampleID.txt", "TCGASubtype.20170308.tsv", "TGCT_clinicalMatrix",
                                "THCA_clinicalMatrix", "THYM_clinicalMatrix", "UCEC_clinicalMatrix",
                                "UCS_clinicalMatrix", "UVM_clinicalMatrix"), DataType = c("Phenotype",
                                                                                          "Gene Expression Array", "Gene Expression Array", "Gene Expression Array",
                                                                                          "Phenotype", "Phenotype", "Gene Level Copy Number", "Copy Number Segments",
                                                                                          "Phenotype", "Phenotype", "Phenotype", "Phenotype", "Phenotype",
                                                                                          "Gene Expression RNAseq", "Phenotype", "Phenotype", "Gene Expression RNAseq",
                                                                                          "Exon Expression RNAseq", "Gene Expression RNAseq", "Exon Expression RNAseq",
                                                                                          "Phenotype", "Phenotype", "Gene Level Copy Number", "Gene Level Copy Number",
                                                                                          "Gene Expression RNAseq", "Exon Expression RNAseq", "Gene Expression RNAseq",
                                                                                          "Exon Expression RNAseq", "Gene Expression RNAseq", "Gene Expression RNAseq",
                                                                                          "Phenotype", "Gene Expression Array", "DNA Methylation", "DNA Methylation",
                                                                                          "DNA Methylation", "Phenotype", "Phenotype", "Phenotype", "Phenotype",
                                                                                          "iCluster", "Phenotype", "Phenotype", "Phenotype", "Phenotype",
                                                                                          "Phenotype", "Gene Somatic Non-silent Mutation", "Somatic Mutation",
                                                                                          "PARADIGM Pathway Activity", "Phenotype", "miRNA Mature Strand Expression RNAseq",
                                                                                          "miRNA Mature Strand Expression RNAseq", "Gene Somatic Non-silent Mutation",
                                                                                          "Somatic Mutation", "Gene Somatic Non-silent Mutation", "Somatic Mutation",
                                                                                          "Gene Somatic Non-silent Mutation", "Somatic Mutation", "Gene Somatic Non-silent Mutation",
                                                                                          "Somatic Mutation", "Gene Somatic Non-silent Mutation", "Somatic Mutation",
                                                                                          "Gene Somatic Non-silent Mutation", "Somatic Mutation", "Gene Somatic Non-silent Mutation",
                                                                                          "Somatic Mutation", "Gene Somatic Non-silent Mutation", "Somatic Mutation",
                                                                                          "Gene Somatic Non-silent Mutation", "Somatic Mutation", "Gene Somatic Non-silent Mutation",
                                                                                          "Somatic Mutation", "Gene Somatic Non-silent Mutation", "Somatic Mutation",
                                                                                          "Gene Somatic Non-silent Mutation", "DNA Methylation", "Phenotype",
                                                                                          "Phenotype", "Signatures", "miRNA Mature Strand Expression RNAseq",
                                                                                          "PARADIGM Pathway Activity", "PARADIGM Pathway Activity", "PARADIGM Pathway Activity",
                                                                                          "PARADIGM Pathway Activity", "Phenotype", "Phenotype", "Gene Expression RNAseq",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression RNAseq",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression Array",
                                                                                          "Gene Expression RNAseq", "Transcription Factor Regulatory Impact",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression Array",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression Array",
                                                                                          "Transcription Factor Regulatory Impact", "Transcription Factor Regulatory Impact",
                                                                                          "Gene Expression RNAseq", "Transcription Factor Regulatory Impact",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression RNAseq",
                                                                                          "Transcription Factor Regulatory Impact", "Transcription Factor Regulatory Impact",
                                                                                          "Gene Expression RNAseq", "Transcription Factor Regulatory Impact",
                                                                                          "Gene Expression RNAseq", "Transcription Factor Regulatory Impact",
                                                                                          "Gene Expression RNAseq", "Transcription Factor Regulatory Impact",
                                                                                          "Gene Expression Array", "Transcription Factor Regulatory Impact",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression Array",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression RNAseq",
                                                                                          "Transcription Factor Regulatory Impact", "Gene Expression RNAseq",
                                                                                          "Transcription Factor Regulatory Impact", "Transcription Factor Regulatory Impact",
                                                                                          "Phenotype", "Protein Expression RPPA", "Protein Expression RPPA",
                                                                                          "Phenotype", "Phenotype", "Copy Number Segments", "Copy Number Segments",
                                                                                          "Phenotype", "Signatures", "Signatures", "Phenotype", "Phenotype",
                                                                                          "Phenotype", "iCluster", "Signatures", "Phenotype", "Protein Expression RPPA",
                                                                                          "Signatures", "Phenotype", "Phenotype", "Phenotype", "Phenotype",
                                                                                          "Phenotype", "Phenotype", "Phenotype")), class = c("tbl_df",
                                                                                                                                             "tbl", "data.frame"), row.names = c(NA, -145L))
