# simplify TCGA data download workflow
## ------------------------------------
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
#       Exon Expression RNASeq
#           IlluminaHiSeq
#       Gene Expression Array
#           AffyU133a (always change)
#       Gene Expression RNASeq
#           IlluminaHiSeq
#           IlluminaHiSeq pancan normalized
#           IlluminaHiSeq percentile
#       miRNA Mature Strand Expression RNASeq
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

# compiler::setCompilerOptions(suppressAll = TRUE)
# suppress Binding Notes
# suppressBindingNotes <- function(variablesMentionedInNotes) {
#     for(variable in variablesMentionedInNotes) {
#         assign(variable, NULL, envir = .GlobalEnv)
#     }
# }

# suppressBindingNotes(c("XenaHostNames","XenaCohorts", "ProjectID", "DataType", "FileType"))


##' @title Get TCGA Common Data Sets by Project ID and Property
##' @description This is the most useful function for user to download common
##' TCGA datasets, it is similar to `getFirehoseData` function in `RTCGAToolbox`
##'  package.
##' @details TCGA Common Data Sets are frequently used for biological analysis.
##' To make easier to achieve these data, this function provide really easy
##' options to choose datasets and behavior. All availble information about
##' datasets of TCGA can access vis `availTCGA()` and check with `showTCGA()`.
##' @author Shixiang Wang <w_shixiang@163.com>
##' @inheritParams downloadTCGA
##' @param clinical logical. if `TRUE`, download clinical information. Default is `TRUE`.
##' @param download logical. if `TRUE`, download data, otherwise return a result list include data
##' information. Default is `FALSE`. You can set this to `FALSE` if you want to check what you will download or
##' use other function provided by `UCSCXenaTools` to filter result datasets you want to download.
##' @param forceDownload logical. if `TRUE`, force to download files no matter if exist. Default is `FALSE`.
##' @param mRNASeq logical. if `TRUE`, download mRNASeq data. Default is `FALSE`.
##' @param mRNAArray logical. if `TRUE`, download mRNA microarray data. Default is `FALSE`.
##' @param mRNASeqType character vector. Can be one, two or three
##' in `c("normalized", "pancan normalized", "percentile")`.
##' @param miRNASeq logical. if `TRUE`, download miRNASeq data. Default is `FALSE`.
##' @param exonRNASeq logical. if `TRUE`, download exon RNASeq data. Default is `FALSE`.
##' @param RPPAArray logical. if `TRUE`, download RPPA data. Default is `FALSE`.
##' @param ReplicateBaseNormalization logical. if `TRUE`, download RPPA data by Replicate Base
##' Normalization (RBN). Default is `FALSE`.
##' @param Methylation logical. if `TRUE`, download DNA Methylation data. Default is `FALSE`.
##' @param MethylationType character vector. Can be one or two in `c("27K", "450K")`.
##' @param GeneMutation logical. if `TRUE`, download gene mutation data. Default is `FALSE`.
##' @param SomaticMutation logical. if `TRUE`, download somatic mutation data. Default is `FALSE`.
##' @param GisticCopyNumber logical. if `TRUE`, download Gistic2 Copy Number data. Default is `FALSE`.
##' @param Gistic2Threshold logical. if `TRUE`, download Threshold Gistic2 data. Default is `TRUE`.
##' @param CopyNumberSegment logical. if `TRUE`, download Copy Number Segment data. Default is `FALSE`.
##' @param RemoveGermlineCNV logical. if `TRUE`, download Copy Number Segment data which has removed
##' germline copy number variation. Default is `TRUE`.
##' @return if `download=TRUE`, return `data.frame` from `XenaDownload`,
##' otherwise return a list including `XenaHub` object and datasets information
##' @export
##' @examples
##' ###### get data, but not download
##'
##' # 1 choose project and data types you wanna download
##' getTCGAdata(project = "LUAD", mRNASeq = TRUE, mRNAArray = TRUE,
##' mRNASeqType = "normalized", miRNASeq = TRUE, exonRNASeq = TRUE,
##' RPPAArray = TRUE, Methylation = TRUE, MethylationType = "450K",
##' GeneMutation = TRUE, SomaticMutation = TRUE)
##'
##' # 2 only choose 'LUAD' and its clinical data
##' getTCGAdata(project = "LUAD")
##' \donttest{
##' ###### download datasets
##'
##' # 3 download clinical datasets of LUAD and LUSC
##' getTCGAdata(project = c("LUAD", "LUSC"), clinical = TRUE, download = TRUE)
##'
##' # 4 download clinical, RPPA and gene mutation datasets of LUAD and LUSC
##' # getTCGAdata(project = c("LUAD", "LUSC"), clinical = TRUE, RPPAArray = TRUE, GeneMutation = TRUE)
##' }
getTCGAdata <- function(project = NULL,
                        clinical = TRUE,
                        download = FALSE,
                        forceDownload = FALSE,
                        destdir = tempdir(),
                        mRNASeq = FALSE,
                        mRNAArray = FALSE,
                        mRNASeqType = "normalized",
                        miRNASeq = FALSE,
                        exonRNASeq = FALSE,
                        RPPAArray = FALSE,
                        ReplicateBaseNormalization = FALSE,
                        Methylation = FALSE,
                        MethylationType = c("27K", "450K"),
                        GeneMutation = FALSE,
                        SomaticMutation = FALSE,
                        GisticCopyNumber = FALSE,
                        Gistic2Threshold = TRUE,
                        CopyNumberSegment = FALSE,
                        RemoveGermlineCNV = TRUE,
                        ...) {
  #----- check data type of input
  stopifnot(!is.null(project))
  stopifnot(is.logical(
    c(
      clinical,
      mRNASeq,
      mRNAArray,
      miRNASeq,
      RPPAArray,
      ReplicateBaseNormalization,
      Methylation,
      GeneMutation,
      SomaticMutation,
      GisticCopyNumber,
      Gistic2Threshold,
      CopyNumberSegment,
      RemoveGermlineCNV,
      download,
      forceDownload
    )
  ))

  projects <- c(
    "LAML",
    "ACC",
    "CHOL",
    "BLCA",
    "BRCA",
    "CESC",
    "COADREAD",
    "COAD",
    "UCEC",
    "ESCA",
    "FPPP",
    "GBM",
    "HNSC",
    "KICH",
    "KIRC",
    "KIRP",
    "DLBC",
    "LIHC",
    "LGG",
    "GBMLGG",
    "LUAD",
    "LUNG",
    "LUSC",
    "SKCM",
    "MESO",
    "UVM",
    "OV",
    "PANCAN",
    "PAAD",
    "PCPG",
    "PRAD",
    "READ",
    "SARC",
    "STAD",
    "TGCT",
    "THYM",
    "THCA",
    "UCS"
  )

  if (!all(project %in% projects)) {
    message("Only following Project valid:")
    print(project[project %in% projects])
    stop("Invaild Input!")
  }

  tcga_all <- .decodeDataType(Target = "tcgaHub")

  # tcga_all %>%
  #     filter(ProjectID %in% project) %>% # select project
  #     filter()


  res <- subset(tcga_all, ProjectID %in% project)
  res %>%
    filter(
      DataType != "Transcription Factor Regulatory Impact",
      DataType != "Signatures",
      DataType != "PARADIGM Pathway Activity",
      DataType != "iCluster"
    ) -> res


  if (clinical) {
    quo_cli <- dplyr::quo((FileType == "Clinical Information"))
  } else {
    quo_cli <- dplyr::quo((FALSE))
  }

  if (mRNASeq) {
    if (!all(mRNASeqType %in% c("normalized", "pancan normalized", "percentile"))) {
      message("Available mRNASeqType values are:")
      print(c("normalized", "pancan normalized", "percentile"))
      stop("Not Vaild Input!")
    }

    RNA <- c(
      "IlluminaHiSeq RNASeqV2",
      "IlluminaHiSeq RNASeqV2 pancan normalized",
      "IlluminaHiSeq RNASeqV2 in percentile rank"
    )
    names(RNA) <- c("normalized", "pancan normalized", "percentile")
    RNA_select <- c(RNA[mRNASeqType], "Batch effects normalized")

    quo_RNA <- dplyr::quo((
      DataType == "Gene Expression RNASeq" & FileType %in% RNA_select
    ))
  } else {
    quo_RNA <- dplyr::quo((FALSE))
  }

  if (mRNAArray) {
    quo_RNAa <- dplyr::quo((DataType == "Gene Expression Array"))
  } else {
    quo_RNAa <- dplyr::quo((FALSE))
  }

  if (miRNASeq) {
    miRNA_select <- c("IlluminaHiSeq RNASeq", "Batch effects normalized")
    quo_miRNA <- dplyr::quo((
      DataType == "miRNA Mature Strand Expression RNASeq" &
        FileType %in% miRNA_select
    ))
  } else {
    quo_miRNA <- dplyr::quo((FALSE))
  }

  if (exonRNASeq) {
    quo_exon <- dplyr::quo((
      DataType == "Exon Expression RNASeq" &
        FileType == "IlluminaHiSeq RNASeqV2"
    ))
  } else {
    quo_exon <- dplyr::quo((FALSE))
  }
  # Have no miRNA Array? Need Check
  # if(miRNAArray){
  #
  # }
  if (RPPAArray) {
    if (ReplicateBaseNormalization) {
      RPPA_select <- "RPPA normalized by RBN"
    } else {
      RPPA_select <- "RPPA"
    }
    quo_RPPA <- dplyr::quo((
      DataType == "Protein Expression RPPA" &
        FileType %in% c(RPPA_select, "RPPA pancan normalized")
    ))
  } else {
    quo_RPPA <- dplyr::quo((FALSE))
  }

  if (Methylation) {
    if (!all(MethylationType %in% c("27K", "450K"))) {
      message("Available MethylationType values are:")
      print(c("27K", "450K"))
      stop("Not Vaild Input!")
    }

    Methy <- c("Methylation27K", "Methylation450K")
    names(Methy) <- c("27K", "450K")
    Methy_select <- Methy[MethylationType]

    quo_Methy <- dplyr::quo((
      DataType == "DNA Methylation" & FileType %in% Methy_select
    ))
  } else {
    quo_Methy <- dplyr::quo((FALSE))
  }

  if (GeneMutation) {
    quo_genMutation <- dplyr::quo((
      DataType == "Gene Somatic Non-silent Mutation" &
        FileType %in% c("broad automated", "MC3 Public Version")
    ))
  } else {
    quo_genMutation <- dplyr::quo((FALSE))
  }

  if (SomaticMutation) {
    quo_somaticMutation <- dplyr::quo((
      DataType == "Somatic Mutation" &
        FileType %in% c("broad automated", "MC3 Public Version")
    ))
  } else {
    quo_somaticMutation <- dplyr::quo((FALSE))
  }

  if (GisticCopyNumber) {
    if (Gistic2Threshold) {
      gistic_select <- "Gistic2 thresholded"
    } else {
      gistic_select <- "Gistic2"
    }
    quo_gistic <- dplyr::quo((
      DataType == "Gene Level Copy Number" & FileType == gistic_select
    ))
  } else {
    quo_gistic <- dplyr::quo((FALSE))
  }

  if (CopyNumberSegment) {
    if (RemoveGermlineCNV) {
      cns_select <- "After remove germline cnv"
    } else {
      cns_select <- "Before remove germline cnv"
    }
    quo_cns <- dplyr::quo((
      DataType == "Copy Number Segments" & FileType == cns_select
    ))
  } else {
    quo_cns <- dplyr::quo((FALSE))
  }

  cond_select <- dplyr::quo(
    !!quo_cli |
      !!quo_RNA |
      !!quo_RNAa |
      !!quo_miRNA |
      !!quo_exon |
      !!quo_RPPA |
      !!quo_Methy |
      !!quo_genMutation |
      !!quo_somaticMutation | !!quo_gistic | !!quo_cns
  )
  res <- filter(res, !!cond_select)

  if (download) {
    res %>%
      XenaGenerate() %>%
      XenaQuery() %>%
      XenaDownload(destdir = destdir, force = forceDownload, ...)
  } else {
    xe <- res %>% XenaGenerate()
    list(Xena = xe, DataInfo = res)
  }
}




