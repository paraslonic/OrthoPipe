library("plyr")
library("parallel")
library("foreach")
library("doParallel")


#cl <- makeCluster(15)
#registerDoParallel(cl, cores = 15)
load("/data6/bio/runs-manolov/NGon/orthoPipe/results/dist.matrices.core.rdat")

L = dist.matrices.core
maxes = sapply(L, max)
hist(maxes, breaks = 50, col = "dodgerblue3")
L = L[-which(maxes == 0)]

#L = L[1:10]

count = length(L)
M = matrix(0, nrow = count, ncol = count)
colnames(M) = names(L)
rownames(M) = names(L)
M[lower.tri(M)] = aaply(combn(count, 2), 2, 
                        function(x) { cor(L[[x[2] ]], L[[ x[1] ]], method = "spearman") })
M = M+t(M)
diag(M) = 1

save(M, file = "M.rdata")


