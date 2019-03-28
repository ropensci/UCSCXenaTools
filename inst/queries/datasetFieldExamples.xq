; datasetFieldExamples
(fn [dataset count]
    (map :name (query {:select [:field.name]
                       :from [:dataset]
                       :join [:field [:= :dataset.id :dataset_id]]
                       :where [:= :dataset.name dataset]
                       :limit count})))
