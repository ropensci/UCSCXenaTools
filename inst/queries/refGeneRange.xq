; refGeneRange
(fn [dataset chr start end]
	(xena-query {:select ["position (2)" "position" "exonCount" "exonStarts" "exonEnds" "name2"]
				:from [dataset]
				:where [:in "position" [[chr start end]]]}))