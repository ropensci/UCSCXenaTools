---
title: "Simple Client for UCSC Xena Genome Data and Analysis Hub"
output: html_document
vignette: >
  % \VignetteIndexEntry{Monday Lab, part B.1: Introduction to Bioconductor}
  % \VignetteEngine{knitr::rmarkdown}
---

NOTE: generated from inst/README.Rmd


```
## Title: Simple Client to UCSC Xena
## Author: Martin Morgan [cre]
## Version: 0.0.1
## 
## -- File: /home/mtmorgan/R/x86_64-unknown-linux-gnu-library/3.2-BiocDevel/XenaR/Meta/package.rds 
## -- Fields read: Title, Author, Version
```

This package is a simple client to the data management aspects of UCSC
[Xena](http://xena.ucsc.edu). It is very much a work in progress.

Install (one-time; using `biocLite()` or `devtools::install_github()`)
and then load the library.


```r
source("http://bioconductor.org/biocLite.R")
biocLite("mtmorgan/xenar") 
```

```r
library(XenaR) 
```

## Discovery

Use `XenaHub()` to discover available resources, illustrated here
exploring available cohorts. It's also possible to explore `hosts()`
and `datasets()`.


```r
xe <- XenaHub()
xe
```

```
## class: XenaHub 
## hosts():
##   https://genome-cancer.soe.ucsc.edu/proj/public/xena
## cohorts() (77 total):
##   (unassigned)
##   1000_genomes
##   balagurunathan2008_public
##   ...
##   weir2007_public
##   YauClinical_public
## datasets() (1014 total):
##   public/TCGA/TCGA.UCS.sampleMap/RPPA
##   public/TCGA/TCGA.UCS.sampleMap/HiSeqV2_exon
##   public/TCGA/TCGA.UCS.sampleMap/HiSeqV2
##   ...
##   public/other/1000_genomes/BRCA1
##   public/other/1000_genomes/BRCA2
```

```r
head(cohorts(xe))
```

```
## [1] "(unassigned)"              "1000_genomes"             
## [3] "balagurunathan2008_public" "bardeesy2006_public"      
## [5] "basso2005_public"          "ccle"
```

## Refinement

Having identified one (or more) hosts, cohorts, datasets of interest,
provide these as arguments to `XenaHub()`, e.g., to work with the
"ccle" corhort,


```r
xe <- XenaHub(cohorts="ccle")
xe
```

```
## class: XenaHub 
## hosts():
##   https://genome-cancer.soe.ucsc.edu/proj/public/xena
## cohorts() (1 total):
##   ccle
## datasets() (4 total):
##   public/other/ccle/CCLE_Expression_2012-04-06.matrix
##   public/other/ccle/ccle_clinicalMatrix
##   public/other/ccle/CCLE_Expression_Entrez_2012-04-06.matrix
##   public/other/ccle/CCLE.copynumber.hugomatrix
```

```r
datasets(xe)
```

```
## [1] "public/other/ccle/CCLE_Expression_2012-04-06.matrix"       
## [2] "public/other/ccle/ccle_clinicalMatrix"                     
## [3] "public/other/ccle/CCLE_Expression_Entrez_2012-04-06.matrix"
## [4] "public/other/ccle/CCLE.copynumber.hugomatrix"
```

Mix cohorts as required, e.g.,


```r
XenaHub(cohorts=c("ccle", "1000_genomes"))
```

```
## class: XenaHub 
## hosts():
##   https://genome-cancer.soe.ucsc.edu/proj/public/xena
## cohorts() (2 total):
##   ccle
##   1000_genomes
## datasets() (6 total):
##   public/other/ccle/CCLE_Expression_2012-04-06.matrix
##   public/other/ccle/ccle_clinicalMatrix
##   public/other/ccle/CCLE_Expression_Entrez_2012-04-06.matrix
##   public/other/ccle/CCLE.copynumber.hugomatrix
##   public/other/1000_genomes/BRCA1
##   public/other/1000_genomes/BRCA2
```

One is often interested in identifying samples or features present in
each data set, or shared by all data sets, or present in any of
several data sets. Identifying these samples, including samples in
arbitrarily chosen data sets, is shown below.


```r
## samples in each dataset, first host
x <- samples(xe, by="datasets", how="each")[[1]]
lengths(x)        # data sets in ccle cohort on first (only) host
```

```
##        public/other/ccle/CCLE_Expression_2012-04-06.matrix 
##                                                        967 
##                      public/other/ccle/ccle_clinicalMatrix 
##                                                        972 
## public/other/ccle/CCLE_Expression_Entrez_2012-04-06.matrix 
##                                                        967 
##               public/other/ccle/CCLE.copynumber.hugomatrix 
##                                                        972
```

```r
sapply(x, head, 3)                 # 3 sample identifiers
```

```
##      public/other/ccle/CCLE_Expression_2012-04-06.matrix
## [1,] "NCIN87_STOMACH"                                   
## [2,] "CMK86_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"         
## [3,] "PCM6_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"          
##      public/other/ccle/ccle_clinicalMatrix     
## [1,] "NCIN87_STOMACH"                          
## [2,] "CMK86_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"
## [3,] "PCM6_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE" 
##      public/other/ccle/CCLE_Expression_Entrez_2012-04-06.matrix
## [1,] "NCIN87_STOMACH"                                          
## [2,] "CMK86_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"                
## [3,] "PCM6_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"                 
##      public/other/ccle/CCLE.copynumber.hugomatrix
## [1,] "NCIN87_STOMACH"                            
## [2,] "CMK86_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"  
## [3,] "PCM6_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"
```

```r
## samples common to _all_ datasets, 1st host
y <- samples(xe, by="datasets", how="all")[[1]]
length(y)
```

```
## [1] 967
```

```r
Map(function(x) all(y %in% x), x)
```

```
## $`public/other/ccle/CCLE_Expression_2012-04-06.matrix`
## [1] TRUE
## 
## $`public/other/ccle/ccle_clinicalMatrix`
## [1] TRUE
## 
## $`public/other/ccle/CCLE_Expression_Entrez_2012-04-06.matrix`
## [1] TRUE
## 
## $`public/other/ccle/CCLE.copynumber.hugomatrix`
## [1] TRUE
```

```r
## samples in _any_ dataset, 1st host
z <- samples(xe, by="dataset", how="any")[[1]]
length(z)
```

```
## [1] 972
```

```r
Map(function(x) all(x %in% z), x)
```

```
## $`public/other/ccle/CCLE_Expression_2012-04-06.matrix`
## [1] TRUE
## 
## $`public/other/ccle/ccle_clinicalMatrix`
## [1] TRUE
## 
## $`public/other/ccle/CCLE_Expression_Entrez_2012-04-06.matrix`
## [1] TRUE
## 
## $`public/other/ccle/CCLE.copynumber.hugomatrix`
## [1] TRUE
```

```r
## samples in the first and fourth datasets
datasets(xe)[c(1, 4)]
```

```
## [1] "public/other/ccle/CCLE_Expression_2012-04-06.matrix"
## [2] "public/other/ccle/CCLE.copynumber.hugomatrix"
```

```r
w <- samples(xe, datasets(xe)[c(1, 4)], by="datasets", how="all")[[1]]
length(w)
```

```
## [1] 967
```

```r
head(w)
```

```
## [1] "NCIN87_STOMACH"                          
## [2] "CMK86_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"
## [3] "PCM6_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE" 
## [4] "SNU1105_CENTRAL_NERVOUS_SYSTEM"          
## [5] "DM3_PLEURA"                              
## [6] "NOMO1_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE"
```

# TODO

Lots!

- `features()` to enable selection of features across datasets,
  cohorts, etc.
- `XenaExperiment()` to represent a collection of datasets from
  `XenaHub()`, subset to contain specific samples and features.
- Basic data retirieval of all or part of the assays present in a
  `XenaExperiment`.
