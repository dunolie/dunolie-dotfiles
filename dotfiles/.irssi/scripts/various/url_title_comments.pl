#!/usr/bin/perl -w

###############################################################################
## Colour codes
# edit line 114 :   $string = Colorize("::: ", 8, 0, 0) . Colorize($string, 16, 0, 0);
#
# No      N               H       S       V
# 1       Black           160     0       0
# 14      B Black         160     0       80
# 5       Red             0       240     88
# 7       Yellow          40      240     88
# 3       Green           80      240     88
# 10      Cyan            120     240     88
# 2       Blue            160     240     88
# 6       Magenta         200     240     88
# 4       B Red           0       240     160
# 8       B Yellow        40      240     160
# 9       B Green         80      240     160
# 11      B Cyan          120     240     160
# 12      B Blue          160     240     160
# 13      B Magenta       200     240     160
# 15      White           160     0       176
# 16      B White         160     0       240

###############################################################################
# BUG -- % in url formats color in url %% stops it 
#  $data =~ s/\%/\%\%/g; willstop  
#http://example.com/test%20DONTBEGREEN DONTBEGREEN being bold green backgound
#
#sub sig_printtext {
#  my ($server, $data, $nick, $mask, $target) = @_;
#
#    $window = Irssi::window_find_name('urls');
#
#	$data =~ s/\%/\%\%/g;
#
#    $text = $target.": <".$nick."> ".$data;
#    
#    $window->print($text, MSGLEVEL_CLIENTCRAP) if ($window);
#  }
#}
#
# above taken from RasQulec's (#irssi @ freenode) url_window.pl script
###############################################################################

use strict;
use HTML::TokeParser;
use Irssi;
use Irssi::TextUI;
use vars qw($VERSION %IRSSI);
our $active_pid = undef;
$VERSION = "1.0";
%IRSSI=(
    author  => 'epoch',
    contact => 'epoch@9trickpony.com',
    name    => 'URL title displayer for Irssi.',
    license => 'GPL',
    url => 'http://9trickpony.com'
);

#-------[ History: ]------------------------------------------------------
#	1.0: Initial release, no bugs found, working as it should.
#	1.1: Fork() so we don't tie up irssi.
#-------------------------------------------------------------------------

#-------[ message_public ]------------------------------------------------
#	Get the url from publicly-announced text.
#
#-------------------------------------------------------------------------
sub message_public {
    my ($server, $msg, $nick, $address, $target) = @_;
	#Regex from openurl.pl [http://irssi.org/scripts/scripts/openurl.pl]
	if ($msg =~ qr#((?:https?://[^\s<>"]+|www\.[-a-z0-9.]+)[^\s.,;<">\):])#){
		my ($url) = ($msg) =~ qr#((?:https?://[^\s<>"]+|www\.[-a-z0-9.]+)[^\s.,;<">\):])#;
		return if ($url =~ /(iso|png|jpe?g|bin|sh|c|gif|tiff|mp3|wav|ogg|mpu|pls|wmv|avi|mov|qt|mpe?g)$/i);
		GetTitle($url, $server, $target);
	}
}

#-------[ GetTitle($url) ]------------------------------------------------
#	Get the title of the page, using lqp from the $url.
#
#-------------------------------------------------------------------------
sub GetTitle($$$){
	my ($url, $server, $target)=@_;

    $url =~ s/^\s+//;
    $url =~ s/\s+$//;

	use LWP::UserAgent;
	my $browser = LWP::UserAgent->new();
	$browser->max_size(1000);	#Max is 1M.

	use WWW::Mechanize::Sleepy;
	my $webagent = WWW::Mechanize::Sleepy->new(timeout=>7);
	
	#LWP::UserAgent doesn't like non-absolute URI's; fix.
	if ($url !~ /^(ht|f)tp/){
		$url = "http://$url";	#Assume http.
	}
	
	$webagent -> get($url); 
    if ($webagent->success) {
	    my $stream = HTML::TokeParser->new(\$webagent->content);
	    $stream->get_tag('title');
	    my $title = $stream->get_trimmed_text('/title');

	    if (!$title){ 
		    $title = "No title.";
	    }

	    ActiveWindow($server, $target, $title);
    }else{
		my $string = "Error getting $url";
		ActiveWindow($server, $target, $string);
    }
}


#-------[ ActiveWindow($$$) ]---------------------------------------------------
#	Given a server and target and string, print the string to the active window.
#	Code from openurl.pl
#
#-------------------------------------------------------------------------------
sub ActiveWindow($$$){
	my ($server, $target, $string) = @_;
    my $witem;
    if (defined $server) {
		$witem = $server->window_item_find($target);
    } else {
		$witem = Irssi::window_item_find($target);
    }

    if (defined $witem) {
		$string = Colorize("::: ", 8, 0, 0) . Colorize($string, 16, 0, 0);
		$witem->print($string);
	}
}

#-------[ Colorize($$$$) ]------------------------------------------------------
#	Given a string, and a color code integer, return the color coded string.
#	[ported from my own IrssiBot.pl script 
#		(unreleased as of Fri Sep 17 13:39:42 EDT 2004)]
#
#-------------------------------------------------------------------------------

sub Colorize{   #(string, int, chan, serv) [int=color code]
    my ($str, $fg, $channel, $server)=@_;
	if ($server && $channel){
	    my $chan = $server->channel_find($channel);
	    return $str if ($chan->{mode} =~ /c/);
	}
    my $tmpstr;
    $tmpstr = "\003";
    $tmpstr .= sprintf("%02d", $fg);
    $tmpstr .= $str;
    $tmpstr .= "\003";
    return $tmpstr;
}


# Irssi Signal(s)
Irssi::signal_add('message public','message_public');

