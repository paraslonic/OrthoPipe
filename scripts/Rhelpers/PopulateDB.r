library("RMySQL")

source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname)

strains <- dbGetQuery(con, "select distinct strain from clusters;")
strains <- strains$strain

# orphans
dbGetQuery(con, "CREATE TABLE orphans LIKE cds;")
for (s in strains) { # деревья были большими, а я не знал о left join...
   query = paste("insert into orphans select * from cds where strain = '",s,"' and id not in (select id from clusters where strain = '",s,"')", sep = "")
   res <- dbGetQuery(con, query)
}

# create tables (возможно перенести создание всех таблиц вначало и в один скрипт!)
dbGetQuery(con, "create table clusterSize as select cluster, count(distinct strain) as strains, count(*) as genes from clusters group by cluster");
dbGetQuery(con, "alter table clusterSize add primary key (cluster);")

dbGetQuery(con, "create table cdsClusters as select  cds.*, clusters.cluster,clusterSize.strains, clusterSize.genes from cds left join clusters on cds.strain=clusters.strain and cds.id=clusters.id left join clusterSize on clusters.cluster=clusterSize.cluster")
dbGetQuery(con, "alter table cdsClusters add primary key (strain, id);")
# set 1 to orphans
dbGetQuery(con, "update cdsClusters set genes = 1 where genes is null")
dbGetQuery(con, "update cdsClusters set strains = 1 where strains is null")

dbSendQuery(con, "drop table orphans")

# clusterInfo
dbGetQuery(con, "create table clusterInfo (cluster varchar(64), CorePan varchar(64), KO varchar(64), GO varchar(64), pathways varchar(256))");
dbSendQuery(con, "insert into clusterInfo (cluster) select distinct cluster from clusters")

