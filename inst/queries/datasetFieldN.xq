; datasetFieldN
(fn [dataset]
   (:count (car (query {:select [[:%count.field.name :count]]
                        :from [:dataset]
                        :join [:field [:= :dataset.id :dataset_id]]
                        :where [:= :dataset.name dataset]}))))
