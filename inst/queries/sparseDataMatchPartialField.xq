; sparseDataMatchPartialField
(fn [field dataset names limit]
	(let [getfield (fn [field]
					 (:id (car (query {:select [:field.id]
									   :from [:dataset]
									   :join [:field [:= :dataset.id :field.dataset_id]]
									   :where [:and [:= :field.name field] [:= :dataset.name dataset]]}))))
		  genes (getfield field)]
	  (map :gene (query {:select [:%distinct.gene]
						 :limit limit
						 :order-by [:gene]
						 :from [:field_gene]
						 :join [{:table [[[:name :varchar names]] :T]} [:like :gene :T.name]]
						 :where [:= :field_gene.field_id genes]}))))
