# UCSCXenaTools

![](http://www.r-pkg.org/badges/version-last-release/UCSCXenaTools) ![](http://cranlogs.r-pkg.org/badges/UCSCXenaTools?color=red) [![Open Source Love svg1](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/) [![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/) [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/ShixiangWang/sync-deploy/graphs/commit-activity)

A R package download and explore data from **UCSC Xena data hubs**, which are

> A collection of UCSC-hosted public databases such as TCGA, ICGC, TARGET, GTEx, CCLE, and others. Databases are normalized so they can be combined, linked, filtered, explored and downloaded.
>
> -- [UCSC Xena](https://xena.ucsc.edu/)


## Installation

Install from Github:

```
if(!require(devtools)){
    install.packages("devtools", dependencies = TRUE)
}

devtools::install_github("ShixiangWang/UCSCXenaTools")
```

Load to R:

```
library(UCSCXenaTools)
```

## Usage

The following use clinical data download of LUNG, LUAD, LUSC from TCGA (hg19 version) as an example.

### Create a XenaHub object

Use `XenaHub()` to discover available resources, illustrated here
exploring available cohorts. It's also possible to explore `hosts()`
and `datasets()`.

```
xe <- XenaHub()
xe
## class: XenaHub 
## hosts():
##   https://ucscpublic.xenahubs.net
##   https://tcga.xenahubs.net
##   https://gdc.xenahubs.net
##   https://icgc.xenahubs.net
##   https://toil.xenahubs.net
## cohorts() (137 total):
##   (unassigned)
##   1000_genomes
##   Acute lymphoblastic leukemia (Mullighan 2008)
##   ...
##   TCGA Pan-Cancer (PANCAN)
##   TCGA TARGET GTEx
## datasets() (1521 total):
##   parsons2008cgh_public/parsons2008cgh_genomicMatrix
##   parsons2008cgh_public/parsons2008cgh_public_clinicalMatrix
##   vijver2002_public/vijver2002_genomicMatrix
##   ...
##   TCGA_survival_data
##   mc3.v0.2.8.PUBLIC.toil.xena
head(cohorts(xe))
## [1] "(unassigned)"                                 
## [2] "1000_genomes"                                 
## [3] "Acute lymphoblastic leukemia (Mullighan 2008)"
## [4] "B cells (Basso 2005)"                         
## [5] "Breast Cancer (Caldas 2007)"                  
## [6] "Breast Cancer (Chin 2006)"
```

We can specify the `hostName` argument to query only `TCGA` data.

```
XenaHub(hostName = "TCGA")
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
## datasets() (879 total):
##   TCGA.OV.sampleMap/HumanMethylation27
##   TCGA.OV.sampleMap/HumanMethylation450
##   TCGA.OV.sampleMap/Gistic2_CopyNumber_Gistic2_all_data_by_genes
##   ...
##   TCGA.MESO.sampleMap/MESO_clinicalMatrix
##   TCGA.MESO.sampleMap/Pathway_Paradigm_RNASeq_And_Copy_Number
```

### filter

There are too many datasets, we filter them by `filterXena` function.

Regular expression can be used to filter XenaHub object to what we want.

```
(filterXena(xe, filterDatasets = "clinical") -> xe2)
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
## datasets() (37 total):
##   TCGA.OV.sampleMap/OV_clinicalMatrix
##   TCGA.DLBC.sampleMap/DLBC_clinicalMatrix
##   TCGA.KIRC.sampleMap/KIRC_clinicalMatrix
##   ...
##   TCGA.READ.sampleMap/READ_clinicalMatrix
##   TCGA.MESO.sampleMap/MESO_clinicalMatrix
```

Then select `LUAD`, `LUSC` and `LUNG` 3 datasets.

```
(filterXena(xe2, filterDatasets = "LUAD|LUSC|LUNG")) -> xe2
```

Pipe can be used here.

```
suppressMessages(require(dplyr))

xe %>% 
    filterXena(filterDatasets = "clinical") %>% 
    filterXena(filterDatasets = "luad|lusc|lung")
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
```

### query

Create a query before download data

```
xe2_query = XenaQuery(xe2)

xe2_query
##                       hosts                                datasets
## 1 https://tcga.xenahubs.net TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
## 2 https://tcga.xenahubs.net TCGA.LUNG.sampleMap/LUNG_clinicalMatrix
## 3 https://tcga.xenahubs.net TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
##                                                                             url
## 1 https://tcga.xenahubs.net/download/TCGA.LUSC.sampleMap/LUSC_clinicalMatrix.gz
## 2 https://tcga.xenahubs.net/download/TCGA.LUNG.sampleMap/LUNG_clinicalMatrix.gz
## 3 https://tcga.xenahubs.net/download/TCGA.LUAD.sampleMap/LUAD_clinicalMatrix.gz
```

### download

Default, data will be downloaded to `XenaData` directory under work directory. You can specify the path.

If the data exists, command will not run to download them, but you can force it by `force` option.

```
xe2_download = XenaDownload(xe2_query, destdir = "E:/Github/XenaData/test/")
## We will download files to directory E:/Github/XenaData/test/.
## E:/Github/XenaData/test//TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz, the file has been download!
## E:/Github/XenaData/test//TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz, the file has been download!
## E:/Github/XenaData/test//TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz, the file has been download!
## Note fileNames transfromed from datasets name and / chracter all changed to __ character.
```

### prepare

There are 4 ways to prepare data to R.

```
# way1:  directory
cli1 = XenaPrepare("E:/Github/XenaData/test/")
names(cli1)
## [1] "TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz"
## [2] "TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz"
## [3] "TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz"
```

```
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
```

```
# way3: urls
cli3 = XenaPrepare(xe2_download$url[1:2])
names(cli3)
## [1] "LUSC_clinicalMatrix.gz" "LUNG_clinicalMatrix.gz"
```

```
# way4: xenadownload object
cli4 = XenaPrepare(xe2_download)
names(cli4)
## [1] "TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz"
## [2] "TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz"
## [3] "TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz"
```


## Acknowledgement

This package is based on [XenaR](https://github.com/mtmorgan/XenaR), thanks [Martin Morgan](https://github.com/mtmorgan) for his work.

## LICENSE

GPL-3

please note, code from XenaR package under Apache 2.0 license.

## TODO

* Fix bug
* Make use of `hosts`, `cohorts`, `datasets` and samples
* Make the whole process more quicker and easier

