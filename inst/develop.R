# There are three primary data types: dense matrix (samples by probes), sparse (sample, position, variant), and segmented (sample, position, value).
#
# Dense matrices can be genotypic or phenotypic. Phenotypic matrices have associated field metadata (descriptive names, codes, etc.). Genotypic matricies may have an associated probeMap, which maps probes to genomic locations. If a matrix has hugo probeMap, the probes themselves are gene names. Otherwise, a probeMap is used to map a gene location to a set of probes.

hub = "https://toil.xenahubs.net"
dataset = "tcga_RSEM_gene_tpm"
samples = c("TCGA-02-0047-01","TCGA-02-0055-01","TCGA-02-2483-01","TCGA-02-2485-01")
probes = c('ENSG00000282740.1', 'ENSG00000000005.5', 'ENSG00000000419.12')
genes =c("TP53", "RB1", "PIK3CA")

.p_dataset_probe_values(hub, dataset, samples, probes)
.p_dataset_field(hub, dataset)


.p_dataset_gene_probe_avg(hub, dataset, samples, genes)
.p_dataset_probe_values(hub, dataset, samples, genes)
.p_dataset_fetch(hub, dataset, samples, probes)
.p_dataset_fetch(hub, dataset, samples, genes)

xe = XenaGenerate(XenaData, subset = XenaHosts == hub)

obtain_probe_values(host = hub, dataset = dataset, samples = samples[2], probes = probes[1])

obtain_probe_values = function(xe=NULL, host, dataset, probes=NULL, samples=NULL){
    # stopifnot(length(samples)>=1, length(probes)>=1,
    #           is.character(samples), is.character(probes))

    if (length(samples) == 1) {
        samples <- as.list(samples)
    }
    if (length(probes) == 1) {
        probes <- as.list(probes)
    }

    if (!is.null(xe)) {
        if (class(xe) != "XenaHub") {
            stop("When 'xe' is not NULL, it should be a 'XenaHub' object!")
        }

        all_datasets = datasets(xe)
        n_datasets = length(all_datasets)
        if (n_datasets == 0) {
            stop("NO dataset found!")
        } else if (length(all_datasets) > 1) {
            message(">1 datasets are detected.")
            lapply(all_datasets, function(x) {
                host = XenaData[XenaData$XenaDatasets == x, ]$XenaHosts
                if (length(host) > 1) {
                    stop("Two hosts mapping to one dataset, please use another way for this dataset by specifying both 'host' and 'dataset' ")
                }
                res <- .p_dataset_fetch(host, x, samples, probes)
                rownames(res) <- probes
                colnames(res) <- samples
                res
            })
        } else {
            host = hosts(xe)
            res <- .p_dataset_fetch(host, all_datasets, samples, probes)
            rownames(res) <- probes
            colnames(res) <- samples
            res
        }
    } else if (!all(is.character(host), is.character(dataset))) {
        stop("Input have some problems, please check!")
    } else {
        if (!all(is.character(host), is.character(dataset))) {
            stop("When 'xe' is NULL, 'host' and 'dataset' both must be specified.")
        }
        res <- .p_dataset_fetch(host, dataset, samples, probes)
        rownames(res) <- probes
        colnames(res) <- samples
        res
    }
}


# problem
# > .p_dataset_fetch(luad_host, luad_dataset, samples  = as.list("TCGA-05-4249-01"), probes = as.list("ABSOLUTE_Ploidy"))
# [,1]
# [1,] 3.77
# > .p_dataset_fetch(luad_host, luad_dataset, samples  = as.list("TCGA-05-4249-01"), probes = as.list("BRAF"))
# [,1]
# [1,]    1
# > .p_dataset_fetch(luad_host, luad_dataset, samples  = as.list("TCGA-05-4249-01"), probes = as.list("EGFR"))
# [,1]
# [1,]    0
# > .p_dataset_fetch(luad_host, luad_dataset, samples  = as.list("TCGA-05-4249-01"), probes = as.list("sample_type"))
# [,1]
# [1,]    0

obtain_variants = function(){

}

obtain_segments = function(){

}
