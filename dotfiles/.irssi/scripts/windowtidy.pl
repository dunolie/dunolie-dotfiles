# Windowtidy by James "JamesOff" Seward
#
use strict;
use Irssi;

use vars qw{%IRSSI $VERSION};

%IRSSI = (
	name => 'windowtidy',
	authors => 'James Seward',
	contact => 'james@jamesoff.net',
	url => 'http://jamesoff.net',
	description => 'Closes windows with no items in and no name.',
	license => 'BSD',
	changed => '2007-04-26',
);

$VERSION = "1.0";

sub command_windowtidy {
	my($data,$server,$witem) = @_;

	my $count = 0;

	# need to iterate windows in reverse to stop their positions changing
	# on reflection I guess I could probably just get the size of the windows array and
	# count backwards from there, but it works now so meh :P
	my @windows = sort { $b <=> $a } map { $_->{refnum} } Irssi::windows();

	foreach my $win (@windows) {
		my $window = Irssi::window_find_refnum($win);
		if (($window->{active} eq "") && ($window->{name} eq "")) {
			Irssi::command("window close $win");
			$count++;
		}
	}
	Irssi::print("Tidied away $count window(s).");

	return;
}

Irssi::command_bind('windowtidy', 'command_windowtidy');
