ogs <- names(dist.matrices.core)
# aggregate
dist.matrices.core <- lapply(dist.matrices.core, as.matrix)
dist.matrices.core.3dim <- abind(dist.matrices.core, along=3)
median.dist <- apply(dist.matrices.core.3dim, c(1,2), median)
mean.dist <- apply(dist.matrices.core.3dim, c(1,2), mean)

heatmap.2(as.matrix(mean.dist), trace="none",margin=c(8,8), 
          keysize=1, main = "common genes nucleotide dist. ML tree")

median.dist <- apply(dist.matrices.core.3dim, c(1,2), median)
mean.dist <- apply(dist.matrices.core.3dim, c(1,2), mean)

write.table(dist.mat, "dist.mat", quote=F, sep="\t")
system("mkdir -p geneAlignments")
system("mv *.alseq *.dnadist *.txt geneAlignments; rm qu.dnd", ignore.stderr=T)

# plot
View(dist.mat)
heatmap.2(as.matrix(dist.mat),trace="none",margin=c(8,8), main = "All common genes similarity\n(ML tree)",dendrogram="row")
