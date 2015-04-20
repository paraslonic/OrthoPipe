library("abind")
library("gplots")
library("proxy")
library("phangorn")

# input: ../ortho/ortho_table.txt, ../results/CoreGenesMLTree.nwk, ../results/PangenomeTable.txt
# output: ../results/distance/PanGenesDistance.bray.nonuniq.txt, ../results/distance/PanGenesDistance.bray.txt

# non uniq genes ------------------------------------------------------------------------
 
table <- read.delim("../ortho/ortho_table.txt", head = T)

# calc distance based on pangenome profile
homology.table <- table[, c(3:(ncol(table)-1)) ];
homology.table.t <- data.frame(t(as.matrix(homology.table)))
rownames(homology.table.t) = colnames(homology.table) 
dists <- as.matrix(dist(homology.table.t, method="Bray"))
colnames(dists) <-  gsub("_",' ', colnames(dists))
rownames(dists) <-  gsub("_",' ', rownames(dists))

cex = 0.8
strains.count = nrow(dists)
if(strains.count > 10) { cex = 0.4 }

pdf("../results/pdf/PanGenomeDistanceHeatmap.pdf")
heatmap.2(as.matrix(dists),trace="none",margin=c(8,8), main = "Pangenome distance",
          dendrogram="row", keysize=1.5, cexRow = cex, cexCol = cex)
dev.off()

load("tmp/mltree.rdata")

mungeDistanceAndTree  <- function()
{
  # make same order 
  orders <- order.dendrogram(dnml.tree)
  labs <- labels(dnml.tree)
  pos <- data.frame(labs, orders)
  pos <- pos[order(pos$orders),]
  new_order = match(pos$labs,colnames(dists))
  dists <- dists[new_order, new_order]
  return (dists)
}

dists = mungeDistanceAndTree()

# save distance
system("mkdir -p ../results/distance/")
write.table(dists, "../results/distance/PanGenomeDistance.bray.noorphans.txt",sep = "\t", quote= F)

pdf("../results/pdf/PanGenomeDistanceHeatmapML.pdf")
heatmap.2(as.matrix(dists),trace="none",margin=c(12,12), main = "Pangenome distance by non oprhans\n(ML tree)",
          dendrogram="row", Rowv=dnml.tree, Colv=dnml.tree, keysize=1.5, cexRow = cex, cexCol = cex)
dev.off()
# all genes ------------------------------------------------------------------------

table <- read.delim("../results/PangenomeTable.txt", head = T)

# calc distance based on pangenome profile
homology.table <- table[, c(3:(ncol(table))) ];
homology.table.t <- data.frame(t(as.matrix(homology.table)))
rownames(homology.table.t) = colnames(homology.table) 
dists <- as.matrix(dist(homology.table.t, method="Bray"))
colnames(dists) <-  gsub("_",' ', colnames(dists))
rownames(dists) <-  gsub("_",' ', rownames(dists))

dists = mungeDistanceAndTree()
write.table(dists, "../results/distance/PanGenesDistance.bray.txt", sep = "\t", quote= F)

# plot
pdf("../results/pdf/PanGenomeDistanceHeatmapML_all.pdf")
heatmap.2(as.matrix(dists),trace="none",margin=c(12,12), main = "Pangenome distance by all genes\n(ML tree)",
          dendrogram="row", Rowv=dnml.tree, Colv=dnml.tree, keysize=1.5, cexRow = cex, cexCol = cex)

dev.off()

pdf("../results/pdf/PanGenomeDistanceHeatmap_all.pdf")
heatmap.2(as.matrix(dists),trace="none",margin=c(12,12), main = "Pangenome distance by all genes",
          dendrogram="row", keysize=1.5, cexRow = cex, cexCol = cex)

dev.off()


