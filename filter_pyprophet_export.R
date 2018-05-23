library(data.table)
setwd("~/mysonas/PRPF8/data/DIAsearch/output_old/")
data <- fread("merged_protein_export.tsv")

data_sub <- subset(data, (m_score_peptide_experiment_wide < 0.05) & (m_score < 0.05))

write.table(data_sub, "merged_protein_export_filtered.tsv", quote=F, row.names=F, sep="\t")
