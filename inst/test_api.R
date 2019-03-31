#FUN: test APIss

# DOC for APIs ----------------------------------------

# Lower level APIs
DOC_LOW_xq=c(
    # funs contructed from xq files
    'cohort_samples'= 'All samples in cohort',
    'all_datasets_n'= 'Count the number datasets with non-null cohort',
    'all_field_metadata'= 'Metadata for all dataset fields (phenotypic datasets)',
    'cohort_summary'= 'Count datasets per-cohort, excluding the given dataset types',
    'dataset_fetch'= 'Probe values for give samples',
    'dataset_field'= 'All field (probe) names in dataset',
    'dataset_field_examples'= 'Field names in dataset, up to <count>',
    'dataset_field_n'= 'Number of fields in dataset',
    'dataset_gene_probe_avg'= 'Probe average, per-gene, for given samples',
    'dataset_gene_probes_values'= 'Probe values in gene, and probe genomic positions, for given samples',
    'dataset_list'= 'Dataset metadata for datasets in the given cohorts',  # metadata for cohort
    'dataset_metadata'= 'Dataset metadata',  # metadata for dataset
    'dataset_probe_signature'= 'Computed probe signature for given samples and weight array',
    'dataset_probe_values'= 'Probe values for given samples, and probe genomic positions',
    'dataset_samples'= 'All samples in dataset (optional limit)',
    'dataset_samples_n_dense_matrix'= 'All samples in dataset (faster, for dense matrix dataset only)',
    'feature_list'= 'Dataset field names and long titles (phenotypic datasets)',
    'field_codes'= 'Codes for categorical fields',
    'field_metadata'= 'Metadata for given fields (phenotypic datasets)',
    'gene_transcripts'= 'Gene transcripts',
    'match_fields'= 'Find fields matching names (must be lower-case)',
    'probemap_list'= 'Find probemaps',
    'ref_gene_exons'= 'Gene model',
    'ref_gene_position'= 'Gene position from gene model',
    'ref_gene_range'= 'Gene models overlapping range',
    'segment_data_examples'= 'Initial segmented data rows, with limit',
    'segmented_data_range'= 'Segmented (copy number) data overlapping range',
    'sparse_data'= 'Sparse (mutation) data rows for genes',
    'sparse_data_examples'= 'Initial sparse data rows, with limit',
    'sparse_data_match_field'= 'Genes in sparse (mutation) dataset matching given names',
    'sparse_data_match_field_slow'= 'Genes in sparse (mutation) dataset matching given names, case-insensitive (names must be lower-case)',
    'sparse_data_match_partial_field'= 'Partial match genes in sparse (mutation) dataset',
    'sparse_data_range'= 'Sparse (mutation) data rows overlapping the given range, for the given samples'
    )

DOC_LOW_in = c(
    # funs created in package
    '.host_cohorts' = 'Return cohorts of hosts',
    '.cohort_datasets' = 'Return datasets of cohorts',
    '.cohort_datasets_count' = 'Return dataset count of cohorts',
    '.cohort_samples_each' = 'Return samples present in each cohort',
    '.cohort_samples_any' = 'Return samples present any cohort',
    '.cohort_samples_all' = 'Return samples shared by all cohort',
    '.dataset_samples_each' = 'Return samples present in each dataset',
    '.dataset_samples_any'= 'Return samples present in any cohort',
    '.dataset_samples_all' = 'Return samples shared by all dataset'
)

# Higher level APIs
DOC_HIGH = c(
    'hosts' = 'Return hosts as character vector',
    'cohorts' = 'Return cohorts as character vector',
    'datasets' = 'Return datasets as character vector',
    'samples' = 'Return samples according to "by" and "how" option'
)

DOC_ALL = c(DOC_LOW_xq, DOC_LOW_in, DOC_HIGH)

# API functions ------------------------------------------
all_vs = ls(envir = as.environment("package:UCSCXenaTools"),
            all.names = TRUE)

funs_low_xq = grep("^\\.p", all_vs, value = TRUE)
funs_low_in = c(
    '.host_cohorts',
    '.cohort_datasets',
    '.cohort_datasets_count',
    '.cohort_samples_each',
    '.cohort_samples_any',
    '.cohort_samples_all',
    '.dataset_samples_each',
    '.dataset_samples_any',
    '.dataset_samples_all'
)

funs_high = c(
    'hosts',
    'cohorts',
    'datasets',
    'samples'
)

funs_all = c(funs_low_xq, funs_low_in, funs_high)

