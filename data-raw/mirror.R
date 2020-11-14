## code to mirror all raw datasets (which can be downloaded by users) of UCSC Xena
library(UCSCXenaTools)
destdir <- commandArgs(trailingOnly = TRUE)

download_dataset <- function(x, destdir) {
    x %>%
        XenaGenerate() %>%
        XenaQuery() %>%
        XenaDownload(
            destdir = destdir,
            download_probeMap = TRUE,
            trans_slash = FALSE,
            method = "curl", extra = "-C -") # d断点续传
}

access_datasets <- XenaDataUpdate(saveTolocal = FALSE)
hubs <- unique(access_datasets$XenaHostNames)
lapply(hubs, function(h) {
    x <- subset(access_datasets, XenaHostNames == h)
    message("Mirroring hub: ", h)
    message("================================")
    download_dataset()
})

message("================================")
message("The mirror work has done, please check the log.")
