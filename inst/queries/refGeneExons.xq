; refGeneExons
(fn [dataset genes]
    (xena-query {:select ["position (2)" "position" "exonCount" "exonStarts" "exonEnds" "name2"]
                 :from [dataset]
                 :where [:in :any "name2" genes]}))
