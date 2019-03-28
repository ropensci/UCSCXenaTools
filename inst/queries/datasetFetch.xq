; datasetFetch
(fn [dataset samples probes]
  (fetch [{:table dataset
           :columns probes
           :samples samples}]))