# Examples ------------------------------------------
# examples = c(
#     # funs contructed from xq files
#     ".p_all_cohorts(host = hosts(xe), exclude = NULL)",
#     ".p_all_datasets(hosts(xe))",
#     ".p_all_datasets_n(hosts(xe))",
#     ".p_all_field_metadata(hosts(xe), datasets(xe))",
#     ".p_cohort_samples(hosts(xe), cohorts(xe), 100)",
#     ".p_cohort_summary(hosts(xe), NULL)",
#     ".p_dataset_fetch(hub, dataset, samples, probes)",
#     ".p_dataset_field(hub, dataset)",
#     ".p_dataset_field_examples(hub,dataset,3)",
#     ".p_dataset_field_n(hub, dataset)",
#     ".p_dataset_gene_probe_avg(hub, dataset, samples, genes)",
#     ".p_dataset_gene_probes_values(hub, dataset, samples, genes)",
#     ".p_dataset_list(hosts(xe), cohorts(xe))", # IMPORTANT
#     ".p_dataset_metadata(hub, dataset)",
#     ".p_dataset_probe_signature(hub, dataset, samples, probes, 1)",
#     ".p_dataset_probe_values(hub, dataset, samples, probes)",
#     ".p_dataset_samples(hub, dataset, 10)",
#     ".p_dataset_samples_ndense_matrix(hub, dataset)",
#     ".p_datasets_null_rows(hub)",
#     ".p_feature_list(hub, dataset)",
#     ".p_field_codes(hub, dataset, NULL)",
#     ".p_field_metadata(hub, dataset, NULL)",
#     ".p_gene_transcripts(hub, dataset, 'TP53')",
#     ".p_match_fields(hub, dataset, NULL)",
#     ".p_probe_count(hub, dataset)",
#     ".p_probemap_list(hub)",
#     ".p_ref_gene_exons(hub, dataset, 'TP53')",
#     ".p_ref_gene_position(hub, dataset, 'TP53')",
#     ".p_ref_gene_range(hub, dataset, 'chr1', 500, 10000)",
#     ".p_segment_data_examples(hosts(xe), dataset2, NULL)",
#     ".p_segmented_data_range(hosts(xe), dataset2, sample2, 'chr1', 50, 1000)",
#     ".p_sparse_data",
#     ".p_sparse_data_examples",
#     ".p_sparse_data_match_field",
#     ".p_sparse_data_match_field_slow",
#     ".p_sparse_data_match_partial_field",
#     ".p_sparse_data_range",
#     ".p_transcript_expression",
#     # funs created in package
#     '.host_cohorts',
#     '.cohort_datasets',
#     '.cohort_datasets_count',
#     '.cohort_samples_each',
#     '.cohort_samples_any',
#     '.cohort_samples_all',
#     '.dataset_samples_each',
#     '.dataset_samples_any',
#     '.dataset_samples_all',
#     # higher functions
#     'hosts(xe)',
#     'cohorts(xe)',
#     'datasets(xe)',
#     'samples(xe)'
# )
#
# # If return is list(), maybe the input format is wrong
#
# # Testing -------------------------------------
#
# xe = XenaGenerate(subset = XenaHostNames=="tcgaHub") %>%
#     XenaFilter(filterDatasets = "clinical") %>%
#     XenaFilter(filterDatasets = "LUAD|LUSC|LUNG")
#
# hub = "https://toil.xenahubs.net"
# dataset = "tcga_RSEM_gene_tpm"
# samples = c("TCGA-02-0047-01","TCGA-02-0055-01","TCGA-02-2483-01","TCGA-02-2485-01")
# probes = c('ENSG00000282740.1', 'ENSG00000000005.5', 'ENSG00000000419.12')
# genes =c("TP53", "RB1", "PIK3CA")
# dataset2 = "TCGA.BRCA.sampleMap/SNP6_genomicSegment"
# sample2 = "TCGA-AN-A041-01"
# dataset3 = "TCGA.LAML.sampleMap/mutation_wustl_hiseq"


# Get info -------------------------------------------

funs_df = data.frame(
    funs_name = funs_all,
    xq = c(substring(funs_low_xq, 4), funs_low_in, funs_high),
    level = c(rep("Lower",
                  length(funs_low_xq)+length(funs_low_in)),
              rep("Higher", length(funs_high))),
    stringsAsFactors = FALSE
)

doc_df = as.data.frame(DOC_ALL)
doc_df$xq = rownames(doc_df)

api_df = merge(funs_df, doc_df, by = "xq")
colnames(api_df) = c("Original Name",
                     "Function Name",
                     "Level",
                     "Description")
save(api_df,
     file=file.path(system.file("inst",
                                package = "UCSCXenaTools"),
                    "api.RData"))



# test XenaDataUpdate -----------------------------------------------------

