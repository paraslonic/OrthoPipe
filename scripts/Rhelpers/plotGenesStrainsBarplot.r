table <- read.delim("../ortho/ortho_table.txt", head = TRUE, as.is = TRUE)
View(table)
cols  <- 3:(ncol(table)-1)
vals  <- table[,cols]
strain.count = ncol(vals)
genes.in.og = sum(vals)
genes = system("grep '>' ../ortho/goodProteins.fasta -c", intern=TRUE)
genes = as.numeric(genes)
genes.uniq = genes - genes.in.og
strains = table[,ncol(table)]
strains.hist = hist(strains, breaks=1:strain.count)
strains.hist = c(genes.uniq, strains.hist$counts)
pdf("../genes_strains_barplot.pdf")
barplot(strains.hist, names.arg=1:strain.count, las = 2, cex.names = 1.4,
        col = "dodgerblue4", ylab = "genes", xlab = "strains", cex.lab = 1.6, cex.axis = 0.8)
dev.off()


cloud = sum(strains.hist[1:(0.2*strain.count)])
core = sum(strains.hist[strain.count:(0.8*strain.count)])
cloud.fraq = cloud/genes
core.fraq = core/genes
write.table(data.frame(genes, cloud, core, cloud.fraq, core.fraq), "../results/cloud_core_count.txt", 
            row.names = FALSE, quote = FALSE)
