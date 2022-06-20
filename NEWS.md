# UCSCXenaTools 1.4.8

- Updated treehouse data hub URL.
- 33 treehouse datasets added.

```r
  XenaHostNames XenaDatasets                                                              
   <chr>         <chr>                                                                     
 1 treehouseHub  vaske2019_Participant_Expression_log2TPM_Hugo-2019-09-05.tsv              
 2 treehouseHub  vaske2019_Participant_Clinical-2019-09-12.tsv                             
 3 treehouseHub  TumorCompendium_v11_PolyA_hugo_log2tpm_58581genes_2020-04-09.tsv          
 4 treehouseHub  clinical_TumorCompendium_v11_PolyA_2020-04-09.tsv                         
 5 treehouseHub  TumorCompendium_v11_PolyA_ensembl_expected_count_58581genes_2020-04-09.tsv
 6 treehouseHub  TumorCompendium_v10_PolyA_ensembl_expected_count_58581genes_2019-07-25.tsv
 7 treehouseHub  TumorCompendium_v10_PolyA_hugo_log2tpm_58581genes_2019-07-25.tsv          
 8 treehouseHub  clinical_TumorCompendium_v10_PolyA_2020-01-28.tsv                         
 9 treehouseHub  TreehousePEDv9_clinical_metadata.2019-03-15.tsv                           
10 treehouseHub  TreehousePEDv9_unique_ensembl_expected_count.2019-03-15.tsv               
11 treehouseHub  TreehousePEDv9_unique_hugo_log2_tpm_plus_1.2019-03-15.tsv                 
12 treehouseHub  TreehousePEDv9_Ribodeplete_clinical_metadata.2019-03-25.tsv               
13 treehouseHub  TreehousePEDv9_Ribodeplete_unique_ensembl_expected_count.2019-03-25.tsv   
14 treehouseHub  TreehousePEDv9_Ribodeplete_unique_hugo_log2_tpm_plus_1.2019-03-25.tsv     
15 treehouseHub  clinical_CellLinePolyA_21.06_2021-06-15.tsv                               
16 treehouseHub  CellLinePolyA_21.06_hugo_log2tpm_58581genes_2021-06-15.tsv                
17 treehouseHub  vaske2019_Reference_v5_Clinical_2019-09-12.tsv                            
18 treehouseHub  vaske2019_Reference_v5_Expression_log2TPM_Hugo-2019-09-12.tsv             
19 treehouseHub  treehouse_public_samples_clinical_metadata.2017-09-11.tsv                 
20 treehouseHub  treehouse_public_samples_unique_ensembl_expected_count.2017-09-11.tsv     
21 treehouseHub  treehouse_public_samples_unique_hugo_log2_tpm_plus_1.2017-09-11.tsv       
22 treehouseHub  HybridCaptureCompendium_21.02_hugo_log2tpm_58581genes_2021-02-18.tsv      
23 treehouseHub  clinical_HybridCaptureCompendium_21.02_2021-02-18.tsv                     
24 treehouseHub  TreehousePEDv5_clinical_metadata.2018-05-09.tsv                           
25 treehouseHub  TreehousePEDv5_unique_ensembl_expected_count.2018-06-26.tsv               
26 treehouseHub  TreehousePEDv5_unique_hugo_log2_tpm_plus_1.2018-05-09.tsv                 
27 treehouseHub  TreehousePEDv8_clinical_metadata.2018-07-25.tsv                           
28 treehouseHub  TreehousePEDv8_unique_ensembl_expected_count.2018-07-26.tsv               
29 treehouseHub  TreehousePEDv8_unique_hugo_log2_tpm_plus_1.2018-07-25.tsv                 
30 treehouseHub  CCLEv1_hugo_log2tpm_58581genes_2019-04-15.tsv                             
31 treehouseHub  CellLineIndex_CCLE_RNAseq_forComp_051519.tsv                              
32 treehouseHub  clinical_TreehouseCellLineCompendium_v2_2019-12-02.tsv                    
33 treehouseHub  TreehouseCellLineCompendium_v2_hugo_log2tpm_58581genes_2019-12-02.tsv    
```

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
