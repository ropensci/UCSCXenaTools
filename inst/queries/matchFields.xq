; matchFields
(fn [dataset names]
	(map :name (query {:select [:field.name]
					   :from [:dataset]
					   :join [:field [:= :dataset.id :field.dataset_id]]
					   :where [:and [:in :%lower.field.name names] [:= :dataset.name dataset]]})))
