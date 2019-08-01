.onAttach <- function(libname, pkgname) {
  version <- utils::packageDescription(pkgname, fields = "Version")

  msg <- paste0("=========================================================================
", pkgname, " version ", version, "
Project URL: https://github.com/ropensci/UCSCXenaTools
Usages: https://shixiangwang.github.io/home/en/tools/#ucscxenatools

If you use it in published research, please cite:
Wang, Shixiang, et al. \"The predictive power of tumor mutational burden
    in lung cancer immunotherapy response is influenced by patients' sex.\"
    International journal of cancer (2019).
=========================================================================
                 ")
  # Init API functions
  .init_api()
  base::packageStartupMessage(msg)
}
