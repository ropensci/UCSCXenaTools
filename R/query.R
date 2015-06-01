.xena_post <- function(host, query, ...) {
    host <- paste0(host, "/data/")
    res <- POST(host, body=query)
    stop_for_status(res)
    content(res, ...)
}

.null_cohort <- "(unassigned)"

.quote <- function(s)
    paste0('"', s, '"')

.quote_cohort <- function(cohort) {
    ifelse(cohort == .null_cohort, 'nil', .quote(cohort))
}

.collapse <- function(l, collapse=" ") {
    paste0(.quote(l), collapse=collapse)
}

.collapse_cohort <- function(cohorts, collapse=" ")
    paste0(.quote_cohort(cohorts), collapse=collapse)

.arrayfmt <- function(l, collapse=.collapse) {
    paste0('[', collapse(l), ']')
}

.samples_any_query <- function(what) paste0('
    (map :value
      (query {
         :select [:%distinct.value]
         :from [:dataset]
         :join [:field [:= :dataset.id :dataset_id]
                :code [:= :field_id :field.id]]
         :where [:and
                 [:in ',  what, ']
                 [:= :field.name "sampleID"]]
       }))
')

.samples_all_query <- function(where, what, n) paste0('
    (map :value
        (query {
            :select [:value] :from [{
                :select [', where, ' :value]
                :modifiers [:distinct]
                :join [:field [:= :dataset.id :dataset_id]
                       :code [:= :field_id :field.id]]
                :where [:and [:in ', where, ' ', what, ']
                        [:= :field.name "sampleID"]]
                :from [:dataset]
            }]
            :group-by [:value]
            :having [:= :%count.value ', n, ']
        }))
')

.cohort_samples_any_query <- function(cohorts) {
    what <- paste(':cohort', .arrayfmt(cohorts, .collapse_cohort))
    .samples_any_query(what)
}

.cohort_samples_all_query <- function(cohorts) {
    what <- .arrayfmt(cohorts, .collapse_cohort)
    .samples_all_query(":cohorts", what, length(cohorts))
}    

.dataset_samples_any_query <- function(datasets) {
    what <- paste(':dataset.name', .arrayfmt(datasets))
    .samples_any_query(what)
}

.dataset_samples_all_query <- function(datasets) {
    what <- .arrayfmt(datasets)
    .samples_all_query(":dataset.name", what, length(datasets))
}
    

.all_cohorts_query <- function() {
    paste0(
        '(map :cohort\n',
        '  (query\n',
        '    {:select [[#sql/call [:distinct #sql/call [:ifnull :cohort "(unassigned)"]] :cohort]]\n',
        '     :from [:dataset]}))')
}
    
.all_datasets_query <- function(cohorts) {
    paste0(
        '(query {:select [:name :type :datasubtype :probemap :text :status]\n',
        '        :from [:dataset]\n',
        '        :where [:in :cohort ', .arrayfmt(cohorts), ']})')
}

.all_dataset_names_query <- function(cohorts) {
    paste0(
        '(map :name\n',
         '(query {:select [:name] :from [:dataset]\n',
                 ':where [:in :cohort ', .arrayfmt(cohorts), ']}))\n')
}

.dataset_list_query <- function(cohort) paste0(
    paste0(
        '(query {:select [:name :type :datasubtype :probemap :text :status]\n',
        '        :from [:dataset]\n',
        '        :where [:= :cohort ', .quote_cohort(cohort), ']})')
)

.dataset_query <- function(dataset) {
    paste0(
        '(query {:select [:name :longtitle :type :datasubtype :probemap :text :status]\n',
        '        :from [:dataset]\n',
        '        :where [:= :dataset.name ', .quote(dataset), ']})')
}

## *_string

.feature_list_query <- function(dataset) {
    paste0(
        '(query {:select [:field.name :feature.longtitle]\n',
        '        :from [:field]\n',
        '        :where [:= :dataset_id {:select [:id]\n',
        '                         :from [:dataset]\n',
        '                         :where [:= :name ', .quote(dataset), ']}]\n',
        '        :left-join [:feature [:= :feature.field_id :field.id]]})')
}

.feature_names_query <- function(dataset) {
    paste0(
        '(map :name\n',
        ' (query {:select [:field.name]\n',
        '        :from [:field]\n',
        '        :where [:= :dataset_id {:select [:id]\n',
        '                         :from [:dataset]\n',
        '                         :where [:= :name ', .quote(dataset), ']}]\n',
        '        :left-join [:feature [:= :feature.field_id :field.id]]}))')
}

## *_string

.dataset_field_string <- function(dataset) {
    paste0(
        '(query {:select [:field.name]\n',
        '        :from [:dataset]\n',
        '        :join [:field [:= :dataset.id :dataset_id]]\n',
        '        :where [:= :dataset.name ', .quote(dataset), ']})')
}

## action

.host_is_alive <- function(host) {
    tryCatch({
        result <- .xena_post(host, "(+ 1 2)")
        stop_for_status(result)
        TRUE
    }, error=function(...) {
        FALSE
    })
}

.all_cohorts <- function(hosts) {
    lapply(hosts, function(h) {
        sort(unlist(.xena_post(h, .all_cohorts_query()), use.names=FALSE))
    })
}

.count_datasets <- function(hosts, cohorts) {
    query <- paste0(
        '(query {:select [:%count.*]\n',
                ':from [:dataset]\n',
                ':where [:in :cohort', .arrayfmt(cohorts), ']}))\n')
    unlist(lapply(hosts, function(h) .xena_post(h, query)), use.names=FALSE)
}

.cohort_samples_each <- function(hosts, cohorts) {
    lapply(hosts, function(h) {
        result <- lapply(cohorts, function(c) {
            .xena_post(h, .cohort_samples_any_query(c), simplifyVector=TRUE)
        })
        Filter(Negate(is.null), result)
    })
}

.cohort_samples_any <- function(hosts, cohorts) {
    query <- .cohort_samples_any_query(cohorts)
    lapply(hosts, .xena_post, query, simplifyVector=TRUE)
}

.cohort_samples_all <- function(hosts, cohorts) {
    query <- .cohort_samples_all_query(cohorts)
    lapply(hosts, .xena_post, query, simplifyVector=TRUE)
}

.all_datasets <- function(hosts, cohorts) {
    lapply(hosts, function(h) {
        .xena_post(h, .all_datasets_query(cohorts))
    })
}

.all_dataset_names <- function(hosts, cohorts) {
    lapply(hosts, function(h) {
        .xena_post(h, .all_dataset_names_query(cohorts))
    })
}

.dataset_list <- function(hosts, cohort) {
    lapply(hosts, function(h) {
        .xena_post(h, .dataset_list_query(cohort))
    })
}

.dataset_samples_each <- function(hosts, datasets) {
    lapply(hosts, function(h) {
        result <- lapply(datasets, function(d) {
            .xena_post(h, .dataset_samples_any_query(d), simplifyVector=TRUE)
        })
        Filter(Negate(is.null), result)
    })
}

.dataset_samples_any <- function(hosts, datasets) {
    query <- .dataset_samples_any_query(datasets)
    lapply(hosts, .xena_post, query, simplifyVector=TRUE)
}

.dataset_samples_all <- function(hosts, datasets) {
    query <- .dataset_samples_all_query(datasets)
    lapply(hosts, .xena_post, query, simplifyVector=TRUE)
}

.dataset_feature_names <- function(hosts, dataset) {
    lapply(hosts, function(h) {
        unlist(.xena_post(h, .feature_names_query(dataset)))
    })
}

.dataset_field <- function(hosts, ds) {
    lapply(hosts, function(h) {
        .xena_post(h, .dataset_field_string(ds))
    })
}
