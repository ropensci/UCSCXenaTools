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

XenaPrepare <- function(objects,
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
  stopifnot(
    is.character(objects) |
      is.data.frame(objects),
    is.logical(use_chunk)
  )

  subset_rows.bk <- subset_rows
  select_cols.bk <- select_cols

  subset_rows <- substitute(subset_rows)
  if (is.name(subset_rows)) {
    subset_rows <- substitute(eval(subset_rows.bk))
  }

  select_cols <- substitute(select_cols)
  if (is.name(select_cols)) {
    select_cols <- substitute(eval(select_cols.bk))
  }

  # subset_rows <- substitute(subset_rows)
  # select_cols <- substitute(select_cols)

  #    subset_direction = match.arg(subset_direction)

  objects2 <- objects

  if (is.character(objects)) {
    if (length(objects) == 0) {
      stop("Please check you input!")
    }

    # Is the input directory?
    if (all(dir.exists(objects))) {
      if (length(objects) > 1) {
        stop("We do not accept multiple directories as input.")
      } else {
        files <- paste0(objects, "/", dir(objects))
        res <- lapply(files, function(x) {
          if (use_chunk) {
            if (is.null(callback)) {
              f <- function(x, pos) {
                subset(x,
                  eval(subset_rows),
                  select = eval(select_cols)
                )
              }
            } else {
              f <- callback
            }

            y <- readr::read_tsv_chunked(
              x,
              readr::DataFrameCallback$new(f),
              chunk_size = chunk_size,
              comment = comment,
              na = na,
              col_types = readr::cols()
            )
          } else {
            y <- readr::read_tsv(
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
          objectsName <- make.names(dir(objects))
          names(res) <- objectsName
        }
      }
    } else if (all(file.exists(objects))) {
      res <- lapply(objects, function(x) {
        if (use_chunk) {
          if (is.null(eval(callback))) {
            f <- function(x, pos) {
              subset(x,
                eval(subset_rows),
                select = eval(select_cols)
              )
            }
          } else {
            f <- callback
          }

          y <- readr::read_tsv_chunked(
            x,
            readr::DataFrameCallback$new(f),
            chunk_size = chunk_size,
            comment = comment,
            na = na,
            col_types = readr::cols()
          )
        } else {
          y <- readr::read_tsv(
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
        objectsName <- make.names(basename(objects))
        names(res) <- objectsName
      }
      if (length(res) == 1) {
        res <- res[[1]]
      }
    }
    else {
      # check urls
      all_right <- grepl(pattern = "http", x = objects)

      if (any(all_right)) {
        objects <- objects[all_right]
        if (length(objects) == 1) {
          if (use_chunk) {
            if (is.null(callback)) {
              f <- function(x, pos) {
                subset(x,
                  eval(subset_rows),
                  select = eval(select_cols)
                )
              }
            } else {
              f <- callback
            }

            res <- readr::read_tsv_chunked(
              objects,
              readr::DataFrameCallback$new(f),
              chunk_size = chunk_size,
              comment = comment,
              na = na,
              col_types = readr::cols()
            )
          } else {
            res <- readr::read_tsv(
              objects,
              comment = comment,
              na = na,
              col_types = readr::cols(),
              ...
            )
          }

          # res = suppressMessages(read_tsv(objects, comment=comment, na=na, ...))
        } else {
          res <- lapply(objects, function(x) {
            if (use_chunk) {
              if (is.null(callback)) {
                f <- function(x, pos) {
                  subset(x,
                    eval(subset_rows),
                    select = eval(select_cols)
                  )
                }
              } else {
                f <- callback
              }

              y <- readr::read_tsv_chunked(
                x,
                readr::DataFrameCallback$new(f),
                chunk_size = chunk_size,
                comment = comment,
                na = na,
                col_types = readr::cols()
              )
            } else {
              y <- readr::read_tsv(
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
            objectsName <- make.names(basename(objects))
            names(res) <- objectsName
          }
        }
      }
      all_wrong <- !all_right
      if (any(all_wrong)) {
        bad_urls <- objects2[all_wrong]
        message("Some inputs are wrong, maybe you should check:")
        print(bad_urls)
      }
    }
  } else {
    if (!"destfiles" %in% colnames(objects)) {
      stop(
        "Input data.frame should contain 'destfiles' column which generated by XenaDownload functions. Please check your input."
      )
    }

    files <- objects$destfiles
    res <- XenaPrepare(
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
