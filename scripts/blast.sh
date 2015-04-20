echo "BLAST"

name=$(basename "$1")
ext="${name##*.}"
name="${name%.*}"

perl helpers/fasta-splitter.pl --n-parts 100 $1
mkdir -p parts
mv $name.part*.fasta parts

i=0
for f in parts/$name.part*.fasta
do
	echo $f
	i=$[$i +1]
	qsub -pe make 4 -cwd -N "ortho_$i" -o out.log -e err.log helpers/blastp_tab.qsub $f
done
echo "cat parts/*.out > blast.out" > helpers/postblast.sh
echo "rm -r parts" >> helpers/postblast.sh 

qsub -cwd -hold_jid "ortho_"* helpers/postblast.sh 
