use Bio::SeqIO;

@strains = `ls ../faa/ | sed 's/.fasta//g'`;
@strains = map(chomp, @strains);

`Rscript helpers/selectCoreSimpl.r`;
@core = `cat core`;
map(chomp, @core);
map {$Cores{$_} = 1 } @core;

open F, "<named_groups.txt" ;
`mkdir -p coreGroupsFaa`;
while (my $clust = <F>) {
	($clustid, @genes) = split (" ", $clust);
	next if($Cores{$clustid} != 1);	
	$id_out = "coreGroupsFaa/$clustid.txt";	
	open O, ">$id_out";
	print O join("\n", @genes);
	close(O);	
	$faa_out = "coreGroupsFaa/$clustid.faa";
	$faa_al_out = "coreGroupsFaa/${clustid}_aligned.faa";
	`selectSeqs.pl -f $id_out goodProteins.fasta > $faa_out`;
	`rm $id_out`;
	$cores++;
	`helpers/./clustalo  -i $faa_out > $faa_al_out`;
	 
}

print "selected $cores core gene groups\n";

# concatanate all groups to 1
@files = `ls coreGroupsFaa/*_aligned.faa`;
my %Sequences = ();
foreach $fn (@files)
{
        $inseq = Bio::SeqIO->new(-file => "$fn",  -format => "fasta");
        while($seq = $inseq->next_seq)
        {
		$seq->id() =~ /(.+?)\|/;
                $strain =  $1;
                $Sequences {$strain} .= $seq->seq();
        }
}
open O, ">coreGroupsFaa/core.fasta";
foreach $strain(keys %Sequences)
{
        print O ">$strain\n";
        print O $Sequences {$strain} . "\n";
}
close(O);

# concat
`perl helpers//Fasta2Phylip.pl coreGroupsFaa/core.fasta coreGroupsFaa/core.phy`;
`helpers/./PhyML-3.1_linux64 -i coreGroupsFaa/core.phy -d aa -q`;

print "done.\n" ;
 