##' @title Easily Download TCGA Data by Several Options
##' @description TCGA is a very useful database and here we provide this function to
##' download TCGA (include TCGA Pancan) datasets in human-friendly way. Users who are not
##' familiar with R operation will benefit from this.
##' @details All availble information about datasets of TCGA can access vis `availTCGA()` and
##' check with `showTCGA()`.
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param project default is `NULL`. Should be one or more of TCGA project id (character vector) provided by Xena.
##' See all available project id, please use `availTCGA("ProjectID")`.
##' @param data_type default is `NULL`. Should be a character vector specify data type.
##' See all available data types by `availTCGA("DataType")`.
##' @param file_type default is `NULL`. Should be a character vector specify file type.
##' See all available file types by `availTCGA("FileType")`.
##' @inheritParams XenaDownload
##' @return same as `XenaDownload()` function result.
##' @export
##' @examples
##' \donttest{
##' # download RNASeq data (use UVM as example)
##' downloadTCGA(project = "UVM",
##'                  data_type = "Gene Expression RNASeq",
##'                  file_type = "IlluminaHiSeq RNASeqV2")
##' }
##' @seealso [UCSCXenaTools::XenaQuery()],
##' [UCSCXenaTools::XenaFilter()],
##' [UCSCXenaTools::XenaDownload()],
##' [UCSCXenaTools::XenaPrepare()],
##' [UCSCXenaTools::availTCGA()],
##' [UCSCXenaTools::showTCGA()]

