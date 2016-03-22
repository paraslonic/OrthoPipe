# input: panGenomeTableAll.csv
# orphans are not taken in view 
# this version for data2. should be modified for this, orphans should be added

PanCorePermutations = 20

library("gplots")
library("RColorBrewer")

# get orthologues
table <- read.delim("panGenomeTableAll.csv", head = TRUE, as.is = TRUE)
strain.count = ncol(table) # id is a rowname 

tpan = data.frame()
tcore = data.frame()

# make permutations and calculations
fpan <- function(x){ return (sum(x) >= 1)}
for (s in 1:PanCorePermutations) 
{
  t <- table[,sample(1:ncol(table))]
  vcore = c()
  vpan = c()
  pan.orphs = 0
  for (i in 0:(strain.count-1))
  {
    temp <- data.frame(t[,c(1:(1+i))])
    core <- apply(temp, 1, prod)
    pan <- apply(temp, 1, fpan)
    vcore <- c(vcore, sum(core))
    vpan <- c(vpan, sum(pan))
  }
  tcore <- rbind(vcore, tcore)
  tpan <- rbind(vpan, tpan)
}

core.mean <- apply(tcore, 2, mean)
pan.mean <- apply(tpan, 2, mean)

# plot main
colors = brewer.pal(4, name = "Paired")
core.color1 = colors[3]
core.color2 = colors[4]
pan.color1 = colors[1]
pan.color2 = colors[2]

pdf("CorePanProfile.pdf")
strains  <- 1:strain.count
plot(strains , rep(max(vpan) , strain.count), type='n', ylim = c(0, max(vpan)*1.2), 
     xlab = "genomes", ylab = "number of OG", xaxt='n',bty ="n")
axis(1, at =strains, las = 2)
lines(strains, core.mean, col = core.color1, lwd = 4)
lines(strains, pan.mean, col = pan.color1, lwd = 4)
legend("topleft", c("Pan genome","Core genome"), lwd = c(4, 4), col = c(pan.color2,core.color2),
       bty = "n")

pancore.table  <- rbind(core = core.mean, pan = pan.mean)
colnames(pancore.table)  <- strains
write.table(pancore.table, "PanCoreProfile.txt" ,sep = "\t", quote= F)

# fit core
y <- core.mean
x <- strains
nls <- as.data.frame(summary(nls(y ~ A1 + A2 * exp(B1*x), start=list(A1=2500,A2=500,B1=-0.2)))$parameters)
core.estimates = nls$Estimate

y.pred = nls$Estimate[1] + nls$Estimate[2] * exp(nls$Estimate[3]*x)
points(strains, y.pred, col = core.color2, lwd = 2, pch = 3)
abline(h = nls$Estimate[1], lty = 2, col = core.color2)

# fit pan
y <- pan.mean
x <- strains
nls <- as.data.frame(summary(nls(y ~ A1 + A2 * x ^ B1, start=list(A1=2500,A2=500,B1=0.4)))$parameters)
pan.estimates = nls$Estimate
y.pred = nls$Estimate[1] + nls$Estimate[2] * x^nls$Estimate[3]
points(strains, y.pred, col = pan.color2, lwd = 2, pch = 3)
dev.off()

# write estimates
estimates = rbind(core.estimates, pan.estimates)
colnames(estimates) = c("A1","A2","B1")
write.table(estimates, "PanCoreEstimates.txt", sep = "\t", quote= FALSE)
