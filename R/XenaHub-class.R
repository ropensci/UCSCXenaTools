# FUN: Set Class & operate XenaHub object directly

##' Class XenaHub
##' @description  a S4 class to represent UCSC Xena Data Hubs
##' @slot hosts hosts of data hubs
##' @slot cohorts cohorts of data hubs
##' @slot datasets datasets of data hubs
##' @importFrom methods new
##' @export
.XenaHub <- setClass(
  "XenaHub",
  representation = representation(
    hosts = "character",
    cohorts = "character",
    datasets = "character"
  )
)

setMethod("show", "XenaHub", function(object) {
  showsome <- function(label, x) {
    len <- length(x)
    if (len > 6) {
      x <- c(head(x, 3), "...", tail(x, 2))
    }
    cat(label,
      "() (",
      len,
      " total):",
      "\n  ",
      paste0(x, collapse = "\n  "),
      "\n",
      sep = ""
    )
  }
  cat("class:", class(object), "\n")
  cat("hosts():",
    "\n  ", paste0(hosts(object), collapse = "\n  "),
    "\n",
    sep = ""
  )
  showsome("cohorts", cohorts(object))
  showsome("datasets", datasets(object))
})


##' @title UCSC Xena Default Hosts
##' @description Return Xena default hosts
##' @return A character vector include current defalut hosts
##' @author Shixiang Wang <w_shixiang@163.com>
##' @seealso [UCSCXenaTools::XenaHub()]
##' @export
xena_default_hosts <- function() {
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

.xena_hosts <- c(
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
names(.xena_hosts) <- xena_default_hosts()


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
XenaHub <- function(hosts = xena_default_hosts(),
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
  stopifnot(
    is.character(hosts),
    is.character(cohorts),
    is.character(datasets)
  )

  hostName <- unique(hostName)

  if (length(hostName) != length(.xena_hosts) &
    all(
      hostName %in% .xena_hosts
    )) {
    .temp <- names(.xena_hosts)
    names(.temp) <- .xena_hosts
    hostNames <- .temp %>%
      as.data.frame() %>%
      t() %>%
      as.data.frame()
    rm(.temp)

    hosts <- as.character(hostNames[, hostName])
  } else if (!all(hostName %in% .xena_hosts)) {
    stop("Bad hostName, please check")
  }

  if (is.null(names(hosts))) {
    names(hosts) <- hosts
  }

  hosts0 <- hosts
  hosts <- Filter(.host_is_alive, hosts)
  if (length(hosts) == 0L) { # nocov start
    stop(
      "\n  no hosts responding:",
      "\n    ",
      paste0(hosts0, collapse = "\n  ")
    )
  } # nocov end

  all_cohorts <- unlist(.host_cohorts(hosts), use.names = FALSE)
  if (length(cohorts) == 0L) {
    cohorts <- all_cohorts
  } else {
    hosts <- hosts[.cohort_datasets_count(hosts, cohorts) != 0L]
  }

  all_datasets <- unlist(.cohort_datasets(hosts, cohorts),
    use.names = FALSE
  )
  if (length(datasets) == 0L) {
    datasets <- all_datasets
  } else {
    if (!all(datasets %in% all_datasets)) { # nocov start
      bad_dataset <- datasets[!datasets %in% all_datasets]
      message("Following datasets are not in datasets of hosts, ignore them...")
      message(bad_dataset)
    } # nocov end
    datasets <- all_datasets[all_datasets %in% datasets]
  }


  .XenaHub(
    hosts = hosts,
    cohorts = cohorts,
    datasets = datasets
  )
}

##' Get or Update Newest Data Information of UCSC Xena Data Hubs
##' @param saveTolocal logical. Whether save to local R package data directory for permanent use
##' or Not.
##' @return a `data.frame` contains all datasets information of Xena.
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
XenaDataUpdate <- function(saveTolocal = TRUE) { # nocov start
  hosts <- xena_default_hosts()
  XenaList <- sapply(hosts, function(x) {
    onehost_cohorts <- unlist(.host_cohorts(x), use.names = FALSE)
    sapply(onehost_cohorts, function(y) {
      onecohort_datasets <- unlist(.cohort_datasets(x, y))
    })
  })

  # check XenaList, the structure of Truehouse differ from others, is a matrix
  for (i in 1:length(XenaList)) {
    if (!is.list(XenaList[[i]])) {
      x <- XenaList[[i]]
      Tolist <- lapply(seq_len(ncol(x)), function(i)
        x[, i])
      names(Tolist) <- colnames(x)
      XenaList[[i]] <- Tolist
    }
  }

  resDF <- data.frame(stringsAsFactors = FALSE)
  for (i in 1:length(XenaList)) {
    hostNames <- names(XenaList)[i]
    cohortNames <- names(XenaList[[i]])
    res <- data.frame(stringsAsFactors = FALSE)

    for (j in 1:length(cohortNames)) {
      oneCohort <- XenaList[[i]][j]
      # The unassigned cohorts have NULL data, remove it
      if (names(oneCohort) != "(unassigned)") {
        resCohort <- data.frame(
          XenaCohorts = names(oneCohort),
          XenaDatasets = as.character(oneCohort[[1]]),
          stringsAsFactors = FALSE
        )
        res <- rbind(res, resCohort)
      }
    }
    res$XenaHosts <- hostNames
    resDF <- rbind(resDF, res)
  }

  XenaHostNames <- .xena_hosts

  resDF$XenaHostNames <- XenaHostNames[resDF$XenaHosts]
  XenaData <- resDF[, c(
    "XenaHosts",
    "XenaHostNames",
    "XenaCohorts",
    "XenaDatasets"
  )]

  # .p_dataset_list(hosts(xe), cohorts(xe)) can also obtain
  # metadata for dataset from cohort view
  meta_data <- apply(XenaData, 1, function(x) {
    .p_dataset_metadata(x[1], x[4])
  })
  names(meta_data) <- XenaData[["XenaDatasets"]]

  tidy_data <- lapply(meta_data, function(tt) {
    SampleCount <- tt[["count"]]
    DataSubtype <- tt[["datasubtype"]]
    Type <- tt[["type"]]
    ProbeMap <- tt[["probemap"]]

    j_data <- jsonlite::parse_json(tt[["text"]])
    # decode metadata from json format
    # note json data may have different elements for
    #                different cohort datasets
    # more work need to be done here
    #
    # tt$text contains metadata for dataset
    # tt$pmtext contains metadata for probemap
    LongTitle <- j_data[["longTitle"]]
    Citation <- j_data[["citation"]]
    Label <- j_data[["label"]]
    Tags <- .collapse_list(j_data[["tags"]])
    AnatomicalOrigin <- .collapse_list(j_data[["anatomical_origin"]])
    SampleType <- .collapse_list(j_data[["sample_type"]])
    Version <- j_data[["version"]]
    PrimaryDisease <- j_data[["acute lymphoblastic leukemia"]]
    Platform <- j_data[["platform"]]
    Unit <- j_data[["unit"]]

    res <- c(
      SampleCount = SampleCount,
      DataSubtype = DataSubtype,
      Platform = Platform,
      Unit = Unit,
      Label = Label,
      Type = Type,
      AnatomicalOrigin = AnatomicalOrigin,
      PrimaryDisease = PrimaryDisease,
      SampleType = SampleType,
      Tags = Tags,
      ProbeMap = ProbeMap,
      LongTitle = LongTitle,
      Citation = Citation,
      Version = Version
    )
  })

  # tidy_data2 = do.call(rbind, tidy_data)
  tidy_data2 <- dplyr::rbind_list(tidy_data)
  XenaData <- dplyr::bind_cols(XenaData, tidy_data2)
  XenaData <- dplyr::as_tibble(XenaData)

  if (saveTolocal) {
    data_dir <- base::system.file("data", package = "UCSCXenaTools")
    if (dir.exists(data_dir)) {
      save(XenaData, file = file.path(data_dir, "XenaData.rda"))
    } else {
      message("There is no data directory ", data_dir)
      message("Please check it.")
    }
  }
  XenaData
} # nocov end

.collapse_list <- function(x) {
  sapply(x, function(x) x) %>% paste0(collapse = ",")
}


utils::globalVariables(c(".p_dataset_metadata"))
