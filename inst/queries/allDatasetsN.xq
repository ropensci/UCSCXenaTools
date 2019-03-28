; allDatasetsN
(fn []
	(count (query {:select [:cohort]
               :from [:dataset]
               :where [:<> :cohort nil]})))
