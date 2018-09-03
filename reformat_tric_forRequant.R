# module load new
# module load /cluster/apps/imsb/modules
# module load r/3.4.0
# module load mpfr
# module load open_mpi

library(data.table)
setwd("~/mysonas/PRPF8/data/DIAsearch/output/")
data <- fread("aligned_filtered.csv")

data[, align_origfilename := gsub(".mzXML.gz","",filename)]

write.table(data, "aligned_filtered_fixed.csv", quote=F, row.names=F, sep="\t")
