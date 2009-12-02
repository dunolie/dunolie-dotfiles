use Irssi;
use strict;

use vars qw($VERSION %IRSSI);

$VERSION="0.3.4";
%IRSSI = (
	authors=> 'BC-bd',
	contact=> 'bd@bc-bd.org',
	name=> 'nm',
	description=> 'right aligned nicks depending on longest nick',
	license=> 'GPL v2',
	url=> 'https://bc-bd.org/svn/repos/irssi/trunk/',
);

# $Id$
# nm.pl
# for irssi 0.8.4 by bd@bc-bd.org
#
# right aligned nicks depending on longest nick
#
# inspired by neatmsg.pl from kodgehopper <kodgehopper@netscape.net
# formats taken from www.irssi.de
# thanks to adrianel <adrinael@nuclearzone.org> for some hints
# thanks to Eric Wald <eswald@gmail.com> for the left alignment patch
# inspired by nickcolor.pl by Timo Sirainen and Ian Peters
#
#########
# USAGE
###
# 
# /neatredo to recalculate longest nick. (should not be needed)
#
#########
# OPTIONS
#########
#
# /set neat_colorize <ON|OFF>
# 	* ON  : colorize nicks
# 	* OFF : do not colorize nicks
#
# /set neat_colors <string>
# 	Use these colors when colorizing nicks, eg:
#
# 		/set neat_colors yYrR
#
# 	See the file formats.txt on an explanation of what colors are
# 	available.
#
# /set neat_left_actions <ON|OFF>
#	* ON  : print nicks left-aligned on actions
#	* OFF : print nicks right-aligned on actions
#
# /set neat_left_messages <ON|OFF>
#	* ON  : print nicks left-aligned on messages
#	* OFF : print nicks right-aligned on messages
#
# /set neat_right_mode <ON|OFF>
#	* ON  : print the mode of the nick e.g @%+ after the nick
#	* OFF : print it left of the nick 
#
# /set neat_maxlength <number>
#	* number : Maximum length of Nicks to display. Longer nicks are truncated.
#	* 0      : Do not truncate nicks.
#
# /set neat_melength <number>
#	* number : number of spaces to substract from /me padding
#
###
################
###
#
# Changelog
#
# Version 0.3.4
#  - fxed off by one error in nick_to_color, patch by jrib, see
#  https://bc-bd.org/trac/irssi/ticket/24
#
# Version 0.3.3
#  - added support for alignment in queries, see
#    https://bc-bd.org/trac/irssi/ticket/21
#
# Version 0.3.2
#  - integrated left alignment patch from Eric Wald <eswald@gmail.com>, see
#    https://bc-bd.org/trac/irssi/ticket/18
#
# Version 0.3.1
#  - /me padding, see https://bc-bd.org/trac/irssi/ticket/17
#
# Version 0.3.0
#  - integrate nick coloring support
#
# Version 0.2.1
#  - moved neat_maxlength check to reformat() (thx to Jerome De Greef <jdegreef@brutele.be>)
#
# Version 0.2.0
#  - by adrianel <adrinael@nuclearzone.org>
#     * reformat after setup reload
#     * maximum length of nicks
#
# Version 0.1.0
#  - got lost somewhere
#
# Version 0.0.2
#  - ugly typo fixed
#  
# Version 0.0.1
#  - initial release
#
###
################
###
#
# BUGS
#
# Empty nicks, eg "<> message"
# 	This seems to be triggered by some themes. As of now there is no known
# 	fix other than changing themes, see
# 	https://bc-bd.org/trac/irssi/ticket/19
#
# Well, it's a feature: due to the lacking support of extendable themes
# from irssi it is not possible to just change some formats per window.
# This means that right now all windows are aligned with the same nick
# length, which can be somewhat annoying.
# If irssi supports extendable themes, I will include per-server indenting
# and a setting where you can specify servers you don't want to be indented
#
###
################

my ($longestNick, %saved_colors, @colors, $alignment, $sign);

my $colorize = -1;

sub reformat() {
	my $max = Irssi::settings_get_int('neat_maxlength');
	my $actsign = Irssi::settings_get_bool('neat_left_actions')? '': '-';
	$sign = Irssi::settings_get_bool('neat_left_messages')? '': '-';

	if ($max && $max < $longestNick) {
		$longestNick = $max;
	}

	my $me = $longestNick - Irssi::settings_get_int('neat_melength');
	$me = 0 if ($me < 0);

	Irssi::command('^format own_action {ownaction $['.$actsign.$me.']0} $1');
	Irssi::command('^format action_public {pubaction $['.$actsign.$me.']0}$1');

	my $length = $sign . $longestNick;
	if (Irssi::settings_get_bool('neat_right_mode') == 0) {
		Irssi::command('^format own_msg {ownmsgnick $2 {ownnick $['.$length.']0}}$1');
		Irssi::command('^format own_msg_channel {ownmsgnick $3 {ownnick $['.$length.']0}{msgchannel $1}}$2');
		Irssi::command('^format pubmsg_me {pubmsgmenick $2 {menick $['.$length.']0}}$1');
		Irssi::command('^format pubmsg_me_channel {pubmsgmenick $3 {menick $['.$length.']0}{msgchannel $1}}$2');
		Irssi::command('^format pubmsg_hilight {pubmsghinick $0 $3 $['.$length.']1%n}$2');
		Irssi::command('^format pubmsg_hilight_channel {pubmsghinick $0 $4 $['.$length.']1{msgchannel $2}}$3');
		Irssi::command('^format pubmsg {pubmsgnick $2 {pubnick $['.$length.']0}}$1');
		Irssi::command('^format pubmsg_channel {pubmsgnick $2 {pubnick $['.$length.']0}}$1');
	} else {
		Irssi::command('^format own_msg {ownmsgnick {ownnick $['.$length.']0$2}}$1');
		Irssi::command('^format own_msg_channel {ownmsgnick {ownnick $['.$length.']0$3}{msgchannel $1}}$2');
		Irssi::command('^format pubmsg_me {pubmsgmenick {menick $['.$length.']0}$2}$1');
		Irssi::command('^format pubmsg_me_channel {pubmsgmenick {menick $['.$length.']0$3}{msgchannel $1}}$2');
		Irssi::command('^format pubmsg_hilight {pubmsghinick $0 $0 $['.$length.']1$3%n}$2');
		Irssi::command('^format pubmsg_hilight_channel {pubmsghinick $0 $['.$length.']1$4{msgchannel $2}}$3');
		Irssi::command('^format pubmsg {pubmsgnick {pubnick $['.$length.']0$2}}$1');
		Irssi::command('^format pubmsg_channel {pubmsgnick {pubnick $['.$length.']0$2}}$1');
	}

	# format queries
	Irssi::command('^format own_msg_private_query {ownprivmsgnick {ownprivnick $['.$length.']2}}$1');
	Irssi::command('^format msg_private_query {privmsgnick $['.$length.']0}$2');
};

