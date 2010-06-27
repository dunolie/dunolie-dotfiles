# (c) 2008 by Gerfried Fuchs <rhonda@deb.at>

use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

use utf8;

$VERSION = '0.1';

%IRSSI = ( # {{{
	'authors'     => 'Gerfried Fuchs',
	'contact'     => 'rhonda@deb.at',
	'name'        => 'flip text',
	'description' => 'flips the text "umop apisdn"',
	'license'     => 'GPLv2+ & BSD',
	'url'         => 'http://rhonda.deb.at/projects/irssi/scripts/fliptext.pl',
	'changed'     => '2008-04-22',
); # }}}

# Maintainer & original Author:  Gerfried Fuchs <rhonda@deb.at>
# Based on web based version:    http://www.revfad.com/flip.html


# This script offers you /fliptext which flips text upside down

# Version-History: {{{
# ================
# 0.1 -- first version available to track history from...
# }}}

# TODO List
# ... currently empty

# DONE List

my %flipTable = ( # {{{
	a => 'ɐ',
	b => 'q',
	c => 'ɔ', #open o -- from pne
	d => 'p',
	e => 'ǝ',
	f => 'ɟ', #from pne
	g => 'ƃ',
	h => 'ɥ',
	i => 'ı', #from pne
	j => 'ɾ',
	k => 'ʞ',
	#l => 'ʃ',
	m => 'ɯ',
	n => 'u',
	r => 'ɹ',
	t => 'ʇ',
	v => 'ʌ',
	w => 'ʍ',
	y => 'ʎ',
	'.' => '˙',
	'[' => ']',
	'(' => ')',
	'{' => '}',
	'?' => '¿', #from pne
	'!' => '¡',
	"'" => ',',
	'<' => '>',
	'_' => '‾',
	';' => '؛',
	'‿' => '⁀',
	'⁅' => '⁆',
	'∴' => '∵',
);

foreach my $key (keys %flipTable) {
	$flipTable{$flipTable{$key}} = $key;
} # }}}

sub FlipText { # {{{
	my ($msg) = @_;
	$msg =~ s/./(defined $flipTable{$&}) ? $flipTable{$&} : $&/eg;
	return reverse $msg;
} # }}}


sub cmd_fliptext { # {{{
	my ($msg, undef, $channel) = @_;
	$channel->command("msg $channel->{'name'} " . FlipText($msg));
} # }}}

sub cmd_fliptextme { # {{{
	my ($msg, undef, $channel) = @_;
	$channel->command("me " . FlipText($msg));
} # }}}


Irssi::command_bind('fliptext',   'cmd_fliptext');
Irssi::command_bind('fliptextme', 'cmd_fliptextme');

# vim:foldmethod=marker:
