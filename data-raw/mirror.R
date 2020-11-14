## code to mirror all raw datasets (which can be downloaded by users) of UCSC Xena
library(UCSCXenaTools)
destdir <- commandArgs(trailingOnly = TRUE)
# You can do it with 'curl' command
XenaDataUpdate(saveTolocal = FALSE) %>%
    XenaGenerate() %>%
    XenaQuery() %>%
    XenaDownload(xq,
                 destdir = destdir,
                 download_probeMap = TRUE,
                 trans_slash = FALSE,
                 method = "curl", extra = "-C -")
