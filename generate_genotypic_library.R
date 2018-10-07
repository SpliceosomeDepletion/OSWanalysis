library(data.table)

data <- fread("SpecLib_cons_all_unimod.mrm")
#data <- fread("test.mrm")

mapping <- subset(data, select=c("V10","V13"))

split <- strsplit(mapping$V13, split = ";")

mapSingleGene <- function(protein_map){
protein_map <- gsub("^cf\\|","",protein_map)
isoform_map <- gsub("\\|.*$","",protein_map)
gene_map <- unique(gsub("\\-.*$","",isoform_map))
gene_map <- paste(c(length(gene_map),gene_map), collapse = "/")
gene_map
}

newprot <- lapply(split, mapSingleGene)

mapping[,gene_id:=unlist(newprot)]

data_new <- copy(data)
data_new[,V13 := mapping$gene_id]

idx_genotypic <- grep("1/",data_new$V13)
data_new_genotypic <- data_new[idx_genotypic]

data_new_genotypic[, V13 := gsub("1/","",V13)]

write.table(data_new_genotypic,"SpecLib_cons_all_unimod_genotypic.mrm", quote=F, col.names=F, row.names=F, sep="\t")
write.table(mapping,"mapping_genotypic.tsv", quote=F, col.names=F, row.names=F, sep="\t")
