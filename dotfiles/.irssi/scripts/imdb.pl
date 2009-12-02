#!/usr/bin/perl

# imdb.pl - Query imdb.org and return info for Film and TV Titles, as well as actor details.
# eg:
#[20:45:08] <Flash_> !imdb Jaws
#[20:45:09] Bodkin Jaws (1975)  ::  http://www.imdb.com/title/tt0073195
#[20:45:09] Bodkin Directed by Steven Spielberg. With Roy Scheider, Robert Shaw, Richard Dreyfuss. When a gigantic great white shark begins to menace the small island ...

use strict;
use Irssi;
use LWP::UserAgent;
use vars qw($VERSION %IRSSI);

$VERSION = '001';
%IRSSI = (
    authors     => 'Flash',
    contact     => 'flash@digdilem.org',
    name        => 'imdb',
    description => 'Query IMDB and return info about films etc',
    license     => 'GNU General Public License 3.0' );

my $lastline; # Simple anti-spam, repeated lines are ignored

sub query_imdb { # use google instead!
	my ($server,$msg,$nick,$address,$target) = @_;
	if ($msg =~ /^\!imdb\s+(.+)$/) {
		if ($msg eq $lastline) { print "imdb spamline detected, bailing"; return; } # Avoid spam
		$lastline = $msg;
		my $query = $1;
		my $ua = LWP::UserAgent->new;
		$ua->agent("aFlashbot/001 ");
		my $request = HTTP::Request->new(GET => "http://www.google.com/search?hl=en&q=site%3Aimdb.com+$query");
		my $result = $ua->request($request);
		my $content = $result->content;
		if ($content =~ /did not match any documents/) { return "%c<%b<%K-----------%b>%c> %R• %KSorry - %rfilm%K of that name %rnot found%K"; }
		# Some prep
		$content =~ s/&\#39;/'/g;
		$content =~ s/&quot;/\"/g;
		$content =~ s/&amp;/&/g;
		#
		$content =~ /http:\/\/www.imdb.com\/(.*?)\/\"/;
		my $film_url = $1;
		#print "%c<%b<%K-----------%b>%c> %G• %gIMDB %Kreturned (%g$1%K)%g %K http://www.imdb.com/$film_url";
		#
		$content =~ /<em>(.*?)<\/a/;
		my $film_name = $1;
		$film_name =~ s/<\/em>//gi;
		$film_name =~ s/<em>//gi;
		#
		$content =~ /<div class=std\>(.*?)<b/;
		my $film_desc = $1;
		$film_desc =~ s/<\/em>//gi;
		$film_desc =~ s/<em>//gi;
		$film_desc =~ s/Visit IMDb/\0/; # Get rid of advert
		#$film_desc .= '...';
		#$film_desc =~ s/&gt;/\>/g;
		#$film_desc =~ s/&lt;/</g;
		print "%c<%b<%K-----------%b>%c> %G• %gIMDB %Kreturned%g $film_name %K http://www.imdb.com/$film_url";
		my @ret;
		$server->command("/msg $target $film_name  ::  http://www.imdb.com/$film_url");
		#$server->command("/msg $target $film_desc");
		return @ret;
	} # End, message wasn't for me.
}

Irssi::signal_add('message public','query_imdb');
Irssi::signal_add('message own_public','query_imdb');
