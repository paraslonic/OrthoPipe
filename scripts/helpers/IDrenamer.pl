#! /usr/bin/perl -w

use Bio::SeqIO;

my $usage = "[file] [format] [filtered file]\n";
my $file = shift or die $usage;
my $format = shift or die $usage;
my $result = shift or die $usage;

my $inseq = Bio::SeqIO->new( -file => "<$file", -format => $format,);
my $outseq = Bio::SeqIO->new( -file => ">$result", -format => $format,);
$i = 1;

while( my $seq = $inseq->next_seq) 
{
	$prefix = "contig";
	$prefix = "plasmid" if ($seq->id() =~ /plasmid/);
	#print $seq->id();
	my $id = $prefix.$i;
	$nseq = Bio::Seq->new( -display_id => $id,
                             -seq => $seq->seq());
	$outseq->write_seq($nseq);
	$i = $i + 1;
}

print "remains: ", $i;
			

