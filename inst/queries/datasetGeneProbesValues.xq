; datasetGeneProbesValues
(fn [dataset samples genes]
	(let [probemap (:probemap (car (query {:select [:probemap]
										   :from [:dataset]
										   :where [:= :name dataset]})))
			position (xena-query {:select ["name" "position"] :from [probemap] :where [:in :any "genes" genes]})
			probes (position "name")]
	  [position
		(fetch [{:table dataset
				 :samples samples
				 :columns probes}])]))
