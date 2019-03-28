; featureList
(fn [dataset]
	(query {:select [:field.name :feature.longtitle]
			:from [:field]
			:where [:= :dataset_id {:select [:id]
							 :from [:dataset]
							 :where [:= :name dataset]}]
			:left-join [:feature [:= :feature.field_id :field.id]]}))

