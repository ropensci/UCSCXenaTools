.onAttach <- function(libname, pkgname) {
  version <- utils::packageDescription(pkgname, fields = "Version")

  msg <- paste0("=========================================================================================
", pkgname, " version ", version, "
Project URL: https://github.com/ropensci/UCSCXenaTools
Usages: https://cran.r-project.org/web/packages/UCSCXenaTools/vignettes/USCSXenaTools.html

If you use it in published research, please cite:
Wang et al., (2019). The UCSCXenaTools R package: a toolkit for accessing genomics data
  from UCSC Xena platform, from cancer multi-omics to single-cell RNA-seq.
  Journal of Open Source Software, 4(40), 1627, https://doi.org/10.21105/joss.01627
=========================================================================================
                              --Enjoy it--")
  # Init API functions
  .init_api()
  base::packageStartupMessage(msg)
}
