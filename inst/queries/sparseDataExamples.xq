; sparseDataExample
(fn [dataset count]
	{:rows (xena-query {:select ["ref" "alt" "altGene" "effect" "dna-vaf" "rna-vaf" "amino-acid" "genes" "sampleID" "position"]
						:from [dataset]
						:limit count})})