.p_dataset_metadata(XenaData$XenaHosts[178], XenaData$XenaDatasets[178]) ->tt2

# examples for understand structure

tt2 = structure(list(pmtext = "{\"name\":\"probeMap/hugo_gencode_good_hg19_V24lift37_probemap\",\"type\":\"probeMap\",\"version\":\"2017-07-25\",\"assembly\":\"hg19\",\"url\":\"http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/wgEncodeGencodeBasicV24lift37.txt.gz\",\"wrangling_procedure\":\"convert UCSC GB download to start index 1\",\"label\":\"HUGO: human gene symbol (hg19) e.g. TP53\",\"userlevel\":\"basic\",\"idtype\":\"gene\"}",
               status = "loaded", text = "{\"owner\":\"TCGA\",\"longTitle\":\"TCGA bladder urothelial carcinoma (BLCA) gene expression by RNAseq (polyA+ IlluminaHiSeq)\",\"cohort\":\"TCGA Bladder Cancer (BLCA)\",\"url\":\"https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/distro_ftpusers/anonymous/tumor/blca/cgcc/unc.edu/illuminahiseq_rnaseqv2/rnaseqv2/\",\"probeMap\":\"probeMap/hugo_gencode_good_hg19_V24lift37_probemap\",\"dataSubType\":\"gene expression RNAseq\",\"security\":\"public\",\"rnatype\":\"polyA+\",\"label\":\"IlluminaHiSeq\",\"tags\":[\"cancer\"],\"path\":\"data/public/TCGA/BLCA/HiSeqV2\",\"anatomical_origin\":[\"Bladder\"],\"name\":\"TCGA.BLCA.sampleMap/HiSeqV2\",\"dataproducer\":\"University of North Carolina TCGA genome characterization center\",\"wrangling_procedure\":\"Level_3 data (file names: *.rsem.genes.normalized_results) are downloaded from TCGA DCC, log2(x+1) transformed, and processed at UCSC into Xena repository\",\"sample_type\":[\"tumor\"],\"redistribution\":true,\"groupTitle\":\"TCGA bladder urothelial carcinoma\",\"type\":\"genomicMatrix\",\"wrangler\":\"Xena TCGAscript RNAseq processed on 2017-10-13\",\"version\":\"2017-10-13\",\"gdata_tags\":[\"transcription\"],\"unit\":\"log2(norm_count+1)\",\"notes\":\"the probeMap is hugo for the short term, however probably around 10% of the gene symbols are not HUGO names, but ENTRE genes\",\"primary_disease\":\"bladder urothelial carcinoma\",\"platform\":\"IlluminaHiSeq_RNASeqV2\",\"colnormalization\":true,\"description\":\"The gene expression profile was measured experimentally using the Illumina HiSeq 2000 RNA Sequencing platform by the University of North Carolina TCGA genome characterization center. Level 3 data was downloaded from TCGA data coordination center. This dataset shows the gene-level transcription estimates, as in log2(x+1) transformed RSEM normalized count. Genes are mapped onto the human genome coordinates using UCSC Xena HUGO probeMap (see ID/Gene mapping link below for details). Reference to method description from University of North Carolina TCGA genome characterization center: <a href=\\\"https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/distro_ftpusers/anonymous/tumor/blca/cgcc/unc.edu/illuminahiseq_rnaseqv2/rnaseqv2/unc.edu_BLCA.IlluminaHiSeq_RNASeqV2.Level_3.1.17.0/DESCRIPTION.txt\\\" target=\\\"_blank\\\"><u>DCC description</u></a><br><br>In order to more easily view the differential expression between samples, we set the default view to center each gene or exon to zero by independently subtracting the mean of each gene or exon on the fly. Users can view the original non-normalized values by adjusting visualization settings.<br><br>\"}",
               probemap = "probeMap/hugo_gencode_good_hg19_V24lift37_probemap",
               datasubtype = "gene expression RNAseq", type = "genomicMatrix",
               count = 426L, longtitle = "TCGA bladder urothelial carcinoma (BLCA) gene expression by RNAseq (polyA+ IlluminaHiSeq)",
               name = "TCGA.BLCA.sampleMap/HiSeqV2"), class = "data.frame", row.names = 1L)


jsonlite::parse_json(tt2$text) # metadata for dataset
jsonlite::parse_json(tt2$pmtext) # metadata for probeMap
tt2$count # n of samples


# obtain data list of cohort metadata ----------------------------------------
# cohort_df = unique(XenaData[, c(1, 3)])
# cohort_df = as.data.frame(cohort_df)
#
# cohort_metadata = apply(cohort_df, 1, function(x) {
#     .p_dataset_list(x[1], x[2])
# })
