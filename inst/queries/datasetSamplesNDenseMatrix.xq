; datasetSamplesNDenseMatrix
(fn [dataset]
    (map :rows
        (query
            {:select [:rows]
             :from [:dataset]
             :where [:= :name dataset]})))
