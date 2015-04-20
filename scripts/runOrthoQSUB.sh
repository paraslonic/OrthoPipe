perl helpers/createdb.pl
rm -rf pairs
#ortho=/data4/bio/runs-ms/soft/OrthoMCL/bin 
orthomclInstallSchema helpers/db.config

# blast
#orthomclFilterFasta ../faa 10 20
#makeblastdb -in goodProteins.fasta -dbtype prot  -out goodProteins.fasta
#bash blast.sh goodProteins.fasta

# ortho
orthomclBlastParser blast.out ../faa > simseq.txt
orthomclLoadBlast helpers/db.config simseq.txt; 
orthomclPairs helpers/db.config pairs.log cleanup=no
orthomclDumpPairsFiles helpers/db.config
mcl mclInput --abc -I 1.5 -o groups.txt
orthomclMclToGroups OG 1000 < groups.txt > named_groups.txt
perl helpers/namedGroups2table.pl > ortho_table.txt
mkdir -p ../ortho
mv blast.out goodProteins.* groups.txt mclInput named_groups.txt pairs pairs.log poorProteins.fasta simseq.txt ortho_table.txt ../ortho
