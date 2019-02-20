library(data.table)
library(ggplot2)

setwd("~/mysonas/PRPF8/data/DDAsearch")

transitionlist_optimized_decoys <- fread("transitionlist_optimized_decoys.tsv")

transitionlist_optimized <- subset(transitionlist_optimized_decoys, Decoy==0)

unique_genes <- unique(transitionlist_optimized$ProteinId)
unique_mod_peptides <- unique(transitionlist_optimized$ModifiedPeptideSequence)
unique_peptides <- unique(transitionlist_optimized$PeptideSequence)

unique_gene_count <- length(unique_genes)
unique_mod_peptide_count <- length(unique_mod_peptides)
unique_peptide_count <- length(unique_peptides)

summary_dt <- data.table(
  unit=c("genes","primary peptide sequences", "modified peptide sequences"),
  count=c(unique_gene_count, unique_peptide_count, unique_mod_peptide_count)
)

write.table(summary_dt,"library_summary.txt",sep="\t",col.names=T,row.names=F,quote=F)