sub cmd_neatRedo{
	$longestNick = 0;

	# get own nick length
	foreach (Irssi::servers()) {
		my $len = length($_->{nick});

		if ($len > $longestNick) {
			$longestNick = $len;
		}
	}

	# get the lengths of the other people
	foreach (Irssi::channels()) {
		foreach ($_->nicks()) {
			$saved_colors{$_->{nick}} = "%".nick_to_color($_->{nick});

			my $len = length($_->{nick});

			if ($len > $longestNick) {
				$longestNick = $len;
			}
		}
	}

	reformat();
}

sub sig_newNick
{
	my ($channel, $nick) = @_;

	my $thisLen = length($nick->{nick});

	if ($thisLen > $longestNick) {
		$longestNick = $thisLen;
		reformat();
	}

	$saved_colors{$nick->{nick}} = "%".nick_to_color($nick->{nick});
}

# something changed
sub sig_changeNick
{
	my ($channel, $nick, $old_nick) = @_;

	# we only need to recalculate if this was the longest nick
	if (length($old_nick) == $longestNick) {
	
		my $thisLen = length($nick->{nick});

		# and only if the new nick is shorter
		if ($thisLen > $longestNick) {
			$longestNick = $thisLen;
			reformat();
		} else {
			cmd_neatRedo();
		}
	}

	$saved_colors{$nick->{nick}} = $saved_colors{$nick->{old_nick}};
	delete $saved_colors{$nick->{old_nick}}
}
sub sig_removeNick
{
	my ($channel, $nick) = @_;

	my $thisLen = length($nick->{nick});

	# we only need to recalculate if this was the longest nick
	if ($thisLen == $longestNick) {
		cmd_neatRedo();
	}
}

# based on simple_hash from nickcolor.pl
sub nick_to_color($) {
	my ($string) = @_;
	chomp $string;
	my @chars = split //, $string;
	my $counter;

	foreach my $char (@chars) {
		$counter += ord $char;
	}

	return $colors[$counter % ($#colors + 1)];
}

sub color_left($) {
	Irssi::command('^format pubmsg {pubmsgnick $2 {pubnick '.$_[0].'$['.$sign.$longestNick.']0}}$1');
	Irssi::command('^format pubmsg_channel {pubmsgnick $2 {pubnick '.$_[0].'$['.$sign.$longestNick.']0}}$1');
}

sub color_right($) {
	Irssi::command('^format pubmsg {pubmsgnick {pubnick '.$_[0].'$['.$sign.$longestNick.']0}$2}$1');
	Irssi::command('^format pubmsg_channel {pubmsgnick {pubnick '.$_[0].'$['.$sign.$longestNick.']0}$2}$1');
}

sub sig_public {
	my ($server, $msg, $nick, $address, $target) = @_;

	&$alignment($saved_colors{$nick});
}

sub sig_setup {
	@colors = split(//, Irssi::settings_get_str('neat_colors'));

	# check left or right alignment
	if (Irssi::settings_get_bool('neat_right_mode') == 0) {
		$alignment = \&color_left;
	} else {
		$alignment = \&color_right;
	}
	
	# check if we switched coloring on or off
	my $new = Irssi::settings_get_bool('neat_colorize');
	if ($new != $colorize) {
		if ($new) {
			Irssi::signal_add('message public', 'sig_public');
		} else {
			if ($colorize >= 0) {
				Irssi::signal_remove('message public', 'sig_public');
			}
		}
	}
	$colorize = $new;

	cmd_neatRedo();
	&$alignment('%w');
}

Irssi::settings_add_bool('misc', 'neat_left_messages', 0);
Irssi::settings_add_bool('misc', 'neat_left_actions', 0);
Irssi::settings_add_bool('misc', 'neat_right_mode', 1);
Irssi::settings_add_int('misc', 'neat_maxlength', 0);
Irssi::settings_add_int('misc', 'neat_melength', 2);
Irssi::settings_add_bool('misc', 'neat_colorize', 1);
Irssi::settings_add_str('misc', 'neat_colors', 'rRgGyYbBmMcC');

Irssi::command_bind('neatredo', 'cmd_neatRedo');

Irssi::signal_add('nicklist new', 'sig_newNick');
Irssi::signal_add('nicklist changed', 'sig_changeNick');
Irssi::signal_add('nicklist remove', 'sig_removeNick');

Irssi::signal_add('setup changed', 'sig_setup');
Irssi::signal_add_last('setup reread', 'sig_setup');

sig_setup;
