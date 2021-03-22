# UCSCXenaTools 1.4.3

- Implemented using hiplot for `fetch()` functions.

# UCSCXenaTools 1.4.1 (1.4.2)

- Removed unpublished Xena hub TDI.

# UCSCXenaTools 1.4.0

- Supported downloading data from Hiplot mirror site <https://xena.hiplot.com.cn/>.

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
