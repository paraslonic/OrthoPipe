#!/srv/common/bin/perl

###############################################################################
##	parses genbank file and prints CDS to with annotation (product) as id. 
#	23.08.13 	A. Manolov

use Bio::SeqIO;
use File::Basename;

my $fin = shift or die "[genbank file]";

$name = fileparse($fin, qr/\.[^.]*/);

$in = Bio::SeqIO->new(-file => $fin, -format => 'Genbank');
$id = 1;
while (my $seq = $in->next_seq()) {
	$contig = $seq->display_id();
	my @cds = grep { $_->primary_tag eq 'CDS' } $seq->get_SeqFeatures();
	foreach my $feature (@cds) {
		if($feature->has_tag('translation') ){
			my $fseq = $feature->spliced_seq;
			my @prod = $feature->get_tag_values('product');
			my @locus = $feature->location;
			my $prod = $prod[0];
			$prod =~ s/\s+/_/g; 
			print ">$name|$id|$prod|$contig"."|".$feature->start."|".$feature->end."\n".$fseq->seq()."\n";
			$id++;
		}
	}
}
