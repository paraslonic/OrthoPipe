mkdir -p ../prokka
for i in ../fasta/*.fasta
do
	name=$(basename "$i")
	ext="${name##*.}"
	name="${name%.*}"
	echo $name
	prokka --cpus 20 --outdir "../prokka/$name" --force --prefix $name --locustag "prok" $i
done
