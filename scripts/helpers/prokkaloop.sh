mkdir -p ../prokka
for i in ../fasta/*.fasta
do
	name=$(basename "$i")
	ext="${name##*.}"
	name="${name%.*}"
	echo $name
	/srv/common/opt/prokka-1.7/bin/prokka --cpus 20 --outdir "../prokka/$name" --force --prefix $name --locustag "prok" $i
done
