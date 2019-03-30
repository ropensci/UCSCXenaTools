#FUN: Create API functions from .xq files

#' Convert camel case to snake case
#'
#' @param name a character vector
#'
#' @return same length as `name` but with snake case
#' @export
#'
#' @examples
#' to_snake("sparseDataRange")
to_snake = function(name) {
    s = sub('(.)([A-Z][a-z]+)', '\\1_\\2', name)
    s = gsub('([a-z0-9])([A-Z])', '\\1_\\2', s)
    tolower(s)
}

.rm_extension = function(filepath) {
    sub(pattern = "(.*)\\..*$", replacement = "\\1",
        basename(filepath))
}

.marshall_param = function(p) {
    if (!is.atomic(p)){
        stop("Input type should be atomic!")
    }

    if (length(p) == 1) {
        return(.quote(p))
    } else if (length(p) > 1) {
        return(.arrayfmt(p))
    } else {
        return('nil')
    }
}

.call = function(query, params) {
    sprintf('(%s %s)', query,
            paste(sapply(params, .marshall_param),
                  collapse = " "))
}

.make_fun = function(fun, body, args) {
    eval(parse(text = paste(fun,
                            '<- function(',
                            args,
                            ') {\n',
                            body ,
                            '\n}',
                            sep='')),
         envir = as.environment("package:UCSCXenaTools"))
    # as.call(c(as.name("{"), e)) -> body(ff)
    # parse(text="y=\"1\"; return(y)")
}


.init_api = function() {
    #.api_generator
    xq_files = list.files(
        system.file("queries", package = "UCSCXenaTools"),
        pattern = "xq",
        full.names = TRUE
    )

    if (length(xq_files) == 0) {
        stop("No xq file find!")
    }


    for (f in xq_files) {
        fn = .rm_extension(f)
        fun = to_snake(fn)
        query = readr::read_file(f)
        params = sub("^[^[]+[[]([^]]*)[]].*$",
                     "\\1",
                     query)
        params = unlist(strsplit(params, split = " "))
        all_params = c("host", params)

        params = paste(params, collapse = ", ")
        all_params = paste(all_params, collapse = ", ")
        # Create hidden variable for storing xquery
        xquery = paste0(".xq_", fun)
        assign(xquery, query,
               envir = as.environment("package:UCSCXenaTools"))
        body = sprintf("xquery=get(\".xq_%s\", as.environment(\"package:UCSCXenaTools\")) \n.xena_post(host, .call(xquery, list(%s)), simplifyVector = TRUE)",
                       fun,
                       params)

        # Create hidden functions
        fun = paste0(".p_", fun)
        .make_fun(fun, body, all_params)
    }
}
