$_ = shift;

if(/[^a-zA-Z0-9_.\/]/){
	print "strange symbol in $_\n"; 
	$old = $_; 
	s/[^a-zA-Z0-9_.\/]/_/g;
	s/_+/_/g;
	$new = $_;
	if($new ne $old)
	{ 
		print "$old -> $new\n";
		`mv "$old" $new`; 
	} 
}
   
