use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '1.0';
%IRSSI = (
    authors     => 'Gerfried Fuchs',
    contact     => 'rhonda@deb.at',
    name        => 'Complete renamed nick differently',
    description => 'When using tab completion on an old nick complete to the new nick instead.',
    license     => 'BSD',
);

## hardcoded for the time being, too lazy to make it configurable
## also not network aware, matches on the channel on all networks
my %list_of_nick_replaces = (
	'#irssi' => {
		'saneduck' => 'madduck',
		'alfie'    => 'Rhonda'
	}
);

sub complete_old_nick {
	my ($strings, $window, $word, $linestart, $want_space) = @_;

	# $strings -> array ref to fill with (additional) completions
	# $window -> match against channel name
	# $word -> grep for it
	# $linestart -> only do when it's empty
	# $want_space -> set it to 1 to have a space after the completion

	return unless defined %list_of_nick_replaces->{$window->{active}->{name}};

	my (@oldnicks) = grep /^\Q$word/,
		keys %{%list_of_nick_replaces->{$window->{active}->{name}}};
	return unless $#oldnicks >= 0;

	my $suffix = $linestart eq ''
		? Irssi::settings_get_str('completion_char')
		: '';
	foreach my $oldnick (@oldnicks) {
		push @$strings,
			%list_of_nick_replaces->{$window->{active}->{name}}->{$oldnick}
			. $suffix;
	}
	$$want_space = 1;
}

Irssi::signal_add_first( 'complete word',  \&complete_old_nick );
