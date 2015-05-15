use Data::Dumper;
use Bio::SeqIO;

print "running concatenate_alseq.pl\n";

open S, "<tmp/strains.txt";
$i = 1;

while(<S>){
	chomp;
	next if(/^strains$/);
	$strains{$i} = $_;
	$i++;	
}

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
open O, ">core.fasta";
open ON, ">coreNamed.fasta";
foreach $strain(keys %Sequences)
{
	$strain =~ s/\.alseq//;
	print "$strain\n";
	print ON ">$strains{$strain}\n";
	print ON $Sequences {$strain} . "\n";
	print O ">$strain\n";
	print O $Sequences {$strain} . "\n";
}
close(O);


