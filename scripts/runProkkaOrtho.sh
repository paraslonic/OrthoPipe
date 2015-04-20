echo "start" > log
echo "genome fastas:" >> log; find ../fasta -name "*.fasta" | wc -l >> log
#
## 1. Prokka
bash helpers/prokkaloop.sh
echo "prokka built gbf-s: " >> log; find ../prokka -name "*.gbf" | wc -l >> log
#
mkdir -p ../gbf
find ../prokka -name "*.gbf" -exec cp {} ../gbf/ \;
#
mkdir -p ../prokka/faa
for i in ../gbf/*.gbf
do
	name=$(basename "$i"); name="${name%.*}"
	perl helpers/GB2faa.pl $i  > ../prokka/faa/$name.fasta
done

mkdir ../faa
cp ../prokka/faa/* ../faa

# 2. ORTHO
bash -x runOrtho.sh
mkdir -p ../ortho
mv blast.out goodProteins.* groups.txt mclInput named_groups.txt pairs pairs.log poorProteins.fasta simseq.txt ortho_out ../ortho

