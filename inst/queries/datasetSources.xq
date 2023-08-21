; datasetSources
(fn [dataset]
  (query {:select [:source.name :source.hash]
          :from [:dataset]
          :join [:dataset_source [:= :dataset.id :dataset_id]
                 :source [:= :source.id :source_id]]
          :where [:= :dataset.name dataset]}))
