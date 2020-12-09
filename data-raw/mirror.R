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
    message("Set thread to 0 to run sequentially.")
    quit("no", status = 1)
}

destdir <- path.expand(args[1])
threads <- as.integer(args[2])

sink(file = file.path(destdir, "mirror.txt"))
on.exit(sink(NULL))
message("destdir: ", destdir)
message("threads: ", threads)

if (!dir.exists(destdir)) dir.create(destdir, recursive = TRUE)
if (threads != 0) {
    future::plan(multisession, workers = threads)
    call_fun <- furrr::future_map
} else {
    call_fun <- purrr::map
}

download_dataset <- function(x, destdir) {
    x %>%
        XenaGenerate() %>%
        XenaQuery() %>%
        XenaDownload(
            destdir = destdir,
            download_probeMap = TRUE,
            trans_slash = FALSE,
            force = TRUE,
            method = "curl", extra = "-C -") # 断点续传
}

access_datasets <- XenaData # XenaDataUpdate(saveTolocal = FALSE)
hubs <- unique(access_datasets$XenaHostNames)

dataset_list <- call_fun(hubs, function(h) {
    sink(file = file.path(destdir, "mirror.txt"), append = TRUE)
    x <- subset(access_datasets, XenaHostNames == h)
    message("Mirroring hub: ", h)
    message("================================")
    download_dataset(x, file.path(destdir, h))
})

mapping_df <- Reduce(rbind, dataset_list)

message("================================")
message("The mirror work has done, please check the mirror.txt.")

write.csv(mapping_df,
          file = file.path(destdir, "mapping_dataframe.csv"),
          row.names = FALSE, quote = FALSE)
