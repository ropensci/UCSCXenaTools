context("test-basic-workflow")

data("XenaData", package = "UCSCXenaTools")
head(XenaData)

test_that("Load XenaData works", {
  expect_is(XenaData, "data.frame")
})

xe <- XenaGenerate(subset = XenaHostNames == "tcgaHub")

test_that("XenaGenerate works", {
  expect_is(xe, "XenaHub")
})

xe2 <- XenaFilter(xe, filterDatasets = "clinical")
xe2 <- XenaFilter(xe2, filterDatasets = "LUAD|LUSC")

test_that("XenaFilter works", {
  expect_is(xe2, "XenaHub")
})

xe2_query <- XenaQuery(xe2)

test_that("XenaQuery works", {
  expect_is(xe2_query, "data.frame")
})

xe2_download <- XenaDownload(xe2_query, trans_slash = FALSE, download_probeMap = TRUE)
xe2_download <- XenaDownload(xe2_query,
  trans_slash = TRUE,
  destdir = file.path(tempdir(), "test_ucscxenatools")
)

# 4 ways to prepare data
dt1 <- XenaPrepare(file.path(tempdir(), "test_ucscxenatools"))
dt1 <- XenaPrepare(file.path(tempdir(), "test_ucscxenatools"), use_chunk = TRUE)
dt2 <- XenaPrepare(xe2_download$destfiles[1])
dt2 <- XenaPrepare(xe2_download$destfiles[1], use_chunk = TRUE)
dt3 <- XenaPrepare(xe2_download$url[1])
dt3 <- XenaPrepare(xe2_download$url[1], use_chunk = TRUE)
dt3 <- XenaPrepare(xe2_download$url, use_chunk = TRUE)
dt4 <- XenaPrepare(xe2_download)
dt4 <- XenaPrepare(xe2_download, use_chunk = TRUE)

### Simplified functions
expect_error(getTCGAdata("xxx"))
expect_error(getTCGAdata(c("UVM", "LUAD"), mRNASeq = TRUE, mRNASeqType = "xxx"))
expect_error(getTCGAdata(c("UVM", "LUAD"),
  Methylation = TRUE, MethylationType = "xxx",
  RPPAArray = TRUE, ReplicateBaseNormalization = FALSE
))
getTCGAdata(c("UVM", "LUAD"),
  GisticCopyNumber = TRUE, Gistic2Threshold = FALSE,
  CopyNumberSegment = TRUE, RemoveGermlineCNV = FALSE
)
getTCGAdata("LUNG", download = TRUE)
getTCGAdata("LUAD",
  clinical = FALSE, mRNASeq = TRUE,
  mRNAArray = TRUE, miRNASeq = TRUE, exonRNASeq = TRUE,
  RPPAArray = TRUE, ReplicateBaseNormalization = TRUE,
  Methylation = TRUE, GeneMutation = TRUE, SomaticMutation = TRUE,
  GisticCopyNumber = TRUE, Gistic2Threshold = TRUE, CopyNumberSegment = TRUE, RemoveGermlineCNV = TRUE
)


downloadTCGA(
  project = "UVM",
  data_type = "Phenotype",
  file_type = "Clinical Information"
)
downloadTCGA("xxx",
  data_type = "Phenotype",
  file_type = "Clinical Information"
)

availTCGA()
availTCGA(which = "ProjectID")
availTCGA(which = "DataType")
availTCGA(which = "FileType")

showTCGA()
showTCGA("LUAD")

# clean all
rm(list = ls())
