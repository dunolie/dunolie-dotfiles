# - db.pl
# IRC Helper Bot

use Irssi;
#use strict;
use vars qw($VERSION %IRSSI);

my $db_version = "20020225/alpha";
my $db_file = "$ENV{HOME}/.bocik/database";
my $db_mtn = "$ENV{HOME}/.bocik/db_maintain";
my $friends_file = "$ENV{HOME}/.bocik/friends";
my $nr_sites = 3;

$VERSION = $db_version;
%IRSSI = (
    authors     => 'Tomasz Sterna',
    contact     => 'smoku@jaszczur.org',
    name        => 'DB',
    description => 'Maintains on-line encyclopedia and queries google.',
    license     => 'Public Domain',
);


# glob matching
sub globMatcher ($$) {
	my ($what, $regex) = @_;
	$what = lc($what);
	$regex = lc($regex);
	$regex =~ s/\(//g;
	$regex =~ s/\)//g;
	$regex =~ s/\\/\\\\/g;
	$regex =~ s/\./\./g;
	$regex =~ s/\*/\.\*/g;
	$regex =~ s/\!/\\\!/g;
	$regex =~ s/\?/\.\?/g;
	$regex =~ s/\^/\\\^/g;
	$regex =~ s/\+/\\\+/g;

	my $matches = $what =~ /^$regex$/i;

	return $matches;
}

# loading friends from file
sub load_friends {
	if (-e $friends_file) {
		@friends = ();
		local *F;
		open(F, "<$friends_file");
		local $/ = "\n";
		while (<F>) {
			chop;
			# ignoring comments
			if (/^\#/) {
				next;
			}
			my $newFriend = new_friend(split("%"));
			if ($newFriend->{hostmask} ne "") {
				push(@friends, $newFriend);
			} else {
				Irssi::print("Skipping $newFriend (bad hostmask?)");
			}
		}
		close(F);
		Irssi::print("DB loaded $friends_file");
	} else {
		Irssi::print("Cannot load $friends_file");
	}
}
# mask, flags, channel(s), password
sub new_friend {
	my $friend = {};
	$friend->{hostmask} = shift;
	$friend->{flags} = shift;
	my $chanstr = shift;
	$chanstr = lc($chanstr);
	$friend->{password} = shift;
	my @channels = split(",", $chanstr);
	foreach my $channel (@channels) {
		$friend->{channels}->{$channel} = 1;
	}
	return $friend;
}

# is_friend($channelName, $nick, $userhost)
# returns index of the friend or -1 if not a friend
sub is_friend {
	my ($nick, $userhost) = @_;
	for (my $idx = 0; $idx < @friends; ++$idx) {
		if (globMatcher(($nick . "!" . $userhost), $friends[$idx]->{hostmask})) {
			return $idx;
		}
	}
	return -1;
}

# friend_has_flag($idx, $flag)
# return true if friend numbered $idx has $flag, false if hasn't
sub friend_has_flag {
	my ($idx, $flag) = @_;
	if ($friends[$idx]->{flags} =~ /$flag/) {
		return 1;
	}
	return 0;
}

