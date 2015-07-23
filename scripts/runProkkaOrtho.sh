echo "start" > log
echo "genome fastas:" >> log; find ../fasta -name "*.fasta" | wc -l >> log
#
## 1. Prokka
bash helpers/prokkaloop.sh
echo "genebank files in prokka dir: " >> log; find ../prokka -name "*.gb*" | wc -l >> log
#
mkdir -p ../gb
find ../prokka -name "*.gb*" -exec cp {} ../gb/ \;
#
echo "genebank files in gb dir: " >> log; find ../gb/ -name "*.gb*" | wc -l >> log
mkdir -p ../prokka/faa

for i in ../gb/*.gb*
do
        perl helpers/normalizeNames.pl $i
done

for i in ../gb/*.gb*
do
	name=$(basename "$i"); name="${name%.*}"
	echo "$name"
	perl helpers/GB2faa.pl $i  > ../prokka/faa/$name.fasta
done

mkdir ../faa
cp ../prokka/faa/* ../faa

# 2. ORTHO
bash -x runOrtho.sh
mkdir -p ../ortho
mv blast.out goodProteins.* groups.txt mclInput named_groups.txt pairs pairs.log poorProteins.fasta simseq.txt ortho_table.txt ../ortho

