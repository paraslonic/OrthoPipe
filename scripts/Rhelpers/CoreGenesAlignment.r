#setwd("/home/manolov/proj/diff_Bacs/gonorea/ThePipeline/scripts")

# choose core genes with ok length difference. make multiple alignment of them. calc distance
# input: cdsClusters table
# output: tmp/strains.txt; results/dist.matrices.core.rdat - distances by each of core gene; tmp/coreGenes/*.alseq

library("RMySQL")
#library("abind")
library("gplots")

source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname, host=Host, port=3306)

strains = dbGetQuery(con, "select distinct(strain) as strains from cds")
system("mkdir -p tmp")
write.table(strains,"tmp/strains.txt", quote = F, row.names = FALSE)
strains = strains$strains; 

strains.count = length(strains)

# select core genes and filter by length --------------------------------------------------------
clusters <- dbGetQuery(con, "select cluster from clusterInfo where CorePan ='core'")
clusters = clusters$cluster; 
clusters.count = length(clusters)

dist.matrices.core = list()

# save core genes sequence --------------------------------------------------------
system("mkdir -p tmp/coreGenes")
system("rm tmp/coreGenes/*.*")

print("aligning core genes")
for (i in 1:clusters.count)
{
  clust = clusters[i]
  clust.name = gsub(":","", clust) # workaround 4 orthomcl behaviour
  clust.fname = paste("tmp/coreGenes/",gsub(":","", clust),".txt",sep="")
  # create a fasta file with each cds from cluster
  system(paste("rm ",clust.fname,sep=""),ignore.stderr=T)
  for(j in 1:strains.count)
  {
    strain = strains[j]
    seq <- dbGetQuery(con,paste("select nseq from cdsClusters where cluster = '",clust,"' and strain='", strain, "';", sep=""))  
    seq = seq$nseq[1]
    system(paste('echo ">',j,'" >> ',clust.fname,sep=""))
    system(paste("echo ",seq," >> ",clust.fname, sep=""))
  }
  clust.alname = paste("tmp/coreGenes/",gsub(":","", clust),".alseq",sep="")
  clust.distname = paste("tmp/coreGenes/",gsub(":","", clust),".dnadist",sep="")
  # align and calc dist 
  system(paste("emma -sequence ", clust.fname ," -outseq ",clust.alname," -dendoutfile qu.dnd"))
  system(paste("fdnadist -sequence $(pwd)/", clust.alname ," -outfile  $(pwd)/",clust.distname,"  -method f ", sep=""))
  system(paste("bash helpers/ph2mat.sh", clust.distname,"tmp/coreGenes/out"))
  o <- read.delim("tmp/coreGenes/out",sep=" ", header=F, as.is = T)  
  rownames(o) = strains[o$V1]
  o <- o[,-1]
  colnames(o) = rownames(o)
  o <- o[,order(colnames(o), sort(colnames(o)))]
  o <- o[order(rownames(o), sort(rownames(o))),]
  print(paste("i =",i, "of", clusters.count))
  dist.matrices.core[[clust.name]] = o
}

system("mkdir -p ../results")
system("rm qu.dnd")
save(dist.matrices.core, file="../results/dist.matrices.core.rdat")
