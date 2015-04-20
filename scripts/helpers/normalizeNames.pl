$dir = shift;
$_ = shift;

if(/-/){ 
	$old = $_; 
	s/-/_/g;
	s/\..*/\.fasta/g;
	$new =$_;
	print "$old -> $new\n";
	`mv $dir/$old $dir/$new`; 
}
   
