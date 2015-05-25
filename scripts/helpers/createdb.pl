$DBname = ""; $password = ""; $user = ""; $host = "";
open (F, "<", "../config.txt");
while (<F>){
	if($_ =~ /DBname\s+=\s+"(\w*)"/ )	{ $DBname = $1 };
	if($_ =~ /User\s+=\s+"(\w*)"/ ) 	{ $user = $1 };
	if($_ =~ /Password\s+=\s+"(\w*)"/ )	{ $password = $1 };
	if($_ =~ /Host\s+=\s+"([\w\.]*)"/ )	{ $host = $1 };
	if($_ =~ /Port\s+=\s+"([\w\.]*)"/ )	{ $port = $1 };
}

print "\nwill create $DBname on $host\n";
`mysql -u $user -p$password -e 'drop database if exists $DBname' --host $host`;
`mysql -u $user -p$password -e 'create database $DBname' --host $host`; 

# make config file for OMCL
open C, "<helpers/db.config_fish";
my $fish = do { local $/; <C> };
eval $fish;
