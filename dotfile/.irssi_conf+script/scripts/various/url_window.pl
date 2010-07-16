# Print clickable URLS to a window named "urls"
use Irssi;
use vars qw($VERSION %IRSSI); 
$VERSION = "0.02";
%IRSSI = (
    authors	=> "Ras",
    contact	=> "RasQulec\@gmail.com", 
    name	=> "urlwin",
    description	=> "Print clickable URL's to a window named \"urls\"",
    license	=> "Public Domain",
    url		=> "http://irssi.org/",
    changed	=> "Wed Jul 30 23:11:02 EDT 2008"
);

# RegExp & defaultcommands
%urltypes = ( http => { regexp => qr#((?:https?://[^\s<>"]+|www\.[-a-z0-9.]+)[^\s.,;<">\):])# },
              ftp  => { regexp => qr#((?:ftp://[^\s<>"]+|ftp\.[-a-z0-9.]+)[^\s.,;<">\):])# },
	      mail => { regexp => qr#([-_a-z0-9.]+\@[-a-z0-9.]+\.[-a-z0-9.]+)# },
	    );

sub check_url ($) {
    my ($text) = @_;
    foreach (keys %urltypes) {
	return 1 if ($text =~ /$urltypes{$_}->{regexp}/);
    }
}



sub sig_printtext {
  my ($server, $data, $nick, $mask, $target) = @_;

  if (check_url($data)) {
    $window = Irssi::window_find_name('urls');

	$data =~ s/\%/\%\%/g;

    $text = $target.": <".$nick."> ".$data;
    
    $window->print($text, MSGLEVEL_CLIENTCRAP) if ($window);
  }
}

$window = Irssi::window_find_name('urls');
Irssi::print("Create a window named 'urls'") if (!$window);

Irssi::signal_add('message public', 'sig_printtext');