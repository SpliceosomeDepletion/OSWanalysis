# module load new
# module load /cluster/apps/imsb/modules
# module load r/3.4.0
# module load mpfr
# module load open_mpi

library(data.table)
setwd("~/mysonas/PRPF8/data/DIAsearch/output/")
data <- fread("merged_peptide_export.tsv")

library(ggplot2)

data_sub <- subset(data, (m_score_peptide_experiment_wide < 0.2) & (m_score < 0.2))
write.table(data_sub, "merged_peptide_export_filtered.tsv", quote=F, row.names=F, sep="\t")

a <- ggplot(data, aes(x=d_score)) + geom_density()
b <- ggplot(data, aes(x=m_score)) + geom_density()
c <- ggplot(data, aes(x=m_score_peptide_experiment_wide)) + geom_density()
d <- ggplot(data, aes(x=m_score_peptide_global)) + geom_density()

pdf("scoreDistributions_beforeFiltering.pdf")
  plot(a)
  plot(b)
  plot(c)
  plot(d)
dev.off()

a_sub <- ggplot(data_sub, aes(x=d_score)) + geom_density()
b_sub <- ggplot(data_sub, aes(x=m_score)) + geom_density()
c_sub <- ggplot(data_sub, aes(x=m_score_peptide_experiment_wide)) + geom_density()
d_sub <- ggplot(data_sub, aes(x=m_score_peptide_global)) + geom_density()

pdf("scoreDistributions_afterFiltering.pdf")
  plot(a_sub)
  plot(b_sub)
  plot(c_sub)
  plot(d_sub)
dev.off()
