;probeCount
(fn [dataset]
  (query {:select [:name :rows] 
  		  :from [:dataset]
  		  :where [:= :dataset.name dataset]}))