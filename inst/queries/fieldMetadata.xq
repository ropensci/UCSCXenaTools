; fieldMetadata
(fn [dataset fields]
	(query
	  {:select [:P.name :feature.*]
	   :from [[{:select [:field.name :field.id]
				:from [:field]
				:join [{:table [[[:name :varchar fields]] :T]} [:= :T.name :field.name]]
				:where [:= :dataset_id {:select [:id]
								 :from [:dataset]
								 :where [:= :name dataset]}]} :P]]
	   :left-join [:feature [:= :feature.field_id :P.id]]}))
