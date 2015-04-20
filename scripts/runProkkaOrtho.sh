echo "start" > log
echo "genome fastas:" >> log; find ../fasta -name "*.fasta" | wc -l >> log
#
## 1. Prokka
bash helpers/prokkaloop.sh
echo "prokka built gbf-s: " >> log; find ../prokka -name "*.gbf" | wc -l >> log
#
mkdir -p ../gb
find ../prokka -name "*.gbf" -exec cp {} ../gb/ \;
#
mkdir -p ../prokka/faa
for i in ../gb/*.gb*
do
	name=$(basename "$i"); name="${name%.*}"
	perl helpers/GB2faa.pl $i  > ../prokka/faa/$name.fasta
done

mkdir ../faa
cp ../prokka/faa/* ../faa

# 2. ORTHO
bash -x runOrtho.sh
mkdir -p ../ortho
mv blast.out goodProteins.* groups.txt mclInput named_groups.txt pairs pairs.log poorProteins.fasta simseq.txt ortho_table.txt ../ortho

