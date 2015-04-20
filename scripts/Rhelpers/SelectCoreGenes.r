# input: cdsClusters table
# output: clusterInfo (CorePan)

library("RMySQL")
library("gplots")

source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname)

# kill old
dbSendQuery(con, "drop table if exists coreClusters");
dbSendQuery(con, "update clusterInfo set CorePan = ''");

strains = dbGetQuery(con, "select distinct(strain) as strains from cds")
strains = strains$strains; 
strains.count = length(strains)

# select core genes and filter by length --------------------------------------------------------
comand = paste("select cluster, min(nlength) as minl, max(nlength) as maxl from cdsClusters where strains =", strains.count," and genes =", strains.count, "group by cluster")
clusters <- dbGetQuery(con, comand)
print(paste("CORE GENES:", length(clusters$cluster)))
clusters.core <- subset(clusters, (maxl - minl)/maxl < maxLengthVar)
print(paste("FILTERED CORE GENES:", length(clusters.core$cluster)))
system(paste0("echo 'Filtered core genes: ", length(clusters.core$cluster), "' >> ../Log.txt"))

#clusters.core <- clusters

# upload them to mysql
dbWriteTable(con,"coreClusters", clusters.core)
dbSendQuery(con, "update clusterInfo set CorePan = 'core' where clusterInfo.cluster in (select cluster from coreClusters)")
