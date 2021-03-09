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
    "https://xena.treehouse.gi.ucsc.edu:443",
    "https://pcawg.xenahubs.net",
    "https://atacseq.xenahubs.net",
    "https://singlecellnew.xenahubs.net",
    "https://kidsfirst.xenahubs.net"
    #"https://tdi.xenahubs.net"
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
  "singlecellHub",
  "kidsfirstHub"
  #"tdiHub"
)

names(.xena_hosts) <- xena_default_hosts()

# Add Hiplot mirror url
# Still use UCSC Xena URL if it is not available
.xena_hosts_hiplot <- .xena_hosts
names(.xena_hosts_hiplot) <- c(
  "https://xena-ucscpublic.hiplot.com.cn",
  "https://xena-tcga.hiplot.com.cn",
  "https://xena-gdc.hiplot.com.cn",
  "https://xena-icgc.hiplot.com.cn",
  "https://xena-toil.hiplot.com.cn",
  "https://xena-pancanatlas.hiplot.com.cn",
  "https://xena.treehouse.gi.ucsc.edu:443", #!
  "https://xena-pcawg.hiplot.com.cn",
  "https://xena-atacseq.hiplot.com.cn",
  "https://singlecellnew.xenahubs.net", #!
  "https://kidsfirst.xenahubs.net" #!
  #"https://tdi.xenahubs.net" #!
)
# Map hiplot to ucsc
.xena_mirror_map <- names(.xena_hosts)
names(.xena_mirror_map) <- names(.xena_hosts_hiplot)
# Map ucsc to hiplot
.xena_mirror_map_rv <- names(.xena_hosts_hiplot)
names(.xena_mirror_map_rv) <- names(.xena_hosts)

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
##' @examples
##' \dontrun{
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
                      "singlecellHub",
                      "kidsfirstHub"
                      #"tdiHub"
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
##' @examples
##' \dontrun{
##' XenaDataUpdate()
##' XenaDataUpdate(saveTolocal = TRUE)
##' }
XenaDataUpdate <- function(saveTolocal = TRUE) { # nocov start
  # .p_all_cohorts(list(unique(XenaData$XenaHosts)[10]), exclude = list(NULL))
  # .p_dataset_list(list(XenaData$XenaHosts[1]), list(XenaData$XenaCohorts[1]))
  try_query = function(h, max_try = 3L) {
    Sys.sleep(0.1)
    tryCatch(
      {
        message("==> Trying #", abs(max_try - 4L))
        .p_all_cohorts(list(h), exclude = list(NULL))
      },
      error = function(e) {
        if (max_try == 1) {
          warning("Tried 3 times but failed, this hub may down or please check URL or your internet connection!", immediate. = TRUE)
          return(NULL)
        } else {
          try_query(h, max_try - 1L)
        }
      }
    )
  }

  message("=> Obtaining info from UCSC Xena hubs...")
  XenaInfo <- lapply(names(.xena_hosts), function(h) {
    message("==> Searching cohorts for host ", h, "...")

    chs <- try_query(h, max_try = 3L)
    if (is.null(chs)) {
      return(NULL)
    }
    chs <- setdiff(chs, "(unassigned)")
    message("===> #", length(chs), " cohorts found.")
    message("===> Querying datasets info...")
    zz <- lapply(chs, function(x, h) {
      .p_dataset_list(list(h), list(x))
    }, h = h) %>%
      stats::setNames(chs) %>%
      dplyr::bind_rows(.id = "XenaCohorts")
    message("===> #", nrow(zz), " datasets found.")
    message("==> Done for host ", h, "...")
    zz
  }) %>%
    stats::setNames(names(.xena_hosts)) %>%
    dplyr::bind_rows(.id = "XenaHosts")

  message("=> Done for obtaining.")
  message("=> Parsing datasets metadata...")

  XenaInfo <- XenaInfo %>%
    dplyr::rename(
      XenaDatasets = .data$name,
      SampleCount = .data$count,
      DataSubtype = .data$datasubtype,
      Type = .data$type,
      LongTitle = .data$longtitle,
      ProbeMap = .data$probemap
    ) %>%
    dplyr::mutate(XenaHostNames = .xena_hosts[.data$XenaHosts])

  j_data <- lapply(XenaInfo$text, function(x) {
    # decode metadata from json format
    # note json data may have different elements for
    #                different cohort datasets
    # more work need to be done here
    #
    # tt$text contains metadata for dataset
    # tt$pmtext contains metadata for probemap
    json_df <- jsonlite::parse_json(x)
    dplyr::tibble(
      Citation = json_df[["citation"]] %||% NA,
      Label = json_df[["label"]] %||% NA,
      Tags = .collapse_list(json_df[["tags"]]) %||% NA,
      AnatomicalOrigin = .collapse_list(json_df[["anatomical_origin"]]) %||% NA,
      SampleType = .collapse_list(json_df[["sample_type"]]) %||% NA,
      Version = json_df[["version"]] %||% NA,
      PrimaryDisease = json_df[["primary_disease"]] %||% NA,
      Platform = json_df[["platform"]] %||% NA,
      Unit = json_df[["unit"]] %||% NA
    )
  })

  message("=> Done for parsing. Tidying...")

  tidy_data <- dplyr::bind_rows(j_data)
  XenaData <- dplyr::bind_cols(XenaInfo, tidy_data)
  XenaData <- dplyr::as_tibble(XenaData)

  XenaData <- XenaData %>%
    dplyr::select(
      c(
        "XenaHosts", "XenaHostNames", "XenaCohorts", "XenaDatasets", "SampleCount",
        "DataSubtype", "Label", "Type", "AnatomicalOrigin", "SampleType",
        "Tags", "ProbeMap", "LongTitle", "Citation", "Version",
        "Unit", "Platform"
      )
    )

  message("=> Tidying done.")

  if (saveTolocal) {
    message("=> Saving...")
    data_dir <- base::system.file("data", package = "UCSCXenaTools")
    if (dir.exists(data_dir)) {
      save(XenaData, file = file.path(data_dir, "XenaData.rda"))
    } else {
      message("There is no data directory ", data_dir)
      message("Please check it.")
    }
  }
  message("=> Done.")
  XenaData
} # nocov end

.collapse_list <- function(x) {
  sapply(x, function(x) x) %>% paste0(collapse = ",")
}

`%||%` <- function(x, y) {
  # ifelse(is.null(x), y, x)
  if (is.null(x)) {
    y
  } else {
    x
  }
}

utils::globalVariables(c(
  ".p_dataset_metadata",
  ".p_all_cohorts",
  ".p_dataset_list"
))
