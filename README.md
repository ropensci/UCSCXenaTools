
<!-- README.md is generated from README.Rmd. Please edit that file -->

# UCSCXenaTools <img src='man/figures/logo.png' align="right" height="200" alt="logo"/>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/UCSCXenaTools)](https://cran.r-project.org/package=UCSCXenaTools)
[![lifecycle](https://img.shields.io/badge/lifecycle-stable-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R-CMD-check](https://github.com/ropensci/UCSCXenaTools/actions/workflows/main.yml/badge.svg)](https://github.com/ropensci/UCSCXenaTools/actions/workflows/main.yml)
[![](https://cranlogs.r-pkg.org/badges/grand-total/UCSCXenaTools?color=orange)](https://cran.r-project.org/package=UCSCXenaTools)
[![rOpenSci](https://badges.ropensci.org/315_status.svg)](https://github.com/ropensci/software-review/issues/315)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.01627/status.svg)](https://doi.org/10.21105/joss.01627)

<!-- badges: end -->

**UCSCXenaTools** is an R package for accessing genomics data from UCSC
Xena platform, from cancer multi-omics to single-cell RNA-seq. Public
omics data from UCSC Xena are supported through [**multiple turn-key
Xena Hubs**](https://xenabrowser.net/datapages/), which are a collection
of UCSC-hosted public databases such as TCGA, ICGC, TARGET, GTEx, CCLE,
and others. Databases are normalized so they can be combined, linked,
filtered, explored and downloaded.

**Who is the target audience and what are scientific applications of
this package?**

- Target Audience: cancer and clinical researchers, bioinformaticians
- Applications: genomic and clinical analyses

## Table of Contents

- [Installation](#installation)
- [Data Hub List](#data-hub-list)
- [Basic usage](#basic-usage)
- [Citation](#citation)
- [How to contribute](#how-to-contribute)
- [Acknowledgment](#acknowledgment)

## Installation

Install stable release from r-universe/CRAN with:

``` r
install.packages('UCSCXenaTools', repos = c('https://ropensci.r-universe.dev', 'https://cloud.r-project.org'))
#install.packages("UCSCXenaTools")
```

You can also install devel version of **UCSCXenaTools** from github
with:

``` r
# install.packages("remotes")
remotes::install_github("ropensci/UCSCXenaTools")
```

If you want to build vignette in local, please add two options:

``` r
remotes::install_github("ropensci/UCSCXenaTools", build_vignettes = TRUE, dependencies = TRUE)
```

## Data Hub List

All datasets are available at <https://xenabrowser.net/datapages/>.

Currently, **UCSCXenaTools** supports the following data hubs of UCSC
Xena.

- UCSC Public Hub: <https://ucscpublic.xenahubs.net/>
- TCGA Hub: <https://tcga.xenahubs.net/>
- GDC Xena Hub (new): <https://gdc.xenahubs.net/>
- GDC v18.0 Xena Hub (old): <https://gdcV18.xenahubs.net/>
- ICGC Xena Hub: <https://icgc.xenahubs.net/>
- Pan-Cancer Atlas Hub: <https://pancanatlas.xenahubs.net/>
- UCSC Toil RNAseq Recompute Compendium Hub:
  <https://toil.xenahubs.net/>
- PCAWG Xena Hub: <https://pcawg.xenahubs.net/>
- ATAC-seq Hub: <https://atacseq.xenahubs.net/>
- Treehouse Xena Hub: <https://xena.treehouse.gi.ucsc.edu:443/>
- …

Users can update dataset list from the newest version of UCSC Xena by
hand with `XenaDataUpdate()` function, followed by restarting R and
`library(UCSCXenaTools)`.

If any url of data hub is changed or a new data hub is online, please
remind me by emailing to <w_shixiang@163.com> or [opening an issue on
GitHub](https://github.com/ropensci/UCSCXenaTools/issues).

## Basic usage

Download UCSC Xena datasets and load them into R by **UCSCXenaTools** is
a workflow with `generate`, `filter`, `query`, `download` and `prepare`
5 steps, which are implemented as `XenaGenerate`, `XenaFilter`,
`XenaQuery`, `XenaDownload` and `XenaPrepare` functions, respectively.
They are very clear and easy to use and combine with other packages like
`dplyr`.

To show the basic usage of **UCSCXenaTools**, we will download clinical
data of LUNG, LUAD, LUSC from TCGA (hg19 version) data hub. Users can
learn more about **UCSCXenaTools** by running
`browseVignettes("UCSCXenaTools")` to read vignette.

### XenaData data.frame

**UCSCXenaTools** uses a `data.frame` object (built in package)
`XenaData` to generate an instance of `XenaHub` class, which records
information of all datasets of UCSC Xena Data Hubs.

You can load `XenaData` after loading `UCSCXenaTools` into R.

``` r
library(UCSCXenaTools)
#> =========================================================================================
#> UCSCXenaTools version 1.6.0
#> Project URL: https://github.com/ropensci/UCSCXenaTools
#> Usages: https://cran.r-project.org/web/packages/UCSCXenaTools/vignettes/USCSXenaTools.html
#> 
#> If you use it in published research, please cite:
#> Wang et al., (2019). The UCSCXenaTools R package: a toolkit for accessing genomics data
#>   from UCSC Xena platform, from cancer multi-omics to single-cell RNA-seq.
#>   Journal of Open Source Software, 4(40), 1627, https://doi.org/10.21105/joss.01627
#> =========================================================================================
#>                               --Enjoy it--
data(XenaData)

head(XenaData)
#> # A tibble: 6 × 17
#>   XenaHosts XenaHostNames XenaCohorts XenaDatasets SampleCount DataSubtype Label
#>   <chr>     <chr>         <chr>       <chr>              <int> <chr>       <chr>
#> 1 https://… publicHub     Breast Can… ucsfNeve_pu…          51 gene expre… Neve…
#> 2 https://… publicHub     Breast Can… ucsfNeve_pu…          57 phenotype   Phen…
#> 3 https://… publicHub     Glioma (Ko… kotliarov20…         194 copy number Kotl…
#> 4 https://… publicHub     Glioma (Ko… kotliarov20…         194 phenotype   Phen…
#> 5 https://… publicHub     Lung Cance… weir2007_pu…         383 copy number CGH  
#> 6 https://… publicHub     Lung Cance… weir2007_pu…         383 phenotype   Phen…
#> # ℹ 10 more variables: Type <chr>, AnatomicalOrigin <chr>, SampleType <chr>,
#> #   Tags <chr>, ProbeMap <chr>, LongTitle <chr>, Citation <chr>, Version <chr>,
#> #   Unit <chr>, Platform <chr>
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
#>   TCGA Lung Cancer (LUNG)
#>   TCGA Lung Adenocarcinoma (LUAD)
#>   TCGA Lung Squamous Cell Carcinoma (LUSC)
#> datasets() (3 total):
#>   TCGA.LUNG.sampleMap/LUNG_clinicalMatrix
#>   TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#>   TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
```

Query and download.

``` r
XenaQuery(df_todo) %>%
  XenaDownload() -> xe_download
#> This will check url status, please be patient.
#> All downloaded files will under directory /var/folders/h0/s_35svc15n1glmp65lbbkx9w0000gn/T//RtmpmgBjSb.
#> The 'trans_slash' option is FALSE, keep same directory structure as Xena.
#> Creating directories for datasets...
#> Downloading TCGA.LUNG.sampleMap/LUNG_clinicalMatrix
#> Downloading TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#> Downloading TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
```

Prepare data into R for analysis.

``` r
cli = XenaPrepare(xe_download)
class(cli)
#> [1] "list"
names(cli)
#> [1] "LUNG_clinicalMatrix" "LUAD_clinicalMatrix" "LUSC_clinicalMatrix"
```

## More to read

- [Introduction and basic usage of
  UCSCXenaTools](https://shixiangwang.github.io/home/en/tools/ucscxenatools-intro/)
- [UCSCXenaTools: Retrieve Gene Expression and Clinical Information from
  UCSC Xena for Survival
  Analysis](https://shixiangwang.github.io/home/en/post/ucscxenatools-201908/)
- [Obtain RNAseq Values for a Specific Gene in Xena
  Database](https://shixiangwang.github.io/home/en/post/2020-07-22-ucscxenatools-single-gene/)
- [UCSC Xena Access APIs in
  UCSCXenaTools](https://shixiangwang.github.io/home/en/tools/ucscxenatools-api/)

## Citation

Cite me by the following paper.

    Wang et al., (2019). The UCSCXenaTools R package: a toolkit for accessing genomics data
      from UCSC Xena platform, from cancer multi-omics to single-cell RNA-seq. 
      Journal of Open Source Software, 4(40), 1627, https://doi.org/10.21105/joss.01627

    # For BibTex
      
    @article{Wang2019UCSCXenaTools,
        journal = {Journal of Open Source Software},
        doi = {10.21105/joss.01627},
        issn = {2475-9066},
        number = {40},
        publisher = {The Open Journal},
        title = {The UCSCXenaTools R package: a toolkit for accessing genomics data from UCSC Xena platform, from cancer multi-omics to single-cell RNA-seq},
        url = {https://dx.doi.org/10.21105/joss.01627},
        volume = {4},
        author = {Wang, Shixiang and Liu, Xuesong},
        pages = {1627},
        date = {2019-08-05},
        year = {2019},
        month = {8},
        day = {5},
    }

Cite UCSC Xena by the following paper.

    Goldman, Mary, et al. "The UCSC Xena Platform for cancer genomics data 
        visualization and interpretation." BioRxiv (2019): 326470.

## How to contribute

For anyone who wants to contribute, please follow the guideline:

- Clone project from GitHub
- Open `UCSCXenaTools.Rproj` with RStudio
- Modify source code
- Run `devtools::check()`, and fix all errors, warnings and notes
- Create a pull request

## Acknowledgment

This package is based on [XenaR](https://github.com/mtmorgan/XenaR),
thanks [Martin Morgan](https://github.com/mtmorgan) for his work.

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
