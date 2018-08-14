##'  a S4 class to represent UCSC Xena Data Hubs
##'  @slot hosts hosts of data hubs
##'  @slot cohorts cohorts of data hubs
##'  @slot datasets datasets of data hubs
##'  @importFrom methods new
.XenaHub = setClass("XenaHub",
    representation=representation(hosts="character", cohorts="character",
      datasets="character"))


##' @title UCSC Xena Default Hosts
##' @description Return Xena Default hosts
##' @return A character vector include current defalut hosts
##' @author Shixiang Wang <w_shixiang@163.com>
##' @seealso \code{\link[UCSCXenaTools]{XenaHub}}
##' @export
xena_default_hosts = function() {
    c("https://ucscpublic.xenahubs.net",
      "https://tcga.xenahubs.net",
      "https://gdc.xenahubs.net",
      "https://icgc.xenahubs.net",
      "https://toil.xenahubs.net")
}

##' Generate a XenaHub Object
##'
##' Major function of \code{UCSCXenatools}. It is used to generate original
##' \code{XenaHub} object according to hosts, cohorts, datasets or hostName.
##' If these arguments not specified, all hosts and corresponding datasets
##' will be returned as a \code{XenaHub} object. All datasets can be found
##' at <https://xenabrowser.net/datapages/>.
##'
##'
##' @param hosts a character vector specify UCSC Xena hosts, all available hosts can be
##' found by \code{xena_default_hosts()} function. \code{hostName} is a recommend option
##' for substitute this.
##' @param cohorts default is empty character vector, all cohorts will be returned.
##' @param datasets default is empty character vector, all datasets will be returned.
##' @param hostName one to five of \code{"UCSC_Public", "TCGA", "GDC", "ICGC", "Toil"}. This is
##' a easier option for user than \code{hosts} option. Note, this option will overlap \code{hosts}.
##' @return a \code{XenaHub} object
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @importFrom httr stop_for_status POST content
##' @importFrom utils head tail
##' @import methods
##' @examples
##' #1 query all hosts, cohorts and datasets
##' xe = XenaHub()
##' xe
##' #2 query only TCGA hosts
##' xe = XenaHub(hostName = "TCGA")
##' xe
##' hosts(xe)     # get hosts
##' cohorts(xe)   # get cohorts
##' datasets(xe)  # get datasets
##' samples(xe)   # get samples
XenaHub = function(hosts=xena_default_hosts(), cohorts=character(),
             datasets=character(), hostName=c("UCSC_Public", "TCGA", "GDC", "ICGC", "Toil")){

    stopifnot(is.character(hosts), is.character(cohorts),
              is.character(datasets))

    hostName = unique(hostName)

    if(length(hostName) != 5 & all(hostName %in% c("UCSC_Public", "TCGA", "GDC", "ICGC", "Toil")) ){
      hostNames = data.frame(UCSC_Public="https://ucscpublic.xenahubs.net",
                             TCGA="https://tcga.xenahubs.net",
                             GDC="https://gdc.xenahubs.net",
                             ICGC="https://icgc.xenahubs.net",
                             Toil="https://toil.xenahubs.net", stringsAsFactors = FALSE)
      hosts = as.character(hostNames[, hostName])
    }

    # hostName = match.arg(hostName)
    #
    # if(hostName != ""){
    #     hosts = switch(hostName,
    #                     UCSC_Public="https://ucscpublic.xenahubs.net",
    #                     TCGA="https://tcga.xenahubs.net",
    #                     GDC="https://gdc.xenahubs.net",
    #                     ICGC="https://icgc.xenahubs.net",
    #                     Toil="https://toil.xenahubs.net")
    # }

    if (is.null(names(hosts)))
        names(hosts) = hosts

    hosts0 = hosts
    hosts = Filter(.host_is_alive, hosts)
    if (length(hosts) == 0L)
        stop("\n  no hosts responding:",
             "\n    ", paste0(hosts0, collapse="\n  "))

    all_cohorts = unlist(.host_cohorts(hosts), use.names=FALSE)
    if (length(cohorts) == 0L) {
        cohorts = all_cohorts
    } else {
        hosts = hosts[.cohort_datasets_count(hosts, cohorts) != 0L]
    }

    all_datasets = unlist(.cohort_datasets(hosts, cohorts),
                          use.names=FALSE)
    if (length(datasets) == 0L){
        datasets = all_datasets
    }else{
        if(!all(datasets %in% all_datasets)){
            bad_dataset = datasets[!datasets %in% all_datasets]
            message("Following datasets are not in datasets of hosts, ignore them...")
            message(bad_dataset)
        }
        datasets = all_datasets[all_datasets %in% datasets]
    }


    .XenaHub(hosts=hosts, cohorts=cohorts, datasets=datasets)
}

