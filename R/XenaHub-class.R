.XenaHub <- setClass("XenaHub", 
    representation=representation(hosts="character", cohorts="character",
      datasets="character"))

xena_default_hosts <- function() {
    c("https://genome-cancer.soe.ucsc.edu/proj/public/xena",
      "http://localhost:7222")
}

XenaHub <-
    function(hosts=xena_default_hosts(), cohorts=character(),
             datasets=character())
{
    stopifnot(is.character(hosts), is.character(cohorts),
              is.character(datasets))
    if (is.null(names(hosts)))
        names(hosts) <- hosts
    
    hosts0 <- hosts
    hosts <- Filter(.host_is_alive, hosts)
    if (length(hosts) == 0L)
        stop("\n  no hosts responding:",
             "\n    ", paste0(hosts0, collapse="\n  "))

    if (length(cohorts) == 0L) {
        cohorts <- unlist(.host_cohorts(hosts), use.names=FALSE)
    } else {
        hosts <- hosts[.cohort_datasets_count(hosts, cohorts) != 0L]
    }

    if (length(datasets) == 0L)
        datasets <- unlist(.cohort_datasets(hosts, cohorts),
                           use.names=FALSE)

    .XenaHub(hosts=hosts, cohorts=cohorts, datasets=datasets)
}

hosts <- function(x) unname(slot(x, "hosts"))

cohorts <- function(x) slot(x, "cohorts")

datasets <- function(x) slot(x, "datasets")

.samples_by_host <- function(x, hosts, how) {
    if (length(hosts) == 0L) {
        hosts <- hosts(x)
    } else {
        stopifnot(all(hosts %in% hosts(x)))
    }
    if (is.null(names(hosts)))
        names(hosts) <- hosts

    cohorts <- cohorts(x)
    if (is.null(names(cohorts)))
        names(cohorts) <- cohorts
    x <- .cohort_samples_any(hosts, cohorts)
    switch(how,
           each=x,
           any=unique(unlist(x, use.names=FALSE)),
           all=Reduce(function(x, y) x[x %in% y], x))
}

.samples_by_cohort <- function(x, cohorts, how) {
    if (length(cohorts) == 0L) {
        cohorts <- cohorts(x)
    } else {
        stopifnot(all(cohorts %in% cohorts(x)))
    }
    if (is.null(names(cohorts)))
        names(cohorts) <- cohorts

    fun <- switch(how, each = .cohort_samples_each,
                  all = .cohort_samples_all,
                  any = .cohort_samples_any)
    fun(hosts(x), cohorts)
}

.samples_by_dataset <- function(x, datasets, how) {
    if (length(datasets) == 0L) {
        datasets <- datasets(x)
    } else {
        stopifnot(all(datasets %in% datasets(x)))
    }
    if (is.null(names(datasets)))
        names(datasets) <- datasets

    fun <- switch(how, each = .dataset_samples_each,
                  all = .dataset_samples_all,
                  any = .dataset_samples_any)
    fun(hosts(x), datasets)
}

samples <- function(x, i=character(), by=c("hosts", "cohorts", "datasets"),
                    how=c("each", "any", "all"))
{
    stopifnot(is(x, "XenaHub"), is.character(i))
    by <- match.arg(by)
    how <- match.arg(how)

    fun = switch(match.arg(by), hosts=.samples_by_host,
           cohorts=.samples_by_cohort, datasets=.samples_by_dataset)
    fun(x, i, how)
}

setMethod("show", "XenaHub", function(object) {
    showsome <- function(label, x) {
        len <- length(x)
        if (len > 6)
            x <- c(head(x, 3), "...", tail(x, 2))
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

