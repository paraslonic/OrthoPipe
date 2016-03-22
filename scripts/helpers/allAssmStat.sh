length_filter.pl assembly/mira/mira_d_results/mira_out.unpadded.fasta fasta 500 assembly/mira500.fasta
length_filter.pl assembly/spades/contigs.fasta fasta 500 assembly/spades500.fasta
cp assembly/newbler/assembly/454LargeContigs.fna assembly/newbler500.fasta

mkdir -p stats
echo "spades, mira, newbler assembly metrics:" > stats/assemblyStats.txt
assemblyStats.pl assembly/spades500.fasta  >> stats/assemblyStats.txt
assemblyStats.pl assembly/mira500.fasta | tail -1 >> stats/assemblyStats.txt
assemblyStats.pl assembly/newbler500.fasta | tail -1 >> stats/assemblyStats.txt

