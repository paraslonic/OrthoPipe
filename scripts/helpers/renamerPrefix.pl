#! /usr/bin/perl -w

use Bio::SeqIO;

my $usage = "[file] [prefix] [filtered file]\n";
my $file = shift or die $usage;
my $format = "fasta";
my $prefix = shift;
my $result = shift or die $usage;

my $inseq = Bio::SeqIO->new( -file => "<$file", -format => $format,);
my $outseq = Bio::SeqIO->new( -file => ">$result", -format => $format,);
$i = 1;

while( my $seq = $inseq->next_seq) 
{
	my $id = "${prefix}_${i}";
	$nseq = Bio::Seq->new( -display_id => $id,
                             -seq => $seq->seq());
	$outseq->write_seq($nseq);
	$i = $i + 1;
}

print "remains: ", $i;
			

