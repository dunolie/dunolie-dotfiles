#!/usr/bin/perl
# Parse URL's posted to an IRC log (irssi formated)
# Generates an HTML page from the links. 
#

use strict;

use constant DIR => '/Users/robbie/bin/irssi-urlparse.pl';

my $file = $ARGV[0];
die("File $file not found\n") unless( -e $file );

my $chan = $1 if $file =~ /#([^\.]+)\.log/i;
my $title = "URL's mentioned in $chan";
my $duration = "30 minutes";
my $update = localtime();

my @data = ();

open( FILE, $file );

while(<FILE>) {
	my $line = $_;
	# 10:10:23 <nname> what they say 
	if( $line =~ /^\d{1,2}:\d{1,2} <[~@%&\+\s]([^>]+)>.*(http:\/\/[0-9a-zA-Z:\$_.+!*\-\/?\#=,]+).*$/i ) {
		my $item = {
			nick => $1,
			url => $2,
			line => $line,
		};

		push @data, $item;
	}

}
close FILE;

##### Output the html page #####
open( OUT, ">/Users/robbie/Sites/irssi-logs/$chan.html" );

open( HEADER, DIR . "/header.tpl" );
my $head = join("", <HEADER>);
close HEADER;

$head =~ s/\{\$title\}/$title/;
$head =~ s/\{\$chan\}/$chan/;
$head =~ s/\{\$duration\}/$duration/;
$head =~ s/\{\$update\}/$update/;

my $len = @data;
$head =~ s/\{\$count\}/$len/;

print OUT $head;

my $count = 0;
foreach my $item (reverse @data) {
	my $line = $item->{line};
	chomp($line);
	$line =~ s/\'/\\\'/gi;
	$line =~ s/\"/\\\"/gi;
	$line =~ s/\</&lt;/gi;
	$line =~ s/\>/&gt;/gi;


	my $url = $item->{url};
	my $urltext = $url;
	$urltext = substr($urltext, 0, 64) . "..." if( length($urltext) > 64 );
  
	my $tr = "";
	if( $count % 2 != 0 ) { $tr = " class=\"alt\""; }
	print OUT << "EOD";
	<tr $tr>
		<td>$item->{nick}</td>
		<td><a href="$url" title="$url">$urltext</a></td>
		<td><span class="line" onmouseover="setTip('$line');">Text</span></td>
	</tr>

EOD

	$count++;

}

open( FOOTER, DIR . "/footer.tpl" );
my $footer = join("", <FOOTER>);
print OUT $footer;

close OUT;
