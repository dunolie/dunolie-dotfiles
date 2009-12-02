# Words-per-minute counter for irssi
#
# TODO: detect pasting and ignore?
#		(seems to require a patch that's not integrated into irssi yet)
#		sanity checks will have to do for now
# TODO: count WPM for commands that send messages (/me, /notice/, /msg)
#
# USAGE: /script load wpm
#		 /statusbar prompt add wpm
#
#		 Or choose another statusbar instead of "prompt".
#		 See /help statusbar.
#
#		 Statusbar item shows WPM of your last line, and your average WPM
#		 since the script was loaded (in brackets). To reset your average,
#		 just load the script again.
#		 
#		 No configuration required, but there are a couple of settings:
#		 /set wpm_simple on = just count words bounded by spaces
#		 /set wpm_simple off = count a word as five characters (default)
#
#		 /set wpm_strict on = lines where text is inserted by nick-completion
#							  or ^Y are ignored (default)
#		 /set wpm_strict off = lines where text is inserted by nick-competion
#							   (or ^Y) are allowed where <= 9 chars; longer
#							   text insertions invalidate the line
#
#		 See http://en.wikipedia.org/wiki/Typing#Words_per_minute


use strict;
use Irssi 20021105; 
use Irssi::TextUI;
use Time::HiRes ("time");

use vars qw($VERSION %IRSSI);
$VERSION = '1.3';
%IRSSI = (
	authors		=> 'James Seward',
	contact		=> 'james@jamesoff.net',
	name		=> 'wordsperminute',
	description => 'adds a statusbar item showing your typing rate',
	license		=> 'BSD',
	url			=> 'http://jamesoff.net/',
	changed		=> '2008-04-08T11:25:44Z'
);

# $start_time is time this line was started
# $total_time is total time spent typing
# $total_words is total number of words typed
# $total_chars is the total number of chars typed
my $start_time;
my $total_time = 0;
my $total_words = 0;
my $total_chars = 0;

# $last_wpm is WPM for last (valid) line typed
# $last_cpm is CPM for last (valid) line typed
# $last_charcount is used for checking the input is going the right way
my $last_wpm = 0;
my $last_cpm;
my $last_charcount = 0;

# cache for wpm_strict setting
my $wpm_strict;

# Redraw the statusbar item
sub wpm_draw {
	my ($sbItem, $get_size_only) = @_;
	my $wpm;
	my $cpm;

	if ($total_time > 0) {
		$wpm = $total_words * (60.0 / $total_time);
		$cpm = $total_chars * (60.0 / $total_time);
	}
	else {
		if (Irssi::settings_get_bool('wpm_debug')) {
			Irssi::print("total time ! > 0");
		}
		$wpm = 0;
		$cpm = 0;
	}

	my $sb_text = "{sb ";

	if (Irssi::settings_get_bool('show_wpm')) {
		$sb_text .= sprintf("wpm:%.1f (%.1f) ", $last_wpm, $wpm);
	}

	if (Irssi::settings_get_bool('show_cpm')) {
		$sb_text .= sprintf("cpm:%.1f (%.1f)", $last_cpm, $cpm);
	}

	if (length($sb_text) == 4) {
		$sb_text .= "wpm: over 9000";
	}

	$sb_text .= "}";

	$sbItem->default_handler($get_size_only, $sb_text, undef, 1);
}


# Handle a keystroke on the prompt
# If the length is 1 (i.e. first char typed), start the timer
# If the first char is /, ignore the line
sub wpm_keypress() {
		my $input_line = Irssi::parse_special("\$L");

		my $input_length = length($input_line);

		if ($input_length == 0) {
			$start_time = 0;
			$last_charcount = 0;
			return;
		}

		if ($input_line =~ /^\//) {
			return;
		}

		if ($input_length > $last_charcount) {
			# check if someone's used ^y
			my $diff = $input_length - $last_charcount;
			my $limit = $wpm_strict ? 1 : 9;
			if ($diff > $limit) {
				$start_time = 0;
				$last_charcount = 0;
				return;
			}

			# if the char count is going up, start the timer
			# (if it's going, down, they've backspaced)
			if ($input_length == 1) {
				# just started typing
				$start_time = Time::HiRes::time;
			}
		}

		$last_charcount = $input_length;

		# turns out we can't catch the input line on enter here
		# by the time we get our signal, the line's blank!
}


# Handle a line of text being sent
sub wpm_send() {
	my $line = $_[0];

	if ($start_time > 0) {
		wpm_calculate($line);
		Irssi::statusbar_items_redraw('wpm');
	}
	else {
		if (Irssi::settings_get_bool('wpm_debug')) {
			Irssi::print("start time is 0, not calculating wpm");
		}
	}
}


# Calculate WPM based on first parameter and global timer info
sub wpm_calculate() {
	my ($line) = $_[0];
	
	# do cpm stuff here
	my $chars = length($line);
	$total_chars += $chars;

	# remove punctuation
	$line =~ tr/a-zA-Z0-9/ /cs;

	my $end_time = Time::HiRes::time;
	my $time_taken = $end_time - $start_time;
	if ($time_taken == 0) {
		return;
	}

	# vague sanity check
	if ($time_taken > 60) {
		return;
	}

	my @words = split(/ +/, $line);

	if (@words == 0) {
		return;
	}

	my $word_count = 0;

	if (Irssi::settings_get_bool('wpm_simple')) {
		$word_count = @words;
	}
	else {
		# each batch of 5 letters counts as a word
		foreach my $word (@words) {
			$word_count += (length($word) / 5);
		}
	}

	my $wpm = $word_count * (60.0 / $time_taken);
	#Irssi::print("line wpm: $wpm");
	my $cpm = $chars * (60.0 / $time_taken);

	# another sanity check
	# wikipedia suggests a really fast typing rate is ~120, so >200 is a bit silly
	if ($wpm > 200) {
		return;
	}

	$total_words += $word_count;
	$total_time += $time_taken;
	$last_wpm = $wpm;
	$last_cpm = $cpm;
}


# Cache value of wpm_strict setting so we don't call
# settings_get_bool every keystroke
sub wpm_cache_setting() {
	$wpm_strict = Irssi::settings_get_bool('wpm_strict');
}


# Statusbar item
Irssi::statusbar_item_register ( 'wpm', 0, 'wpm_draw' );

# Signals
Irssi::signal_add_last('gui key pressed', 'wpm_keypress');
Irssi::signal_add('send text', 'wpm_send');
Irssi::signal_add('setup changed', 'wpm_cache_setting');

# Settings
Irssi::settings_add_bool('wpm', 'wpm_simple', 0);
Irssi::settings_add_bool('wpm', 'wpm_strict', 1);
Irssi::settings_add_bool('wpm', 'wpm_debug', 0);
Irssi::settings_add_bool('wpm', 'show_cpm', 1);
Irssi::settings_add_bool('wpm', 'show_wpm', 1);

# pre-load the cache
$wpm_strict = Irssi::settings_get_bool('wpm_strict');

