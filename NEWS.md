# v1.2.2

## Minor changes

* update website and documentation

# v1.2.1

## Bug fixes

* fix API functions cannot be called from outside

## New features

* Add option to `XenaDownload` function for downloading gene id mapping data
* Add `XenaQueryProbeMap()` for querying probemap of datasets.

## Minor changes

* export `XenaHub` Class
* improve `XenaQuery` function
* update website and documentation

# v1.2.0

* reformat code files
* update `XenaData` & `XenaDataUpdate()` function to obtain more info
* add `jsonlite` as import package
* add metadata for all datasets into package `inst` dir

# v1.1.1

* update doc for APIs 
* modify description for package

# v1.1.0

* this version will change many variable names or functions. Update and Read the [documentation](https://github.com/ShixiangWang/UCSCXenaTools) are highly recommended!
* add API functions, this is inspired by [xenaPython](https://github.com/ucscXena/xenaPython) package
* remove useless query sentence from old code from XenaR
* I rename all hub names
* single cell hub is added
* new `XenaData` contains much more information
* improve internal code

# v1.0.1

* fix some grammar errors in documentation

# v1.0.0

* update README, documentation and vignette
* fix some typo
* new function: `XenaBrowse` - open the dataset link using web browser
* open grel all parameters to `XenaFilter` function

# v0.2.7

* fix bug #2
* add pipe operator
* add doc & docs

# v0.2.6

* add new datahub [**ATACseq**](https://xenabrowser.net/datapages/?host=https%3A%2F%2Fatacseq.xenahubs.net&removeHub=https%3A%2F%2Fxena.treehouse.gi.ucsc.edu%3A443) 
* enhance preparing data to R: provide options to select subset of original file data (see #1)

# v0.2.5

* add new datahub **PCAWG**
* speed up `XenaFilter` function

# v0.2.4

* add new function `getTCGAdata` to help user download TCGA data by projects and biological data type

# v0.2.3

* add shiny app to show TCGA datasets information of Xena
* add `downloadTCGA` function to help user quickly download TCGA datasets

# v0.2.2

* fix question about using temp directory

# v0.2.1

* Add two hosts: Treehouse and TCGA Pan-Cancer



