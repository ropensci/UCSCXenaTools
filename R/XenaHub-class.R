##'  @title a S4 class to represent UCSC Xena Data Hubs
##'  @slot hosts hosts of data hubs
##'  @slot cohorts cohorts of data hubs
##'  @slot datasets datasets of data hubs
##'  @importFrom methods new
.XenaHub = setClass(
    "XenaHub",
    representation = representation(
        hosts = "character",
        cohorts = "character",
        datasets = "character"
    )
)


##' @title UCSC Xena Default Hosts
##' @description Return Xena default hosts
##' @return A character vector include current defalut hosts
##' @author Shixiang Wang <w_shixiang@163.com>
##' @seealso [UCSCXenaTools::XenaHub()]
##' @export
xena_default_hosts = function() {
    c(
        "https://ucscpublic.xenahubs.net",
        "https://tcga.xenahubs.net",
        "https://gdc.xenahubs.net",
        "https://icgc.xenahubs.net",
        "https://toil.xenahubs.net",
        "https://pancanatlas.xenahubs.net",
        "https://xena.treehouse.gi.ucsc.edu",
        "https://pcawg.xenahubs.net",
        "https://atacseq.xenahubs.net",
        "https://singlecell.xenahubs.net"
    )
}

.xena_hosts = c(
    "publicHub",
    "tcgaHub",
    "gdcHub",
    "icgcHub",
    "toilHub",
    "pancanAtlasHub",
    "treehouseHub",
    "pcawgHub",
    "atacseqHub",
    "singlecellHub"
)
names(.xena_hosts) = xena_default_hosts()


##' Generate a XenaHub Object
##'
##' It is used to generate original
##' `XenaHub` object according to hosts, cohorts, datasets or hostName.
##' If these arguments not specified, all hosts and corresponding datasets
##' will be returned as a `XenaHub` object. All datasets can be found
##' at <https://xenabrowser.net/datapages/>.
##'
##'
##' @param hosts a character vector specify UCSC Xena hosts, all available hosts can be
##' found by `xena_default_hosts()` function. `hostName` is a more recommend option.
##' @param cohorts default is empty character vector, all cohorts will be returned.
##' @param datasets default is empty character vector, all datasets will be returned.
##' @param hostName name of host, available options can be accessed by `.xena_hosts`
##'  This is an easier option for user than `hosts` option. Note, this option
##'  will overlap `hosts`.
##' @return a [XenaHub] object
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @importFrom httr stop_for_status POST content
##' @importFrom utils head tail
##' @import methods
##' @examples
##' \donttest{
##' #1 query all hosts, cohorts and datasets
##' xe = XenaHub()
##' xe
##' #2 query only TCGA hosts
##' xe = XenaHub(hostName = "tcgaHub")
##' xe
##' hosts(xe)     # get hosts
##' cohorts(xe)   # get cohorts
##' datasets(xe)  # get datasets
##' samples(xe)   # get samples
##' }
XenaHub = function(hosts = xena_default_hosts(),
                   cohorts = character(),
                   datasets = character(),
                   hostName = c(
                       "publicHub",
                       "tcgaHub",
                       "gdcHub",
                       "icgcHub",
                       "toilHub",
                       "pancanAtlasHub",
                       "treehouseHub",
                       "pcawgHub",
                       "atacseqHub",
                       "singlecellHub"
                   )) {
    stopifnot(is.character(hosts),
              is.character(cohorts),
              is.character(datasets))

    hostName = unique(hostName)

    if (length(hostName) != length(.xena_hosts) &
        all(
            hostName %in% .xena_hosts
        )) {
        .temp = names(.xena_hosts)
        names(.temp) = .xena_hosts
        hostNames = .temp %>% as.data.frame() %>% t() %>% as.data.frame()
        rm(.temp)

        hosts = as.character(hostNames[, hostName])
    }

    if (is.null(names(hosts)))
        names(hosts) = hosts

    hosts0 = hosts
    hosts = Filter(.host_is_alive, hosts)
    if (length(hosts) == 0L)
        stop("\n  no hosts responding:",
             "\n    ",
             paste0(hosts0, collapse = "\n  "))

    all_cohorts = unlist(.host_cohorts(hosts), use.names = FALSE)
    if (length(cohorts) == 0L) {
        cohorts = all_cohorts
    } else {
        hosts = hosts[.cohort_datasets_count(hosts, cohorts) != 0L]
    }

    all_datasets = unlist(.cohort_datasets(hosts, cohorts),
                          use.names = FALSE)
    if (length(datasets) == 0L) {
        datasets = all_datasets
    } else{
        if (!all(datasets %in% all_datasets)) {
            bad_dataset = datasets[!datasets %in% all_datasets]
            message("Following datasets are not in datasets of hosts, ignore them...")
            message(bad_dataset)
        }
        datasets = all_datasets[all_datasets %in% datasets]
    }


    .XenaHub(hosts = hosts,
             cohorts = cohorts,
             datasets = datasets)
}

