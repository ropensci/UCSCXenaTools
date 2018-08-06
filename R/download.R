# download feature
# under host_url/download/
# under development

# xe <- XenaHub()
# hosts(xe)
# cohorts(xe)
# head(datasets(xe))
# samples(xe)
# 
# xe2 <- XenaHub(datasets = "HiSeqV2", hostName = "TCGA")
# 
# hostsName = hosts(XenaHub(hostName = "UCSC_Public"))
# datasetsName = xquery[10,"datasets"]
# link = paste0(hostsName,"/download/",datasetsName,".gz" )
# download.file(url = link, destfile = "E:/Github/XenaData/test.tsv.gz")
# 
# basename(datasets(xe)) %>% table() %>% names()

XenaQuery = function(x){
    hostsName = hosts(x)
    datasetsName = datasets(x)
    
    if(length(hostsName) == 1){
        dlink = paste0(hostsName,"/download/",datasetsName,".gz")
        query = data.frame(hosts = hostsName, datasets = datasetsName, url = dlink, stringsAsFactors = FALSE)
    }else{
        # identify relationship of hosts and datasets
        query = data.frame(hosts = "NA", datasets = datasetsName, url = "NA", stringsAsFactors = FALSE)
        for(onehost in hostsName){
            xe = XenaHub(hosts = onehost)
            dataset_list = datasets(xe)
            query$hosts[query$datasets %in% dataset_list] = hosts(xe)
        }
        query$url = paste0(query$hosts, "/download/", query$datasets, ".gz")
        
    }
    
    invisible(query)
}
    
XenaDownload = function(xquery, destdir=paste0(getwd(), "XenaData"), basedir="data"){
    
    stopifnot(is.data.frame(xquery), c("url") %in% names(xquery))
    
    xquery$fileName = gsub(pattern = "/", replacement = "__", x = xquery$datasets)
    xquery$fileName = paste0(xquery$fileName, ".gz")
    destdir = paste0(destdir,"/",basedir)
    xquery$destfile = paste0(destdir, "/", xquery$fileName)
    
    if(!dir.exists(destdir)) {
        dir.create(destdir, recursive = TRUE)
    }
    
    message("We will download files to directory ", destdir, ".")
    
    apply(xquery, 1, function(x){
        tryCatch({
            message("Downloading ", x[4])
            download.file(x[3], destfile = x[5])}, error = function(e){
                message("Can not find file", x[4], ", this file maybe not compressed.")
                x[3] = gsub(pattern = "\\.gz$", "", x[3])
                x[4] = gsub(pattern = "\\.gz$", "", x[4])
                x[5] = gsub(pattern = "\\.gz$", "", x[5])
                message("Try downloading file", x[4], "...")
                download.file(x[3], destfile = x[5])
            })
        
    })
    
    message("Note filenames transfromed from datasets name and / chracter all changed to __ character.")
    invisible(xquery)
}