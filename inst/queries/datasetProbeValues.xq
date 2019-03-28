; datasetProbeValues
(fn [dataset samples probes]
  (let [probemap (:probemap (car (query {:select [:probemap]
                                         :from [:dataset]
                                         :where [:= :name dataset]})))
        position (if probemap
                    ((xena-query {:select ["name" "position"]
                                  :from [probemap]
                                  :where [:in "name" probes]}) "position")
                    nil)]
    [position
     (fetch [{:table dataset
              :columns probes
              :samples samples}])]))

