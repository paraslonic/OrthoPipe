# input: cdsClusters, ../ortho/ortho_table.txt
# output: ../results/pdf/CorePanProfile.pdf, ../results/PanCoreProfile.txt

library("gplots")
library("RMySQL")

# ortho table
table <- read.delim("../ortho/ortho_table.txt", head = T, as.is = T)
cols  <- 3:(ncol(table)-1)
tmp  <- table[,cols]; tmp[ tmp > 1 ]  <- 1; table[,cols]  <- tmp

# sql
source("../config.txt")
con <- dbConnect(MySQL(), user=User, password=Password, dbname=DBname)
orph <- dbGetQuery(con, "select strain,count(*) as count from cdsClusters where strains = 1 group by strain;")
#

fpan <- function(x){ return (sum(x) >= 1)}

strain.count = ncol(table) - 3 #id, prod, count

tpan = data.frame()
tcore = data.frame()

for (s in 1:PanCorePermutations) # permutations
{
  t <- table[,sample(cols)]
  vcore = c()
  vpan = c()
  pan.orphs = 0
  for (i in 0:(strain.count-1))
  {
    temp <- data.frame(t[,c(1:(1+i))])
    core <- apply(temp, 1, prod)
    pan <- apply(temp, 1, fpan)
    pan.orphs = sum(orph[ orph$strain %in% colnames(temp), 2])
    vcore <- c(vcore, sum(core))
    vpan <- c(vpan, sum(pan) + pan.orphs)
  }
  tcore <- rbind(vcore, tcore)
  tpan <- rbind(vpan, tpan)
}

core.mean <- apply(tcore, 2, mean)
pan.mean <- apply(tpan, 2, mean)
length(core.mean)

pdf("../results/pdf/CorePanProfile.pdf")
strains  <- cols-2
plot(strains, rep(max(vpan) , strain.count), type='n', ylim = c(0, max(vpan)*1.2), 
     xlab = "species", ylab = "number of gene families")
axis(1, at =strains)
lines(strains, core.mean, col = "red", lwd = 3)
lines(strains, pan.mean, col = "dark blue", lwd = 3)
points(strains, core.mean, col = "red", lwd = 2, pch = 16)
points(strains, pan.mean, col = "dark blue", lwd = 2, pch = 16)
legend("topleft", c("Core genome", "Pan genome"), lwd = c(4, 4), col = c("red", "dark blue"))
dev.off()

pancore.table  <- rbind(core = core.mean, pan = pan.mean)
colnames(pancore.table)  <- strains
write.table(pancore.table, "../results/PanCoreProfile.txt" ,sep = "\t", quote= F)