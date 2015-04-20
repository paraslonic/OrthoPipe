perl helpers/createdb.pl
rm -rf pairs
#ortho=/data4/bio/runs-ms/soft/OrthoMCL/bin 
orthomclInstallSchema helpers/db.config

# blast
orthomclFilterFasta ../faa 10 20
makeblastdb -in goodProteins.fasta -dbtype prot  -out goodProteins.fasta
blastp -db goodProteins.fasta -query goodProteins.fasta -outfmt 6 -out blast.out -num_threads 24

# ortho
orthomclBlastParser blast.out ../faa > simseq.txt
orthomclLoadBlast helpers/db.config simseq.txt; 
orthomclPairs helpers/db.config pairs.log cleanup=no
orthomclDumpPairsFiles helpers/db.config
mcl mclInput --abc -I 1.5 -o groups.txt
orthomclMclToGroups OG 1000 < groups.txt > named_groups.txt
perl helpers/namedGroups2table.pl > ortho_table.txt
mkdir -p ../ortho
cp ortho_table.txt named_groups.txt ../ortho
