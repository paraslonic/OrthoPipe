date > ../Log.txt

perl helpers/createdb.pl

for f in ../gb/*.gb*; do perl helpers/gb2db.pl $f; done

perl helpers/named_groups2db.pl

# Rrrr
Rscript Rhelpers/PopulateDB.r
Rscript Rhelpers/SelectCoreGenes.r

Rscript Rhelpers/CoreGenesAlignment.r
Rscript Rhelpers/plotGenesStrainsBarplot.r
Rscript Rhelpers/PanGenomeTable.r
Rscript Rhelpers/CoreGenesMLTree.r

Rscript Rhelpers/CoreGenesDistancePlot.r
Rscript Rhelpers/PanGenesDistancePlot.r
Rscript Rhelpers/PlotPanCoreProfile.r


date > ../Log.txt

