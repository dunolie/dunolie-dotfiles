#!/opt/local/bin/perl
use strict;
use warnings;

open my $infile, "<", "yaydl.pl" or die $!;
my @array = <$infile>;
close $infile;
$array[0] = "#!/opt/local/bin/perl\n";
open $infile, ">", "yaydl.pl" or die $!;
foreach(@array){
	print $infile $_;
}
close $infile;
   	
