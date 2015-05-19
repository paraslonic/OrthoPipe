# input: ../results/dist.matrices.core.rdat, ../results/CoreGenesMLTree.nwk
# output: ../results/pdf/CoreGenesHeatmap.pdf, ../results/distance/CoreGenesDistance.txt

library("abind")
library("gplots")
library("phangorn")
library("ape")

system("mkdir -p ../results/distance")
system("mkdir -p ../results")
system("mkdir -p ../results/pdf")

load(file="../results/dist.matrices.core.rdat")
class(dist.matrices.core)
dists.3d <- abind(dist.matrices.core, along=3)
dists.median <- apply(dists.3d, c(1,2), median)
write.table(dists.median, "../results/distance/CoreGenesDistance.txt", sep = "\t", quote= F)

# make normal names
colnames(dists.median) <-  gsub("_",' ', colnames(dists.median))
rownames(dists.median) <-  gsub("_",' ', rownames(dists.median))
strains = read.delim("tmp/strains.txt", as.is = T)
strains$strains = gsub("_",' ',strains$strains)

cex = 0.8
strains.count = nrow(strains)
if(strains.count > 10) { cex = 0.4 }

# no tree heatmap
pdf("../results/pdf/CoreGenesDistanceHeatmap.pdf")
heatmap.2(as.matrix(dists.median),trace="none",margin=c(12,12), main = "Distance by core genes",dendrogram="row",
         keysize=1.5, cexRow = cex, cexCol = cex)
dev.off()


# make and import dnaml tree
dnml.tree <- read.tree("../results/CoreGenesMLTree.nwk")
dnml.tree$tip.label = strains$strains[as.integer(dnml.tree$tip.label)]
write.tree(dnml.tree, file = "../results/CoreGenesMLTreeNamed.nwk");

pdf("../results/pdf/CoreGenesMLTree_.pdf")
par(mar = c(4,4,4,14))
plot(dnml.tree, hor = T)
dev.off()

dnml.tree$edge.length[which(dnml.tree$edge.length == 0)] <- 0.0000001
dnml.tree <- multi2di(dnml.tree)
dnml.tree <- midpoint(dnml.tree)
dnml.tree <- chronos(dnml.tree)

dnml.tree <- as.dendrogram(as.hclust(dnml.tree))
save(dnml.tree, file = "tmp/mltree.rdata")

pdf("../results/pdf/CoreGenesMLTree.pdf")
par(mar = c(4,4,4,14))
plot(dnml.tree, hor = T)
dev.off()

png("../results/pdf/CoreGenesMLTree.png")
par(mar = c(4,4,4,14))
plot(dnml.tree, hor = T)
dev.off()


# make same order 
orders <- order.dendrogram(dnml.tree)
labs <- labels(dnml.tree)
pos <- data.frame(labs, orders)
pos <- pos[order(pos$orders),]
new_order = match(pos$labs,colnames(dists.median))
dists.median <- dists.median[new_order, new_order ]

# plot
pdf("../results/pdf/CoreGenesDistanceHeatmap_ML.pdf")
heatmap.2(as.matrix(dists.median),trace="none",margin=c(12,12), main = "Distance by core genes\n(ML tree)",dendrogram="row",
          Rowv=dnml.tree, Colv=dnml.tree, keysize=1.5, cexRow = cex, cexCol = cex)
dev.off()

