# typofix.pl - when someone uses s/foo/bar typofixing, this script really
# goes and modifies the original text on screen.

use Irssi 20020115 qw(
    settings_get_str	settings_get_bool
    settings_add_str	settings_add_bool
    signal_add		signal_stop
);

$VERSION = '1.10';
%IRSSI = (
    authors	=> 'Juerd (first version: Timo Sirainen, additions by: Qrczak)',
    contact	=> 'tss@iki.fi, juerd@juerd.nl, qrczak@knm.org.pl',
    name	=> 'Typofix',
    description	=> 'When someone uses s/foo/bar/, this really modifies the text',
    license	=> 'Same as Irssi',
    url		=> 'http://juerd.nl/irssi/',
    changed	=> 'Wed Mar 19 11:00 CET 2002',
    bugs	=> 'Removes color, sorry',
    upgrade_info => '/set typofix_modify_string \x08old\x0Fnew\x50',
    NOTE1	=> 'DO NOT USE ANY TYPOFIX SCRIPT. SCROLL BUFFER FUCKUPS GUARANTEED.',
    NOTE2	=> 'This script is for no longer being maintained (for now)',
);

#  /SET typofix_modify_string  [fixed]    - append string after replaced text
#  /SET typofix_hide_replace NO           - hide the s/foo/bar/ line
# (J) /SET typofix_format                 - format with "old" and "new" in it
# (J) /SET typofix_limit                  - keep it LOW. limits /g

use strict;
use Irssi::TextUI;

my $chars = '/|;:\'"_=+*&^%$#@!~,.?-';
my $regex = qq{(?x-sm:                       # "s/foo/bar/i # oops"
	\\s*				     # Optional whitespace
	s                                    # Substitution operator      s
	([$chars])                           # Delimiter                  /
	    (   (?: \\\\. | (?!\\1). )*   )  # Pattern                    foo
	    # Backslash plus any char, or a single non-delimiter char
	\\1                                  # Delimiter                  /
	    (   (?: \\\\. | (?!\\1). )*   )  # Replacementstring          bar
	\\1?                                 # Optional delimiter         /
	([a-z]*)                             # Modifiers                  i
	\\s*                                  # Optional whitespace         
	(.?)                                 # Don't hide if there's more # oops
)};


my $UNDO_BUFFER_SIZE = 10;

# window specific undo buffer
my %undo_buffer;
my %undo_buffer_pos;

sub replace {
    my ($window, $nick, $from, $to, $opt, $screen) = @_;

    my $view = $window->view();
    my $line = $screen ? $view->{bottom_startline} : $view->{startline};

    my $last_line;
    (my $copy = $from) =~ s/\^|^/^.*\\b$nick\\b.*?\\s.*?/;
    while ($line) {
	my $text = $line->get_text(0);
	eval {
    	    $last_line = $line 
		if ($line->{info}->{level} & (MSGLEVEL_PUBLIC | MSGLEVEL_MSGS)) &&
		$text !~ /$regex/o && $text =~ /$copy/;
	};
	$line = $line->next();
    }
    return 0 if (!$last_line);
    my $text = $last_line->get_text(0);

    # variables and case insensitivity
    $from =~ s/[\\\$]([1-8])/'\\' . ($1 + 1)/ge;
    $to   =~ s/[\\\$]([1-8])/ '$' . ($1 + 1)/ge;
    $to   =~ s/\\//g;
    $from = "(?i:$from)" if $opt =~ /i/;

    # text replacing
    $text =~ s/(.*\b$nick\b.*?\s)//;
    my $pre = $1;
    my $format = settings_get_str('typofix_format');
    $format =~ s/\\x(..)/chr(0) . chr hex $1/eg;
    $format =~ s/old/\xFF\cA\cA/;
    $format =~ s/new/\xFF\cB\cB/;

    eval{
	my @replace;
	if ($opt =~ /g/) {
	    my $limit = settings_get_str('typofix_limit');
	    while (my ($old) = $text =~ /($from)/g) {
		$text =~ s//$format/;
		push @replace, [$old, $to, $2, $3, $3, $4, $5, $6, $7, $8, $9];
		last if @replace >= $limit; # Avoid endless loops :)
	    }
	    for (@replace) {
		$text =~ s/\xFF\cA\cA/$_->[0]/;
		$text =~ s/\xFF\cB\cB/$_->[1]/;
    		$text =~ s/\$([2-9])/$_->[$1]/g;
	    }
	} else {
	    if (my ($old) = $text =~ /($from)/g) {
		$text =~ s//$format/;
		$_ = [$old, $to, $2, $3, $3, $4, $5, $6, $7, $8, $9];
		$text =~ s/\xFF\cA\cA/$_->[0]/;
		$text =~ s/\xFF\cB\cB/$_->[1]/;
		$text =~ s/\$([2-9])/$_->[$1]/g;
	    }
	}
    };
    Irssi::print "Typofix warning: $@", return 0 if $@;
    $text = $pre . $text . settings_get_str('typofix_modify_string');

    my $prev_line = $last_line->prev();
    my $info = $last_line->{info};
    $view->remove_line($last_line);

    $view->insert_line(
	$view->{buffer}->insert(
	    $prev_line,
	    "$text\x00\x80",
	    length($text) + 2,
	    $info
	)
    );
    $view->redraw();

    return 1;
}

sub event_privmsg {
    my ($server, $data, $nick, $address) = @_;
    my ($target, $text) = $data =~ /^(\S*)\s:(.*)/;

    return unless $text =~ /^$regex/o;
    my ($from, $to, $opt, $extra) = ($2, $3, $4, $5);

    my $hide = settings_get_bool('typofix_hide_replace') && !$extra;

    my $ischannel = $server->ischannel($target);
    my $level = $ischannel ? MSGLEVEL_PUBLIC : MSGLEVEL_MSGS;

    $target = $nick unless $ischannel;
    my $window = $server->window_find_closest($target, $level);

    signal_stop() if (replace($window, $nick, $from, $to, $opt, 0) && $hide);
}

sub event_own_public {
    my ($server, $text, $target) = @_;

    return unless $text =~ /^$regex/o;
    my ($from, $to, $opt, $extra) = ($2, $3, $4, $5);

    my $hide = settings_get_bool('typofix_hide_replace') && !$extra;
    $hide = 0 if settings_get_bool('typofix_own_no_hide');

    my $level = $server->ischannel($target) ? MSGLEVEL_MSGS : MSGLEVEL_PUBLIC;
    my $window = $server->window_find_closest($target, $level);

    signal_stop() if (replace($window, $server->{nick}, $from, $to, $opt, 0) && $hide);
}

sub replace_line {
    my ($view, $line, $text) = @_;

    my $prev_line = $line->prev();
    my $info = $line->{info};

    $view->remove_line($line);
    $line = $view->{buffer}->insert($prev_line, "$text\x00\x80", length($text)+2, $info);
    $view->insert_line(
	$view->{buffer}->insert(
	    $prev_line,
	    "$text\x00\x80",
	    length($text) + 2,
	    $info
	)
    );
    $view->redraw();
    return $line->{_irssi};
}

settings_add_str ('typofix', 'typofix_modify_string', ' [fixed]');
settings_add_str ('typofix', 'typofix_format', '\x08old\x0Fnew\x50');
settings_add_str ('typofix', 'typofix_limit', '5');
settings_add_bool('typofix', 'typofix_hide_replace', 0);
settings_add_bool('typofix', 'typofix_own_no_hide', 0);

signal_add {
    'event privmsg'		=> \&event_privmsg,
    'message own_public'	=> \&event_own_public
};