# query google
sub google {

        my ($data) = @_;
        my $url = "";
	my $nr_sites = 3;
	my $i = 0;
	my (@lines, @pages);
	my $mode = "quiet";

	# Format the query-string
	$data =~ s/\s/+/g;
	$data =~ s/[^-a-zA-Z0-9\"+]//g;
	my $query = $data;
	Irssi::print("querying google for: \"$query\"");

	# Do the actual seach
	my $content = `curl -A "AgentName/0.1 " "http://www.google.com/search?hl=en&q=$query" 2>/dev/null`;

	# Replace <br> with newlines
	# and remove tags
        $content =~ s/\<br\>/\n/g;
        $content =~ s/\<.+?\>//sg;

	#Irssi::print($content);
	# Make array @pages of all search-results
        @lines = split("\n", $content);
        @pages = grep (/Similar\ pages/, @lines);

	# Remove empty entries in @pages
	for ($i=0;$i<=$#pages;$i++) {
		$pages[$i] =~ s/\s+.*//g;
		if ($pages[$i] =~ /(^\n|\s+\n)/){ splice(@pages, $i, 1) };
		if ($pages[$i] !~ /\./){ splice(@pages, $i, 1) };
	}

	if($nr_sites > $#pages) { $nr_sites = $#pages + 1};

	# create result
	my $result = "";
	for ($i=0; $i<$nr_sites; $i++) {
		$pages[$i] =~ s/\s+.*//g;
		$result = $result."http://".$pages[$i]."  ";
	}
	return $result;
}

# searching through db
sub search_file {
	if (-e $db_file) {
		my @matches = ();
		local *F;
		open(F, "<$db_file") or die "Couldn't open $db_file for reading";
		seek(F, 0, 0);
		local $/ = "\n";
		my $query = shift;
		my $tries = 0;
		my $orgquery = "";
		while (<F>) {
			chop;
			my $item = {};
			($item->{name}, $item->{text}) = split("%!%");
			if ( globMatcher($item->{name}, $query) ) {
				if ($item->{text} =~ s/^\-\>//i) {
		Irssi::print("found link:".$item->{name}."->".$item->{text});
					if (++$tries > 5 ) {
						$item->{name} = "BLAD";
						$item->{text} = "Zbyt gleboka rekursja ($orgquery)";
						push(@matches, $item);
						return @matches;
					}
					$query = $item->{text};
					$query =~ s/\s+.*//i;
		Irssi::print("looking for:".$query);
					if ( is_in_file($query) ){
						seek(F, 0, 0);
						$orgquery = $item->{name} if ( ! $orgquery );
					} else {
		Irssi::print("autoremoving:".$item->{name});
						handleRemove("", $item->{name}, "", "(self)", "(automaintanance)");
						$item->{text} = "Martwy link (".$item->{name}."->$query) - usuniety";
						$item->{name} = "BLAD";
						push(@matches, $item);
					}
				} else {
					if ($orgquery) {
						$item->{name} = $orgquery;
						$orgquery = "";
					}
					push(@matches, $item);
				}
			}
		}
		close(F);
		return @matches;
	} else {
		Irssi::print("$db_file not exist");
	}
}

sub is_in_file {
	if (-e $db_file) {
		local *F;
		open(F, "<$db_file") or die "Couldn't open $db_file for reading";
		seek(F, 0, 0);
		local $/ = "\n";
		my $query = shift;
		while (<F>) {
			chop;
			my $item = {};
			($item->{name}, $item->{text}) = split("%!%");
			if ( globMatcher($item->{name}, $query) ) {
				close(F);
				return 1;
			}
		}
		close(F);
		return 0;
	} else {
		Irssi::print("$db_file not exist");
		return 0;
	}

}

sub handleQuery {
	my ($server, $query, $argument, $target) = @_;

	if (lc($query) eq lc($server->{nick})) {
		$server->command("/NOTICE $target Porucznik Kerrigan - do uslug. ($db_version)");
		return;
	}

	my @items = search_file($query);
	if ( @items > 0 ) {
		if ( @items > 1 ) {
			if ( @items < 21 ) {
				my $msg = scalar(@items) . " trafien(ia): ";
				foreach my $item (@items) {
					$msg = $msg . " " . $item->{name};
				}
				$server->command("/NOTICE $target $msg");
			} else {
				$server->command("/NOTICE $target Wiecej niz 20 trafien (".scalar(@items)."). Sprobuj byc bardziej konkretnym.");
			}
		} else {
			my ($to_send) = $items[0]->{text};
			if ($argument) {
				$to_send =~ s/\{[^\{\}]*\}/$argument/g;
			} else {
				$to_send =~ s/\{|\}//g;
			}
			$server->command("/NOTICE $target $items[0]->{name}:  $to_send");
		}
	} else {
		$server->command("/NOTICE $target Brak trafien. Moze globbing?");
		local *F;
		open(F, ">>$db_mtn") or die "Couldn't open $db_mtn for appending";
		print(F "!MISS $target: $query\n");
		close(F);
	}
}

sub handleAdd {
	my ($server, $text, $target, $nick, $address) = @_;

	my($item) = split(/ /, $text, 2);
	$text =~ s/^[^\s]*\s*//i;
	if ( is_in_file($item) > 0) {
		$server->command("/NOTICE $target Eeee.. No wiesz, ale $item to juz jest.");
	} else {
		Irssi::print("$nick!$address is adding '$item' as: $text");
		local *F;
		open(F, ">>$db_file") or die "Couldn't open $db_file for appending";
		print(F "$item%!%$text  <$nick>\n");
		close(F);
		local *F;
		open(F, ">>$db_mtn") or die "Couldn't open $db_mtn for appending";
		print(F "++ADD $target,$nick!$address: $item -> $text\n");
		close(F);
		$server->command("/NOTICE $nick $item: dodany -> $text");
	}
}

sub handleRemove {
	my ($server, $text, $target, $nick, $address) = @_;

	my($item) = split(/ /, $text, 2);
	if ( ! is_in_file($item) ) {
		Irssi::print("$nick!$address tried to remove '$item'");
		$server->command("/NOTICE $target Eeee.. No wiesz, ale $item to jeszcze nikt nie opisal.") if ($server);
	} else {
		Irssi::print("$nick!$address is removing '$item'");
		if (-e $db_file) {
			local *F;
			local *G;
			open(F, "<$db_file") or die "Couldn't open $db_file for reading";
			open(G, ">$db_file.tmp") or die "Couldn't open $db_file.tmp for writing";
			local $/ = "\n";
			while (<F>) {
				chop;
				my $line = {};
				($line->{name}, $line->{text}) = split("%!%");
				if (! globMatcher($line->{name}, $item) ) {
					print(G $line->{name}."%!%".$line->{text}."\n");
				}
			}
			close(F);
			close(G);
			rename("$db_file.tmp", "$db_file");
			local *F;
			open(F, ">>$db_mtn") or die "Couldn't open $db_mtn for appending";
			print(F "--DEL $target,$nick!$address: $item\n");
			close(F);
			$server->command("/NOTICE $nick $item: usuniety.") if ($server);
		} else {
			Irssi::print("$db_file not exist");
		}
	}
}

# message handler
sub event_privmsg {
	my ($server, $data, $nick, $address) = @_;
	my ($target, $text) = split(/ :/, $data, 2);

	$target = $nick if ( ! ( $target =~/^\#/ ) );
	#Irssi::print("Target: $target, Text: \"$text\", Nick: $nick, Address: $address"); #return;
	
	if ( (my $idx = is_friend($nick, $address)) > -1) {
		if (friend_has_flag($idx, "m")) {
			if ($text =~ s/^\+\+\s+//i) {
				handleAdd($server, $text, $target, $nick, $address);
			}
		}
		if (friend_has_flag($idx, "r")) {
			if ($text =~ s/^\-\-\s+//i) {
				handleRemove($server, $text, $target, $nick, $address);
			}
		}
	} else {
		$target = $nick;
	}
	
	
	if ($text =~ s/^\?\?\s+//i) {
		my($query) = split(/ /, $text, 2);
		$text =~ s/^[^\s]*\s*//i;
		$text =~ s/\s*$//i;
		Irssi::print("Query detected for $target: \"$query\" by $nick");
		handleQuery($server, $query, $text, $target);
	}
	if ($text =~ s/^\?G\s+//i) {
		$text =~ s/\s*$//i;
		Irssi::print("Google requested for $target: \"$text\" by $nick");
		$server->command("/NOTICE $target Googled: ".google($text));
	}
}

load_friends();

Irssi::signal_add('event privmsg', 'event_privmsg')
