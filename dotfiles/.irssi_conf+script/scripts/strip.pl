use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "0.2";
%IRSSI = (
	authors     => "planb",
	contact     => "planb\@ironsunrise.com",
	name        => "strip.pl",
	description => "Simple script that removes colors and other formatting (bold, etc) from specific channels or nicknames - Based on CleanPublic by Jørgen Tjernø (darkthorne\@samsen.com)",
	license     => "GPL",
	url         => "http://www.ironsunrise.com/",
	changed     => "Sat Dec 27 13:26:32 EST 2008"
);

#0.1
#  Initial release.
#0.2
#  Regex support on nick/channel matching.
#  For instance, /set strip_nicknames Bob Katee-(.*)

sub strip_formatting {
	my ($server, $data, $nick, $mask, $target) = @_;
	foreach my $chan (split(' ', Irssi::settings_get_str('strip_channels'))) {
		if ($target =~ /^$chan$/) { 
			#Strip formatting
			$data =~ s/\x03\d?\d?(,\d?\d?)?|\x02|\x1f|\x16|\x06|\x07//g;
			#Send to window 1 if no other sutible target.. (Should never happen.)
			my $twin = Irssi::window_find_name($target);
			if (!defined($twin)) { $twin = Irssi::window_find_refnum(1); }
			#Continue with display
			Irssi::signal_continue($server, $data, $nick, $mask, $target);
			return;
		}
	}

	foreach my $name (split(' ', Irssi::settings_get_str('strip_nicknames'))) {
		if ($nick =~ /^$name$/) { 
			$data =~ s/\x03\d?\d?(,\d?\d?)?|\x02|\x1f|\x16|\x06|\x07//g;
			my $twin = Irssi::window_find_name($target);
			if (!defined($twin)) { $twin = Irssi::window_find_refnum(1); }
			Irssi::signal_continue($server, $data, $nick, $mask, $target);
			return;
		}
	}
}

Irssi::signal_add('message public', 'strip_formatting');
Irssi::settings_add_str('lookandfeel', 'strip_channels', '');
Irssi::settings_add_str('lookandfeel', 'strip_nicknames', '');
