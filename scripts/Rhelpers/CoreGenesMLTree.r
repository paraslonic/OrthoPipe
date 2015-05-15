# choose make MK tree on core genes
# input: tmp/coreGenes/concatenatedGenes/*.fasta
# output: results/CoreGenesMLTree.nwk, results/CoreGenesMLTree.pdf

library("RMySQL")
library("phangorn")

# join core genes by strain to tmp/coreGenes/concatenatedGenes
system("perl helpers/concatenate_alseq.pl")

# build ML tree
system("fdnaml -sequence tmp/coreGenes/concatenatedGenes/core.fasta -outfile tmp/dnamlCoreOut.txt -intreefile ''")
system("mkdir -p ../results")
system("mv core.treefile ../results/CoreGenesMLTree.nwk")

# # plot it
# system("mkdir -p ../results/pdf")
# pdf("../results/pdf/CoreGenesMLTree.pdf")
# dnml.tree <- read.tree("../results/CoreGenesMLTree.nwk")
# plot(dnml.tree)
# dnml.tree <- multi2di(dnml.tree)
# dnml.tree <- midpoint(dnml.tree)
# dnml.tree <- chronos(dnml.tree)
# dnml.tree <- as.dendrogram(as.hclust(dnml.tree))
# class(dnml.tree)
# #plot(dnml.tree, hor = T)
# dev.off()


