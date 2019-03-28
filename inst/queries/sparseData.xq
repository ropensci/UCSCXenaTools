; sparseData
(fn [dataset samples genes]
	(let [getfield (fn [field]
					 (:id (car (query {:select [:field.id]
									   :from [:dataset]
									   :join [:field [:= :dataset.id :field.dataset_id]]
									   :where [:and [:= :field.name field] [:= :dataset.name dataset]]}))))
		  sampleID (getfield "sampleID")]
	  {:samples (map :value (query {:select [:value]
									:from [:code]
									:where [:and [:in :value samples][:= :field_id sampleID]]}))
	   :rows (xena-query {:select ["ref" "alt" "altGene" "effect" "dna-vaf" "rna-vaf" "amino-acid" "genes" "sampleID" "position"]
						  :from [dataset]
						  :where [:and [:in :any "genes" genes] [:in "sampleID" samples]]})}))
