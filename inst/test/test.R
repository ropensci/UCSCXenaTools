
# xe <- XenaHub()
# hosts(xe)
# cohorts(xe)
# head(datasets(xe))
# samples(xe)
# 
xe2 <- XenaHub(hostName = "TCGA")
filterXena(xe2, filterDatasets = "LUAD_clinical|LUAD.*HiSeqV2$") -> xe2_filter
xe2_download = XenaQuery(xe2_filter)
XenaDownload(xe2_download, destdir = "E:/Github/XenaData/")

require(readr)
read_tsv(file = xe2_download$url[2], progress = TRUE) -> cli
read_tsv(file = xe3query$url[2], progress = TRUE) -> htseq_counts
# 
# hostsName = hosts(XenaHub(hostName = "UCSC_Public"))
# datasetsName = xquery[10,"datasets"]
# link = paste0(hostsName,"/download/",datasetsName,".gz" )
# download.file(url = link, destfile = "E:/Github/XenaData/test.tsv.gz")
# 
# basename(datasets(xe)) %>% table() %>% names()


# test download and prepare functions
xe4 <- XenaHub(hostName = "TCGA")
filterXena(xe4, filterDatasets = "clinical") -> xe4_filter
xe4_download = XenaQuery(xe4_filter)
xe4_download2 = XenaDownload(xe4_download, destdir = "E:/Github/XenaData/TCGA_Clinical")

# way1:  directory
cli1 = XenaPrepare("E:/Github/XenaData/TCGA_Clinical/")
# way2: local files
XenaPrepare(c("E:/Github/XenaData/TCGA_Clinical/TCGA.ACC.sampleMap__ACC_clinicalMatrix.gz"))
cli2 = XenaPrepare(c("E:/Github/XenaData/TCGA_Clinical/TCGA.ACC.sampleMap__ACC_clinicalMatrix.gz"))
cli2 = XenaPrepare(c("E:/Github/XenaData/TCGA_Clinical/TCGA.ACC.sampleMap__ACC_clinicalMatrix.gz",
                     "E:/Github/XenaData/TCGA_Clinical/TCGA.BLCA.sampleMap__BLCA_clinicalMatrix.gz"))
# way3: urls
cli3 = XenaPrepare(xe4_download$url[1:3])
cli3 = XenaPrepare(xe4_download$url[1])

# way4: xenadownload object
cli4 = XenaPrepare(xe4_download2)