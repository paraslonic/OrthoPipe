use Data::Dumper;
use Bio::SeqIO;

print "running concatenate_alseq.pl\n";

$dir = "tmp/coreGenes"; 
opendir(DIR, $dir);
my @files = readdir DIR;
$i = 0;

my %Sequences = ();
print "\nclusters:\n";
foreach $fn (@files)
{
	next until($fn =~ /\.alseq/);
	#last if($i++ > 3);
	print "$fn\n";
	$inseq = Bio::SeqIO->new(-file => "$dir/$fn",  -format => "fasta");
	while($seq = $inseq->next_seq)
	{
		$strain =  $seq->id();
		$Sequences {$strain} .= $seq->seq();
	}
}

$outdir = "tmp/coreGenes/concatenatedGenes";
`mkdir -p $outdir `;
print "\nstrains:\n";
foreach $strain(keys %Sequences)
{
	$strain =~ s/\.alseq//;
	print "$strain\n";
	open O, ">", "$outdir/$strain.fasta";
	print O ">$strain\n";
	print O $Sequences {$strain} . "\n";
}


