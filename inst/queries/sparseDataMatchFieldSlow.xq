; sparseDataMatchFieldSlow
(fn [field dataset names]
	(let [getfield (fn [field]
					 (:id (car (query {:select [:field.id]
									   :from [:dataset]
									   :join [:field [:= :dataset.id :field.dataset_id]]
									   :where [:and [:= :field.name field] [:= :dataset.name dataset]]}))))
		  genes (getfield field)]
	  (map :gene (query {:select [:%distinct.gene]
						 :from [:field_gene]
						 :where [:and
								 [:= :field_gene.field_id genes]
								 [:in :%lower.gene names]]}))))

