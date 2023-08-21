; datasetStatus
(fn [dataset]
	 (query {:select [:status :text] :from [:dataset] :where [:= :name dataset]}))
