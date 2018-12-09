
<!-- README.md is generated from README.Rmd. Please edit that file -->

# UCSCXenaTools: A R package download and explore data from **UCSC Xena data hubs**

<img src="https://github.com/ShixiangWang/UCSCXenaTools/blob/master/inst/figures/UCSCXenaTools.png" height="200" align="right" />

![](http://www.r-pkg.org/badges/version-last-release/UCSCXenaTools)
[![GitHub
tag](https://img.shields.io/github/tag/ShixiangWang/UCSCXenaTools.svg?label=Github)](https://github.com/ShixiangWang/UCSCXenaTools)
![](http://cranlogs.r-pkg.org/badges/UCSCXenaTools)
![](http://cranlogs.r-pkg.org/badges/grand-total/UCSCXenaTools)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/ShixiangWang/UCSCXenaTools?branch=master&svg=true)](https://ci.appveyor.com/project/ShixiangWang/UCSCXenaTools)
[![Coverage
Status](https://img.shields.io/codecov/c/github/ShixiangWang/UCSCXenaTools/master.svg)](https://codecov.io/github/ShixiangWang/UCSCXenaTools?branch=master)
[![GitHub
issues](https://img.shields.io/github/issues/ShixiangWang/UCSCXenaTools.svg)](https://github.com/ShixiangWang/UCSCXenaTools/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+)

**Current Version: 0.2.6**

`UCSCXenaTools` is a R package download and explore data from **UCSC
Xena data hubs**, which are

> A collection of UCSC-hosted public databases such as TCGA, ICGC,
> TARGET, GTEx, CCLE, and others. Databases are normalized so they can
> be combined, linked, filtered, explored and downloaded.
> 
> – [UCSC Xena](https://xena.ucsc.edu/)

If you use this package in academic field, please cite:

*Wang, Shixiang, et al. “APOBEC3B and APOBEC mutational signature as
potential predictive markers for immunotherapy response in non-small
cell lung cancer.” Oncogene (2018).*

## Installation

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
??UCSCXenaTools
```

## Data Hub List

All datasets are available at <https://xenabrowser.net/datapages/>.

Currently, `UCSCXenaTools` support all 9 data hubs of UCSC Xena.

  - UCSC Public Hub: <https://ucscpublic.xenahubs.net>
  - TCGA Hub: <https://tcga.xenahubs.net>
  - GDC Xena Hub: <https://gdc.xenahubs.net>
  - ICGC Xena Hub: <https://icgc.xenahubs.net>
  - Pan-Cancer Atlas Hub: <https://pancanatlas.xenahubs.net>
  - GA4GH (TOIL) Hub: <https://toil.xenahubs.net>
  - Treehouse Hub: <https://xena.treehouse.gi.ucsc.edu>
  - PCAWG: <https://pcawg.xenahubs.net>
  - ATAC-seq: <https://atacseq.xenahubs.net>

If the `API` changed, please remind me by email to <w_shixiang@163.com>
or open an issue on
[GitHub](https://github.com/ShixiangWang/UCSCXenaTools/issues).

## Usage

Download UCSC Xena Datasets and load them into R by `UCSCXenaTools` is a
workflow in `generate`, `filter`, `query`, `download` and `prepare` 5
steps, which are implemented as `XenaGenerate`, `XenaFilter`,
`XenaQuery`, `XenaDownload` and `XenaPrepare`, respectively. They are
very clear and easy to use and combine with other packages like `dplyr`.

The following use clinical data download of LUNG, LUAD, LUSC from TCGA
(hg19 version) as an example.

### XenaData data.frame

Begin from version `0.2.0`, `UCSCXenaTools` use a `data.frame` object
(built in package) `XenaData` to generate an instance of `XenaHub`
class, which communicate with API of UCSC Xena Data Hubs.

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

### Generate a XenaHub object

This can be implemented by `XenaGenerate` function, which generate
`XenaHub` object from `XenaData` data frame.

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
#>   https://pcawg.xenahubs.net
#> cohorts() (126 total):
#>   Acute lymphoblastic leukemia (Mullighan 2008)
#>   Breast Cancer (Caldas 2007)
#>   Breast Cancer (Chin 2006)
#>   ...
#>   PCAWG (donor centric)
#>   PCAWG (specimen centric)
#> datasets() (1583 total):
#>   mullighan2008_public/mullighan2008_500K_genomicMatrix
#>   mullighan2008_public/mullighan2008_public_clinicalMatrix
#>   mullighan2008_public/mullighan2008_SNP6_genomicMatrix
#>   ...
#>   relativePromoterActivity.sp
#>   promoterCentricTable_0.2_1.0.sp
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

> You can use `XenaHub()` to generate a `XenaHub` object for API
> communication, but it is not recommended.

It’s possible to explore `hosts()`, `cohorts()` and `datasets()`.

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
#> cohorts() (37 total):
#>   TCGA Acute Myeloid Leukemia (LAML)
#>   TCGA Adrenocortical Cancer (ACC)
#>   TCGA Bile Duct Cancer (CHOL)
#>   ...
#>   TCGA Thyroid Cancer (THCA)
#>   TCGA Uterine Carcinosarcoma (UCS)
#> datasets() (37 total):
#>   TCGA.LAML.sampleMap/LAML_clinicalMatrix
#>   TCGA.ACC.sampleMap/ACC_clinicalMatrix
#>   TCGA.CHOL.sampleMap/CHOL_clinicalMatrix
#>   ...
#>   TCGA.THCA.sampleMap/THCA_clinicalMatrix
#>   TCGA.UCS.sampleMap/UCS_clinicalMatrix
```

Then select `LUAD`, `LUSC` and `LUNG` 3 datasets.

``` r
XenaFilter(xe2, filterDatasets = "LUAD|LUSC|LUNG") -> xe2
```

Pipe can be used here.

``` r
suppressMessages(require(dplyr))

xe %>% 
    XenaFilter(filterDatasets = "clinical") %>% 
    XenaFilter(filterDatasets = "luad|lusc|lung")
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

### Query

Create a query before download data

``` r
xe2_query = XenaQuery(xe2)
xe2_query
#>                       hosts                                datasets
#> 1 https://tcga.xenahubs.net TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#> 2 https://tcga.xenahubs.net TCGA.LUNG.sampleMap/LUNG_clinicalMatrix
#> 3 https://tcga.xenahubs.net TCGA.LUSC.sampleMap/LUSC_clinicalMatrix
#>                                                                             url
#> 1 https://tcga.xenahubs.net/download/TCGA.LUAD.sampleMap/LUAD_clinicalMatrix.gz
#> 2 https://tcga.xenahubs.net/download/TCGA.LUNG.sampleMap/LUNG_clinicalMatrix.gz
#> 3 https://tcga.xenahubs.net/download/TCGA.LUSC.sampleMap/LUSC_clinicalMatrix.gz
```

### Download

Default, data will be downloaded to system temp directory. You can
specify the path.

If the data exists, command will not run to download them, but you can
force it by `force` option.

``` r
xe2_download = XenaDownload(xe2_query)
#> We will download files to directory /tmp/RtmpNXm4j5.
#> Downloading TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz
#> Downloading TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz
#> Downloading TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz
#> Note fileNames transfromed from datasets name and / chracter all changed to __ character.
## not run
#xe2_download = XenaDownload(xe2_query, destdir = "E:/Github/XenaData/test/")
```

> Note fileNames transfromed from datasets name and / chracter all
> changed to \_\_ character.

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
#> [1] "TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz"
#> [2] "TCGA.LUNG.sampleMap__LUNG_clinicalMatrix.gz"
#> [3] "TCGA.LUSC.sampleMap__LUSC_clinicalMatrix.gz"
```

## TCGA Common Data Easy Download

### getTCGAdata

`getTCGAdata` provide a quite easy download way for TCGA datasets, user
can specify multiple options to select which data and corresponding file
type want to download. Default this function will return a list include
`XenaHub` object and selective datasets information. Once you are sure
the datasets is exactly what you want, `download` can be set to `TRUE`
to download the data.

Check arguments of `getTCGAdata`:

``` r
args(getTCGAdata)
#> function (project = NULL, clinical = TRUE, download = FALSE, 
#>     forceDownload = FALSE, destdir = tempdir(), mRNASeq = FALSE, 
#>     mRNAArray = FALSE, mRNASeqType = "normalized", miRNASeq = FALSE, 
#>     exonRNASeq = FALSE, RPPAArray = FALSE, ReplicateBaseNormalization = FALSE, 
#>     Methylation = FALSE, MethylationType = c("27K", "450K"), 
#>     GeneMutation = FALSE, SomaticMutation = FALSE, GisticCopyNumber = FALSE, 
#>     Gistic2Threshold = TRUE, CopyNumberSegment = FALSE, RemoveGermlineCNV = TRUE, 
#>     ...) 
#> NULL

# or run
# ??getTCGAdata to read documentation
```

Select one or more projects, default will select only clinical datasets:

``` r
getTCGAdata(c("UVM", "LUAD"))
#> $Xena
#> class: XenaHub 
#> hosts():
#>   https://tcga.xenahubs.net
#> cohorts() (2 total):
#>   TCGA Lung Adenocarcinoma (LUAD)
#>   TCGA Ocular melanomas (UVM)
#> datasets() (2 total):
#>   TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#>   TCGA.UVM.sampleMap/UVM_clinicalMatrix
#> 
#> $DataInfo
#>                   XenaHosts XenaHostNames                     XenaCohorts
#> 1 https://tcga.xenahubs.net          TCGA TCGA Lung Adenocarcinoma (LUAD)
#> 2 https://tcga.xenahubs.net          TCGA     TCGA Ocular melanomas (UVM)
#>                              XenaDatasets ProjectID  DataType
#> 1 TCGA.LUAD.sampleMap/LUAD_clinicalMatrix      LUAD Phenotype
#> 2   TCGA.UVM.sampleMap/UVM_clinicalMatrix       UVM Phenotype
#>               FileType
#> 1 Clinical Information
#> 2 Clinical Information

tcga_data = getTCGAdata(c("UVM", "LUAD"))

# only return XenaHub object
tcga_data$Xena
#> class: XenaHub 
#> hosts():
#>   https://tcga.xenahubs.net
#> cohorts() (2 total):
#>   TCGA Lung Adenocarcinoma (LUAD)
#>   TCGA Ocular melanomas (UVM)
#> datasets() (2 total):
#>   TCGA.LUAD.sampleMap/LUAD_clinicalMatrix
#>   TCGA.UVM.sampleMap/UVM_clinicalMatrix

# only return datasets information
tcga_data$DataInfo
#>                   XenaHosts XenaHostNames                     XenaCohorts
#> 1 https://tcga.xenahubs.net          TCGA TCGA Lung Adenocarcinoma (LUAD)
#> 2 https://tcga.xenahubs.net          TCGA     TCGA Ocular melanomas (UVM)
#>                              XenaDatasets ProjectID  DataType
#> 1 TCGA.LUAD.sampleMap/LUAD_clinicalMatrix      LUAD Phenotype
#> 2   TCGA.UVM.sampleMap/UVM_clinicalMatrix       UVM Phenotype
#>               FileType
#> 1 Clinical Information
#> 2 Clinical Information
```

Set `download=TRUE` to download data, default data will be downloaded to
system temp directory (you can specify the path with `destdir` option):

``` r
# only download clinical data
getTCGAdata(c("UVM", "LUAD"), download = TRUE)
#> We will download files to directory /tmp/RtmpNXm4j5.
#> /tmp/RtmpNXm4j5/TCGA.LUAD.sampleMap__LUAD_clinicalMatrix.gz, the file has been download!
#> Downloading TCGA.UVM.sampleMap__UVM_clinicalMatrix.gz
#> Note fileNames transfromed from datasets name and / chracter all changed to __ character.
```

#### Support Data Type and Options

  - clinical information: `clinical`
  - mRNA Sequencing: `mRNASeq`
  - mRNA microarray: `mRNAArray`
  - miRNA Sequencing: `miRNASeq`
  - exon Sequencing: `exonRNASeq`
  - RPPA array: `RPPAArray`
  - DNA Methylation: `Methylation`
  - Gene mutation: `GeneMutation`
  - Somatic mutation: `SomaticMutation`
  - Gistic2 Copy Number: `GisticCopyNumber`
  - Copy Number Segment: `CopyNumberSegment`

> other data type supported by Xena cannot download use this function.
> Please refer to `downloadTCGA` function or `XenaGenerate` function.

**NOTE**: Sequencing data are all based on Illumina Hiseq platform,
other platform (Illumina GA) data supported by Xena cannot download
using this function. This is for building consistent data download flow.
Mutation use `broad automated` version (except `PANCAN` use `MC3 Public
Version`). If you wan to download other datasets, please refer to
`downloadTCGA` function or `XenaGenerate` function.

### download any TCGA data by datatypes and filetypes

`downloadTCGA` function can used to download any TCGA data supported by
Xena, but in a way different from `getTCGAdata` function.

``` r
# download RNASeq data (use UVM as an example)
downloadTCGA(project = "UVM",
                 data_type = "Gene Expression RNASeq",
                  file_type = "IlluminaHiSeq RNASeqV2")
```

See the arguments:

``` r
args(downloadTCGA)
#> function (project = NULL, data_type = NULL, file_type = NULL, 
#>     destdir = tempdir(), force = FALSE, ...) 
#> NULL
```

Except `destdir` option, you only need to select three arguments for
downloading data. Even throught the number is far less than
`getTCGAdata`, it is more complex than the latter.

Before you download data, you need spare some time to figure out what
data type and file type available and what your datasets have.

`availTCGA` can return all information you need:

``` r
availTCGA()
#> Note not all projects have listed data types and file types, you can use showTCGA function to check if exist
#> $ProjectID
#>  [1] "LAML"     "ACC"      "CHOL"     "BLCA"     "BRCA"     "CESC"    
#>  [7] "COADREAD" "COAD"     "UCEC"     "ESCA"     "FPPP"     "GBM"     
#> [13] "HNSC"     "KICH"     "KIRC"     "KIRP"     "DLBC"     "LIHC"    
#> [19] "LGG"      "GBMLGG"   "LUAD"     "LUNG"     "LUSC"     "SKCM"    
#> [25] "MESO"     "UVM"      "OV"       "PANCAN"   "PAAD"     "PCPG"    
#> [31] "PRAD"     "READ"     "SARC"     "STAD"     "TGCT"     "THYM"    
#> [37] "THCA"     "UCS"     
#> 
#> $DataType
#>  [1] "DNA Methylation"                       
#>  [2] "Gene Level Copy Number"                
#>  [3] "Somatic Mutation"                      
#>  [4] "Gene Expression RNASeq"                
#>  [5] "miRNA Mature Strand Expression RNASeq" 
#>  [6] "Gene Somatic Non-silent Mutation"      
#>  [7] "Copy Number Segments"                  
#>  [8] "Exon Expression RNASeq"                
#>  [9] "Phenotype"                             
#> [10] "PARADIGM Pathway Activity"             
#> [11] "Protein Expression RPPA"               
#> [12] "Transcription Factor Regulatory Impact"
#> [13] "Gene Expression Array"                 
#> [14] "Signatures"                            
#> [15] "iCluster"                              
#> 
#> $FileType
#>  [1] "Methylation27K"                            
#>  [2] "Methylation450K"                           
#>  [3] "Gistic2"                                   
#>  [4] "wustl hiseq automated"                     
#>  [5] "IlluminaGA RNASeq"                         
#>  [6] "IlluminaHiSeq RNASeqV2 in percentile rank" 
#>  [7] "IlluminaHiSeq RNASeqV2 pancan normalized"  
#>  [8] "IlluminaHiSeq RNASeqV2"                    
#>  [9] "After remove germline cnv"                 
#> [10] "PANCAN AWG analyzed"                       
#> [11] "Clinical Information"                      
#> [12] "wustl automated"                           
#> [13] "Gistic2 thresholded"                       
#> [14] "Before remove germline cnv"                
#> [15] "Use only RNASeq"                           
#> [16] "Use RNASeq plus Copy Number"               
#> [17] "bcm automated"                             
#> [18] "IlluminaHiSeq RNASeq"                      
#> [19] "bcm curated"                               
#> [20] "broad curated"                             
#> [21] "RPPA"                                      
#> [22] "bsgsc automated"                           
#> [23] "broad automated"                           
#> [24] "bcgsc automated"                           
#> [25] "ucsc automated"                            
#> [26] "RABIT Use IlluminaHiSeq RNASeqV2"          
#> [27] "RABIT Use IlluminaHiSeq RNASeq"            
#> [28] "RPPA normalized by RBN"                    
#> [29] "RABIT Use Agilent 244K Microarray"         
#> [30] "wustl curated"                             
#> [31] "Use Microarray plus Copy Number"           
#> [32] "Use only Microarray"                       
#> [33] "Agilent 244K Microarray"                   
#> [34] "IlluminaGA RNASeqV2"                       
#> [35] "bcm SOLiD"                                 
#> [36] "RABIT Use IlluminaGA RNASeqV2"             
#> [37] "RABIT Use IlluminaGA RNASeq"               
#> [38] "RABIT Use Affymetrix U133A Microarray"     
#> [39] "Affymetrix U133A Microarray"               
#> [40] "MethylMix"                                 
#> [41] "bcm SOLiD curated"                         
#> [42] "Gene Expression Subtype"                   
#> [43] "Platform-corrected PANCAN12 dataset"       
#> [44] "Batch effects normalized"                  
#> [45] "MC3 Public Version"                        
#> [46] "TCGA Sample Type and Primary Disease"      
#> [47] "RPPA pancan normalized"                    
#> [48] "Tumor copy number"                         
#> [49] "Genome-wide DNA Damage Footprint HRD Score"
#> [50] "TCGA Molecular Subtype"                    
#> [51] "iCluster cluster assignments"              
#> [52] "iCluster latent variables"                 
#> [53] "RNA based StemnessScore"                   
#> [54] "DNA methylation based StemnessScore"       
#> [55] "Pancan Gene Programs"                      
#> [56] "Immune Model Based Subtype"                
#> [57] "Immune Signature Scores"
```

Note not all datasets have these property, `showTCGA` can help you to
check it. It will return all data in TCGA, you can use following code in
RStudio and search your data.

``` r
View(showTCGA())
```

**OR you can use shiny app provided by `UCSCXenaTools` to search**.

Run shiny by:

``` r
UCSCXenaTools::XenaShiny()
```

Download by shiny is under consideration, I am try learning more about
how to operate shiny.

## SessionInfo

``` r
sessionInfo()
#> R version 3.5.1 (2018-07-02)
#> Platform: x86_64-pc-linux-gnu (64-bit)
#> Running under: elementary OS 5.0 Juno
#> 
#> Matrix products: default
#> BLAS: /home/zd/anaconda3/lib/R/lib/libRblas.so
#> LAPACK: /home/zd/anaconda3/lib/R/lib/libRlapack.so
#> 
#> locale:
#>  [1] LC_CTYPE=zh_CN.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=zh_CN.UTF-8        LC_COLLATE=zh_CN.UTF-8    
#>  [5] LC_MONETARY=zh_CN.UTF-8    LC_MESSAGES=zh_CN.UTF-8   
#>  [7] LC_PAPER=zh_CN.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=zh_CN.UTF-8 LC_IDENTIFICATION=C       
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] bindrcpp_0.2.2       dplyr_0.7.6          UCSCXenaTools_0.2.5 
#> [4] RevoUtils_11.0.1     RevoUtilsMath_11.0.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] Rcpp_0.12.18         knitr_1.20           bindr_0.1.1         
#>  [4] magrittr_1.5         hms_0.4.2            tidyselect_0.2.4    
#>  [7] xtable_1.8-2         R6_2.2.2             rlang_0.2.1         
#> [10] httr_1.3.1           stringr_1.3.1        tools_3.5.1         
#> [13] shinydashboard_0.7.1 htmltools_0.3.6      yaml_2.2.0          
#> [16] rprojroot_1.3-2      digest_0.6.15        assertthat_0.2.0    
#> [19] tibble_1.4.2         crayon_1.3.4         shiny_1.1.0         
#> [22] readr_1.1.1          later_0.7.3          purrr_0.2.5         
#> [25] promises_1.0.1       mime_0.5             glue_1.3.0          
#> [28] evaluate_0.11        rmarkdown_1.10       stringi_1.2.4       
#> [31] compiler_3.5.1       pillar_1.3.0         backports_1.1.2     
#> [34] httpuv_1.4.5         pkgconfig_2.0.1
```

## Bug Report

I have no time to test if all condition are right and all datasets can
normally be downloaded. So if you have any question or suggestion,
please open an issue on Github at
<https://github.com/ShixiangWang/UCSCXenaTools/issues>.

## Acknowledgement

This package is based on [XenaR](https://github.com/mtmorgan/XenaR),
thanks [Martin Morgan](https://github.com/mtmorgan) for his work.

## LICENSE

GPL-3

please note, code from XenaR package under Apache 2.0 license.

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.
