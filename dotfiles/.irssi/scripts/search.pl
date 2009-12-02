# search.pl
#
# USAGE
# /search <regexp>
# then /next or /prev
#
# TODO
# - hilight search terms
#

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

$VERSION = "0.1";
%IRSSI = (
    authors	=> "Gabor Adam TOTH",
    contact	=> "tg\@x-net.hu",
    name	=> "search",
    description	=> "search in scroll buffer",
    license	=> "GPL",
    url		=> "http://scripts.irssi.hu/search.pl",
    changed	=> "Tue 20 Jun 16:22 CET 2004"
);

use Irssi::TextUI;

my $end = 0;
my $pattern = "";
my $direction = "";

sub cmd_search {
    my ($data, $server, $witem) = @_;
    $pattern = $data;
    $direction = "start";
    $end = 0;
    search();
}

sub cmd_next {
    return if !$pattern;
    $direction = "forward";
    $direction = "start" if $end;
    search();
}

sub cmd_prev {
    return if !$pattern;
    $direction = "backward";
    $direction = "end" if $end;
    search();
}

sub search {
    my $buf = '';
    my $view = Irssi::active_win()->view();
    my $line = $view->get_bookmark("search");
    $_ = $direction;
    if ( !$line || $end ) {
	s/forward/start/;
	s/backward/end/;
    }
    
    SWITCH: {
	/forward/ && do {
	     $line = $line->next();
	     last SWITCH; };
	/backward/ && do { 
	    $line = $line->prev();
	     last SWITCH; };
	/start/ && do { 
	    $line = $view->get_lines();
	    $view->set_bookmark("search", $line);
	    $direction = "forward";
	    last SWITCH; };
	/end/ && do { 
	    $view->set_bookmark_bottom("search");
	    $line = $view->get_bookmark("search");	    
	    $direction = "backward";
	    Irssi::print("end");
	    last SWITCH; };
    }

    while ( defined $line) {
	$buf = $line->get_text(0);
	if ( $buf =~ /$pattern/ ) {
		$view->scroll_line($line);
		$view->set_bookmark("search", $line);		
		$end = 0;
		return;
	}
	$line = $line->next() if $direction eq "forward";
	$line = $line->prev() if $direction eq "backward";	
    }
    
    if ( !$end ) {
	$end = 1;
	search();
    }
}
                                                                                         
Irssi::command_bind('search', 'cmd_search');
Irssi::command_bind('next', 'cmd_next');
Irssi::command_bind('prev', 'cmd_prev');
