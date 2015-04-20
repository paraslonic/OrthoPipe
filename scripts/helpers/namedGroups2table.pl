#!/usr/bin/perl 
use Data::Dumper;

open F, '<', "named_groups.txt";

%clust = ();
%strains = ();

while (my $f = <F>) {
	($clustid, @genes) = split (" ", $f);
	my %names = ();
	foreach $gene (@genes)
	{
		($strain, $id, $product) = split (/\|/, $gene);
		$clust{$clustid}{$strain}++;
		$clust{$clustid}{"${strain}_pname"} = $product;
		$names{$product}++;
		$strains{$strain} = 1;
	}
	#select name with maximum representatives
	$clust{$clustid}{"name"} = (reverse sort { $names{$a} <=> $names{$b} } keys %names)[0];
}

# make out
my @strains = keys %strains;
print "id\tproduct\t" . join("\t", @strains). "\tstrains\n";		#header

foreach $clust ( keys %clust){
	print "$clust\t" .  $clust{$clust}{"name"} . "\t";
	my $strain_string;
	my $count = 0;
	for (@strains) {
 		$strain_string .= (exists $clust{$clust}{$_}? $clust{$clust}{$_} : 0) . "\t";
 		$count += exists $clust{$clust}{$_}? 1 : 0;
	}
	print "$strain_string$count\n";
}