downloadTCGA <- function(project = NULL,
                         data_type = NULL,
                         file_type = NULL,
                         destdir = tempdir(),
                         force = FALSE,
                         ...) {
  stopifnot(
    !is.null(project),
    !is.null(data_type),
    !is.null(file_type)
  )
  tcga_all <- .decodeDataType(Target = "tcgaHub")
  tcga_projects <- unique(tcga_all$ProjectID)

  # suppress binding notes
  ProjectID <- DataType <- FileType <- NULL

  if (!all(project %in% tcga_projects)) {
    message(
      project,
      " are not (all) valid, please select one or more of following valid project ID:"
    )
    print(tcga_projects, quote = FALSE)
    return(invisible(NULL))
  }

  res <- tcga_all %>%
    filter(
      ProjectID %in% project,
      DataType %in% data_type,
      FileType %in% file_type
    )

  if (nrow(res) == 0) { # nocov start
    message("Find nothing about your input, please check it.")
    message("availTCGA and showTCGA function may help you.")
    return(invisible(NULL))
  } # nocov end

  res %>%
    XenaGenerate() %>%
    XenaQuery() %>%
    XenaDownload(destdir = destdir, force = force, ...)
}

##' @title Get or Check TCGA Available ProjectID, DataType and FileType
##' @param which a character of `c("All", "ProjectID", "DataType", "FileType")`
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @examples
##' \donttest{
##' availTCGA("all")
##' }
availTCGA <- function(which = c("all", "ProjectID", "DataType", "FileType")) {
  which <- match.arg(which)
  tcga_all <- .decodeDataType(Target = "tcgaHub")
  tcga_projects <- unique(tcga_all$ProjectID)
  tcga_datatype <- unique(tcga_all$DataType)
  tcga_filetype <- unique(tcga_all$FileType)

  if (which == "all") {
    message(
      "Note not all projects have listed data types and file types, you can use showTCGA function to check if exist"
    )
    return(
      list(
        ProjectID = tcga_projects,
        DataType = tcga_datatype,
        FileType = tcga_filetype
      )
    )
  }

  if (which == "ProjectID") {
    return(tcga_projects)
  }
  if (which == "DataType") {
    return(tcga_datatype)
  }
  if (which == "FileType") {
    return(tcga_filetype)
  }
}

