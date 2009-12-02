# autoop.pl by Jonas Berlin <jonas@berlin.vg> http://outerspace.dyndns.org/~xkr47/

use Irssi;

$ver = "0.4";
$nextidx = 0;

# check config file setting
sub read_settings {
    $autoop_conf_file = Irssi::settings_get_str("autoop_config_file");
    $autoop_autosave = Irssi::settings_get_bool("autoop_autosave");

    if(!$autoop_conf_file) {
	$autoop_conf_file = $ENV{"HOME"}."/.irssi/autoop.conf";
      Irssi::print "autoop: Using configuration file $autoop_conf_file. See variable autoop_config_file.";
      Irssi::settings_add_str("misc", "autoop_config_file", $autoop_conf_file);
    }

    if(!$autoop_autosave) {
	$autoop_autosave = 1;
      Irssi::print "autoop: Autosave mode enabled by default. See variable autoop_autosave.";
      Irssi::settings_add_bool("misc", "autoop_autosave", $autoop_autosave);
    }
}

# read config file
sub load_conf {
    undef %nickmasks;
    undef %usermasks;
    undef %hostmasks;
    undef %channelmasks;
    undef %ircnetmasks;

    # save separator
    my $old_sep = $/;
    $/ = "\n";

    open CONFFILE, "<".$autoop_conf_file;
    $nextidx = int(<CONFFILE>);

    while(<CONFFILE>) {
	chomp;
	my ($idx,$nickmask,$usermask,$hostmask,$channelmask,$ircnetmask) = split /\t/;
	$nickmasks{$idx} = $nickmask;
	$usermasks{$idx} = $usermask;
	$hostmasks{$idx} = $hostmask;
	$channelmasks{$idx} = $channelmask;
	$ircnetmasks{$idx} = $ircnetmask;
    }
    close CONFFILE;

    # restore original separator
    $/ = $old_sep;
}

sub save_conf {
    open CONFFILE, ">".$autoop_conf_file;
    print CONFFILE $nextidx."\n";
    while(($idx, $nickmask) = each %nickmasks) {
	$usermask = $usermasks{$idx};
	$hostmask = $hostmasks{$idx};
	$channelmask = $channelmasks{$idx};
	$ircnetmask = $ircnetmasks{$idx};
	print CONFFILE $idx."\t".$nickmask."\t".$usermask."\t".$hostmask."\t".$channelmask."\t".$ircnetmask."\n";
    }
    close CONFFILE;
}

sub autosave_conf {
    save_conf if $autoop_autosave;
}

sub get_cur_channel() {
    my $server_o = Irssi::active_server();
    my $window_o = Irssi::active_win();
    my @items = $window_o->items();
    my $item_o;
    foreach $item_o (@items) {
	next unless($item_o->is_active());
	
	my $channel = $item_o->{name};
	my $channel_o = $server_o->channel_find($channel);

	return $channel_o if($channel_o);
    }

    return ();
}

