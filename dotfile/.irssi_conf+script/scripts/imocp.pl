#!/usr/bin/perl

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION="0.2.2";

%IRSSI = (
	authors 	=> "%G• %gScript%K by %g#hack.se%n",
	name		=> "%G• %gmocp",
	description	=> "%G• %gControl mocp%K via %gIrssi.%K Use the %g/mocp%K command. See \"%g/mocp help%K\" for documentation",
);

#Print out the load status to the status list
Irssi::print("$IRSSI{name} $VERSION %Ksuccessfully%g loaded!%n\n$IRSSI{authors}\n$IRSSI{description}");

#########
# DOCUMENTATION
#########
#
# iMOCP is a script that make Irssi able to talk with MOCP. Put the script in ~/.irssi/scripts or
# ~/.irssi/scripts/autorun to make it autoload, when you start Irssi. If you dosen't use the autorun folder
# then you have to load iMOCP with this command:
#
#	/script load imocp.pl
#
# iMOCP commands:
# /mocp play	- Play track
# /mocp pause	- Pause track
# /mocp p	- Toggle between play and pause
# /mocp next	- Play next track
# /mocp n
# /mocp prev	- Play previous track
# /mocp b
# /mocp info	- Display track information i status window
# /mocp i
# /mocp npf	- Print now playing filename to channel.
# /mocp np	- Print current track title to
#		chat window. This only supports
#		id3-tag yet.
#
#########

#########
# CHANGELOG
#########
#
# 0.2.2:
# * Play / pause bug fixed thanks Curium for bugreport!
#
# 0.2.1:      
# * Fixed bug that caused iMOCP to crash.
# * Added /mocp help, command to display all functions
# * Created a changelog
#
#
# 0.2:        
# * Added more bindings to mocp.
# * Fixed stop-play problem
# * Added support for toggle between play and pause
#
########

# Display help
sub mocp_help {
	Irssi::print("%M•%m  mocp ♫      %k-%m  Commands%n");
	Irssi::print("%G•%g /mocp play   %K-%g  Play track%n");
	Irssi::print("%G•%g /mocp pause  %K-%g  Pause track%n");
	Irssi::print("%G•%g /mocp p      %K-%g  Toggle between play and pause%n");
	Irssi::print("%G•%g /mocp next   %K-%g  Next track%n");
	Irssi::print("%G•%g /mocp n      %K-%g  Next track%n");
	Irssi::print("%G•%g /mocp prev   %K-%g  Previous track%n");
	Irssi::print("%G•%g /mocp b      %K-%g  Previous track%n");
	Irssi::print("%G•%g /mocp np     %K-%g  Print out current track in channel, title by ID3 tag%n");
	Irssi::print("%G•%g /mocp npf    %K-%g  Print out current track in channel, filename%n");
	Irssi::print("%G•%g /mocp info   %K-%g  Information about the current track%n");
	Irssi::print("%G•%g /mocp i      %K-%g  Information about the current track%n");
	Irssi::print("%G•%g /mocp help   %K-%g  Display this help%n");
}


# Fetch title
sub mocp_np {
	my ($data, $server, $item) = @_;

	my $info=`mocp -i`;
	my($title) = $info =~ /^Title: (.*?)\n/ms;

	if ($title == "") {
		my($title) = $info =~ /^File: (.*?)\n/ms;
	}

	# These are the text's that should be shown before and after the filename in the output
        my $msg_first = 'mocp np ♫: ';
	my $msg_last = '';

	if ($item && ($item->{type} eq "CHANNEL" || $item->{type} eq "QUERY")) {
		$item->command("MSG ".$item->{name}." $msg_first\'$title\'$msg_last");
	} else {
		Irssi::print("%R•%K You're %rnot in%K any %rchannel!%n");
	}
}

# Fetch now playing file
sub mocp_npf {
	my ($data, $server, $item) = @_;

	my $info=`mocp -i`;
	my($title) = $info =~ /^File: (.*?)\n/ms;

	my @arr = split('/',$title);

	# These are the text's that should be shown before and after the filename in the output
        my $msg_first = 'mocp np ♫: ';
	my $msg_last = ' - moc 2.4.0';

	if ($item && ($item->{type} eq "CHANNEL" || $item->{type} eq "QUERY")) {
		$item->command("MSG ".$item->{name}." $msg_first\'@arr[scalar(@arr) - 1]\'$msg_last");
	} else {
		Irssi::print("%R•%K You're %rnot in%K an %rchannel!%n");
	}
}

# Switch to the next song
sub mocp_next {
	my ($data, $server, $item) = @_;

	my $next=`mocp -f`;
	Irssi::print("%G•%g mocp ♫:%K Switching to %gnext song%n");
}

# Switch to prev song
sub mocp_prev {
	my ($data, $server, $item) = @_;

	my $next=`mocp -r`;
	Irssi::print("%G•%g mocp ♫:%K Switching to %gprevious song%n");
}

# Fetch song info
sub mocp_info {
	my ($data, $server, $item) = @_;

	my $info=`mocp -i`;
	
	Irssi:print("%G•%g mocp ♫:\n*****\n".$info."\n*****");

}

# Play or pause the music
sub mocp_play_pause {
	my ($data, $server, $item) = @_;

	my $next=`mocp -G`;
	Irssi::print("%G•%g mocp ♫:%K Play/pause");
}

# Stop the music
#sub mocp_stop {
#	my ($data, $server, $item) = @_;
#
#	my $next=`mocp -s`;
#	Irssi::print("iMOCP: Stop");
#}

# This is used to bind the mocp command the the fetch function
Irssi::command_bind 'mocp' => sub {
    	my ( $data, $server, $item ) = @_;
        $data =~ s/\s+$//g;
	Irssi::command_runsub ('mocp', $data, $server, $item ) ;
};

# Handle subactions
Irssi::signal_add_first 'default command mocp' => sub {
	# If unknown subcommand
	Irssi::print("%M•%m mocp ♫: Unknown command, \"%m/mocp help%K\" might give you a clue!");
};

# Bindings
Irssi::command_bind('mocp np', 'mocp_np');
Irssi::command_bind('mocp npf', 'mocp_npf');
Irssi::command_bind('mocp next', 'mocp_next');
Irssi::command_bind('mocp n', 'mocp_next');
Irssi::command_bind('mocp prev', 'mocp_prev');
Irssi::command_bind('mocp b', 'mocp_prev');
Irssi::command_bind('mocp play', 'mocp_play_pause');
Irssi::command_bind('mocp p', 'mocp_play_pause');
Irssi::command_bind('mocp pause', 'mocp_play_pause');
Irssi::command_bind('mocp info', 'mocp_info');
Irssi::command_bind('mocp i', 'mocp_info');
Irssi::command_bind('mocp help', 'mocp_help');
