; cohortSummary
(fn [exclude]
	(query {:select [:cohort [:%count.* :count]]
			:from [:dataset]
			:where [:not [:in :type exclude]]
			:group-by [:cohort]}))