##' Get or Update Newest Data Information of UCSC Xena Data Hubs
##' @param saveTolocal logical. Whether save to local R package data directory for permanent use
##' or Not.
##' @return a `data.frame` contains all datasets information of Xena.
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
XenaDataUpdate = function(saveTolocal = TRUE) {
    hosts = xena_default_hosts()
    XenaList = sapply(hosts, function(x) {
        onehost_cohorts = unlist(.host_cohorts(x), use.names = FALSE)
        sapply(onehost_cohorts, function(y) {
            onecohort_datasets = unlist(.cohort_datasets(x, y))
        })
    })

    # check XenaList, the structure of Truehouse differ from others, is a matrix
    for (i in 1:length(XenaList)) {
        if (!is.list(XenaList[[i]])) {
            x = XenaList[[i]]
            Tolist = lapply(seq_len(ncol(x)), function(i)
                x[, i])
            names(Tolist) = colnames(x)
            XenaList[[i]] = Tolist
        }
    }

    resDF = data.frame(stringsAsFactors = FALSE)
    for (i in 1:length(XenaList)) {
        hostNames = names(XenaList)[i]
        cohortNames = names(XenaList[[i]])
        res = data.frame(stringsAsFactors = FALSE)

        for (j in 1:length(cohortNames)) {
            oneCohort = XenaList[[i]][j]
            # The unassigned cohorts have NULL data, remove it
            if (names(oneCohort) != "(unassigned)") {
                resCohort = data.frame(
                    XenaCohorts = names(oneCohort),
                    XenaDatasets = as.character(oneCohort[[1]]),
                    stringsAsFactors = FALSE
                )
                res = rbind(res, resCohort)
            }
        }
        res$XenaHosts = hostNames
        resDF = rbind(resDF, res)
    }

    XenaHostNames = .xena_hosts

    resDF$XenaHostNames = XenaHostNames[resDF$XenaHosts]
    XenaData = resDF[, c("XenaHosts",
                         "XenaHostNames",
                         "XenaCohorts",
                         "XenaDatasets")]
    if (saveTolocal) {
        data_dir = base::system.file("data", package = "UCSCXenaTools")
        if (dir.exists(data_dir)) {
            save(XenaData, file = file.path(data_dir, "XenaData.rda"))
        } else{
            message("There is no data directory ", data_dir)
            message("Please check it.")
        }
    }
    XenaData
}


##' Filter a XenaHub Object
##'
##' One of main functions in **UCSCXenatools**. It is used to filter
##' `XenaHub` object according to cohorts, datasets. All datasets can be found
##' at <https://xenabrowser.net/datapages/>.
##'
##' @param x a [XenaHub] object
##' @param filterCohorts default is `NULL`. A character used to filter cohorts,
##' regular expression is supported.
##' @param filterDatasets default is `NULL`. A character used to filter datasets,
##' regular expression is supported.
##' @param ignore.case if `FALSE`, the pattern matching is case sensitive
##' and if `TRUE`, case is ignored during matching.
##' @param ... other arguments except `value` passed to [base::grep()].
##' @return a `XenaHub` object
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @examples
##' # operate TCGA datasets
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' xe
##' # get all names of clinical data
##' xe2 = XenaFilter(xe, filterDatasets = "clinical")
##' datasets(xe2)
XenaFilter = function(x,
                      filterCohorts = NULL,
                      filterDatasets = NULL,
                      ignore.case = TRUE, ...) {
    if (is.null(filterCohorts) & is.null(filterDatasets)) {
        message("No operation for input, do nothing...")
    }

    cohorts_select = character()
    datasets_select = character()

    # suppress binding notes
    XenaHosts = XenaCohorts = XenaDatasets = NULL

    if (!is.null(filterCohorts)) {
        cohorts_select = grep(
            pattern = filterCohorts,
            x@cohorts,
            ignore.case = ignore.case,
            value = TRUE,
            ...
        )
    }

    if (!is.null(filterDatasets)) {
        datasets_select = grep(
            pattern = filterDatasets,
            x@datasets,
            ignore.case = ignore.case,
            value = TRUE,
            ...
        )
    }

    if (identical(cohorts_select, character()) &
        identical(datasets_select, character())) {
        warning("No valid cohorts or datasets find! Please check your input.")
    } else{
        if (identical(cohorts_select, character()) &
            !identical(datasets_select, character())) {
            UCSCXenaTools::XenaGenerate(subset = XenaHosts %in% x@hosts &
                                            XenaDatasets %in% datasets_select)
        } else{
            if (!identical(cohorts_select, character()) &
                identical(datasets_select, character())) {
                UCSCXenaTools::XenaGenerate(subset = XenaHosts %in% x@hosts &
                                                XenaCohorts %in% cohorts_select)
            } else{
                UCSCXenaTools::XenaGenerate(
                    subset = XenaHosts %in% x@hosts &
                        XenaCohorts %in% cohorts_select &
                        XenaDatasets %in% datasets_select
                )
            }
        }
    }
}

