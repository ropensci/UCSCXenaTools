; transcriptExpression
(fn [transcripts studyA subtypeA studyB subtypeB dataset]
  (let [tcgaTypes
        (map :value (query {:select [:value]
                            :from [:code]
                            :join [:field [:= :field_id :field.id]
                                   :dataset [:= :dataset_id :dataset.id]]
                            :where [:and [:= :dataset.name "TcgaTargetGTEX_phenotype.txt"]
                                         [:= :field.name "_sample_type"]
                                         [:not= :value ["Control Analyte" "Solid Tissue Normal"]]]}))
        fetchSamples {
          "tcga" (fn [subtype]
                  ((xena-query {:select ["sampleID"]
                                :from ["TcgaTargetGTEX_phenotype.txt"]
                                :where [:and [:in "_study" ["TCGA"]]
                                             [:in "_sample_type" tcgaTypes]
                                             [:in "detailed_category" [subtype]]]})  "sampleID"))
          "gtex" (fn [subtype]
                  ((xena-query {:select ["sampleID"]
                                :from ["TcgaTargetGTEX_phenotype.txt"]
                                :where [:and [:in "_study" ["GTEX"]]
                                             [:in "_sample_type" ["Normal Tissue"]]
                                             [:in "_primary_site" [subtype]]]}) "sampleID"))}]
    [(fetch [{:table dataset
              :columns transcripts
              :samples ((fetchSamples studyA) subtypeA)}])
     (fetch [{:table dataset
              :columns transcripts
              :samples ((fetchSamples studyB) subtypeB)}])]))
