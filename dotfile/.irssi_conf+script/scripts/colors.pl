#!/usr/bin/perl

use strict;
my $text = "How to use these colors ('#' means a number as MIRC color code):

<Ctrl>-b        set bold
<Ctrl>-c#[,#]   set foreground and optionally background color
<Ctrl>-o        reset all formats to plain text
<Ctrl>-v        set inverted color mode
<Ctrl>-_        set underline
<Ctrl>-7        same as <Ctrl>-_

To reset a mode set it again, f.e.
<Ctrl-C>3<Ctrl-V>FOO<Ctrl-V>BAR
creates black on green FOO followed by a green on black BAR";

sub colors {
	# server - the active server in window
	# witem - the active window item (eg. channel, query)
	#         or undef if the window is empty
	my ($data, $server, $witem) = @_;
	if ($witem){
		foreach (0..15){
			$witem->command("ECHO " . "\cC" . sprintf("%02d", $_) . "Press ^C" . 
				sprintf("%02d", $_) . "message...           " . sprintf("%02d", $_));
		}  
		foreach my $line(split(/\n/, $text)){
			$witem->command("ECHO $line");
		} 
	}
	else{
		foreach (0..15){
			Irssi::print("\cC" . sprintf("%02d", $_) . "Press ^C" . 
				sprintf("%02d", $_) . "message...           " . sprintf("%02d", $_));
		}  
		Irssi::print($text);
	}
}

Irssi::command_bind('colors', 'colors');

