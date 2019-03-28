; datasetMetadata
(fn [dataset]
    (let [count-table {:select [[:dataset.name :dname] [:%count.value :count]]
                       :from [:dataset]
                       :join [:field [:= :dataset.id :dataset_id]
                       :code [:= :field.id :field_id]]
                       :group-by [:dataset.name]
                       :where [:= :field.name "sampleID"]}]
        (query {:select [:d.name :d.longtitle :count :d.type :d.datasubtype :d.probemap :d.text :d.status [:pm-dataset.text :pmtext]]
                   :from [[:dataset :d]]
                   :left-join [[:dataset :pm-dataset] [:= :pm-dataset.name :d.probemap]
                                count-table [:= :dname :d.name]]
                   :where [:= :d.name dataset]})))
