host = "https://toil.xenahubs.net"
dataset = "tcga_RSEM_gene_tpm"
samples = c("TCGA-02-0047-01","TCGA-02-0055-01","TCGA-02-2483-01","TCGA-02-2485-01")
probes = c('ENSG00000282740.1', 'ENSG00000000005.5', 'ENSG00000000419.12')
genes =c("TP53", "RB1", "PIK3CA")

# How about clinical data?
luad_host = "https://tcga.xenahubs.net"
luad_dataset = "TCGA.LUAD.sampleMap/LUAD_clinicalMatrix"

# Test fetch_*

fetch_dense_values(host, dataset, probes, samples, check = TRUE)
fetch_dense_values(host, dataset, probes, samples, check = FALSE)  # much faster

# obtain all datasets
system.time(fetch_dense_values(host, dataset, check = TRUE))
system.time(fetch_dense_values(host, dataset, check = FALSE))  # faster

fetch_dense_values(host, dataset, probes, samples, check = FALSE)
fetch_dense_values(host, dataset, genes, samples, check = FALSE, use_probeMap = TRUE)

fetch_dense_values(host, "tcga_RSEM_Hugo_norm_count", genes, samples, check = FALSE)

# works for clinical?
# only works for numeric variables
fetch_dense_values(luad_host, luad_dataset, check = FALSE) -> tt
