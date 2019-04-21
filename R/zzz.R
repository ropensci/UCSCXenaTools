.onAttach = function(libname, pkgname) {
    version = utils::packageDescription(pkgname, fields = "Version")

    msg = paste0("=========================================================================
", pkgname, " version ", version, "
Github page: https://github.com/ShixiangWang/UCSCXenaTools
Documentation: https://shixiangwang.github.io/UCSCXenaTools/

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
