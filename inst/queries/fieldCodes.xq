; fieldCodes
(fn [dataset fields]
	(query
	  {:select [:P.name [#sql/call [:group_concat :value :order :ordering :separator #sql/call [:chr 9]] :code]]
	   :from [[{:select [:field.id :field.name]
				:from [:field]
				:join [{:table [[[:name :varchar fields]] :T]} [:= :T.name :field.name]]
				:where [:= :dataset_id {:select [:id]
								 :from [:dataset]
								 :where [:= :name dataset]}]} :P]]
	   :left-join [:code [:= :P.id :field_id]]
	   :group-by [:P.id]}))
