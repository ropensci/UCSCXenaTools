; allDatasets
(fn []
	(query {:select [:name :type]
               :from [:dataset]}))