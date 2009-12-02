#!/usr/bin/perl -w
#
# cp2iso.pl
# Translates CP1250 to ISO8859-2 in incoming messages
#
# Written by Jakub Jankowski <shasta@toxcorp.com>
# for Irssi 0.7.98.4+
#
# Released under GNU GPLv2 or later
#
# /SET cp2iso_notify <ON|OFF>
#  - whether to notify you about translated text
#
# /SET cp2iso_suffix [string]
#  - string to append to translated text

use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.3";
%IRSSI = (
    authors     => 'Jakub Jankowski',
    contact     => 'shasta@toxcorp.com',
    name        => 'cp2iso',
    description => 'Translates CP1250 to ISO8859-2 in incoming messages',
    license     => 'GNU GPLv2 or later',
    url         => 'http://toxcorp.com/irc/irssi/',
);

use Irssi;

sub message_public {
	return unless $_[1] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[1] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("message public", @_);
}

sub message_private {
	return unless $_[1] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[1] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("message private", @_);
}

sub message_dcc_chat {
	return unless $_[1] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[1] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("dcc chat message", @_);
}

sub message_irc_action {
	return unless $_[1] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[1] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("message irc action", @_);
}

sub message_part {
	return unless $_[4] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[4] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("message part", @_);
}

sub message_quit {
	return unless $_[3] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[3] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("message quit", @_);
}

sub message_kick {
	return unless $_[5] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[5] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("message kick", @_);
}

sub message_topic {
	return unless $_[2] =~ tr/\214\234\217\237\245\271/\246\266\254\274\241\261/;
	$_[2] .= suffix();
	Irssi::signal_stop();
	Irssi::signal_emit("message topic", @_);
}

sub suffix {
	return unless Irssi::settings_get_bool("cp2iso_notify");
	my $set = Irssi::settings_get_str("cp2iso_suffix");
	return unless (length($set));
	return $set if ($set =~ /^\ /);
	return " " . $set;
}

Irssi::settings_add_bool("misc", "cp2iso_notify", 1);
Irssi::settings_add_str("misc", "cp2iso_suffix", "[cp1250]");
Irssi::signal_add("message public", "message_public");
Irssi::signal_add("message private", "message_private");
Irssi::signal_add("message irc action", "message_irc_action");
Irssi::signal_add("message part", "message_part");
Irssi::signal_add("message quit", "message_quit");
Irssi::signal_add("message kick", "message_kick");
Irssi::signal_add("message topic", "message_topic");
Irssi::signal_add("dcc chat message", "message_dcc_chat");
