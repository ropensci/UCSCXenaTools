#!/usr/bin/env Rscript
## code to mirror all raw datasets (which can be downloaded by users) of UCSC Xena

# Update to the recent UCSCXenaTools
# BiocManager::install("UCSCXenaTools")

suppressMessages(library(UCSCXenaTools))
library(furrr)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
    message("Error: two arguments are required!")
    message()
    message("Usage: ./mirror.R <destdir> <thread>")
    quit("no", status = 1)
}


sink(file = file.path(destdir, "mirror.log"))
destdir <- path.expand(args[1])
threads <- as.integer(args[2])
message("destdir: ", destdir)
message("threads: ", threads)

if (!dir.exists(destdir)) dir.create(destdir, recursive = TRUE)
future::plan(multisession, workers = threads)

download_dataset <- function(x, destdir) {
    x %>%
        XenaGenerate() %>%
        XenaQuery() %>%
        XenaDownload(
            destdir = destdir,
            download_probeMap = TRUE,
            trans_slash = FALSE,
            method = "curl", extra = "-C -") # 断点续传
}

access_datasets <- XenaData[1:10] # XenaDataUpdate(saveTolocal = FALSE)
hubs <- unique(access_datasets$XenaHostNames)

dataset_list <- furrr::future_map(hubs, function(h) {
    sink(file = file.path(destdir, "mirror.log"), append = TRUE)
    x <- subset(access_datasets, XenaHostNames == h)
    message("Mirroring hub: ", h)
    message("================================")
    download_dataset(x, file.path(destdir, h))
},
.progress = TRUE
)

mapping_df <- Reduce(rbind, dataset_list)

message("================================")
message("The mirror work has done, please check the log.")
sink()

write.csv(mapping_df,
          file = file.path(destdir, "mapping_dataframe.csv"),
          row.names = FALSE)
