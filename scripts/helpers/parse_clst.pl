#!/usr/bin/perl 
use Data::Dumper;

open F, '<', "named_groups.txt";
open O, ">ortho_table.txt";

%clust = ();
%strains = ();

while (my $f = <F>) {
	($clustid, @genes) = split (" ", $f);
	my %names = ();
	foreach $gene (@genes)
	{
		($strain, $num, $product) = split (/\|/, $gene);
		$clust{$clustid}{$strain} = 1;
		$clust{$clustid}{"${strain}_pname"} = $product;
		$names{$product}++;
		$strains{$strain} = 1;
	}
	#select name with maximum representatives
	$clust{$clustid}{"name"} = (reverse sort { $names{$a} <=> $names{$b} } keys %names)[0];
}

# make out
my @strains = keys %strains;
print O "id\tproduct\t" . join("\t", @strains). "\tcount\n";		#header

foreach $clust ( keys %clust){
	print O "$clust \t" .  $clust{$clust}{name} . "\t";
	my $strain_string;
	my $count = 0;
	for (@strains) {
 		$strain_string .= (exists $clust{$clust}{$_}? 1 : 0) . "\t";
 		$count += exists $clust{$clust}{$_}? 1 : 0;
		$clust{$clust}{$_}  = 0 if !exists $clust{$clust}{$_} ;
	}
	print O "$strain_string$count\n";
	$clust{$clust}{string} = $strain_string;	
}

close O;
`sed -i 's/_/ /g' out`;
