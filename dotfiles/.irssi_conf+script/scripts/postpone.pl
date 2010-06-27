# by Stefan 'tommie' Tomanek <stefan@pico.ruhr.de>
#
#

use strict;

use vars qw($VERSION %IRSSI);
$VERSION = "20030208";
%IRSSI = (
    authors     => "Stefan 'tommie' Tomanek",
    contact     => "stefan\@pico.ruhr.de",
    name        => "postpone",
    description => "Postpones messages sent to a splitted user and resends them when the nick rejoins",
    license     => "GPLv2",
    changed     => "$VERSION",
    commands     => "postpone"
);

use Irssi 20020324;
use vars qw(%messages);

sub draw_box ($$$$) {
    my ($title, $text, $footer, $colour) = @_;
    my $box = '';
    $box .= '%R,--[%n%9%U'.$title.'%U%9%R]%n'."\n";
    foreach (split(/\n/, $text)) {
        $box .= '%R|%n '.$_."\n";
    }
    $box .= '%R`--<%n'.$footer.'%R>->%n';
    $box =~ s/%.//g unless $colour;
    return $box;
}

sub show_help() {
    my $help="Postpone $VERSION
%g/postpone help%K
    Display this help
%g/postpone flush <nick>%K
    Flush postponed messages to <nick>
%g/postpone list%K
    List postponed messages
";
    my $text = '';
    foreach (split(/\n/, $help)) {
        $_ =~ s/^\/(.*)$/%9\/$1%9/;
        $text .= $_."\n";
    }
    print CLIENTCRAP &draw_box("Postpone", $text, "help", 1);
}


sub cmd_pp ($$$) {
    my ($args, $server, $witem) = @_;
    return unless ($witem && $witem->{type} eq "CHANNEL");
    if ($args =~ /^(\w+?): (.*)$/) {
	my ($target, $msg) = ($1,$2);
	if ($witem->nick_find($target)) {
	    # Just leave me alone
            $witem->print("%G•%g person is here, message not postponed", MSGLEVEL_CLIENTCRAP);
	    return;
	} else {
	    $witem->print("%G•%K %U".$target."%U is %gnot here, message has been postponed: \"".$args."\"", MSGLEVEL_CLIENTCRAP);
	    push @{$messages{$server->{tag}}{$witem->{name}}{$target}}, $args;
	}
    }
}

sub event_message_join ($$$$) {
    my ($server, $channel, $nick, $address) = @_;
    return unless (defined $messages{$server->{tag}});
    return unless (defined $messages{$server->{tag}}{$channel});
    return unless (defined $messages{$server->{tag}}{$channel}{$nick});
    return unless (scalar(@{$messages{$server->{tag}}{$channel}{$nick}}) > 0);
    my $chan = $server->channel_find($channel);
    $chan->print("%G•%g Sending postponed messages%K for %g".$nick, MSGLEVEL_CLIENTCRAP);
    while (scalar(@{$messages{$server->{tag}}{$channel}{$nick}}) > 0) {
	my $msg = pop @{$messages{$server->{tag}}{$channel}{$nick}};
	$server->command('MSG '.$channel.' '.$msg);
    }
    
}

sub cmd_postpone ($$$) {
    my ($args, $server, $witem) = @_;
    my @arg = split(/ /, $args);
    if (scalar(@arg) < 1) {
	#foo
    } elsif ($arg[0] eq 'flush' && defined $arg[1]) {
	return unless ($witem && $witem->{type} eq "CHANNEL");
	while (scalar(@{$messages{$server->{tag}}{$witem->{name}}{$arg[1]}}) > 0) {
	    my $msg = pop @{$messages{$server->{tag}}{$witem->{name}}{$arg[1]}};
	    $server->command('MSG '.$witem->{name}.' '.$msg);
	}
    } elsif ($arg[0] eq 'list') {
	my $text;
	foreach (keys %messages) {
	    $text .= $_."\n";
	    foreach my $channel (keys %{$messages{$_}}) {
		$text .= " %U".$channel."%U \n";
		foreach my $nick (sort keys %{$messages{$_}{$channel}}) {
		    $text .= ' |'.$_."\n" foreach @{$messages{$_}{$channel}{$nick}};
		}
	    }
	}
	print CLIENTCRAP &draw_box('Postpone', $text, 'messages', 1);
    } elsif ($arg[0] eq 'help') {
	show_help();
    }
}

Irssi::command_bind('postpone', \&cmd_postpone);
Irssi::command_bind('pp', \&cmd_pp);

Irssi::signal_add('message join', \&event_message_join);

print CLIENTCRAP "%K----------- %G•%g Postpone %K".$VERSION."%g loaded. %K For help do %g'/postpone help'";

