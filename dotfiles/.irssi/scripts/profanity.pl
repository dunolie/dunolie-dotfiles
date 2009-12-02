# To use, place in ~/.irssi/scripts and load with /script load profanity.pl
#
# It will automatically take action on things you write with one of the
# space separated swear words from the "badwords" setting in the profanity
# section. By default, it replaces the bad word with '****', but by changing
# the "action" setting from the default "censor" to "block", you can entirely
# block any message containing a swear word.

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '0.1';
%IRSSI = (
    authors     => 'Josh Holland',
    contact     => 'jrh@joshh.co.uk',
    name        => 'Profanity filter',
    description => 'Censor or confirm any message that contains profanity.',
    license     => 'GPLv3'
);

Irssi::settings_add_str("profanity", "badwords", "fuck shit wank cunt bollock piss");
Irssi::settings_add_str("profanity", "action", "censor");

my $last_sent = '';
sub swear_block {
    my ($re, $data, $server, $witem) = @_;

    if ($data =~ /($re)/i) {
	if ($data eq $last_sent) {
	    undef $last_sent;
	    return;
	}
	$witem->print(
	    "Blocked message containing $1", MSGLEVEL_CLIENTNOTICE);
	$witem->print(
	    "Send it again to confirm", MSGLEVEL_CLIENTNOTICE);
	$last_sent = $data;
	Irssi::signal_stop();
    }
}

sub swear_censor {
    my ($re, $data, $server, $witem) = @_;
    $data =~ s/$re/****/gi if $data =~ m[^[^/]|/me];
    Irssi::signal_continue($data, $server, $witem);
}

sub dispatch {
    my $swearstring = Irssi::settings_get_str("badwords");
    my @swearwords = split /\s/, $swearstring;
    $swearstring = join '|', map { "\Q$_\E" } @swearwords;
    my $action = Irssi::settings_get_str("action");
    if ($action eq "censor") {
	swear_censor $swearstring, @_;
    } elsif ($action eq "block") {
	swear_block $swearstring, @_;
    }
}

Irssi::signal_add "send text", \&dispatch;
Irssi::signal_add "send command", \&dispatch;
