# Print hilighted messages & private messages to window named "hilight"
# for irssi 0.7.99 by Timo Sirainen
use Irssi;
use vars qw($VERSION %IRSSI); 
$VERSION = "1.0";
%IRSSI = (
    authors	=> "Riku Lindblad",
    contact	=> "shrike@addiktit.net", 
    name	=> "urlwin",
    description	=> "Print urls to a window named \'urls\'",
    license	=> "BSD",
    url		=> "http://tefra.fi/software/irssi/",
);

# find urls with a simple regex, should work unless there is an user error
sub find_url {
   my $text = shift;
   if($text =~ /((ftp|http):\/\/[^ ]+)/i){
	  return $1;
   }elsif($text =~ /(www\.[^ ]+)/i){
	  return "http://".$1;
   }
   return undef;
}

# filter public messages, find urls from them and print them to the url window
sub sig_pubmsg {
    my($server,$text,$nick,$hostmask,$channel)=@_;
    
    $url = find_url($text);
    
    if ($url) {
	$window = Irssi::window_find_name('urls');
	
	$uid = sprintf("%22s", $nick."|".$channel);
	$line = $uid." %W>>>%n ".$url;
	$line =~ s/%([^Wn])/%%$1/g;
	$window->print($line, MSGLEVEL_NEVER) if ($window);
    }
}

$window = Irssi::window_find_name('urls');
Irssi::print("Create a window named 'urls'") if (!$window);

Irssi::signal_add('message public', 'sig_pubmsg');