##' Get or Update Newest Data Information of UCSC Xena Data Hubs
##' @param saveTolocal logical. Whether save to local R package data directory for permanent use
##' or Not.
##' @return a \code{data.frame} contains all datasets information of Xena.
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @examples
##'
##' \dontrun{
##'  XenaDataUpdate() # update newest information to local directory for use
##'  newest_Xena = XenaDataUpdate(saveTolocal=FALSE) # just get info, not save
##' }
XenaDataUpdate = function(saveTolocal=TRUE){
    hosts = xena_default_hosts()
    XenaList = sapply(hosts, function(x){
        onehost_cohorts = unlist(.host_cohorts(x), use.names = FALSE)
        sapply(onehost_cohorts, function(y){
            onecohort_datasets = unlist(.cohort_datasets(x, y))
        })
    })

    resDF = data.frame(stringsAsFactors = FALSE)
    for(i in 1:length(XenaList)){
        hostNames = names(XenaList)[i]
        cohortNames = names(XenaList[[i]])
        res = data.frame(stringsAsFactors = FALSE)

        for (j in 1:length(cohortNames)){
            oneCohort = XenaList[[i]][j]
            # The unassigned cohorts have NULL data, remove it
            if(names(oneCohort) != "(unassigned)"){
                resCohort = data.frame(XenaCohorts=names(oneCohort),
                                       XenaDatasets=as.character(oneCohort[[1]]),
                                       stringsAsFactors = FALSE)
                res = rbind(res, resCohort)
            }
        }
        res$XenaHosts = hostNames
        resDF = rbind(resDF, res)
    }

    XenaHostNames = c("UCSC_Public", "TCGA", "GDC", "ICGC", "Toil")
    names(XenaHostNames) = c("https://ucscpublic.xenahubs.net",
                             "https://tcga.xenahubs.net",
                             "https://gdc.xenahubs.net",
                             "https://icgc.xenahubs.net",
                             "https://toil.xenahubs.net")

    resDF$XenaHostNames = XenaHostNames[resDF$XenaHosts]
    XenaData = resDF[, c("XenaHosts", "XenaHostNames", "XenaCohorts", "XenaDatasets")]
    if(saveTolocal){
        data_dir = base::system.file("data",package = "UCSCXenaTools")
        if(dir.exists(data_dir)){
            save(XenaData, file=paste0(data_dir, "/XenaData.rda"))
        }else{
            message("There is no data directory ", data_dir)
            message("Please check it.")
        }
    }
    XenaData
}


##' Filter a XenaHub Object
##'
##' Major function of \code{UCSCXenatools}. It is used to filter
##' \code{XenaHub} object according to cohorts, datasets. All datasets can be found
##' at <https://xenabrowser.net/datapages/>. Note, the change for filtering cohorts and
##' datasets are independent.
##'
##'
##' @param x a \code{XenaHub} object
##' @param filterCohorts default is \code{NULL}. A character used to filter cohorts,
##' regular expression is supported.
##' @param filterDatasets default is \code{NULL}. A character used to filter datasets,
##' regular expression is supported.
##' @param ignore.case if \code{FALSE}, the pattern matching is case sensitive and if \code{TRUE}, case is ignored during matching.
##' @return a \code{XenaHub} object
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @examples
##' # operate TCGA datasets
##' xe = XenaGenerate(subset = XenaHostNames == "TCGA")
##' xe
##' # get all names of clinical data
##' xe2 = XenaFilter(xe, filterDatasets = "clinical")
##' datasets(xe2)
XenaFilter = function(x, filterCohorts=NULL, filterDatasets=NULL, ignore.case=TRUE){
    if(is.null(filterCohorts) & is.null(filterDatasets)){
        message("No operation for input, do nothing...")
    }

    cohorts_select = character()
    datasets_select = character()

    if (!is.null(filterCohorts)){
        cohorts_select = grep(pattern = filterCohorts, x@cohorts, ignore.case = ignore.case, value = TRUE)
    }

    if (!is.null(filterDatasets)){
        datasets_select = grep(pattern = filterDatasets, x@datasets, ignore.case = ignore.case, value = TRUE)
    }

    XenaHub(hosts = x@hosts, cohorts = cohorts_select, datasets = datasets_select)
}

