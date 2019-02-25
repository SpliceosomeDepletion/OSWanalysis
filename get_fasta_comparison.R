library(data.table)
library(ggplot2)

setwd("~/mysonas/PRPF8/data/databaseComparison")

library(Biostrings)
customDB <- readAAStringSet("PRPF8_protgen_combined_1FPKM.fasta",use.names=F)
trembl <- readAAStringSet("uniprot_human_trembl_iRTcrap.fasta",use.names=F)
swissprot_isoforms <- readAAStringSet("uniprot_human_sprot_variants_iRTcrap.fasta",use.names=F)
swissprot_canonical <- readAAStringSet("uniprot_human_sprot_canonical_iRTcrap.fasta",use.names=F)

dbs_prot <- list(customDB = customDB,
                 trembl = trembl,
                 swissprot_isoforms = swissprot_isoforms,
                 swissprot_canonical = swissprot_canonical)
dbs_prot_ <- lapply(dbs_prot, as.character)

library(VennDiagram)

# PTranscript level 
whichplot <- c("customDB", "swissprot_isoforms", "trembl")
venn.plot <- venn.diagram(dbs_prot[whichplot],
                          filename = NULL,
                          print.mode = "raw", fill = c("green", "blue",  "red"), alpha = 0.5,
                          cex = 1.8, margin = 0.05, cat.cex = 1.8, category.names = "",
                          force.unique = T, lwd = 0, euler.d = T, scaled= T)

pdf(paste0("Database_Proteins_",paste0(whichplot, collapse = "_"),"_venn.pdf"))
grid.draw(venn.plot)
dev.off()

# Peptide level
# digest databases

library(cleaver)

dbs_pep <- lapply(dbs_prot, cleave, enzym = "trypsin", missedCleavages = c(0))
dbs <- lapply(dbs_pep,unlist)
dbs <- lapply(dbs, function(x) x[nchar(x) >= 6])

whichplot <- c("customDB", "swissprot_isoforms", "trembl")
venn.plot <- venn.diagram(dbs[whichplot],
             filename = NULL,
             print.mode = "raw", fill = c("green", "blue",  "red"), alpha = 0.5,
             cex = 1.8, margin = 0.05, cat.cex = 1.8, category.names = "",
             force.unique = T, lwd = 0, inverted = T)

pdf(paste0("Database_Peptides_",paste0(whichplot, collapse = "_"),"_venn.pdf"))
grid.draw(venn.plot)
dev.off()

# Count comparisons
customDB_transcript_count <- length(unique(dbs_prot$customDB))
swissprot_isoforms_transcript_count <- length(unique(dbs_prot$swissprot_isoforms))
swissprot_canonical_transcript_count <- length(unique(dbs_prot$swissprot_canonical))
trembl_transcript_count <- length(unique(dbs_prot$trembl))

countDT <- data.table(DB=c("customDB", "swissprot +isoforms", "swissprot canonical", "trembl"),
                      #genes=c(customDB_gene_count, swissprot_isoforms_gene_count, swissprot_canonical_gene_count, trembl_gene_count),
                      transcripts = c(customDB_transcript_count, swissprot_isoforms_transcript_count, swissprot_canonical_transcript_count, trembl_transcript_count))
countDT.m <- melt(countDT, id.vars=c("DB"), value.name="count")

customDB_header <- fread("PRPF8_protgen_combined_1FPKM_ids.txt", sep="\t", header = F, col.names = "header")
contaminants_and_irts <- c("cRAP_|HA_tag|Clonetech|pTO_HA|Streptactin|TRYP_PIG|RT-Kit-WR")
customDB_header <- customDB_header[! grep(contaminants_and_irts, header)]

customDB_header[,id:=gsub(">[[:alpha:]]*\\|","",header)]
customDB_header[,id:=gsub("\\|.*","",id)]
customDB_header[,gene:=gsub("[\\-].*","",id)]
customDB_header[,transcript:=gsub("[\\_].*","",id)]

customDB_header_gene_count <- length(unique(customDB_header$gene))
customDB_header_transcript_count <- length(unique(customDB_header$transcript))

gencode_gene_count <- 19940 # GENCODE - Human Release Statistics 2.pdf

gencode_customDB_comparison <- data.table(
  DB=c("gencode", "customDB"),
  variable=c("genes","genes"),
  count=c(gencode_gene_count,customDB_header_gene_count))

transcripts_per_gene_comparison <- data.table(
  DB=c("customDB", "swissprot +isoforms", "swissprot canonical", "trembl"),
  variable=c("transcripts per gene","transcripts per gene","transcripts per gene","transcripts per gene"),
  count = c(customDB_transcript_count/customDB_header_gene_count, swissprot_isoforms_transcript_count/gencode_gene_count, swissprot_canonical_transcript_count/gencode_gene_count, trembl_transcript_count/gencode_gene_count))

allCountDT <- rbind(rbind(countDT.m,gencode_customDB_comparison),transcripts_per_gene_comparison)
allCountDT$variable <- factor(allCountDT$variable, levels = c("genes","transcripts","transcripts per gene"))

pdf("fasta_comparison.pdf", width=9, height=4)
p <- ggplot(allCountDT , aes(x=DB, y=count, group=variable)) +
  facet_wrap(.~variable, scales = "free") + 
  geom_bar(stat="identity") +
  geom_text(aes(label=round(count, digits = 2)), vjust=1.6, color="white",
            position = position_dodge(0.9), size=3.5) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p)
dev.off()

#pdf("fasta_transcript_comparison.pdf", width=4, height=4)
#p <- ggplot(countDT.m, aes(x=DB, y=count, group=variable)) +
#  facet_wrap(.~variable) + 
#  geom_bar(stat="identity") +
#  geom_text(aes(label=count), vjust=1.6, color="white",
#            position = position_dodge(0.9), size=3.5) +
#  theme_classic() +
#  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#print(p)
#dev.off()

#pdf("gencode_customDB_comparison.pdf", width=3, height=4)
#p <- ggplot(gencode_customDB_comparison, aes(x=DB, y=count, group=variable)) +
#  facet_wrap(.~variable) + 
#  geom_bar(stat="identity") +
#  geom_text(aes(label=count), vjust=1.6, color="white",
#            position = position_dodge(0.9), size=3.5) +
#  theme_classic() +
#  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#print(p)
#dev.off()

#pdf("transcripts_per_gene_comparison_comparison.pdf", width=3, height=4)
#p <- ggplot(transcripts_per_gene_comparison, aes(x=DB, y=count, group=variable)) +
#  facet_wrap(.~variable) + 
#  geom_bar(stat="identity") +
#  geom_text(aes(label=round(count, digits = 2)), vjust=1.6, color="white",
#            position = position_dodge(0.9), size=3.5) +
#  theme_classic() +
#  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#print(p)
#dev.off()
