.onAttach = function(libname, pkgname) {
    version = utils::packageDescription(pkgname, fields = "Version")

    msg = paste0("=========================================================================
", pkgname, " version ", version, "
Github page: https://github.com/ShixiangWang/UCSCXenaTools
Documentation: https://shixiangwang.github.io/UCSCXenaTools/
If you use it in published research, please cite:
Wang, Shixiang, et al. \"APOBEC3B and APOBEC mutational signature
    as potential predictive markers for immunotherapy
    response in non-small cell lung cancer.\" Oncogene (2018).
=========================================================================
                 ")
    base::packageStartupMessage(msg)
}
