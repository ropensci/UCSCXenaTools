use_cache <- function(id, op, dir = tempdir()) {
    id <- digest::digest(id)
    fp <- file.path(dir, paste0(id, ".rds"))
    if (file.exists(fp)) {
        readRDS(fp)
    } else {
        data <- eval(parse(text = op), envir = parent.frame())
        saveRDS(data, file = fp)
        data
    }
}
