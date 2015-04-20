library("RMySQL")
library("reshape2")

source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname)

clust.len <- dbGetQuery(con, "select cluster, strain, nlength from cdsClusters order by cluster;")
clust.len <- clust.len[!is.na(clust.len$cluster),]
str(clust.len)
clust.len.w <- dcast(clust.len, strain ~ cluster, value.var= "nlength", fun.aggregate = list)
write.table(clust.len.w, "cluster_genes_length_wide.txt", quote=F, sep="\t", row.names = F)