##' Get hosts of XenaHub object
##' @param x a \code{XenaHub} object
##' @import methods
##' @return a character vector contains hosts
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "TCGA"); hosts(xe)
hosts = function(x) unname(slot(x, "hosts"))
##' Get cohorts of XenaHub object
##' @param x a \code{XenaHub} object
##' @return a character vector contains cohorts
##' @import methods
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "TCGA"); cohorts(xe)
cohorts = function(x) slot(x, "cohorts")
##' Get datasets of XenaHub object
##' @param x a \code{XenaHub} object
##' @return a character vector contains datasets
##' @import methods
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "TCGA"); datasets(xe)
datasets = function(x) slot(x, "datasets")

.samples_by_host = function(x, hosts, how) {
    if (length(hosts) == 0L) {
        hosts = hosts(x)
    } else {
        stopifnot(all(hosts %in% hosts(x)))
    }
    if (is.null(names(hosts)))
        names(hosts) = hosts

    cohorts = cohorts(x)
    if (is.null(names(cohorts)))
        names(cohorts) = cohorts
    x = .cohort_samples_any(hosts, cohorts)
    switch(how,
           each=x,
           any=unique(unlist(x, use.names=FALSE)),
           all=Reduce(function(x, y) x[x %in% y], x))
}

.samples_by_cohort = function(x, cohorts, how) {
    if (length(cohorts) == 0L) {
        cohorts = cohorts(x)
    } else {
        stopifnot(all(cohorts %in% cohorts(x)))
    }
    if (is.null(names(cohorts)))
        names(cohorts) = cohorts

    fun = switch(how, each = .cohort_samples_each,
                  all = .cohort_samples_all,
                  any = .cohort_samples_any)
    fun(hosts(x), cohorts)
}

.samples_by_dataset = function(x, datasets, how) {
    if (length(datasets) == 0L) {
        datasets = datasets(x)
    } else {
        stopifnot(all(datasets %in% datasets(x)))
    }
    if (is.null(names(datasets)))
        names(datasets) = datasets

    fun = switch(how, each = .dataset_samples_each,
                  all = .dataset_samples_all,
                  any = .dataset_samples_any)
    fun(hosts(x), datasets)
}

##' get samples of XenaHub object according to by and how action arguments
##'
##' One is often interested in identifying samples or features present in each data set,
##' or shared by all data sets, or present in any of several data sets.
##' Identifying these samples, including samples in arbitrarily chosen data sets.
##' @param x a \code{XenaHub} object
##' @param i a empty character
##' @param by a character specify \code{by} action
##' @param how a character specify \code{how} action
##' @return a list include samples
##' @import methods
##' @export
##' @examples
##' \dontrun{
##' xe = XenaHub(cohorts = "Cancer Cell Line Encyclopedia (CCLE)")
##' # samples in each dataset, first host
##' x = samples(xe, by="datasets", how="each")[[1]]
##' lengths(x)        # data sets in ccle cohort on first (only) host
##' }

samples = function(x, i=character(), by=c("hosts", "cohorts", "datasets"),
                    how=c("each", "any", "all"))
{
    stopifnot(is(x, "XenaHub"), is.character(i))
    by = match.arg(by)
    how = match.arg(how)

    fun = switch(match.arg(by), hosts=.samples_by_host,
           cohorts=.samples_by_cohort, datasets=.samples_by_dataset)
    fun(x, i, how)
}

setMethod("show", "XenaHub", function(object) {
    showsome = function(label, x) {
        len = length(x)
        if (len > 6)
            x = c(head(x, 3), "...", tail(x, 2))
        cat(label, "() (", len, " total):",
            "\n  ", paste0(x, collapse="\n  "),
            "\n", sep="")
    }
    cat("class:", class(object), "\n")
    cat("hosts():",
        "\n  ", paste0(hosts(object), collapse="\n  "),
        "\n", sep="")
    showsome("cohorts", cohorts(object))
    showsome("datasets", datasets(object))
})

