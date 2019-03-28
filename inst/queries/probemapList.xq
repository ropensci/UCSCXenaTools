;probemapList
(fn []
  (query {:select [:name :text]
          :from [:dataset]
          :where [:= :type "probeMap"]}))
