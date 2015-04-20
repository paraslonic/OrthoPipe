use DBI;
use Bio::SeqIO;

# .........................................................................................................................  
print "adding clusters to DB\n" ;
$DBname = ""; $password = ""; $user = "";
open (F, "<", "../config.txt");

while (<F>){
	if($_ =~ /DBname\s+=\s+"(\w*)"/ )	{ $DBname = $1 };
	if($_ =~ /User\s+=\s+"(\w*)"/ ) 	{ $user = $1 };
	if($_ =~ /Password\s+=\s+"(\w*)"/ )	{ $password = $1 };
}

$file = shift or $file = "../ortho/named_groups.txt";
open F, '<', $file;

my $dbh;

&connectDB;
&createTables;
# .........................................................................................................................  

my $sth = $dbh->prepare("insert into clusters(cluster, strain, id) values (?,?,?)");
while (my $clust = <F>) {
	($clustid, @genes) = split (" ", $clust);	
	foreach $gene (@genes)
	{
		($strain, $id) = split (/\|/, $gene);
		$sth->execute($clustid, $strain, $id);
		#print "($clustid, $strain, $id, $contig)\n";
	}
}
print "done.\n" ;
 
# .........................................................................................................................  
# SUBROUTINE
# ......................................................................................................................... 


sub connectDB{
 	$dbConnectString="dbi:mysql:".$DBname.":mysql_local_infile=1:localhost";
	$dbLogin=$user;
	print "($dbConnectString, $dbLogin, $password)";	
	$dbh = DBI->connect($dbConnectString, $dbLogin, $password) or die "Could not connect to database: $DBI::errstr";
}

 sub createTables{
	my $sql = "drop table if exists clusters;";
	$dbh->do($sql);
	my $sql = "
		create table if not exists clusters (
		cluster varchar(64),
		strain varchar(64),
		id integer,
		primary key (strain, id))";
	$dbh->do($sql);
}
