#!/usr/bin/perl

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

%IRSSI = (
	'authors'	=>	'Haui',
	'contact'	=>	'haui45@web.de',
	'name'		=>	'wiki-search',
	'description'	=>	'this script allows you to "search"' . 
				'wikipedia from irssi',
	'license'	=>	'GPL',
	'version'	=>	'0.1'
	);

use strict;
#uncomment this, if you're sure of having curl installed
`which curl` or die "fatal...curl not found!";
my $string = "";
sub wiki {
 # data - contains the parameters for /wiki
# server - the active server in window
# witem - the active window item (eg. channel, query)
#         or undef if the window is empty
my ($data, $server, $witem) = @_;

if (!$server || !$server->{connected}) {
Irssi::print("Not connected to server");
return;
}

if ($data && $witem && ($witem->{type} eq "CHANNEL" ||
                  $witem->{type} eq "QUERY")) {
$string = "http://en.wikipedia.org/wiki/";
chop($data) while (substr($data, length($data)-1) eq " ");
$data =~ s/(\b)([a-z])/\1\u\2/g;
$data =~ s/ /_/g;
my $url = "$string"."$data";
my @array = `curl -s \"$url\"`;
my $tmp = grep (/<b>Wikipedia does not have an article with this exact name.<\/b>/, @array);
undef(@array);
if ($tmp != 0)
{
$url = "http://en.wikipedia.org/wiki/Special:Search/" . "$data";
$witem->command("/ECHO Nothing found, try $url");
$tmp = 0;
return;
}
$witem->command("SAY $url");

} else {
Irssi::print("No active channel/query in window");
}
}


  Irssi::command_bind('wiki', 'wiki');


