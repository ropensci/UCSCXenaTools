# This extends tests in test-basic-workflow.R
# Skip these tests on CRAN
skip_on_cran()

xe <- XenaGenerate(subset = grepl("BRCA", XenaCohorts))
xe2 <- XenaHub(hostName = "tcgaHub")
xe3 <- XenaHub(
  hosts = "https://tcga.xenahubs.net",
  cohorts = "TCGA Breast Cancer (BRCA)",
  datasets = "TCGA.BRCA.sampleMap/HiSeqV2"
)


all_hosts <- c(
  "https://ucscpublic.xenahubs.net",
  "https://tcga.xenahubs.net",
  "https://gdc.xenahubs.net",
  "https://icgc.xenahubs.net",
  "https://toil.xenahubs.net",
  "https://pancanatlas.xenahubs.net",
  "https://xena.treehouse.gi.ucsc.edu:443",
  "https://pcawg.xenahubs.net",
  "https://atacseq.xenahubs.net",
  "https://singlecellnew.xenahubs.net",
  "https://kidsfirst.xenahubs.net"
  #"https://tdi.xenahubs.net"
)


# XenaHub-class.R ---------------------------------------------------------

test_that("show method for XenaHub object works", {
  expect_output(show(xe), "class: XenaHub")
})

test_that("fun xena_default_hosts works", {
  expect_identical(xena_default_hosts(), all_hosts)
})

test_that("fun XenaHub works", {
  expect_output(show(xe2), "class: XenaHub")
  expect_error(XenaHub(hostName = "xxx"))
  expect_output(show(xe3), "class: XenaHub")
})

test_that("fun .collapse_list works", {
  expect_identical(.collapse_list(c("a", "b")), "a,b")
})


# api-higher --------------------------------------------------------------

test_that("funs to get hosts, cohorts, datasets and samples work", {
  expect_identical("https://tcga.xenahubs.net", hosts(xe3))
  expect_identical("TCGA Breast Cancer (BRCA)", cohorts(xe3))
  expect_identical("TCGA.BRCA.sampleMap/HiSeqV2", datasets(xe3))
  samples <- samples(xe3)[[1]]
  expect_true("TCGA-GI-A2C8-01" %in% samples)
})


# Fetch -------------------------------------------------------------------

host <- "https://toil.xenahubs.net"
dataset <- "tcga_RSEM_gene_tpm"
samples <- c("TCGA-02-0047-01", "TCGA-02-0055-01", "TCGA-02-2483-01", "TCGA-02-2485-01")
probes <- c("ENSG00000282740.1", "ENSG00000000005.5", "ENSG00000000419.12")
genes <- c("TP53", "RB1", "PIK3CA")


fetch()
# Fetch samples
fetch_dataset_samples(host, dataset, 2)
# Fetch identifiers
tryCatch({
  fetch_dataset_identifiers(host, dataset)
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})


# Fetch expression value by probes
tryCatch({
  fetch_dense_values(host, dataset, probes, samples, check = FALSE)
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})

tryCatch({
  fetch_dense_values(host, dataset, probes, samples[1], check = TRUE)
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})

tryCatch({
  fetch_dense_values(host, dataset, probes[1], samples[1], check = TRUE)
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})

tryCatch({
  fetch_dense_values(host, dataset, probes[1], samples[1], check = TRUE)
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})

tryCatch({
  expect_error(fetch_dense_values(host, dataset, probes[1], 33, check = TRUE))
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})

tryCatch({
  fetch_dense_values(host, dataset, c(probes[1], "xxx"), c(samples[1], "xxx"), check = TRUE)
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})

# The following two are two time consuming
# fetch_dense_values(host, dataset, probes[1], check = TRUE)
# fetch_dense_values(host, dataset, samples = samples[1], check = TRUE)

# Fetch expression value by gene symbol (if the dataset has probeMap)
tryCatch({
  fetch_dense_values(host, dataset, genes, samples, check = TRUE, use_probeMap = TRUE)
}, error = function(e) {
  if (grepl("500", e$message)) {
    message("Bad network, skipping check")
  } else {
    stop(e$message)
  }
})

# Workflow ----------------------------------------------------------------
expect_warning(XenaFilter(xe))
expect_warning(XenaFilter(xe2, filterCohorts = "TCGA Breast Cancer (BRCA)"))
XenaQueryProbeMap(xe3)

# clean all
rm(list = ls())
