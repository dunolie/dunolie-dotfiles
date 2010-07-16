#!/usr/bin/perl
use warnings;
use strict;
use Irssi;
use Irssi qw(command_bind command signal_add_last signal_stop settings_get_bool settings_add_bool);
use vars qw($VERSION %IRSSI);
$VERSION = "1.2";
%IRSSI = (
authors     => "Colin Horne",
contact     => 'colin@colinhorne.co.uk',
name        => "1337",
description => "Adds 1337 command to irssi",
license     => "GPLv2",
);

# $autodoc$
# include=*; lang=perl; name=Irssi::1337;
# desc="A simple irssi script to convert sensible English to
# "1337". May you be never forgiven should you ever use it!";

# Note: This really needs a full fledged finite state machine,
# but I can't be bothered ;-)

# Incidently, this is a joke I made to annoy someone on IRC, please
# don't ever ever ever use it ;-)

sub _rand {
	my $prob = .5;
	my $ret;
	while (1) {
		$ret = shift;
		push @_, $ret;
		return $ret if rand(1) < $prob;
	}
}

sub _encode {
	my $text = shift;
	my @subs = (
		["ck"		=> ["x", "ck"]],
		["the"		=> ["teh", "teh", "het", "the"]],
		["you"		=> ["joo", "joo", "you"]],
		["hurt"		=> ["owned", "hurt"]],
		["hack"		=> ["hack", "crack"]],
		["like"		=> ["like", "like", "like", "dig"]],
		["f"		=> ["ph", "ph", "f"]],
		["cool"		=> ["cool", "kewl"]],
		["god"		=> ["god", "root"]],
		["s\b"		=> ["z", "z", "s"]],
		["lol\b"	=> ["lolz", "lol"]],
		["!"		=> ["!", "1"]],
		["a" => ["4", "4", "@", "a"]],
		["b" => ["b", "8"]],
		["c" => ["<", "c"]],
		["d" => ["|>", "d"]],
		["e" => ["3", "3", "e"]],
		["f" => ["f"]],
		["g" => ["9", "g"]],
		["h" => ["h", "|-|"]],
		["i" => ["i", "1", "|", "!"]],
		["j" => ["j"]],
		["k" => ["|<", "k"]],
		["l" => ["1", "l"]],
		["m" => ["m"]],
		["n" => ["n"]],
		["o" => ["0", "o"]],
		["p" => ["p"]],
		["q" => ["q"]],
		["r" => ["r"]],
		["s" => ["5", "s", "z"]],
		["t" => ["7", "t"]],
		["u" => ["u"]],
		["v" => ["v", "v", "|/", "\\/"]],
		["w" => ["w"]],
		["x" => ["x", "x", "x", "*"]],
		["y" => ["y", "y", "y", "j"]],
		["z" => ["z", "="]],
	);
	for (@subs) {
		$text =~ s/$_->[0]/&_rand(@{$_->[1]})/gie
	}
	$text =~ s/(.)/rand>.5?uc$1:lc$1/gie;
	$text =~ s/\bj([0o]{2})\b/j$1/gi;
	return $text;
}

Irssi::command_bind('leet', sub { Irssi::active_win->command("/say "._encode(shift)) } );

