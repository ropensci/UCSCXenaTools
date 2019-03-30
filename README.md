
<!-- README.md is generated from README.Rmd. Please edit that file -->

# UCSCXenaTools <img src='man/figures/logo.png' align="right" height="140" width="120" alt="logo"/>

<!-- badges: start -->

[![CRAN](http://www.r-pkg.org/badges/version-last-release/UCSCXenaTools)](https://cran.r-project.org/package=UCSCXenaTools)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/ShixiangWang/UCSCXenaTools?branch=master&svg=true)](https://ci.appveyor.com/project/ShixiangWang/UCSCXenaTools)
[![Travis build
status](https://travis-ci.org/ShixiangWang/UCSCXenaTools.svg?branch=master)](https://travis-ci.org/ShixiangWang/UCSCXenaTools)

![](http://cranlogs.r-pkg.org/badges/UCSCXenaTools)
![](http://cranlogs.r-pkg.org/badges/grand-total/UCSCXenaTools)
[![Coverage
Status](https://img.shields.io/codecov/c/github/ShixiangWang/UCSCXenaTools/master.svg)](https://codecov.io/github/ShixiangWang/UCSCXenaTools?branch=master)
[![GitHub
issues](https://img.shields.io/github/issues/ShixiangWang/UCSCXenaTools.svg)](https://github.com/ShixiangWang/UCSCXenaTools/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+)
[![Closed
issues](https://img.shields.io/github/issues-closed/ShixiangWang/UCSCXenaTools.svg)](https://github.com/ShixiangWang/UCSCXenaTools/issues?q=is%3Aissue+is%3Aclosed)
<!-- badges: end -->

**UCSCXenaTools** is an R package for downloading and exploring data
from [**UCSC Xena data hubs**](https://xenabrowser.net/datapages/),
which are a collection of UCSC-hosted public databases such as TCGA,
ICGC, TARGET, GTEx, CCLE, and others. Databases are normalized so they
can be combined, linked, filtered, explored and downloaded.

## Table of Contents

  - [Installation](#installation)
  - [Data Hub List](#data-hub-list)
  - [Usage](#usage)
  - [Documentation](#documentation)
  - [APIs](#apis)
  - [Citation](#citation)
  - [Acknowledgement](#acknowledgement)
  - [LICENSE](#license)
  - [Code of conduct](#code-of-conduct)

## Installation

Install stable release from CRAN with:

``` r
install.packages("UCSCXenaTools")
```

You can also install devel version of **UCSCXenaTools** from github
with:

``` r
# install.packages("remotes")
remotes::install_github("ShixiangWang/UCSCXenaTools", build_vignettes = TRUE)
```

## Data Hub List

All datasets are available at <https://xenabrowser.net/datapages/>.

Currently, **UCSCXenaTools** supports 10 data hubs of UCSC Xena.

  - UCSC Public Hub: <https://ucscpublic.xenahubs.net>
  - TCGA Hub: <https://tcga.xenahubs.net>
  - GDC Xena Hub: <https://gdc.xenahubs.net>
  - ICGC Xena Hub: <https://icgc.xenahubs.net>
  - Pan-Cancer Atlas Hub: <https://pancanatlas.xenahubs.net>
  - GA4GH (TOIL) Hub: <https://toil.xenahubs.net>
  - Treehouse Hub: <https://xena.treehouse.gi.ucsc.edu>
  - PCAWG Hub: <https://pcawg.xenahubs.net>
  - ATAC-seq Hub: <https://atacseq.xenahubs.net>
  - Singel Cell Xena hub: <https://singlecell.xenahubs.net>

If the url of data hub changed or new data hub online, please remind me
by emailing to <w_shixiang@163.com> or [opening an issue on
GitHub](https://github.com/ShixiangWang/UCSCXenaTools/issues).

## Usage

Download UCSC Xena datasets and load them into R by **UCSCXenaTools** is
a workflow with `generate`, `filter`, `query`, `download` and `prepare`
5 steps, which are implemented as `XenaGenerate`, `XenaFilter`,
`XenaQuery`, `XenaDownload` and `XenaPrepare` functions, respectively.
They are very clear and easy to use and combine with other packages like
`dplyr`.

To show the basic usage of **UCSCXenaTools**, we download clinical data
of LUNG, LUAD, LUSC from TCGA (hg19 version) data hub.

### XenaData data.frame

Begin from version `0.2.0`, **UCSCXenaTools** uses a `data.frame` object
(built in package) `XenaData` to generate an instance of `XenaHub`
class, which records information of all datasets of UCSC Xena Data Hubs.

You can load `XenaData` after loading `UCSCXenaTools` into R.

``` r
library(UCSCXenaTools)
#> =========================================================================
#> UCSCXenaTools version 1.1.0
#> Github page: https://github.com/ShixiangWang/UCSCXenaTools
#> Documentation: https://shixiangwang.github.io/UCSCXenaTools/
#> If you use it in published research, please cite:
#> Wang, Shixiang, et al. "APOBEC3B and APOBEC mutational signature
#>     as potential predictive markers for immunotherapy
#>     response in non-small cell lung cancer." Oncogene (2018).
#> =========================================================================
#> 
data(XenaData)

head(XenaData)
#>                         XenaHosts XenaHostNames
#> 1 https://ucscpublic.xenahubs.net     publicHub
#> 2 https://ucscpublic.xenahubs.net     publicHub
#> 3 https://ucscpublic.xenahubs.net     publicHub
#> 4 https://ucscpublic.xenahubs.net     publicHub
#> 5 https://ucscpublic.xenahubs.net     publicHub
#> 6 https://ucscpublic.xenahubs.net     publicHub
#>                                     XenaCohorts
#> 1 Acute lymphoblastic leukemia (Mullighan 2008)
#> 2 Acute lymphoblastic leukemia (Mullighan 2008)
#> 3 Acute lymphoblastic leukemia (Mullighan 2008)
#> 4                   Breast Cancer (Caldas 2007)
#> 5                   Breast Cancer (Caldas 2007)
#> 6                   Breast Cancer (Caldas 2007)
#>                                               XenaDatasets
#> 1    mullighan2008_public/mullighan2008_500K_genomicMatrix
#> 2 mullighan2008_public/mullighan2008_public_clinicalMatrix
#> 3    mullighan2008_public/mullighan2008_SNP6_genomicMatrix
#> 4              Caldas2007/chinSF2007_public_clinicalMatrix
#> 5             Caldas2007/chinSFGenomeBio2007_genomicMatrix
#> 6                   Caldas2007/naderi2007Exp_genomicMatrix
```

### Workflow

Select datasets.

``` r
# The options in XenaFilter function support Regular Expression
XenaGenerate(subset = XenaHostNames=="tcgaHub") %>% 
  XenaFilter(filterDatasets = "clinical") %>% 
  XenaFilter(filterDatasets = "LUAD|LUSC|LUNG") -> df_todo

df_todo
#> class: XenaHub 
#> hosts():
#>   https://tcga.xenahubs.net
#> cohorts() (3 total):
#>   TCGA Lung Adenocarcinoma (LUAD)
#>   TCGA Lung Cancer (LUNG)
#>   TCGA Lung Squamous Cell Carcinoma (LUSC)
#> datasets() (3 total):
#>   TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#>   TCGA.LUNG.sampleMap/LUNG_clinicalMatrix
#>   TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
```

Query and download.

``` r
XenaQuery(df_todo) %>%
  XenaDownload() -> xe_download
#> This will check url status, please be patient.
#> All downloaded files will under directory /tmp/RtmpEwuFgX.
#> The 'trans_slash' option is FALSE, keep same directory structure as Xena.
#> Creating directories for datasets...
#> Downloading TCGA.LUAD.sampleMap/LUAD_clinicalMatrix.gz
#> Downloading TCGA.LUNG.sampleMap/LUNG_clinicalMatrix.gz
#> Downloading TCGA.LUSC.sampleMap/LUSC_clinicalMatrix.gz
```

Prepare data into R for analysis.

``` r
cli = XenaPrepare(xe_download)
class(cli)
#> [1] "list"
names(cli)
#> [1] "LUAD_clinicalMatrix.gz" "LUNG_clinicalMatrix.gz"
#> [3] "LUSC_clinicalMatrix.gz"
```

### Browse datasets

Create two XenaHub objects:

  - `to_browse` - a XenaHub object contains a cohort and a dataset.
  - `to_browse2` - a XenaHub object contains 2 cohorts and 2 datasets.

<!-- end list -->

``` r
XenaGenerate(subset = XenaHostNames=="tcgaHub") %>%
    XenaFilter(filterDatasets = "clinical") %>%
    XenaFilter(filterDatasets = "LUAD") -> to_browse

to_browse
#> class: XenaHub 
#> hosts():
#>   https://tcga.xenahubs.net
#> cohorts() (1 total):
#>   TCGA Lung Adenocarcinoma (LUAD)
#> datasets() (1 total):
#>   TCGA.LUAD.sampleMap/LUAD_clinicalMatrix

XenaGenerate(subset = XenaHostNames=="tcgaHub") %>%
    XenaFilter(filterDatasets = "clinical") %>%
    XenaFilter(filterDatasets = "LUAD|LUSC") -> to_browse2

to_browse2
#> class: XenaHub 
#> hosts():
#>   https://tcga.xenahubs.net
#> cohorts() (2 total):
#>   TCGA Lung Adenocarcinoma (LUAD)
#>   TCGA Lung Squamous Cell Carcinoma (LUSC)
#> datasets() (2 total):
#>   TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#>   TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
```

`XenaBrowse()` function can be used to browse dataset/cohort links using
your default web browser. At default, this function limit one
dataset/cohort for preventing user to open too many links at once.

``` r
# This will open you web browser
XenaBrowse(to_browse)

XenaBrowse(to_browse, type = "cohort")
```

``` r
# This will throw error
XenaBrowse(to_browse2)
#> Error in XenaBrowse(to_browse2): This function limite 1 dataset to browse.
#>  Set multiple to TRUE if you want to browse multiple links.

XenaBrowse(to_browse2, type = "cohort")
#> Error in XenaBrowse(to_browse2, type = "cohort"): This function limite 1 cohort to browse. 
#>  Set multiple to TRUE if you want to browse multiple links.
```

When you make sure you want to open multiple links, you can set
`multiple` option to `TRUE`.

``` r
XenaBrowse(to_browse2, multiple = TRUE)
XenaBrowse(to_browse2, type = "cohort", multiple = TRUE)
```

## Documentation

More features and usages please read [online documentation on
CRAN](https://cran.r-project.org/web/packages/UCSCXenaTools/vignettes/USCSXenaTools.html)
or [Github website](https://shixiangwang.github.io/UCSCXenaTools/).

## APIs

API functions can be used to query specied data (e.g. expression of a
few genes for a few samples) or information instead of downloading the
entire dataset.

If you want to use APIs provided by **UCSCXenaTools** to access Xena
Hubs, please read [this
vignette](https://shixiangwang.github.io/UCSCXenaTools/articles/xena-apis.html).

## Citation

*Wang, Shixiang, et al. “APOBEC3B and APOBEC mutational signature as
potential predictive markers for immunotherapy response in non-small
cell lung cancer.” Oncogene (2018).*

Or

    @article{wang2018apobec3b,
      title={APOBEC3B and APOBEC mutational signature as potential predictive markers for immunotherapy response in non-small cell lung cancer},
      author={Wang, Shixiang and Jia, Mingming and He, Zaoke and Liu, Xue-Song},
      journal={Oncogene},
      volume={37},
      number={29},
      pages={3924},
      year={2018},
      publisher={Nature Publishing Group}
    }

## Acknowledgement

This package is based on [XenaR](https://github.com/mtmorgan/XenaR),
thanks [Martin Morgan](https://github.com/mtmorgan) for his work.

## LICENSE

GPL-3

Please note, code from XenaR package under Apache 2.0 license.

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.
