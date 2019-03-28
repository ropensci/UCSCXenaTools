## post

.xena_post = function(host, query, ...) {
    host = paste0(host, "/data/")
    res = POST(host, body = query)
    stop_for_status(res)
    content(res, ...)
}

## utiilities

.null_cohort = "(unassigned)"

.quote = function(s)
    paste0('"', s, '"')

.quote_cohort = function(cohort) {
    ifelse(cohort == .null_cohort, 'nil', .quote(cohort))
}

.collapse = function(l, collapse = " ") {
    paste0(.quote(l), collapse = collapse)
}

.collapse_cohort = function(cohorts, collapse = " ")
    paste0(.quote_cohort(cohorts), collapse = collapse)

.arrayfmt = function(l, collapse = .collapse) {
    paste0('[', collapse(l), ']')
}

##
## queries
##

## hosts

.host_cohorts_query = function() {
    paste0(
        '(map :cohort\n',
        '  (query\n',
        '    {:select [[#sql/call [:distinct #sql/call [:ifnull :cohort "(unassigned)"]] :cohort]]\n',
        '     :from [:dataset]}))'
    )
}

## cohorts

.cohort_datasets_query = function(cohorts) {
    paste0(
        '(map :name\n',
        '(query {:select [:name] :from [:dataset]\n',
        ':where [:in :cohort ',
        .arrayfmt(cohorts),
        ']}))\n'
    )
}

.cohort_samples_any_query = function(cohorts) {
    what = paste(':cohort', .arrayfmt(cohorts, .collapse_cohort))
    .samples_any_query(what)
}

.cohort_samples_all_query = function(cohorts) {
    what = .arrayfmt(cohorts, .collapse_cohort)
    .samples_all_query(":cohorts", what, length(cohorts))
}

## datasets

.dataset_samples_any_query = function(datasets) {
    what = paste(':dataset.name', .arrayfmt(datasets))
    .samples_any_query(what)
}

.dataset_samples_all_query = function(datasets) {
    what = .arrayfmt(datasets)
    .samples_all_query(":dataset.name", what, length(datasets))
}

## samples

.samples_any_query = function(what)
    paste0(
        '
        (map :value
        (query {
        :select [:%distinct.value]
        :from [:dataset]
        :join [:field [:= :dataset.id :dataset_id]
        :code [:= :field_id :field.id]]
        :where [:and
        [:in ',
        what,
        ']
        [:= :field.name "sampleID"]]
        }))
        '
    )

.samples_all_query = function(where, what, n)
    paste0(
        '
        (map :value
        (query {
        :select [:value] :from [{
        :select [',
        where,
        ' :value]
        :modifiers [:distinct]
        :join [:field [:= :dataset.id :dataset_id]
        :code [:= :field_id :field.id]]
        :where [:and [:in ',
        where,
        ' ',
        what,
        ']
        [:= :field.name "sampleID"]]
        :from [:dataset]
        }]
        :group-by [:value]
        :having [:= :%count.value ',
        n,
        ']
        }))
        '
        )


##
## actions
##

## host

.host_is_alive = function(host) {
    tryCatch({
        result = .xena_post(host, "(+ 1 2)")
        stop_for_status(result)
        TRUE
    }, error = function(...) {
        FALSE
    })
}

.host_cohorts = function(hosts) {
    query = .host_cohorts_query()
    lapply(hosts, function(h) {
        sort(unlist(.xena_post(h, query), use.names = FALSE))
    })
}

.cohort_datasets = function(hosts, cohorts) {
    lapply(hosts, .xena_post, .cohort_datasets_query(cohorts))
}

.cohort_datasets_count = function(hosts, cohorts) {
    query = paste0(
        '(query {:select [:%count.*]\n',
        ':from [:dataset]\n',
        ':where [:in :cohort',
        .arrayfmt(cohorts),
        ']}))\n'
    )
    unlist(lapply(hosts, .xena_post, query), use.names = FALSE)
}

.cohort_samples_each = function(hosts, cohorts) {
    lapply(hosts, function(h) {
        result = lapply(cohorts, function(c) {
            .xena_post(h, .cohort_samples_any_query(c), simplifyVector = TRUE)
        })
        Filter(Negate(is.null), result)
    })
}

.cohort_samples_any = function(hosts, cohorts) {
    query = .cohort_samples_any_query(cohorts)
    lapply(hosts, .xena_post, query, simplifyVector = TRUE)
}

.cohort_samples_all = function(hosts, cohorts) {
    query = .cohort_samples_all_query(cohorts)
    lapply(hosts, .xena_post, query, simplifyVector = TRUE)
}

.dataset_samples_each = function(hosts, datasets) {
    lapply(hosts, function(h) {
        result = lapply(datasets, function(d) {
            .xena_post(h,
                       .dataset_samples_any_query(d),
                       simplifyVector = TRUE)
        })
        Filter(Negate(is.null), result)
    })
}

.dataset_samples_any = function(hosts, datasets) {
    query = .dataset_samples_any_query(datasets)
    lapply(hosts, .xena_post, query, simplifyVector = TRUE)
}

.dataset_samples_all = function(hosts, datasets) {
    query = .dataset_samples_all_query(datasets)
    lapply(hosts, .xena_post, query, simplifyVector = TRUE)
}