##' Get hosts of XenaHub object
##' @param x a [XenaHub] object
##' @import methods
##' @return a character vector contains hosts
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "tcgaHub"); hosts(xe)
hosts = function(x)
    unname(slot(x, "hosts"))
##' Get cohorts of XenaHub object
##' @param x a [XenaHub] object
##' @return a character vector contains cohorts
##' @import methods
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "tcgaHub"); cohorts(xe)
cohorts = function(x)
    slot(x, "cohorts")
##' Get datasets of XenaHub object
##' @param x a [XenaHub] object
##' @return a character vector contains datasets
##' @import methods
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "tcgaHub"); datasets(xe)
datasets = function(x)
    slot(x, "datasets")

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
    switch(
        how,
        each = x,
        any = unique(unlist(x, use.names = FALSE)),
        all = Reduce(function(x, y)
            x[x %in% y], x)
    )
}

.samples_by_cohort = function(x, cohorts, how) {
    if (length(cohorts) == 0L) {
        cohorts = cohorts(x)
    } else {
        stopifnot(all(cohorts %in% cohorts(x)))
    }
    if (is.null(names(cohorts)))
        names(cohorts) = cohorts

    fun = switch(how,
                 each = .cohort_samples_each,
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

    fun = switch(how,
                 each = .dataset_samples_each,
                 all = .dataset_samples_all,
                 any = .dataset_samples_any)
    fun(hosts(x), datasets)
}

##' Get Samples of a XenaHub object according to 'by' and 'how' action arguments
##'
##' One is often interested in identifying samples or features present in each data set,
##' or shared by all data sets, or present in any of several data sets.
##' Identifying these samples, including samples in arbitrarily chosen data sets.
##' @param x a [XenaHub] object
##' @param i default is a empty character, it is used to specify
##' the host, cohort or dataset by `by` option otherwise
##' info will be automatically extracted by code
##' @param by a character specify `by` action
##' @param how a character specify `how` action
##' @return a list include samples
##' @import methods
##' @export
##' @examples
##' \donttest{
##' xe = XenaHub(cohorts = "Cancer Cell Line Encyclopedia (CCLE)")
##' # samples in each dataset, first host
##' x = samples(xe, by="datasets", how="each")[[1]]
##' lengths(x)        # data sets in ccle cohort on first (only) host
##' }

samples = function(x,
                   i = character(),
                   by = c("hosts", "cohorts", "datasets"),
                   how = c("each", "any", "all"))
{
    stopifnot(is(x, "XenaHub"), is.character(i))
    by = match.arg(by)
    how = match.arg(how)

    fun = switch(
        match.arg(by),
        hosts = .samples_by_host,
        cohorts = .samples_by_cohort,
        datasets = .samples_by_dataset
    )
    fun(x, i, how)
}

setMethod("show", "XenaHub", function(object) {
    showsome = function(label, x) {
        len = length(x)
        if (len > 6)
            x = c(head(x, 3), "...", tail(x, 2))
        cat(label,
            "() (",
            len,
            " total):",
            "\n  ",
            paste0(x, collapse = "\n  "),
            "\n",
            sep = "")
    }
    cat("class:", class(object), "\n")
    cat("hosts():",
        "\n  ", paste0(hosts(object), collapse = "\n  "),
        "\n", sep = "")
    showsome("cohorts", cohorts(object))
    showsome("datasets", datasets(object))
})
