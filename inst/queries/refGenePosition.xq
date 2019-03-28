; refGenePosition
(fn [dataset gene]
	(car ((xena-query {:select ["position"] :from [dataset] :where [:in :any "name2" [gene]]}) "position")))
