#FUN: XenaHub (download) workflow

##' Generate and Subset a XenaHub Object from 'XenaData'
##'
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param XenaData a `data.frame`. Default is `data(XenaData)`.
##' The input of this option can only be `data(XenaData)` or its subset.
##' @param subset logical expression indicating elements or rows to keep.
##' @return a [XenaHub] object.
##' @export
##' @examples
##' # 1 get all datasets
##' XenaGenerate()
##' # 2 get TCGA BRCA
##' XenaGenerate(subset = XenaCohorts == "TCGA Breast Cancer (BRCA)")
##' # 3 get all datasets containing BRCA
##' XenaGenerate(subset = grepl("BRCA", XenaCohorts))

XenaGenerate = function(XenaData = UCSCXenaTools::XenaData,
                        subset = TRUE) {
    enclos = parent.frame()
    subset = substitute(subset)
    row_selector = eval(subset, XenaData, enclos)
    XenaData = XenaData[row_selector,]

    .XenaHub(
        hosts = unique(XenaData$XenaHosts),
        cohorts = unique(XenaData$XenaCohorts),
        datasets = XenaData$XenaDatasets
    )
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


##' Query URL of Datasets before Downloading
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param x a [XenaHub] object
##' @return a `data.frame` contains hosts, datasets and url
##' @importFrom dplyr filter select pull rename mutate
##' @export
##' @examples
##' \donttest{
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' hosts(xe)
##' xe_query = XenaQuery(xe)
##' }
XenaQuery = function(x) {
    message("This will check url status, please be patient.")
    datasetsName = datasets(x)
    query = UCSCXenaTools::XenaData %>%
        dplyr::filter(XenaDatasets %in% datasetsName) %>%
        dplyr::rename(hosts = XenaHosts, datasets = XenaDatasets) %>%
        dplyr::mutate(url = file.path(hosts, "download", datasets)) %>%
        dplyr::mutate(url = ifelse(!sapply(url, httr::http_error),
                                    url, paste0(url, ".gz"))) %>%
        dplyr::select(hosts, datasets, url) %>%
        as.data.frame()

    invisible(query)
}

##' Query ProbeMap URL of Datasets
##'
##' If dataset has no ProbeMap, it will be ignored.
##'
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param x a [XenaHub] object
##' @return a `data.frame` contains hosts, datasets and url
##' @importFrom dplyr filter select pull rename mutate
##' @export
##' @examples
##' \donttest{
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' hosts(xe)
##' xe_query = XenaQueryProbeMap(xe)
##' }
XenaQueryProbeMap = function(x) {
    message("Check ProbeMap urls of datasets.")
    datasetsName = datasets(x)
    query = UCSCXenaTools::XenaData %>%
        dplyr::filter((XenaDatasets %in% datasetsName) & (!is.na(ProbeMap)))

    if (nrow(query) == 0) {
        invisible(data.frame(stringsAsFactors = FALSE))
    } else {
        query = query %>%
            dplyr::rename(hosts = XenaHosts, datasets = ProbeMap) %>%
            dplyr::mutate(url = file.path(hosts, "download", datasets)) %>%
            dplyr::mutate(url = ifelse(!sapply(url, httr::http_error),
                                       url, paste0(url, ".gz"))) %>%
            dplyr::select(hosts, datasets, url) %>%
            as.data.frame()

        invisible(unique(query))
    }
}

##' Download Datasets from UCSC Xena Hubs
##'
##' Avaliable datasets list: <https://xenabrowser.net/datapages/>
##'
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param xquery a tibble object generated by [XenaQuery] function.
##' @param destdir specify a location to store download data. Default is system temp directory.
##' @param download_probeMap if `TRUE`, also download ProbeMap data, which used for id mapping.
##' @param trans_slash logical, default is `FALSE`. If `TRUE`, transform slash '/' in dataset id
##' to '__'. This option is for backwards compatibility.
##' @param force logical. if `TRUE`, force to download data no matter whether files exist.
##'  Default is `FALSE`.
##' @param ... other argument to `download.file` function
##' @return a `tibble`
##' @export
##' @importFrom utils download.file
##' @importFrom dplyr filter
##' @examples
##' \donttest{
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' hosts(xe)
##' xe_query = XenaQuery(xe)
##' xe_download = XenaDownload(xe_query)
##' }

XenaDownload = function(xquery,
                        destdir = tempdir(),
                        download_probeMap = FALSE,
                        trans_slash = FALSE,
                        force = FALSE,
                        ...) {
    stopifnot(is.data.frame(xquery), c("url") %in% names(xquery), is.logical(download_probeMap))

    if (download_probeMap) {
        xquery_probe = UCSCXenaTools::XenaData %>%
            dplyr::filter(XenaDatasets %in% xquery$datasets) %>%
            XenaGenerate() %>%
            XenaQueryProbeMap()
        xquery = rbind(xquery, xquery_probe)
    }

    if (trans_slash) {
        xquery$fileNames = gsub(pattern = "/",
                                replacement = "__",
                                x = xquery$datasets)
    } else {
        xquery$fileNames = xquery$datasets
    }

    xquery$fileNames = ifelse(grepl("\\.gz", xquery$url),
                              paste0(xquery$fileNames, ".gz"),
                              xquery$fileNames)
    #destdir = paste0(destdir,"/")
    xquery$destfiles = file.path(destdir, xquery$fileNames)

    if (!dir.exists(destdir)) {
        dir.create(destdir, recursive = TRUE)
    }

    message("All downloaded files will under directory ", destdir, ".")
    if (!trans_slash) {
        dir_names = dirname(xquery$destfiles)
        message("The 'trans_slash' option is FALSE, keep same directory structure as Xena.")
        message("Creating directories for datasets...")
        for (i in dir_names) {
            dir.create(i, recursive = TRUE)
        }
    }

    apply(xquery, 1, function(x) {
        tryCatch({
            if (!file.exists(x[5]) | force) {
                message("Downloading ", x[4])
                download.file(x[3], destfile = x[5], ...)
            } else{
                message(x[5], ", the file has been download!")
            }
        }, error = function(e) {
            message("Can not find file",
                    x[4],
                    ", this file maybe not compressed.")
            x[3] = gsub(pattern = "\\.gz$", "", x[3])
            x[4] = gsub(pattern = "\\.gz$", "", x[4])
            x[5] = gsub(pattern = "\\.gz$", "", x[5])
            message("Try downloading file", x[4], "...")
            download.file(x[3], destfile = x[5], ...)
        })

    })

    if (trans_slash) {
        message(
            "Note file names inherit from names in datasets column\n  and '/' all changed to '__'."
        )
    }

    invisible(xquery)
}


##' Prepare (Load) Downloaded Datasets to R
##'
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param objects a object of character vector or data.frame. If `objects` is data.frame,
##' it should be returned object of [XenaDownload] function. More easier way is
##' that objects can be character vector specify local files/directory and download urls.
##' @param objectsName specify names for elements of return object, i.e. names of list
##' @param use_chunk default is `FALSE`. If you want to select subset of original data, please set it to
##' `TRUE` and specify corresponding arguments: `chunk_size`, `select_direction`, `select_names`,
##' `callback`.
##' @param chunk_size the number of rows to include in each chunk
##' @param subset_rows logical expression indicating elements or rows to keep:
##' missing values are taken as false. `x` can be a representation of data frame
##' you wanna do subset operation. Of note, the first colname of most of datasets
##' in Xena will be set to "sample", you can use it to select rows.
##' @param select_cols expression, indicating columns to select from a data frame.
##' 'x' can be a representation of data frame you wanna do subset operation,
##' e.g. `select_cols = colnames(x)[1:3]` will keep only first to third column.
##' @param callback a function to call on each chunk, default is `NULL`,
##' this option will overvide operations of subset_rows and select_cols.
##' @param comment a character specify comment rows in files
##' @param na a character vectory specify `NA` values in files
##' @param ... other arguments transfer to `read_tsv` function or
##' `read_tsv_chunked` function (when `use_chunk` is `TRUE`) of `readr` package.
##' @return a list contains file data, which in way of tibbles
##' @export
##' @importFrom readr read_tsv
##' @importFrom readr read_tsv_chunked
##' @importFrom readr cols
##' @examples
##' \donttest{
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' hosts(xe)
##' xe_query = XenaQuery(xe)
##'
##' xe_download = XenaDownload(xe_query)
##' dat = XenaPrepare(xe_download)
##' }

XenaPrepare = function(objects,
                       objectsName = NULL,
                       use_chunk = FALSE,
                       chunk_size = 100,
                       subset_rows = TRUE,
                       select_cols = TRUE,
                       callback = NULL,
                       comment = "#",
                       na = c("", "NA", "[Discrepancy]"),
                       ...) {
    # objects can be url, local files/directory or xena object from xena download process
    stopifnot(is.character(objects) |
                  is.data.frame(objects),
              is.logical(use_chunk))

    subset_rows = substitute(subset_rows)
    select_cols = substitute(select_cols)
    #    subset_direction = match.arg(subset_direction)

    objects2 = objects

    if (is.character(objects)) {
        if (length(objects) == 0)
            stop("Please check you input!")

        # the input are directory?
        if (all(dir.exists(objects)) & !all(file.exists(objects))) {
            if (length(objects) > 1) {
                stop("We do not accept multiple directories as input.")
            } else{
                files = paste0(objects, "/", dir(objects))
                res = lapply(files, function(x) {
                    if (use_chunk) {
                        if (is.null(callback)) {
                            f = function(x, pos) {
                                subset(x,
                                       eval(subset_rows),
                                       select = eval(select_cols))
                            }

                        } else {
                            f = callback
                        }

                        y = readr::read_tsv_chunked(
                            x,
                            readr::DataFrameCallback$new(f),
                            chunk_size = chunk_size,
                            comment = comment,
                            na = na,
                            col_types = readr::cols()
                        )
                    } else {
                        y = readr::read_tsv(
                            x,
                            comment = comment,
                            na = na,
                            col_types = readr::cols(),
                            ...
                        )
                    }

                    y
                })
                if (is.null(objectsName)) {
                    objectsName = make.names(dir(objects))
                    names(res) = objectsName
                }
            }

        } else if (all(file.exists(objects))) {
            res = lapply(objects, function(x) {
                if (use_chunk) {
                    if (is.null(eval(callback))) {
                        f = function(x, pos) {
                            subset(x,
                                   eval(subset_rows),
                                   select = eval(select_cols))
                        }

                    } else {
                        f = callback
                    }

                    y = readr::read_tsv_chunked(
                        x,
                        readr::DataFrameCallback$new(f),
                        chunk_size = chunk_size,
                        comment = comment,
                        na = na,
                        col_types = readr::cols()
                    )
                } else {
                    y = readr::read_tsv(
                        x,
                        comment = comment,
                        na = na,
                        col_types = readr::cols(),
                        ...
                    )
                }

                y
            })
            if (is.null(objectsName)) {
                objectsName = make.names(basename(objects))
                names(res) = objectsName
            }
            if (length(res) == 1) {
                res = res[[1]]
            }
        }
        else{
            # check urls
            all_right = grepl(pattern = "http", x = objects)

            if (any(all_right)) {
                objects = objects[all_right]
                if (length(objects) == 1) {
                    if (use_chunk) {
                        if (is.null(callback)) {
                            f = function(x, pos) {
                                subset(x,
                                       eval(subset_rows),
                                       select = eval(select_cols))
                            }

                        } else {
                            f = callback
                        }

                        res = readr::read_tsv_chunked(
                            objects,
                            readr::DataFrameCallback$new(f),
                            chunk_size = chunk_size,
                            comment = comment,
                            na = na,
                            col_types = readr::cols()
                        )
                    } else {
                        res = readr::read_tsv(
                            objects,
                            comment = comment,
                            na = na,
                            col_types = readr::cols(),
                            ...
                        )
                    }

                    #res = suppressMessages(read_tsv(objects, comment=comment, na=na, ...))
                } else{
                    res = lapply(objects, function(x) {
                        if (use_chunk) {
                            if (is.null(callback)) {
                                f = function(x, pos) {
                                    subset(x,
                                           eval(subset_rows),
                                           select = eval(select_cols))
                                }

                            } else {
                                f = callback
                            }

                            y = readr::read_tsv_chunked(
                                x,
                                readr::DataFrameCallback$new(f),
                                chunk_size = chunk_size,
                                comment = comment,
                                na = na,
                                col_types = readr::cols()
                            )
                        } else {
                            y = readr::read_tsv(
                                x,
                                comment = comment,
                                na = na,
                                col_types = readr::cols(),
                                ...
                            )
                        }

                        y

                    })

                    # use for loop
                    # res = list()
                    # i = 1
                    # for (x in objects){
                    #     res[[i]] = read_tsv(x, comment=comment, ...)
                    #     i = i + 1
                    # }

                    if (is.null(objectsName)) {
                        objectsName = make.names(basename(objects))
                        names(res) = objectsName
                    }
                }
            }
            all_wrong = !all_right
            if (any(all_wrong)) {
                bad_urls = objects2[all_wrong]
                message("Some inputs are wrong, maybe you should check:")
                print(bad_urls)
            }
        }
    } else{
        if (!"destfiles" %in% colnames(objects)) {
            stop(
                "Input data.frame should contain 'destfiles' column which generated by XenaDownload functions. Please check your input."
            )
        }

        files = objects$destfiles
        res = XenaPrepare(
            files,
            objectsName = objectsName,
            use_chunk = use_chunk,
            chunk_size = chunk_size,
            subset_rows = subset_rows,
            select_cols = select_cols,
            callback = callback,
            comment = comment,
            na = na,
            ...
        )
    }

    return(res)
}


#' View One Dataset or Cohort Using Web browser
#'
#' This will open dataset/cohort link of UCSC Xena
#' in user's default browser.
#' @param x a [XenaHub] object.
#' @param type one of "dataset" and "cohort".
#' @param multiple if `TRUE`, browse multiple links instead of throwing error.
#' @importFrom utils URLencode browseURL
#' @export
#'
#' @examples
#' \donttest{
#' XenaGenerate(subset = XenaHostNames=="tcgaHub") %>%
#'   XenaFilter(filterDatasets = "clinical") %>%
#'   XenaFilter(filterDatasets = "LUAD") -> to_browse
#'
#' }
XenaBrowse = function(x, type = c("dataset", "cohort"), multiple=FALSE) {
    if (!inherits(x, "XenaHub")) {
        stop("Input x must be a XenaHub object.")
    }

    type = match.arg(type)

    if (type == "dataset") {
        all_datasets = datasets(x)
        if (length(all_datasets) != 1) {
            if (!multiple) stop("This function limite 1 dataset to browse.\n Set multiple to TRUE if you want to browse multiple links.")
            for (i in all_datasets) {
                xe_tmp = XenaFilter(x, filterDatasets = i,
                                    ignore.case = FALSE, fixed=TRUE)
                y=utils::URLencode(
                    paste0("https://xenabrowser.net/datapages/?",
                           "dataset=", datasets(xe_tmp),
                           "&host=", hosts(xe_tmp)))
                utils::browseURL(y)
            }
        } else {
            y=utils::URLencode(
                paste0("https://xenabrowser.net/datapages/?",
                       "dataset=", datasets(x),
                       "&host=", hosts(x)))
            utils::browseURL(y)
        }
    } else {
        all_cohorts = cohorts(x)
        if (length(all_cohorts) != 1) {
            if (!multiple) stop("This function limite 1 cohort to browse. \n Set multiple to TRUE if you want to browse multiple links.")
            for (i in all_cohorts) {
                xe_tmp = XenaFilter(x, filterCohorts = i,
                                    ignore.case = FALSE, fixed=TRUE)
                y=utils::URLencode(
                    paste0("https://xenabrowser.net/datapages/?",
                           "cohort=", cohorts(xe_tmp)))
                utils::browseURL(y)
            }
        } else {
            y=utils::URLencode(
                paste0("https://xenabrowser.net/datapages/?",
                       "cohort=", cohorts(x)))
            utils::browseURL(y)
        }

    }

    invisible(NULL)
}

utils::globalVariables(c("XenaDatasets", "XenaHosts", "ProbeMap"))
