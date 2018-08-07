# download feature
# under host_url/download/
# under development


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
    
XenaDownload = function(xquery, destdir=paste0(getwd(), "XenaData"), force=FALSE, ...){
    
    stopifnot(is.data.frame(xquery), c("url") %in% names(xquery))
    
    xquery$fileNames = gsub(pattern = "/", replacement = "__", x = xquery$datasets)
    xquery$fileNames = paste0(xquery$fileNames, ".gz")
    #destdir = paste0(destdir,"/")
    xquery$destfiles = paste0(destdir, "/", xquery$fileNames)
    
    if(!dir.exists(destdir)) {
        dir.create(destdir, recursive = TRUE)
    }
    
    message("We will download files to directory ", destdir, ".")
    
    apply(xquery, 1, function(x){
        tryCatch({
            if(!file.exists(x[5]) | force){
                message("Downloading ", x[4])
                download.file(x[3], destfile = x[5], ...)
            }else{
                message(x[5], ", the file has been download!")
            }
            }, error = function(e){
                message("Can not find file", x[4], ", this file maybe not compressed.")
                x[3] = gsub(pattern = "\\.gz$", "", x[3])
                x[4] = gsub(pattern = "\\.gz$", "", x[4])
                x[5] = gsub(pattern = "\\.gz$", "", x[5])
                message("Try downloading file", x[4], "...")
                download.file(x[3], destfile = x[5], ...)
            })
        
    })
    
    message("Note fileNames transfromed from datasets name and / chracter all changed to __ character.")
    invisible(xquery)
}

XenaPrepare = function(objects, objectsName=NULL, comment="#", na=c("", "NA", "[Discrepancy]"), ...){
    # objects can be url, local files/directory or xena object from xena download process
    stopifnot(is.character(objects) | is.data.frame(objects))
    
    objects2 = objects
    
    if(is.character(objects)){
        
        if(length(objects) == 0) stop("Please check you input!")
        
        # the input are directory?
        if(all(dir.exists(objects)) & !all(file.exists(objects))){
            if(length(objects) > 1){
                stop("We do not accept multiple directories as input.")
            }else{
                files = paste0(objects, "/", dir(objects))
                res = lapply(files, function(x){
                    y = suppressMessages(read_tsv(x, comment=comment, na=na, ...))
                    y
            })
            if(is.null(objectsName)){
                    objectsName = make.names(dir(objects))
                    names(res) = objectsName
                    }
                }
            
        }else if(all(file.exists(objects))){
            res = lapply(objects, function(x){
                y = suppressMessages(read_tsv(x, comment=comment, na=na, ...))
                y})
            if(is.null(objectsName)){
                objectsName = make.names(basename(objects))
                names(res) = objectsName
            }
            if (length(res) == 1){
                res = res[[1]]
            }
        }
        else{
            # check urls
            all_right = grepl(pattern = "http", x = objects)
            
            if(any(all_right)){
                objects = objects[all_right]
                if(length(objects) == 1){
                    res = suppressMessages(read_tsv(objects, comment=comment, na=na, ...))
                }else{
                    res = lapply(objects, function(x){
                        y = suppressMessages(read_tsv(x, comment=comment, na=na, ...))})
                    
                    # use for loop
                    # res = list()
                    # i = 1
                    # for (x in objects){
                    #     res[[i]] = read_tsv(x, comment=comment, ...)
                    #     i = i + 1
                    # }
                    
                    if(is.null(objectsName)){
                        objectsName = make.names(basename(objects))
                        names(res) = objectsName
                    }
                }
            }
            all_wrong = !all_right
            if(any(all_wrong)){
                bad_urls = objects2[all_wrong]
                message("Some inputs are wrong, maybe you should check:")
                print(bad_urls)
            }
        }
    }else{
        if(!"destfiles" %in% colnames(objects)){
            stop("Input data.frame should contain 'destfiles' column which generated by XenaDownload functions. Please check your input.")
        }
        
        files = objects$destfiles
        res = XenaPrepare(files, objectsName = objectsName, comment = comment, na=na, ...)
    }
    
    return(res)    
}
