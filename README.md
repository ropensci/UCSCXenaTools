
<!-- README.md is generated from README.Rmd. Please edit that file -->
UCSCXenaTools: A R package download and explore data from **UCSC Xena data hubs**
=================================================================================

![](http://www.r-pkg.org/badges/version-last-release/UCSCXenaTools) [![GitHub tag](https://img.shields.io/github/tag/ShixiangWang/UCSCXenaTools.svg?label=Github)](https://github.com/ShixiangWang/UCSCXenaTools) ![](http://cranlogs.r-pkg.org/badges/UCSCXenaTools) ![](http://cranlogs.r-pkg.org/badges/grand-total/UCSCXenaTools) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ShixiangWang/UCSCXenaTools?branch=master&svg=true)](https://ci.appveyor.com/project/ShixiangWang/UCSCXenaTools) [![Coverage Status](https://img.shields.io/codecov/c/github/ShixiangWang/UCSCXenaTools/master.svg)](https://codecov.io/github/ShixiangWang/UCSCXenaTools?branch=master) [![GitHub issues](https://img.shields.io/github/issues/ShixiangWang/UCSCXenaTools.svg)](https://github.com/ShixiangWang/UCSCXenaTools/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+)

**UCSC Xena data hubs**, which are

> A collection of UCSC-hosted public databases such as TCGA, ICGC, TARGET, GTEx, CCLE, and others. Databases are normalized so they can be combined, linked, filtered, explored and downloaded.
>
> -- [UCSC Xena](https://xena.ucsc.edu/)

**Current Version: 0.2.2**

`UCSCXenaTools` is a R package download and explore data from **UCSC Xena data hubs**, which are

> A collection of UCSC-hosted public databases such as TCGA, ICGC, TARGET, GTEx, CCLE, and others. Databases are normalized so they can be combined, linked, filtered, explored and downloaded.
>
> -- [UCSC Xena](https://xena.ucsc.edu/)

Installation
------------

Install stable release from CRAN with:

``` r
install.packages("UCSCXenaTools")
```

You can also install devel version of UCSCXenaTools from github with:

``` r
# install.packages("devtools")
devtools::install_github("ShixiangWang/UCSCXenaTools", build_vignettes = TRUE)
```

Read this vignettes.

``` r
browseVignettes("UCSCXenaTools")
# or
?UCSCXenaTools
```

Data Hub List
-------------

All datasets are available at <https://xenabrowser.net/datapages/>.

Currently, `UCSCXenaTools` support all 7 data hubs of UCSC Xena.

-   [UCSC Public Hub](https://xenabrowser.net/datapages/?host=https%3A%2F%2Fucscpublic.xenahubs.net): <https://ucscpublic.xenahubs.net>
-   [TCGA Hub](https://xenabrowser.net/datapages/?host=https%3A%2F%2Ftcga.xenahubs.net): <https://tcga.xenahubs.net>
-   [GDC Xena Hub](https://xenabrowser.net/datapages/?host=https%3A%2F%2Fgdc.xenahubs.net): <https://gdc.xenahubs.net>
-   [ICGC Xena Hub](https://xenabrowser.net/datapages/?host=https%3A%2F%2Ficgc.xenahubs.net): <https://icgc.xenahubs.net>
-   [Pan-Cancer Atlas Hub](https://xenabrowser.net/datapages/?host=https%3A%2F%2Fpancanatlas.xenahubs.net): <https://pancanatlas.xenahubs.net>
-   [GA4GH (TOIL) Hub](https://xenabrowser.net/datapages/?host=https%3A%2F%2Ftoil.xenahubs.net): <https://toil.xenahubs.net>
-   [Treehouse Hub](https://xenabrowser.net/datapages/?host=https%3A%2F%2Fxena.treehouse.gi.ucsc.edu): <https://xena.treehouse.gi.ucsc.edu>

If the `API` changed, please remind me by email to <w_shixiang@163.com> or open an issue on [GitHub](https://github.com/ShixiangWang/UCSCXenaTools/issues).

Usage
-----

Download UCSC Xena Datasets and load them into R by `UCSCXenaTools` is a workflow in `generate`, `filter`, `query`, `download` and `prepare` 5 steps, which are implemented as `XenaGenerate`, `XenaFilter`, `XenaQuery`, `XenaDownload` and `XenaPrepare`, respectively. They are very clear and easy to use and combine with other packages like `dplyr`.

The following use clinical data download of LUNG, LUAD, LUSC from TCGA (hg19 version) as an example.

### XenaData data.frame

Begin from version `0.2.0`, `UCSCXenaTools` use a `data.frame` object (built in package) `XenaData` to generate an instance of `XenaHub` class, which communicate with API of UCSC Xena Data Hubs.

You can load `XenaData` after loading `UCSCXenaTools` into R.

``` r
library(UCSCXenaTools)
data(XenaData)

head(XenaData)
#>                         XenaHosts XenaHostNames
#> 1 https://ucscpublic.xenahubs.net   UCSC_Public
#> 2 https://ucscpublic.xenahubs.net   UCSC_Public
#> 3 https://ucscpublic.xenahubs.net   UCSC_Public
#> 4 https://ucscpublic.xenahubs.net   UCSC_Public
#> 5 https://ucscpublic.xenahubs.net   UCSC_Public
#> 6 https://ucscpublic.xenahubs.net   UCSC_Public
#>                                     XenaCohorts
#> 1                                  1000_genomes
#> 2                                  1000_genomes
#> 3 Acute lymphoblastic leukemia (Mullighan 2008)
#> 4 Acute lymphoblastic leukemia (Mullighan 2008)
#> 5 Acute lymphoblastic leukemia (Mullighan 2008)
#> 6                          B cells (Basso 2005)
#>                                               XenaDatasets
#> 1                                       1000_genomes/BRCA2
#> 2                                       1000_genomes/BRCA1
#> 3    mullighan2008_public/mullighan2008_500K_genomicMatrix
#> 4 mullighan2008_public/mullighan2008_public_clinicalMatrix
#> 5    mullighan2008_public/mullighan2008_SNP6_genomicMatrix
#> 6         basso2005_public/basso2005_public_clinicalMatrix
```

### Generate a XenaHub object

This can be implemented by `XenaGenerate` function, which generate `XenaHub` object from `XenaData` data frame.

``` r
XenaGenerate()
#> class: XenaHub 
#> hosts():
#>   https://ucscpublic.xenahubs.net
#>   https://tcga.xenahubs.net
#>   https://gdc.xenahubs.net
#>   https://icgc.xenahubs.net
#>   https://toil.xenahubs.net
#>   https://pancanatlas.xenahubs.net
#>   https://xena.treehouse.gi.ucsc.edu
#> cohorts() (134 total):
#>   1000_genomes
#>   Acute lymphoblastic leukemia (Mullighan 2008)
#>   B cells (Basso 2005)
#>   ...
#>   Treehouse PED v8
#>   Treehouse public expression dataset (July 2017)
#> datasets() (1549 total):
#>   1000_genomes/BRCA2
#>   1000_genomes/BRCA1
#>   mullighan2008_public/mullighan2008_500K_genomicMatrix
#>   ...
#>   treehouse_public_samples_unique_ensembl_expected_count.2017-09-11.tsv
#>   treehouse_public_samples_unique_hugo_log2_tpm_plus_1.2017-09-11.tsv
```

We can set `subset` argument to narrow datasets.

``` r
XenaGenerate(subset = XenaHostNames=="TCGA")
#> class: XenaHub 
#> hosts():
#>   https://tcga.xenahubs.net
#> cohorts() (38 total):
#>   TCGA Acute Myeloid Leukemia (LAML)
#>   TCGA Adrenocortical Cancer (ACC)
#>   TCGA Bile Duct Cancer (CHOL)
#>   ...
#>   TCGA Thyroid Cancer (THCA)
#>   TCGA Uterine Carcinosarcoma (UCS)
#> datasets() (879 total):
#>   TCGA.LAML.sampleMap/HumanMethylation27
#>   TCGA.LAML.sampleMap/HumanMethylation450
#>   TCGA.LAML.sampleMap/Gistic2_CopyNumber_Gistic2_all_data_by_genes
#>   ...
#>   TCGA.UCS.sampleMap/Pathway_Paradigm_RNASeq_And_Copy_Number
#>   TCGA.UCS.sampleMap/mutation_curated_broad
```

> You can use `XenaHub()` to generate a `XenaHub` object for API communication, but it is not recommended.

It's possible to explore `hosts()`, `cohorts()` and `datasets()`.

``` r
xe = XenaGenerate(subset = XenaHostNames=="TCGA")
# get hosts
hosts(xe)
#> [1] "https://tcga.xenahubs.net"
# get cohorts
head(cohorts(xe))
#> [1] "TCGA Acute Myeloid Leukemia (LAML)"
#> [2] "TCGA Adrenocortical Cancer (ACC)"  
#> [3] "TCGA Bile Duct Cancer (CHOL)"      
#> [4] "TCGA Bladder Cancer (BLCA)"        
#> [5] "TCGA Breast Cancer (BRCA)"         
#> [6] "TCGA Cervical Cancer (CESC)"
# get datasets
head(datasets(xe))
#> [1] "TCGA.LAML.sampleMap/HumanMethylation27"                          
#> [2] "TCGA.LAML.sampleMap/HumanMethylation450"                         
#> [3] "TCGA.LAML.sampleMap/Gistic2_CopyNumber_Gistic2_all_data_by_genes"
#> [4] "TCGA.LAML.sampleMap/mutation_wustl_hiseq"                        
#> [5] "TCGA.LAML.sampleMap/GA"                                          
#> [6] "TCGA.LAML.sampleMap/HiSeqV2_percentile"
```

Pipe operator `%>%` can also be used here.

    > library(tidyverse)
    > XenaData %>% filter(XenaHostNames == "TCGA", grepl("BRCA", XenaCohorts), grepl("Path", XenaDatasets)) %>% XenaGenerate()
    class: XenaHub 
    hosts():
      https://tcga.xenahubs.net
    cohorts() (1 total):
      TCGA Breast Cancer (BRCA)
    datasets() (4 total):
      TCGA.BRCA.sampleMap/Pathway_Paradigm_mRNA_And_Copy_Number
      TCGA.BRCA.sampleMap/Pathway_Paradigm_RNASeq
      TCGA.BRCA.sampleMap/Pathway_Paradigm_RNASeq_And_Copy_Number
      TCGA.BRCA.sampleMap/Pathway_Paradigm_mRNA

### Filter

There are too many datasets, we filter them by `XenaFilter` function.

Regular expression can be used to filter XenaHub object to what we want.

``` r
(XenaFilter(xe, filterDatasets = "clinical") -> xe2)
#> class: XenaHub 
#> hosts():
#>   https://tcga.xenahubs.net
#> cohorts() (39 total):
#>   (unassigned)
#>   TCGA Acute Myeloid Leukemia (LAML)
#>   TCGA Adrenocortical Cancer (ACC)
#>   ...
#>   TCGA Thyroid Cancer (THCA)
#>   TCGA Uterine Carcinosarcoma (UCS)
#> datasets() (37 total):
#>   TCGA.OV.sampleMap/OV_clinicalMatrix
#>   TCGA.DLBC.sampleMap/DLBC_clinicalMatrix
#>   TCGA.KIRC.sampleMap/KIRC_clinicalMatrix
#>   ...
#>   TCGA.READ.sampleMap/READ_clinicalMatrix
#>   TCGA.MESO.sampleMap/MESO_clinicalMatrix
```

Then select `LUAD`, `LUSC` and `LUNG` 3 datasets.

``` r
XenaFilter(xe2, filterDatasets = "LUAD|LUSC|LUNG") -> xe2
```

Pipe can be used here.

    suppressMessages(require(dplyr))

    xe %>% 
        XenaFilter(filterDatasets = "clinical") %>% 
        XenaFilter(filterDatasets = "luad|lusc|lung")
    ## class: XenaHub 
    ## hosts():
    ##   https://tcga.xenahubs.net
    ## cohorts() (39 total):
    ##   (unassigned)
    ##   TCGA Acute Myeloid Leukemia (LAML)
    ##   TCGA Adrenocortical Cancer (ACC)
    ##   ...
    ##   TCGA Thyroid Cancer (THCA)
    ##   TCGA Uterine Carcinosarcoma (UCS)
    ## datasets() (3 total):
    ##   TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
    ##   TCGA.LUNG.sampleMap/LUNG_clinicalMatrix
    ##   TCGA.LUAD.sampleMap/LUAD_clinicalMatrix

### Query

Create a query before download data

``` r
xe2_query = XenaQuery(xe2)
xe2_query
#>                       hosts                                datasets
#> 1 https://tcga.xenahubs.net TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
#> 2 https://tcga.xenahubs.net TCGA.LUNG.sampleMap/LUNG_clinicalMatrix
#> 3 https://tcga.xenahubs.net TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#>                                                                             url
#> 1 https://tcga.xenahubs.net/download/TCGA.LUSC.sampleMap/LUSC_clinicalMatrix.gz
#> 2 https://tcga.xenahubs.net/download/TCGA.LUNG.sampleMap/LUNG_clinicalMatrix.gz
#> 3 https://tcga.xenahubs.net/download/TCGA.LUAD.sampleMap/LUAD_clinicalMatrix.gz
```

### Download

Default, data will be downloaded to `XenaData` directory under system temp directory. You can specify the path.

If the data exists, command will not run to download them, but you can force it by `force` option.

``` r
xe2_download = XenaDownload(xe2_query)
#> We will download files to directory D:\tmp\RtmpWEgsNu/XenaData.
#> Downloading TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz
#> Downloading TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz
#> Downloading TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz
#> Note fileNames transfromed from datasets name and / chracter all changed to __ character.
## not run
#xe2_download = XenaDownload(xe2_query, destdir = "E:/Github/XenaData/test/")
```

> Note fileNames transfromed from datasets name and / chracter all changed to \_\_ character.

### Prepare

There are 4 ways to prepare data to R.

    # way1:  directory
    cli1 = XenaPrepare("E:/Github/XenaData/test/")
    names(cli1)
    ## [1] "TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz"
    ## [2] "TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz"
    ## [3] "TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz"

    # way2: local files
    cli2 = XenaPrepare("E:/Github/XenaData/test/TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz")
    class(cli2)
    ## [1] "tbl_df"     "tbl"        "data.frame"

    cli2 = XenaPrepare(c("E:/Github/XenaData/test/TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz",
                         "E:/Github/XenaData/test/TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz"))
    class(cli2)
    ## [1] "list"
    names(cli2)
    ## [1] "TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz"
    ## [2] "TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz"

    # way3: urls
    cli3 = XenaPrepare(xe2_download$url[1:2])
    names(cli3)
    ## [1] "LUSC_clinicalMatrix.gz" "LUNG_clinicalMatrix.gz"

``` r
# way4: xenadownload object
cli4 = XenaPrepare(xe2_download)
names(cli4)
#> [1] "TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz"
#> [2] "TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz"
#> [3] "TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz"
```

### SessionInfo

``` r
sessionInfo()
#> R version 3.5.1 (2018-07-02)
#> Platform: x86_64-w64-mingw32/x64 (64-bit)
#> Running under: Windows 7 x64 (build 7601) Service Pack 1
#> 
#> Matrix products: default
#> 
#> locale:
#> [1] LC_COLLATE=Chinese (Simplified)_People's Republic of China.936 
#> [2] LC_CTYPE=Chinese (Simplified)_People's Republic of China.936   
#> [3] LC_MONETARY=Chinese (Simplified)_People's Republic of China.936
#> [4] LC_NUMERIC=C                                                   
#> [5] LC_TIME=Chinese (Simplified)_People's Republic of China.936    
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] UCSCXenaTools_0.2.1 pacman_0.4.6       
#> 
#> loaded via a namespace (and not attached):
#>  [1] Rcpp_0.12.18    crayon_1.3.4    digest_0.6.15   rprojroot_1.3-2
#>  [5] R6_2.2.2        jsonlite_1.5    backports_1.1.2 magrittr_1.5   
#>  [9] evaluate_0.11   pillar_1.3.0    httr_1.3.1      rlang_0.2.1    
#> [13] stringi_1.1.7   curl_3.2        rmarkdown_1.10  tools_3.5.1    
#> [17] readr_1.1.1     stringr_1.3.1   hms_0.4.2       yaml_2.2.0     
#> [21] compiler_3.5.1  pkgconfig_2.0.1 htmltools_0.3.6 knitr_1.20     
#> [25] tibble_1.4.2
```

Acknowledgement
---------------

This package is based on [XenaR](https://github.com/mtmorgan/XenaR), thanks [Martin Morgan](https://github.com/mtmorgan) for his work.

LICENSE
-------

GPL-3

please note, code from XenaR package under Apache 2.0 license.

ToDo
----

-   Shinny
-   More easier download workflow

Code of conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
