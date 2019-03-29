.init_api()

dataset_probe_signature

hub = "https://toil.xenahubs.net"
dataset = "tcga_RSEM_gene_tpm"
samples = c("TCGA-02-0047-01","TCGA-02-0055-01","TCGA-02-2483-01","TCGA-02-2485-01")
genes =c("TP53", "RB1", "PIK3CA")
dataset_gene_probe_avg(hub, dataset, samples, genes)

all_cohorts(hub, exclude = NULL)
all_datasets(hub)
