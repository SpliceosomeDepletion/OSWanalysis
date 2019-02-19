library(data.table)
library(ggplot2)

setwd("~/mysonas/PRPF8/data/databaseComparison")

psm_summary <- fread("psm_summary.txt")
psm_summary[,DB:=gsub("interact-interact_","",file)]
psm_summary[,DB:=gsub("\\.pep\\.xml","",DB)]
psm_summary[,DB:=gsub("1FPKM","customDB",DB)]
psm_summary[,DB:=gsub("sprot_canonical","swissprot canonical",DB)]
psm_summary[,DB:=gsub("sprot_variants","swissprot +isoforms",DB)]
psm_summary[,PSM_count:=psm_count]

psm_summary[,FDR:=paste0("PSM FDR = ",fdr*100,"%")]
psm_summary$FDR <- factor(psm_summary$FDR, levels = c("PSM FDR = 1%", "PSM FDR = 5%", "PSM FDR = 10%"))

pdf("psm_summary.pdf", width=7, height=4)
  p <- ggplot(psm_summary, aes(x=DB, y=PSM_count)) +
    facet_wrap(.~FDR) + 
    geom_bar(stat="identity") +
    geom_text(aes(label=PSM_count), vjust=1.6, color="white",
              position = position_dodge(0.9), size=3.5) +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  print(p)
dev.off()

