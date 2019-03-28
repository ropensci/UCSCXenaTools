;datasetsNullRows
(fn []
  (query {:select [:name :rows] 
          :from [:dataset] 
          :where [:= :rows nil]}))