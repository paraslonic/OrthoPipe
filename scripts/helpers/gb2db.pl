use DBI;
use Bio::SeqIO;
use File::Basename;

$DBname = ""; $password = ""; $user = "";
open (F, "<", "../config.txt");
while (<F>){
	if($_ =~ /DBname\s+=\s+"(\w*)"/ )	{ $DBname = $1 };
	if($_ =~ /User\s+=\s+"(\w*)"/ ) 	{ $user = $1 };
	if($_ =~ /Password\s+=\s+"(\w*)"/ )	{ $password = $1 };
	if($_ =~ /Host\s+=\s+"([\w\.]*)"/ )     { $host = $1 };
}
# .........................................................................................................................  

my $fin = shift or die "[genbank file]";
$name = fileparse($fin, qr/\.[^.]*/);
$in = Bio::SeqIO->new(-file => $fin, -format => 'Genbank');

my $dbh;

&connectDB;
&createTables;

# .........................................................................................................................  

$i = 1;
my $sth = $dbh->prepare("insert into cds(strain, id, product, nlength, contig, start, stop, strand, pseq, nseq) values (?,?,?,?,?,?,?,?,?, ?)");

while (my $seq = $in->next_seq()) {
        $contig = $seq->display_id();
        my @cds = grep { $_->primary_tag eq 'CDS' } $seq->get_SeqFeatures();
        foreach my $feature (@cds) {
                if($feature->has_tag('translation') ){
                        my @fseq = $feature->get_tag_values('translation');
                        my @prod = $feature->get_tag_values('product');
                        my @locus = $feature->location;
                        $prod = $prod[0];
                        $pseq = $fseq[0];
			$nseq = $feature->spliced_seq->seq();
                        #$prod =~ s/\s/_/g;
                        $sth->execute($name, $i++, $prod, length($nseq), $contig, $feature->start, $feature->end, $feature->strand, $pseq, $nseq); 
                }
        }
}

print "\nTHE END.\n" ;
 
# .........................................................................................................................  
# SUBROUTINE
# ......................................................................................................................... 

sub connectDB{
	$dbConnectString="dbi:mysql:$DBname:$host";
	$dbLogin=$user;
	$dbh = DBI->connect($dbConnectString, $dbLogin, $password) or die "Could not connect to database: $DBI::errstr";
}
 
sub createTables{
	my $sql = "create table if not exists cds(
		strain varchar(256),
		id integer,
		product varchar(1000),
		nlength integer,
		contig varchar(256),
		start integer,
		stop integer,
		strand integer,
		nseq varchar(100000),
		pseq varchar(30000),
		primary key (strain, id))";
	$dbh->do($sql);
}
