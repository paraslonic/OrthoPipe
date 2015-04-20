#setwd("/home/manolov/proj/diff_Bacs/gonorea/ThePipeline/scripts")

# choose core genes with ok length difference. make multiple alignment of them. calc distance
# input: cdsClusters table
# output: results/dist.matrices.noncore.rdat - distances by each of non core gene, tmp/coreGenes/*.alseq

library("RMySQL")
#library("abind")
library("gplots")

source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname)

strains = dbGetQuery(con, "select distinct(strain) as strains from cds")
strains = strains$strains; 
strains.count = length(strains)

# select non core genes--------------------------------------------------------
clusters <- dbGetQuery(con, "select cluster from clusterInfo where (CorePan != 'core' or CorePan is null)")
clusters = clusters$cluster; 

clusters.big <- dbGetQuery(con, "select cluster from clusterSize where strains > 14")
clusters = intersect(clusters, clusters.big$cluster); 

clusters.count = length(clusters)
cat(paste("non core clusters to align:", clusters.count))

dist.matrices.noncore = list()

# save core genes sequence --------------------------------------------------------
system("mkdir -p tmp/nonCoreGenes")
print("aligning non core genes")
for (i in 1:clusters.count)
{
  clust = clusters[i]
  clust.name = gsub(":","", clust) # workaround 4 orthomcl behaviour
  clust.fname = paste("tmp/nonCoreGenes/",gsub(":","", clust),".txt",sep="")
  # create a fasta file with each cds from cluster
  system(paste("rm ",clust.fname,sep=""),ignore.stderr=T)
  for(j in 1:strains.count)
  {
    strain = strains[j]
    seq <- dbGetQuery(con,paste("select nseq from cdsClusters where cluster = '",clust,"' and strain='", strain, "';", sep=""))  
    seq = seq$nseq[1]
    if(length(seq)>0 ){
     system(paste('echo ">',strain,'" >> ',clust.fname,sep=""))
     system(paste("echo ",seq," >> ",clust.fname, sep=""))
    }
  }
  clust.alname = paste("tmp/nonCoreGenes/",gsub(":","", clust),".alseq",sep="")
  clust.distname = paste("tmp/nonCoreGenes/",gsub(":","", clust),".dnadist",sep="")
  # align and calc dist 
  system(paste("emma -sequence ", clust.fname ," -outseq ",clust.alname," -dendoutfile qu.dnd"))
  system(paste("fdnadist -sequence ", clust.alname ," -outfile  ",clust.distname,"  -method f "))
  system(paste("bash helpers/ph2mat.sh", clust.distname,"tmp/nonCoreGenes/out"))
  o <- read.delim("tmp/nonCoreGenes/out",sep=" ", header=F, as.is = T)  
  rownames(o) = o$V1
  o <- o[,-1]
  colnames(o) = rownames(o)
  o <- o[,order(colnames(o), sort(colnames(o)))]
  o <- o[order(rownames(o), sort(rownames(o))),]
  print(paste("i =",i, "of", clusters.count))
  dist.matrices.noncore[[clust.name]] = o
}

system("mkdir -p ../results")
system("rm qu.dnd")
save(dist.matrices.noncore, file="results/dist.matrices.noncore.rdat")
