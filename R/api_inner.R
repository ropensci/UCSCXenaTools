# FUN: API inner utilities, queries and functions.

# post --------------------------------------------------------------------

.xena_post <- function(host, query, ...) {
  host <- paste0(host, "/data/")
  res <- POST(host, body = query)
  stop_for_status(res)
  content(res, ...)
}


# utilities ---------------------------------------------------------------

.null_cohort <- "(unassigned)"

.quote <- function(s)
  paste0('"', s, '"')

.quote_cohort <- function(cohort) {
  ifelse(cohort == .null_cohort, "nil", .quote(cohort))
}

.collapse <- function(l, collapse = " ") {
  paste0(.quote(l), collapse = collapse)
}

.collapse_cohort <- function(cohorts, collapse = " ")
  paste0(.quote_cohort(cohorts), collapse = collapse)

.arrayfmt <- function(l, collapse = .collapse) {
  paste0("[", collapse(l), "]")
}



# queries -----------------------------------------------------------------

## hosts

.host_cohorts_query <- function() {
  paste0(
    "(map :cohort\n",
    "  (query\n",
    '    {:select [[#sql/call [:distinct #sql/call [:ifnull :cohort "(unassigned)"]] :cohort]]\n',
    "     :from [:dataset]}))"
  )
}

## cohorts

.cohort_datasets_query <- function(cohorts) {
  paste0(
    "(map :name\n",
    "(query {:select [:name] :from [:dataset]\n",
    ":where [:in :cohort ",
    .arrayfmt(cohorts),
    "]}))\n"
  )
}

.cohort_samples_any_query <- function(cohorts) {
  what <- paste(":cohort", .arrayfmt(cohorts, .collapse_cohort))
  .samples_any_query(what)
}

.cohort_samples_all_query <- function(cohorts) { # nocov start
  what <- .arrayfmt(cohorts, .collapse_cohort)
  .samples_all_query(":cohorts", what, length(cohorts))
} # nocov end

## datasets

.dataset_samples_any_query <- function(datasets) { # nocov start
  what <- paste(":dataset.name", .arrayfmt(datasets))
  .samples_any_query(what)
} # nocov end

.dataset_samples_all_query <- function(datasets) { # nocov start
  what <- .arrayfmt(datasets)
  .samples_all_query(":dataset.name", what, length(datasets))
} # nocov end

## samples

.samples_any_query <- function(what)
  paste0(
    "\n        (map :value\n        (query {\n        :select [:%distinct.value]\n        :from [:dataset]\n        :join [:field [:= :dataset.id :dataset_id]\n        :code [:= :field_id :field.id]]\n        :where [:and\n        [:in ",
    what,
    ']
        [:= :field.name "sampleID"]]
        }))
        '
  )

.samples_all_query <- function(where, what, n) # nocov start
  paste0(
    "\n        (map :value\n        (query {\n        :select [:value] :from [{\n        :select [",
    where,
    " :value]\n        :modifiers [:distinct]\n        :join [:field [:= :dataset.id :dataset_id]\n        :code [:= :field_id :field.id]]\n        :where [:and [:in ",
    where,
    " ",
    what,
    ']
        [:= :field.name "sampleID"]]
        :from [:dataset]
        }]
        :group-by [:value]
        :having [:= :%count.value ',
    n,
    "]\n        }))\n        "
  ) # nocov end


##
## actions
##


# host --------------------------------------------------------------------

.host_is_alive <- function(host) {
  tryCatch({
    result <- .xena_post(host, "(+ 1 2)")
    stop_for_status(result)
    TRUE
  }, error = function(...) {
    FALSE
  })
}

.host_cohorts <- function(hosts) {
  query <- .host_cohorts_query()
  lapply(hosts, function(h) {
    message("Searching ", h)
    sort(unlist(.xena_post(h, query), use.names = FALSE))
  })
}



# cohort ------------------------------------------------------------------

.cohort_datasets <- function(hosts, cohorts) {
  lapply(hosts, .xena_post, .cohort_datasets_query(cohorts))
}

.cohort_datasets_count <- function(hosts, cohorts) {
  query <- paste0(
    "(query {:select [:%count.*]\n",
    ":from [:dataset]\n",
    ":where [:in :cohort",
    .arrayfmt(cohorts),
    "]}))\n"
  )
  unlist(lapply(hosts, .xena_post, query), use.names = FALSE)
}


# cohort samples ----------------------------------------------------------

.cohort_samples_each <- function(hosts, cohorts) { # nocov start
  lapply(hosts, function(h) {
    result <- lapply(cohorts, function(c) {
      .xena_post(h, .cohort_samples_any_query(c), simplifyVector = TRUE)
    })
    Filter(Negate(is.null), result)
  })
} # nocov end

.cohort_samples_any <- function(hosts, cohorts) {
  query <- .cohort_samples_any_query(cohorts)
  lapply(hosts, .xena_post, query, simplifyVector = TRUE)
}

.cohort_samples_all <- function(hosts, cohorts) { # nocov start
  query <- .cohort_samples_all_query(cohorts)
  lapply(hosts, .xena_post, query, simplifyVector = TRUE)
} # nocov end



# dataset samples ---------------------------------------------------------

.dataset_samples_each <- function(hosts, datasets) { # nocov start
  lapply(hosts, function(h) {
    result <- lapply(datasets, function(d) {
      .xena_post(h,
        .dataset_samples_any_query(d),
        simplifyVector = TRUE
      )
    })
    Filter(Negate(is.null), result)
  })
} # nocov end

.dataset_samples_any <- function(hosts, datasets) { # nocov start
  query <- .dataset_samples_any_query(datasets)
  lapply(hosts, .xena_post, query, simplifyVector = TRUE)
} # nocov end

.dataset_samples_all <- function(hosts, datasets) { # nocov start
  query <- .dataset_samples_all_query(datasets)
  lapply(hosts, .xena_post, query, simplifyVector = TRUE)
} # nocov end



# samples by --------------------------------------------------------------

.samples_by_host <- function(x, hosts, how) {
  if (length(hosts) == 0L) {
    hosts <- hosts(x)
  } else {
    stopifnot(all(hosts %in% hosts(x)))
  }
  if (is.null(names(hosts))) {
    names(hosts) <- hosts
  }

  cohorts <- cohorts(x)
  if (is.null(names(cohorts))) {
    names(cohorts) <- cohorts
  }
  x <- .cohort_samples_any(hosts, cohorts)
  switch(
    how,
    each = x,
    any = unique(unlist(x, use.names = FALSE)),
    all = Reduce(function(x, y)
      x[x %in% y], x)
  )
}

.samples_by_cohort <- function(x, cohorts, how) { # nocov start
  if (length(cohorts) == 0L) {
    cohorts <- cohorts(x)
  } else {
    stopifnot(all(cohorts %in% cohorts(x)))
  }
  if (is.null(names(cohorts))) {
    names(cohorts) <- cohorts
  }

  fun <- switch(how,
    each = .cohort_samples_each,
    all = .cohort_samples_all,
    any = .cohort_samples_any
  )
  fun(hosts(x), cohorts)
} # nocov end

.samples_by_dataset <- function(x, datasets, how) { # nocov start
  if (length(datasets) == 0L) {
    datasets <- datasets(x)
  } else {
    stopifnot(all(datasets %in% datasets(x)))
  }
  if (is.null(names(datasets))) {
    names(datasets) <- datasets
  }

  fun <- switch(how,
    each = .dataset_samples_each,
    all = .dataset_samples_all,
    any = .dataset_samples_any
  )
  fun(hosts(x), datasets)
} # nocov end


# parse data --------------------------------------------------------------
