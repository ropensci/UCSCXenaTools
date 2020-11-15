#!/usr/bin/env Rscript
## code to mirror all raw datasets (which can be downloaded by users) of UCSC Xena

# Update to the recent UCSCXenaTools
# BiocManager::install("UCSCXenaTools")

suppressMessages(library(UCSCXenaTools))
destdir <- commandArgs(trailingOnly = TRUE)

if (length(destdir) != 1) {
    message("Error: only one directory can be set!")
    message()
    message("Usage: ./mirror.R <destdir>")
    quit("no", status = 1)
}

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

access_datasets <- XenaData[c(2,4,8),] # XenaDataUpdate(saveTolocal = FALSE)
hubs <- unique(access_datasets$XenaHostNames)
dataset_list <- lapply(hubs, function(h) {
    x <- subset(access_datasets, XenaHostNames == h)
    message("Mirroring hub: ", h)
    message("================================")
    download_dataset(x, file.path(destdir, h))
})
mapping_df <- Reduce(rbind, dataset_list)

write.csv(mapping_df,
          file = file.path(destdir, "mapping_dataframe.csv"),
          row.names = FALSE)
message("================================")
message("The mirror work has done, please check the log.")
