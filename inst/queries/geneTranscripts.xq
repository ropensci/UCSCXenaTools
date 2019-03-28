; geneTranscripts
(fn [dataset gene]
	(xena-query {:select ["name" "position (2)" "position" "exonCount" "exonStarts" "exonEnds"]
				 :from [dataset]
				 :where [:in :any "name2" [gene]]}))


