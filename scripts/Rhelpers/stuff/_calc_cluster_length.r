# look at cluster length
# input: cdsClusters table
# out: clustersLength table ("cluster", "medianLength","meanLengthDif", "maxLengthDif")

library("RMySQL")

source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname)

# our way
clusters <- dbGetQuery(con, "select distinct cluster as clusters from cdsClusters")
clusters <- clusters$clusters[!is.na(clusters$clusters)]

get.lengthes = function(x) 
{
  lengthes = dbGetQuery(con, paste("select nlength from cdsClusters where cluster ='",x, "'", sep = ''))
  return (lengthes$nlength)
}

Lenghts = lapply(clusters, get.lengthes)
Lenghts.median = unlist(sapply(Lenghts, median))
Lenghts.median.diff = sapply(Lenghts, function(x) { abs((x - median(x))/median(x))} )

max.Lenghts.median.diff = sapply(Lenghts.median.diff, max)
mean.Lenghts.median.diff = sapply(Lenghts.median.diff, mean)

df <- data.frame(clusters, Lenghts.median, mean.Lenghts.median.diff, max.Lenghts.median.diff)
str(df)
colnames(df) = c("cluster", "medianLength","meanLengthDif", "maxLengthDif")
dbSendQuery(con, "drop table if exists clusterLength");
dbWriteTable(con, "clusterLength", df)

system("mkdir -p ../stat/")
Lenghts.median.diff <- unlist(Lenghts.median.diff)
pdf("../stat/length_stat.pdf")
hist(Lenghts.median.diff, breaks= 500, col = "blue", xlim = c(-1,1), main = "diff of gene length and OG median length")
hist(Lenghts.median.diff, breaks= 500, col = "blue", main = "diff of gene length and OG median length")
dev.off()