sub cmd_autoop {
    my ($cmdstr, $server, $unknown) = @_;
    my ($cmd,@params) = split(/ +/,$cmdstr);
    if($cmd =~ /^help$/i) {
	Irssi::print "Autoop help:

AUTOOP ADD [-nick nickmask] [-user usermask] [-host hostmask] [-channel channelmask] [-ircnet ircnetmask]

Adds a new auto-op rule. Masks are in regular expression format (sorry folks) so dots, etc need to be quoted. If some parameter is left out, that parameter is not taken into account when auto-opping. Parameters may be given in any order and duplicated (last one remains in effect).

AUTOOP MODIFY <index> [-nick nickmask] [-user usermask] [-host hostmask] [-channel channelmask] [-ircnet ircnetmask]

Modify an existing auto-op rule. The indexes to use are show with the AUTOOP LIST command. Parameters left out are not modified.

AUTOOP REMOVE <index> [index ...]

Removes the given rule(s) from the list of auto-op rules. The indexes to use are shown with the AUTOOP LIST command. Once used indexes are never re-used, so removing leaves \"holes\".

AUTOOP NOW

Checks all users on the current channel and gives ops to those matching the current autoop rules

AUTOOP LIST

Lists the auto-op rules that currently exist.

AUTOOP LOAD

Load the rule list from the autoop config file (see below), removing any previous rules.

AUTOOP SAVE

Save the rule list to the autoop config file.


 Settings:

autoop_conf_file          The file used to store autoop rules. You can use AUTOOP LOAD and AUTOOP SAVE to load/save from/to the file.
                          Current value: \"$autoop_conf_file\"
autoop_autosave           If true, automatically saves changes made to the autoop rules.
                          Current value: \"".($autoop_autosave?"ON":"OFF")."\"
";

    } elsif($cmd =~ /^add$/i) {
	my $i;
	my $idx, $nickmask = ".*", $usermask = ".*", $hostmask = ".*", $channelmask = ".*", $ircnetmask = ".*";

	if(0+@params < 1) {
	  Irssi::print "autoop: need to specify at least one mask";
	    return;
	}

	for($i=0; $i+1<0+@params; $i+=2) {
	    if($params[$i] eq "-nick") {
		$nickmask = $params[$i+1];
	    } elsif($params[$i] eq "-user") {
		$usermask = $params[$i+1];
	    } elsif($params[$i] eq "-host") {
		$hostmask = $params[$i+1];
	    } elsif($params[$i] eq "-channel") {
		$channelmask = $params[$i+1];
	    } elsif($params[$i] eq "-ircnet") {
		$ircnetmask = $params[$i+1];
	    } else {
	      Irssi::print "autoop: Invalid parameter: $params[$i]";
		return;
	    }
	}
	if(((0+@params)&1) != 0) {
	  Irssi::print "autoop: Incomplete or invalid parameter: $params[-1]";
	    return;
	}

	$idx = $nextidx++;
	$nickmasks{$idx} = $nickmask;
	$usermasks{$idx} = $usermask;
	$hostmasks{$idx} = $hostmask;
	$channelmasks{$idx} = $channelmask;
	$ircnetmasks{$idx} = $ircnetmask;
	
	autosave_conf;

      Irssi::print "autoop: Rule added at index $idx.";

    } elsif($cmd =~ /^modify$/i) {
	my $i;
	my $idx;

	if(0+@params < 2) {
	  Irssi::print "autoop: need to specify at least one mask";
	    return;
	}
	$idx = int(shift @params);

	if(defined $nickmask{$idx}) {
	  Irssi::print "autoop: index $idx not defined; aborting.";
	    return;
	}

	for($i=0; $i+1<0+@params; $i+=2) {
	    if($params[$i] eq "-nick") {
		$nickmasks{$idx} = $params[$i+1];
	    } elsif($params[$i] eq "-user") {
		$usermasks{$idx} = $params[$i+1];
	    } elsif($params[$i] eq "-host") {
		$hostmasks{$idx} = $params[$i+1];
	    } elsif($params[$i] eq "-channel") {
		$channelmasks{$idx} = $params[$i+1];
	    } elsif($params[$i] eq "-ircnet") {
		$ircnetmasks{$idx} = $params[$i+1];
	    } else {
	      Irssi::print "autoop: Invalid parameter: $params[$i]";
		return;
	    }
	}
	if(((0+@params)&1) != 0) {
	  Irssi::print "autoop: Incomplete or invalid parameter: $params[-1]";
	    return;
	}

	autosave_conf;

      Irssi::print "autoop: Rule at index $idx modified.";

    } elsif($cmd =~ /^remove$/i) {
	my $idx;
	foreach $idx (@params) {
	    if(defined $nickmasks{$idx}) {
		delete $nickmasks{$idx};
		delete $usermasks{$idx};
		delete $hostmasks{$idx};
		delete $channelmasks{$idx};
		delete $ircnetmasks{$idx};
	      Irssi::print "autoop: index $idx removed.";

		autosave_conf;
	    } else {
	      Irssi::print "autoop: index $idx not defined; ignoring.";
	    }
	}

    } elsif($cmd =~ /^now$/i) {
	my $channel_o = get_cur_channel();

	if($channel_o) {
	    if (!$channel_o->{chanop}) {
	      Irssi::print "autoop: unable to AUTOOP NOW -- not an operator on channel $channel_o->{name}.";
		return;
	    }
	    
	    my @nicks = $channel_o->nicks();
	    
	    event_massjoin($channel_o, \@nicks);
	    
	    return;
	}

      Irssi::print "autoop: not on a channel";

    } elsif($cmd =~ /^list$/i) {
	my $idx, $nickmask, $usermask, $hostmask, $channelmask, $ircnetmask;

	if(!%nickmasks) {
	  Irssi::print "autoop: No auto-op rules defined.";
	    return;
	}
	
      Irssi::print sprintf("IDX   %-15s %-18s %-25s %-15s %-10s", "NICKMASK", "USERMASK", "HOSTMASK", "CHANNELMASK", "IRCNETMASK");

	while(($idx, $nickmask) = each %nickmasks) {
	    $usermask = $usermasks{$idx};
	    $hostmask = $hostmasks{$idx};
	    $channelmask = $channelmasks{$idx};
	    $ircnetmask = $ircnetmasks{$idx};

	  Irssi::print sprintf("%3d.  %-15s %-18s %-25s %-15s %-10s", $idx, $nickmask, $usermask, $hostmask, $channelmask, $ircnetmask);
	}
	
    } elsif($cmd =~ /^load$/i) {
	load_conf;
      Irssi::print "autoop: Loaded ".(scalar keys %nickmasks)." rules from $autoop_conf_file.";

    } elsif($cmd =~ /^save$/i) {
	save_conf;
      Irssi::print "autoop: Saved ".(scalar keys %nickmasks)." rules to $autoop_conf_file.";

    } else {
      Irssi::print "autoop: Try /AUTOOP HELP.";

    }
}

sub event_massjoin {
    my ($channel_o, $nicks_list) = @_;

    return if (!$channel_o->{chanop});

    my $channel = $channel_o->{name};
    my @nicks = @{$nicks_list};
    my $server_o = $channel_o->{server};
    my $ircnet = $server_o->{tag};

    my $nicklist = "";
    my $nick_o;

    foreach $nick_o (@nicks) {

	next if($nick_o->{op}); # already opped ?

	my $nick = $nick_o->{nick};
	my ($user,$host) = split /@/, $nick_o->{host}, 2;
	my $idx, $nickmask;

	while(($idx, $nickmask) = each %nickmasks) {
	    next unless($nick =~ m/^$nickmask$/i);
	    next unless($user =~ m/^$usermasks{$idx}$/i);
	    next unless($host =~ m/^$hostmasks{$idx}$/i);
	    next unless($channel =~ m/^$channelmasks{$idx}$/i);
	    next unless($ircnet =~ m/^$ircnetmasks{$idx}$/i);
	    
	    $nicklist .= $nick . " ";
	    last;
	}
    }

    $channel_o->command("/op $nicklist") if(length($nicklist));
}

# main

read_settings;
load_conf;

Irssi::signal_add_last('massjoin', 'event_massjoin');
Irssi::command_bind("autoop", "cmd_autoop", "xkr");

Irssi::print "\0034Autoop v$ver\0038 installed, ".(scalar keys %nickmasks)." rules loaded";
