use strict;

open FILE,  "<named_groups.txt";

while(my $line = <FILE>){
#	print $line;
	my @OG = ($line =~ /(OG[0-9]+)/);
#	print @OG;
	my @names = ($line =~ /(?<=\s)([^|]+\|[0-9]+)(?=)/g);
#	print @names;
	foreach (@names){
		print $OG[0]."\t".$_."\n";
	}
} 
