use List::Util qw(min max);

print "checking length of id in fasta files...\n";

@files = `ls -d ../fasta/*`;

foreach $file(@files)
{
	chomp $file;
	print "$file\n";
	@ids = `grep "^>" $file`;
	$max_idlen = max map { length }  @ids;
	if($max_idlen > 20){ 
		`perl helpers/renamerPrefix.pl $file contig tmp.fasta; mv tmp.fasta $file`;
 		print ("changed ids in $file\n");
	}
}
