;datasetProbeSignature
(fn [dataset samples probes weights]
 (let [vals (fetch [{:table dataset
                     :samples samples
                     :columns probes}])]
     (apply + (map (fn [w v] (* v w)) weights vals))))
