; segmentedDataRange
(fn [dataset samples chr start end]
	(let [getfield (fn [field]
					 (:id (car (query {:select [:field.id]
									   :from [:dataset]
									   :join [:field [:= :dataset.id :field.dataset_id]]
									   :where [:and [:= :field.name field] [:= :dataset.name dataset]]}))))
		  sampleID (getfield "sampleID")]
	  {:samples (map :value (query {:select [:value]
									:from [:code]
									:where [:and [:in :value samples][:= :field_id sampleID]]}))
	   :rows (xena-query {:select ["sampleID" "position" "value"]
						  :from [dataset]
						  :where [:and [:in "position" [[chr start end]]] [:in "sampleID" samples]]})}))