##' @title Show TCGA data structure by Project ID or ALL
##' @description This can used to check if data type or file type exist in one or more projects by hand.
##' @param project a character vector. Can be "all" or one or more of TCGA Project IDs.
##' @return a `data.frame` including project data structure information.
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @examples
##' \donttest{
##' showTCGA("all")
##' }
##' @seealso [UCSCXenaTools::availTCGA()]
showTCGA <- function(project = "all") {
  # suppress binding notes
  ProjectID <- DataType <- FileType <- NULL

  tcga_all <- .decodeDataType(Target = "tcgaHub")
  if (project == "all") {
    # res = data.table::data.table(tcga_all)
    # res = res[, .(ProjectID, DataType, FileType)]
    res <- tcga_all %>% select(ProjectID, DataType, FileType)
  } else {
    res <- tcga_all %>%
      filter(ProjectID %in% project) %>%
      select(ProjectID, DataType, FileType)
    # res = data.table::data.table(tcga_all)
    # res = res[ProjectID %in% project, .(ProjectID, DataType, FileType)]
  }

  if (nrow(res) == 0) { # nocov start
    message("Something is wrong in your input, NULL will be returned, please check.")
    return(NULL)
  } # nocov end
  return(res)
}




# Only works for TCGA
.decodeDataType <- function(XenaData = UCSCXenaTools::XenaData,
                            Target = "tcgaHub") {
  # This TCGA include TCGA PANCAN dataset
  if ("tcgaHub" %in% Target) {
    Target <- c(Target, "pancanAtlasHub")
  }

  # supress binding notes
  XenaHostNames <- XenaCohorts <- NULL

  ob <- XenaData %>% filter(XenaHostNames %in% Target)

  if ("tcgaHub" %in% Target) {
    # decode project id
    ob %>% mutate(ProjectID = sub(".*\\((.*)\\)", "\\1", XenaCohorts)) -> ob
    # decode DataType
    ob %>%
      mutate(
        DataType = dplyr::case_when(
          grepl("Gistic2_CopyNumber_Gistic2", XenaDatasets) ~ "Gene Level Copy Number",
          grepl(
            "PANCAN_Genome_Wide_SNP_6_whitelisted.gene.xena",
            XenaDatasets
          ) ~ "Gene Level Copy Number",
          # pancan
          grepl("SNP6", XenaDatasets) ~ "Copy Number Segments",
          grepl(
            "PANCAN_Genome_Wide_SNP_6_whitelisted.xena",
            XenaDatasets
          ) ~ "Copy Number Segments",
          # pancan
          grepl("HumanMethylation", XenaDatasets) ~ "DNA Methylation",
          grepl("MethylMix", XenaDatasets) ~ "DNA Methylation",
          grepl("HiSeq.*_exon", XenaDatasets) ~ "Exon Expression RNASeq",
          grepl("GA_exon", XenaDatasets) ~ "Exon Expression RNASeq",
          grepl("GAV2_exon", XenaDatasets) ~ "Exon Expression RNASeq",
          grepl("AgilentG", XenaDatasets) ~ "Gene Expression Array",
          grepl("HT_HG-U133A", XenaDatasets) ~ "Gene Expression Array",
          grepl("GA$", XenaDatasets) &
            !grepl("RABIT", XenaDatasets) ~ "Gene Expression RNASeq",
          grepl("GAV2$", XenaDatasets) &
            !grepl("RABIT", XenaDatasets) ~ "Gene Expression RNASeq",
          grepl("HiSeq$", XenaDatasets) &
            !grepl("RABIT", XenaDatasets) ~ "Gene Expression RNASeq",
          grepl("HiSeqV2$", XenaDatasets) &
            !grepl("RABIT", XenaDatasets) ~ "Gene Expression RNASeq",
          grepl("HiSeqV2_PANCAN$", XenaDatasets) ~ "Gene Expression RNASeq",
          grepl("HiSeqV2_percentile$", XenaDatasets) ~ "Gene Expression RNASeq",
          grepl(
            "EB\\+\\+AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena",
            XenaDatasets
          ) ~ "Gene Expression RNASeq",
          # pancan
          grepl("miRNA", XenaDatasets) ~ "miRNA Mature Strand Expression RNASeq",
          grepl(
            "pancanMiRs_EBadjOnProtocolPlatformWithoutRepsWithUnCorrectMiRs",
            XenaDatasets
          ) ~ "miRNA Mature Strand Expression RNASeq",
          # pancan
          grepl("Pathway_Paradigm", XenaDatasets) ~ "PARADIGM Pathway Activity",
          grepl("erge_merged_reals", XenaDatasets) ~ "PARADIGM Pathway Activity",
          # pancan
          grepl("clinicalMatrix", XenaDatasets) ~ "Phenotype",
          grepl(
            "Survival_SupplementalTable_S1_20171025_xena_sp",
            XenaDatasets
          ) ~ "Phenotype",
          # pancan
          grepl("Subtype_Immune_Model_Based.txt", XenaDatasets) ~ "Phenotype",
          # pancan
          grepl("TCGASubtype.20170308.tsv", XenaDatasets) ~ "Phenotype",
          # pancan
          grepl(
            "TCGA_phenotype_denseDataOnlyDownload.tsv",
            XenaDatasets
          ) ~ "Phenotype",
          # pancan
          grepl("gene_expression_subtype", XenaDatasets) ~ "Phenotype",
          # OV
          grepl("RPPA", XenaDatasets) ~ "Protein Expression RPPA",
          grepl("mutation_", XenaDatasets) &
            !endsWith(XenaDatasets, "gene") ~ "Somatic Mutation",
          grepl("mc3.v0.2.8.PUBLIC.xena", XenaDatasets) ~ "Somatic Mutation",
          # pancan
          grepl("mutation($|(.*_gene$))", XenaDatasets) ~ "Gene Somatic Non-silent Mutation",
          grepl(
            "mc3.v0.2.8.PUBLIC.nonsilentGene.xena",
            XenaDatasets
          ) ~ "Gene Somatic Non-silent Mutation",
          # pancan
          grepl("RABIT", XenaDatasets) ~ "Transcription Factor Regulatory Impact",
          grepl("iCluster", XenaDatasets) ~ "iCluster",
          grepl(
            "Pancan12_GenePrograms_drugTargetCanon_in_Pancan33.tsv",
            XenaDatasets
          ) ~ "Signatures",
          # pancan
          grepl("TCGA.HRD_withSampleID.txt", XenaDatasets) ~ "Signatures",
          # pancan
          grepl(
            "TCGA_pancancer_10852whitelistsamples_68ImmuneSigs.xena",
            XenaDatasets
          ) ~ "Signatures",
          # pancan
          grepl("StemnessScores_DNAmeth_20170210.tsv", XenaDatasets) ~ "Signatures",
          # pancan
          grepl(
            "StemnessScores_RNAexp_20170127.2.tsv",
            XenaDatasets
          ) ~ "Signatures" # pancan
        )
      ) -> ob

    # decode file type
    ob %>%
      mutate(
        FileType = dplyr::case_when(
          DataType == "Gene Level Copy Number" &
            grepl("Gistic2_all_data_by_genes", XenaDatasets) ~ "Gistic2",
          DataType == "Gene Level Copy Number" &
            grepl("Gistic2_all_thresholded.by_genes", XenaDatasets) ~ "Gistic2 thresholded",
          DataType == "Gene Level Copy Number" &
            grepl(
              "PANCAN_Genome_Wide_SNP_6_whitelisted.gene.xena",
              XenaDatasets
            ) ~ "Tumor copy number",


          DataType == "Copy Number Segments" &
            grepl("SNP6_genomicSegment", XenaDatasets) ~ "Before remove germline cnv",
          DataType == "Copy Number Segments" &
            grepl("SNP6_nocnv_genomicSegment", XenaDatasets) ~ "After remove germline cnv",
          DataType == "Copy Number Segments" &
            grepl(
              "PANCAN_Genome_Wide_SNP_6_whitelisted.xena",
              XenaDatasets
            ) ~ "After remove germline cnv",


          DataType == "DNA Methylation" &
            grepl("HumanMethylation27", XenaDatasets) ~ "Methylation27K",
          DataType == "DNA Methylation" &
            grepl("HumanMethylation450", XenaDatasets) ~ "Methylation450K",
          DataType == "DNA Methylation" &
            grepl("oneoff_TCGA_LGG_MethylMix", XenaDatasets) ~ "MethylMix",


          DataType == "Exon Expression RNASeq" &
            grepl("GA_exon", XenaDatasets) ~ "IlluminaGA RNASeq",
          DataType == "Exon Expression RNASeq" &
            grepl("GAV2_exon", XenaDatasets) ~ "IlluminaGA RNASeqV2",
          DataType == "Exon Expression RNASeq" &
            grepl("HiSeq_exon", XenaDatasets) ~ "IlluminaHiSeq RNASeq",
          DataType == "Exon Expression RNASeq" &
            grepl("HiSeqV2_exon", XenaDatasets) ~ "IlluminaHiSeq RNASeqV2",


          DataType == "Gene Expression Array" &
            grepl("AgilentG4502A", XenaDatasets) ~ "Agilent 244K Microarray",
          DataType == "Gene Expression Array" &
            grepl("HT_HG-U133A", XenaDatasets) ~ "Affymetrix U133A Microarray",

          DataType == "Gene Expression RNASeq" &
            endsWith(XenaDatasets, "GA") ~ "IlluminaGA RNASeq",
          DataType == "Gene Expression RNASeq" &
            endsWith(XenaDatasets, "GAV2") ~ "IlluminaGA RNASeqV2",
          DataType == "Gene Expression RNASeq" &
            endsWith(XenaDatasets, "HiSeq") ~ "IlluminaHiSeq RNASeq",
          DataType == "Gene Expression RNASeq" &
            endsWith(XenaDatasets, "HiSeqV2") ~ "IlluminaHiSeq RNASeqV2",
          DataType == "Gene Expression RNASeq" &
            endsWith(XenaDatasets, "HiSeqV2_PANCAN") ~ "IlluminaHiSeq RNASeqV2 pancan normalized",
          DataType == "Gene Expression RNASeq" &
            endsWith(XenaDatasets, "HiSeqV2_percentile") ~ "IlluminaHiSeq RNASeqV2 in percentile rank",
          DataType == "Gene Expression RNASeq" &
            grepl("AdjustPANCAN_IlluminaHiSeq_RNASeqV2", XenaDatasets) ~ "Batch effects normalized",

          DataType == "miRNA Mature Strand Expression RNASeq" &
            endsWith(XenaDatasets, "miRNA_GA_gene") ~ "IlluminaGA RNASeq",
          DataType == "miRNA Mature Strand Expression RNASeq" &
            endsWith(XenaDatasets, "miRNA_HiSeq_gene") ~ "IlluminaHiSeq RNASeq",
          DataType == "miRNA Mature Strand Expression RNASeq" &
            grepl(
              "pancanMiRs_EBadjOnProtocolPlatformWithoutRepsWithU",
              XenaDatasets
            ) ~ "Batch effects normalized",


          DataType == "PARADIGM Pathway Activity" &
            grepl("merge_merged_reals", XenaDatasets) ~ "Platform-corrected PANCAN12 dataset",
          DataType == "PARADIGM Pathway Activity" &
            endsWith(XenaDatasets, "Pathway_Paradigm_mRNA") ~ "Use only Microarray",
          DataType == "PARADIGM Pathway Activity" &
            endsWith(
              XenaDatasets,
              "Pathway_Paradigm_mRNA_And_Copy_Number"
            ) ~ "Use Microarray plus Copy Number",
          DataType == "PARADIGM Pathway Activity" &
            endsWith(XenaDatasets, "Pathway_Paradigm_RNASeq") ~ "Use only RNASeq",
          DataType == "PARADIGM Pathway Activity" &
            endsWith(
              XenaDatasets,
              "Pathway_Paradigm_RNASeq_And_Copy_Number"
            ) ~ "Use RNASeq plus Copy Number",


          DataType == "Phenotype" &
            endsWith(XenaDatasets, "clinicalMatrix") ~ "Clinical Information",
          DataType == "Phenotype" &
            grepl(
              "Survival_SupplementalTable_S1_20171025_xena_sp",
              XenaDatasets
            ) ~ "Clinical Information",
          DataType == "Phenotype" &
            grepl("gene_expression_subtype", XenaDatasets) ~ "Gene Expression Subtype",
          DataType == "Phenotype" &
            grepl("Subtype_Immune_Model_Based", XenaDatasets) ~ "Immune Model Based Subtype",
          DataType == "Phenotype" &
            grepl("TCGASubtype", XenaDatasets) ~ "TCGA Molecular Subtype",
          DataType == "Phenotype" &
            grepl(
              "TCGA_phenotype_denseDataOnlyDownload",
              XenaDatasets
            ) ~ "TCGA Sample Type and Primary Disease",

          DataType == "Protein Expression RPPA" &
            endsWith(XenaDatasets, "RPPA") ~ "RPPA",
          DataType == "Protein Expression RPPA" &
            endsWith(XenaDatasets, "RPPA_RBN") ~ "RPPA normalized by RBN",
          DataType == "Protein Expression RPPA" &
            grepl("TCGA-RPPA-pancan-clean", XenaDatasets) ~ "RPPA pancan normalized",


          DataType == "Somatic Mutation" &
            grepl("mc3.v0.2.8.PUBLIC.xena", XenaDatasets) ~ "MC3 Public Version",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_bcgsc") ~ "bcgsc automated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_bcm") ~ "bcm automated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_bcm_solid") ~ "bcm SOLiD",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_broad") ~ "broad automated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_curated_bcm") ~ "bcm curated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_curated_bcm_solid") ~ "bcm SOLiD curated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_curated_broad") ~ "broad curated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_curated_wustl") ~ "wustl curated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_ucsc_maf") ~ "ucsc automated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_wustl") ~ "wustl automated",
          DataType == "Somatic Mutation" &
            endsWith(XenaDatasets, "mutation_wustl_hiseq") ~ "wustl hiseq automated",

          DataType == "Gene Somatic Non-silent Mutation" &
            grepl(
              "mc3.v0.2.8.PUBLIC.nonsilentGene.xena",
              XenaDatasets
            ) ~ "MC3 Public Version",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation") ~ "PANCAN AWG analyzed",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_bcgsc_gene") ~ "bsgsc automated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_bcm_gene") ~ "bcm automated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_bcm_solid_gene") ~ "bcm SOLiD",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_broad_gene") ~ "broad automated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_curated_bcm_gene") ~ "bcm curated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_curated_bcm_solid_gene") ~ "bcm SOLiD curated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_curated_broad_gene") ~ "broad curated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_curated_wustl_gene") ~ "wustl curated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_ucsc_maf_gene") ~ "ucsc automated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_wustl_gene") ~ "wustl automated",
          DataType == "Gene Somatic Non-silent Mutation" &
            endsWith(XenaDatasets, "mutation_wustl_hiseq_gene") ~ "wustl hiseq automated",


          DataType == "Transcription Factor Regulatory Impact" &
            grepl("HiSeq.V2$", XenaDatasets) ~ "RABIT Use IlluminaHiSeq RNASeqV2",
          DataType == "Transcription Factor Regulatory Impact" &
            grepl("HiSeq$", XenaDatasets) ~ "RABIT Use IlluminaHiSeq RNASeq",
          DataType == "Transcription Factor Regulatory Impact" &
            grepl("GA.V2$", XenaDatasets) ~ "RABIT Use IlluminaGA RNASeqV2",
          DataType == "Transcription Factor Regulatory Impact" &
            grepl("GA$", XenaDatasets) ~ "RABIT Use IlluminaGA RNASeq",
          DataType == "Transcription Factor Regulatory Impact" &
            grepl("Agilent$", XenaDatasets) ~ "RABIT Use Agilent 244K Microarray",
          DataType == "Transcription Factor Regulatory Impact" &
            grepl("U133A$", XenaDatasets) ~ "RABIT Use Affymetrix U133A Microarray",

          DataType == "iCluster" &
            grepl("TCGA_PanCan33_iCluster_k28_tumor", XenaDatasets) ~ "iCluster cluster assignments",
          DataType == "iCluster" &
            grepl("lat.vars.iCluster.redo.tumor", XenaDatasets) ~ "iCluster latent variables",

          DataType == "Signatures" &
            grepl(
              "Pancan12_GenePrograms_drugTargetCanon",
              XenaDatasets
            ) ~ "Pancan Gene Programs",
          DataType == "Signatures" &
            grepl("StemnessScores_DNAmeth_", XenaDatasets) ~ "DNA methylation based StemnessScore",
          DataType == "Signatures" &
            grepl("StemnessScores_RNAexp", XenaDatasets) ~ "RNA based StemnessScore",
          DataType == "Signatures" &
            grepl(
              "TCGA_pancancer_10852whitelistsamples_68ImmuneSigs",
              XenaDatasets
            ) ~ "Immune Signature Scores",
          DataType == "Signatures" &
            grepl("TCGA.HRD_withSampleID.txt", XenaDatasets) ~ "Genome-wide DNA Damage Footprint HRD Score"
        )
      ) -> ob_tcga
  }
  ob_tcga
}



# grep unique pattern
# ob1 = sub("TCGA.*/(.*)", "\\1", ob$XenaDatasets) %>% table() %>% names() -> uniqueDatasets
# ob1 = tibble(XenaDatasets = uniqueDatasets)
# grep("gene_expression_subtype", ob$XenaDatasets, value = TRUE)


utils::globalVariables(c("DataType", "FileType", "ProjectID"))
