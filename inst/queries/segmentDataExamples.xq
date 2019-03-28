; sparseDataExample
(fn [dataset count]
	{:rows (xena-query {:select ["sampleID" "position" "value"]
						:from [dataset]
						:limit count})})
