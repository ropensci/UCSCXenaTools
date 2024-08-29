# UCSCXenaTools 1.5.0

- Bugs fixed.
- Removed useless action or check config files.
- Removed the `XenaShiny()` function to reduce the dependencies.
- Updated XenaData. Only minor datasets change found from previous data release.
- Hiplot mirror is down, so we removed its usage in documentation (not delete internal code).
- Added two new queries from xenaPython.


# UCSCXenaTools 1.4.8

- Updated to latest Xena dataset list.

# UCSCXenaTools 1.4.7

- 3 datasets were added into `XenaData`.

```r
[1] "TCGA_survival_data_2.txt"                                  
[2] "clinical_CellLinePolyA_21.06_2021-06-15.tsv"               
[3] "CellLinePolyA_21.06_hugo_log2tpm_58581genes_2021-06-15.tsv"
```

- Added support for gene symbol checking and data cache in `fetch()`.

# UCSCXenaTools 1.4.6

- Added code to check hiplot server status.
- Fixed check warnings to follow CRAN policy (#36).

# UCSCXenaTools 1.4.5

- Fixed the download bug for pan-cancer data hub due to unvalid URL. `url_encode()`
is added internally to transform reserved characters (`/` is kept).
- Fixed the download bug because UCSCXenaShiny mutate the result of `XenaQuery()`
and thus change the column number. This bug will not affect XenaTools itself.

# UCSCXenaTools 1.4.4

- Fixed the download bug because UCSCXenaShiny mutate the result of `XenaQuery()`
and thus change the column order. This bug will not affect XenaTools itself.

# UCSCXenaTools 1.4.3

- Implemented using hiplot for `fetch()` functions.

# UCSCXenaTools 1.4.1 (1.4.2)

- Removed unpublished Xena hub TDI.

# UCSCXenaTools 1.4.0

- Supported downloading data from Hiplot mirror site (`https://xena.hiplot.com.cn/`).

# UCSCXenaTools 1.3.6

- Fixed a bug about try times for data download. 
- Make sure a message instead of an error will be returned if download process failed.

# UCSCXenaTools 1.3.5

- Added TDI data Hub containing 9 new datasets.

# UCSCXenaTools 1.3.4

* Updated UCSC Xena datasets, now 1670 datasets available.

# UCSCXenaTools 1.3.3

* Added `fetch_sparse_values()` function.
* Updated treehouse URL.
* Added treehouse datasets.

# UCSCXenaTools 1.3.2

* Fixed bug about an error happened when querying mutation data.
* Dropped "Treehouse" data hub.
* Updated code to update Xena hub datasets.

# UCSCXenaTools 1.3.1

* Added `max_try` option in query and download functions, so they can handle internet connection issue better

# UCSCXenaTools 1.3.0

* Added a new data hub: PCAWG Xena Hub (#24). 
* Added a new data hub: Kids First Xena Hub (#24).
* Updated data update function more robustly.
