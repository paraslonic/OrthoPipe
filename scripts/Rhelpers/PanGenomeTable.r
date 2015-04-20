# input: cdsClusters table; ../ortho/ortho_table.txt
# output: ../results/pan.table.txt

library("RMySQL")

source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname)
strains = (dbGetQuery(con, "select distinct(strain) as strains from cds"))$strains; 

table <- read.delim("../ortho/ortho_table.txt", head = T, check.names=FALSE)
table  <- subset(table, select = -strains)

for(strain in strains){
  if(length(strain.orphans) < 1) { next }
  strain.orphans  <- dbGetQuery(con, paste0("select id, product from cdsClusters  where cluster is null and strain = '", strain, "'"))
  strain.orphans$id = paste0(strain, "_", strain.orphans$id)
  strain.orphans  <-  cbind(strain.orphans, matrix(0, nrow = nrow(strain.orphans), ncol = length(strains)))
  strain.orphans[,match(strain,colnames(table))] = 1  
  colnames(strain.orphans) = colnames(table)
  table  <- rbind(table, strain.orphans)
}

write.table(table, "../results/PangenomeTable.txt", sep = "\t", quote= F)

# stat
clusters <- dbGetQuery(con, paste0("select count(distinct(cluster)) as count from cdsClusters"))
system(paste0("echo 'Groups: ", clusters$count, "' >> ../Log.txt"))

nonorphans <- dbGetQuery(con, paste0("select count(*) as count from cdsClusters  where not cluster is null"))
system(paste0("echo 'Genes in groups: ", nonorphans$count, "' >> ../Log.txt"))

Orphans  <- dbGetQuery(con, paste0("select count(*) as count from cdsClusters  where cluster is null"))
system(paste0("echo 'Orphan genes: ", Orphans$count, "' >> ../Log.txt"))



