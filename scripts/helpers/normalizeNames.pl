$_ = shift;

if(/[^0-9A-Za-z_]/){ 
	$old = $_; 
	s/[^0-9A-Za-z_.\/]/_/g;
	$new =$_;
	if($new != $old) { 
		print "$old -> $new\n";
		`mv $old $new` 
	} 
}
   
