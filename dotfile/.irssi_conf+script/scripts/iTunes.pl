#!/usr/bin/perl -w

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
use Irssi::Irc;

##|
##| Note:
##|
##|     This script is meant to be run on irssi installed on Mac OS X
##|     running iTunes.  If you do not have either, stop reading this now
##|     as this script will not help you at all.  ;)
##|
##| Help Notes:
##|
##|     This Script is releases as-is.  If you are having problems 
##|     running this script, here is some help I can offer, though I
##|     can't promise this will work so dont complain to me if it doesn't:
##|     
##|     * Make sure you have the following set when you compile irssi:
##|         --with-perl=yes
##|         If you already have irssi compiles the easiest way to check
##|         to see if you have perl support is to type:  /script
##|         You will get an 'unknown command' error if you dont, and
##|         possibly something like 'no scripts running' if you do.
##|
##|     * I used DarwinPorts to install irssi.  After DarwinPorts is 
##|         installed, find the Portfile for irssi. It is probably at:
##|             ~/darwinports/dports/irc/irssi/Portfile
##|         Change the text to read:  --with-perl=yes
##|         Then, go to Terminal.app and type:  
##|             sudo port install irssi
##|         If you already had irssi installed, but it is without perl 
##|         support, you can uninstall irssi, and then install it again
##|         after changing the portfile.  To uninstall irssi through
##|         darwinports try:  sudo port uninstall irssi
##|
##|     * irssi scripts need to be placed into the following dir(s):
##|         If you want it to autoload put the file into:  
##|             ~/.irssi/scripts/autorun/
##|         If you want it to be able to load it yourself put it in:
##|             ~/.irssi/scripts/
##|             You will then need to run the command: 
##|                 /script load iTunes.pl
##|         To get to: ~/.irssi hit: cmd-shift-g and type in: ~/.irssi
##|         If you dont already have a scripts dir or autorun dir, you
##|         will need to create them.
##|
##|     * Once installed try the following command:  /itunes help
##|
##| Contact Notes:
##| 
##|     * If you want to contact me, feel free to visit #macosx on
##|         irc.freenode.net (/msg NO_PULSE) or christopher@ungeheier.com
##|         or ungeheiercom using your favorite AIM software.  If I
##|         dont respond, dont take it personally, I may not be at my 
##|         computer.  Also, make sure in the first few messages to me
##|         that you got my name from this script so I know not to just
##|         auto-ignore you.  ;)
##|     * If you would like to see more features added to this script
##|         feel free to contact me with the subject 'irssi iTunes Script Features'
##|     * All releases of this script will end up at:
##|         http://irssi.ungeheier.com
##|     * I will continue to update this script when I have the time.  If at
##|         any point I decide to stop development I will make a note in this
##|         file, as well as the url above.
##|     * Until then, I would ask that if you want to edit this file, please 
##|         do not.  If there are errors in this script, I would prefer that 
##|         you inform me, so I can make the needed changed, and upload a new
##|         version to the url above.  I will give you credit for changes, as
##|         well as anyone who requests new features that I havent already planned.
##|
##| Thanks:
##|
##|     I'd like to thank the following people with help on this script:
##|         Tego - for setting the path to follow.
##|         Pilz-E/Starmanta - for putting up with my n00b questions about Applescript
##|         #macosx - for testing out this script for me. 
##|         Juerd - for his irssi scripting site:  http://juerd.nl/site.plp/irssiscripttut
##|
##| Release Notes:
##|
##| 0.0.1: Going Through Tego's orignal script and rewriting it
##|         No Structure Changes Made, or Added Features
##| 0.0.2: Added !iTunes trigger to not load or display any
##|			info if iTunes is not currently running.
##| 0.0.3: Added catch to !iTunes trigger. Responds differently
##|			depending on state of iTunes (playing/pause/stopped)
##| 0.0.4: Added stats:  /itunes stats
##| 0.0.5: Added search song:  /itunes search song "song name"
##| 0.0.6: Fixed major problem with search function thanks to help from:
##|         http://discussions.info.apple.com/webx?14@462.b48LanzWMqq.0@.ee6ba86
##| 0.0.7: Converted Script from X-Chat Aqua to an irssi script
##| 0.0.8: Added Help/Contact Notes
##| 0.0.9: Cleaned up most of the code
##| 0.1.0: Uploaded to http://irssi.ungeheier.com for the first time
##| 0.1.1: Added Color Globals
##| 0.1.2: Removed Color Globals, Added irssi Theme format
##|         Removed version numbering on load as well. Version is printed
##|         in: /itunes help
##| 0.1.3: Added Playlist command. See: /itunes help
##| 0.1.4: Fixed Search Patterns. You can now search for multiple words
##| 0.1.5: Cleaned some code, and posted it to Version Tracker for the first time.
##| 0.1.6: Fixed printing bug which would occur when someone ran script when not in a channel.
##|			Fixed !iTunes trigger.
##| 0.1.7: Added Shuffle Command: /itunes shuffle
##|			Added Repeat Command: /itunes repeat all/one/off
##| 0.1.8: Added Stream Info Grabbing
##|			Rewrote some of the Show code.
##|			Added Playlist Stats: /itunes playlist stats
##|			Added Number Formatting For Song Count
##|			Cleaned up some code.
##| 0.1.9: Added iPod Stats: /itunes stats ipod
##|			Added iPod Playlist List: /itunes playlist list ipod
##|			Added iPod Playlist Change: /itunes playlist change ipod "Library"
##|			Playlist stats will also work for current iPod Playlist as well.
##| 0.2.0: Added 'me' to printing statements
##|			Added Irssi setable variables:
##|			itunes_reply (which handles the replies to '!itunes'):  either Yes or No
##|			itunes_reply_type (which determines how the reply is sent): either Notice or Msg
##| 0.2.1: Added 'rating' command. It takes a number between 0-5 or nothing at all. If 
##|			nothing is passed, then it will display the rating for the current song. If 
##|			the number given is 0, then the song will be given no stars.
##|

$VERSION = '0.2.1';
%IRSSI = (
    authors     => 'Christopher R. Ungeheier',
    contact     => 'christopher@ungeheier.com',
    name        => 'itunes',
    description => 'iTunes script using Applescripting ',
    license     => 'If you modify this script please give me credit.',
);

##|
##| Other Globals
my ($data, $server, $witem) = @_;

##|
##| Irssi Variables
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_reply', "Yes");
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_reply_type', "Notice");

my $get_track = qq(
	tell application "iTunes.app"
		set this_name to the name of current track
		set this_artist to the artist of current track
		set this_album to the album of current track
		set this_rating to the rating of current track
		set this_length to the time of current track
	end tell
	return this_name & tab & this_artist & tab & this_rating & tab & this_length & tab & this_album
	);

Irssi::theme_register([
    'itunes_header', 'iTunes: %_%k%5$0',
    'itunes_format', 'iTunes: %_$0 %R$1'
]);

Irssi::command_bind itunes => sub {
	# data - contains the parameters for /itunes
	# server - the active server in window
	# witem - the active window item (eg. channel, query)
	#         or undef if the window is empty
	($data, $server, $witem) = @_;

	$data =~ s/\s+/ /g;
	my ($todo,$where,$rest) = split(/\s/,$data);

	if ($todo =~ /^show$/i) { &show; } 
	elsif ($todo =~ /^next$/i) { &next_track; } 
	elsif ($todo =~ /^prev/i) { &prev_track; } 
	elsif ($todo =~ /^boot/i) { &boot_itunes; } 
	elsif ($todo =~ /^quit/i) { &quit_itunes;	} 
	elsif ($todo =~ /^search/i) { &search_itunes; } 
	elsif ( ($todo =~ /^play$/i) && ($where =~ /^track$/i) )  { &play_track; } 
	elsif ($todo =~ /^play$/i) { &play; } 
	elsif ($todo =~ /^stop/i) { &stop; } 
	elsif ($todo =~ /^rating$/i) { &rating; } 
	elsif ($todo =~ /^pause/i) { &pause; } 
	elsif ($todo =~ /^rewind/i) { &rewind;	} 
	elsif ($todo =~ /^volume/i) { &volume;	} 
	elsif ($todo =~ /^playlist$/i) { &playlist;	} 
	elsif ($todo =~ /^repeat$/i) { &repeat; } 
	elsif ($todo =~ /^shuffle$/i) { &shuffle; } 
	elsif ($todo =~ /^stats/i) { &stats; } 
	elsif ($todo =~ /^help/i) {	&help; } 
	else {
		if ($witem)
		{
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Plugin didn't understand your command.");
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "type '/iTunes help' for more info");
		}
	}
	return 1;

};

sub rating
{
	my ($text_rating,$what) = split(/\s/,$data);

	if ($witem)
	{

		if ($what eq "")
		{
			##| Display the number of stars.
			my $rating = qq(
			tell application "iTunes.app"
				set myRating to rating of current track
			return myRating
			end tell
			);
			
			my $rating = qx(osascript -e '$rating');
			$rating = $rating / 20;
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Current Song Rating Is: $rating");

		} else {
			##| Want to grab the current rating
			if (($what == 0) || ($what == 1) || ($what == 2) || ($what == 3) || ($what == 4) || ($what == 5))
			{
				my $rating = $what * 20;
				my $asrating = qq(
				tell application "iTunes.app"
					set rating of current track to $rating
				end tell
				);
			
				my $rating = qx(osascript -e '$asrating');
				
				$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Current Song Rating Has Been Set To: $what");

			} else {
				##| Error
				$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Rating Error: Please Enter A Number Between 0-5");

			}
			
		}
	}

}

sub volume
{
	my ($text_volume,$what) = split(/\s/,$data);
	my $volume;
	my $where;

	if($what =~ /^up$/i)
	{
		$volume = "sound volume + 11";
	} elsif($what =~ /^down$/i) {
		$volume = "sound volume - 9";
	} elsif($what =~ /^\d+$/) {
		$volume = $what + 1;
	} else {
		if ($witem)
		{
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Sorry, bad volume value (you can use 'up', 'down' and a number between 0 and 100)");
		}
		return 1;
	}
	
	my $volume = qq(
	tell application "iTunes.app"
		set sound volume to $volume
		return sound volume
	end tell
	);
	
	my $volume = qx(osascript -e '$volume');

	if ($witem)
	{
		$volume =~ s/\n//g;
		$volume = "iTunes sound volume is on $volume/100";
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "$volume");
	}
}

sub show 
{
	if($witem)
	{
		my $line = "";
		my $get_track = qq(
		tell application "iTunes"
			set this_name to the name of current track
			set this_artist to the artist of current track
			set this_album to the album of current track
			set this_rating to the rating of current track
			set this_length to the time of current track
			set this_stream to the current stream title
		end tell
		return this_name & tab & this_artist & tab & this_rating & tab & this_length & tab & this_album & tab & this_stream
		);

		my $temp = qx(osascript -e '$get_track');
		$temp =~ s/\n//g;

		$temp =~ s/\tmissing value\t/\t\t/g;
		$temp =~ s/\tmissing value$/\t/g;
		my ($track,$player,$rate,$duration,$album,$stream) = split(/\t/,$temp);
	
		if($player eq "")
		{
			my @temp = ("some unknown musician","some undefined musician","someone");
			$player = $temp[int(rand(@temp))];
		}
	
		if ($track =~ /^\s*$/)
		{
			$line = "nothing at all";
		} elsif ($stream !~ /^\s*$/) {
			$line = '"<stream>" on the Stream "<track>"';
			$line  =~ s/<track>/$track/gi;
			$line  =~ s/<stream>/$stream/gi;
		} else {
			$line = '"<track>" by "<player>" from the album "<album>" [<length>]';

			$line  =~ s/<track>/$track/gi;
			$line  =~ s/<player>/$player/gi;
			$line  =~ s/<length>/$duration/gi;
			if ($album)
			{
				$line  =~ s/<album>/$album/gi;
			} else {
				$line  =~ s/<album>/unknown/gi;
			}
		
		}
		my ($text_show,$what) = split(/\s/,$data);

		if ($what ne "me")
		{
			$line = "is listening to " . $line;
			$witem->command("/ME $line");
		} else {
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "- $line");
		}
		
	}

}

sub stats
{
	if ($witem)
	{
		my ($todo,$which,$rest) = split(/\s/,$data);
		lc($which);
		if ($which eq "ipod")
		{

			my $ipod = &ipod_check;
			
			if ($ipod ne "")
			{
			
				my $stats = qq(
				tell application "iTunes"
					repeat with i from 1 to the count of sources
						if the kind of source i is iPod then
							set theSource to the name of source i as text
						end if
					end repeat
			
					set msg to ""
					tell source theSource
						set lib to library playlist 1
						set libName to name of library playlist 1
						if size of lib < 1.0E+9 then
							set my_size to (round (size of lib) / 1024 / 1024 * 100 as string) / 100 & " MB"
						else
							set my_size to ((round (size of lib) / 1024 / 1024 / 1024 * 100) / 100 as string) & " GB"
						end if
						set my_time to time of lib
						set my_count to (count tracks in lib)
					end tell
				end tell
				return libName & tab & my_time & tab & my_count & tab & my_size
				);

				my $stats = qx(osascript -e '$stats');
				$stats =~ s/\n//g;

				$stats =~ s/\tmissing value\t/\t\t/g;	
				$stats =~ s/\tmissing value$/\t/g;
				my ($libName,$mytime,$songs,$size) = split(/\t/,$stats);
				$songs = add_commas($songs);

				if ($rest ne "me")
				{
					my $my_string = "'s iPod is $mytime long, with $songs songs totaling $size";
					$witem->command("/ME $my_string");

				} else {
					my $my_string = "your iPod is $mytime long, with $songs songs totaling $size";
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "$my_string");
				}

			} else {
				
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "No iPod Connected.");

			}

		} else {
			my $stats = qq(
			tell application "iTunes.app"
				set lib to library playlist 1
				set libName to name of library playlist 1
				if size of lib < 1.0E+9 then
					set my_size to (round (size of lib) / 1024 / 1024 * 100 as string) / 100 & " MB"
				else
					set my_size to ((round (size of lib) / 1024 / 1024 / 1024 * 100) / 100 as string) & " GB"
				end if
				set my_time to time of lib
				set my_count to (count tracks in lib)
			end tell
			return libName & tab & my_time & tab & my_count & tab & my_size 
			);

			my $stats = qx(osascript -e '$stats');
			$stats =~ s/\n//g;

			$stats =~ s/\tmissing value\t/\t\t/g;	
			$stats =~ s/\tmissing value$/\t/g;
			my ($libName,$mytime,$songs,$size) = split(/\t/,$stats);
			$songs = add_commas($songs);

			if ($which ne "me")
			{
				my $my_string = "'s iTunes $libName is $mytime long, with $songs songs totaling $size";
				$witem->command("/ME $my_string");

			} else {
				my $my_string = "your iTunes $libName is $mytime long, with $songs songs totaling $size";
				$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "$my_string");
			}



		}
	}

}

sub help 
{
	if ($witem)
	{
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "iTunes $VERSION plugin commands");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes boot     : Loads iTunes ");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes quit     : Quits iTunes ");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes show     : displays playing track" , "     *");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes stats    : display iTunes or iPod stats" , "     *");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes stats");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes stats ipod");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes play     : start playing track");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes stop     : stop playing track");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes pause    : toggle play/pause");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes next     : move to next track");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes prev     : move to previous track");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes rewind   : go back to beginning of the current track");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes search   : need to give what you're looking for artists/songs/albums"); 
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes search artists \"Cop Shoot Cop\"");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes search songs \"Ask Questions Later\"");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes search albums \"Surprise, Surprise\"");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes playlist : takes one of three variables: list, change, stats" , "     *"); 
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes playlist list");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes playlist list ipod");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes playlist stats");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes playlist change \"Library\"");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes playlist change ipod \"Library\"");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes repeat   : takes one of three variables: all, one, or off"); 
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes playlist list");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes shuffle  : changes shuffle status to either On or Off"); 
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    example: /itunes shuffle");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes volume   : set & display sound volume in iTunes (not system volume)"); 
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                    options : up, down or a number from 0 till 100");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes rating   : takes a number between 0-5 or nothing at all"); 
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /iTunes help     : shows this help text");
		
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "--------Settings--------");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /set itunes_reply      : Handles if script will reply to '!itunes' or not (either Yes or No)");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                        : example: /set itunes_reply Yes");
		my $reply = Irssi::settings_get_str($IRSSI{'name'} . '_reply');
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                        : current setting: '$reply'");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " /set itunes_reply_type : Determines how reply is sent (either Notice or Msg)");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                        : example: /set itunes_reply_type Notice");
		my $reply_type = Irssi::settings_get_str($IRSSI{'name'} . '_reply_type');
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "                        : current setting: '$reply_type'");
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', " * Commands can be followed with 'me' in order to display data locally.");
	}	
}

sub next_track 
{
	my $next = qq(
		ignoring application responses
			tell application "iTunes.app"
				next track
			end tell
		end ignoring
	);
	$next = qx(osascript -e '$next');
	
	if ($witem)
	{
		$next = qx(osascript -e '$get_track');
		$next =~ s/\n//g;
		$next =~ s/\t/ \- /g;
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', $next);
	}
}

sub prev_track 
{
	my $prev = qq(
		ignoring application responses
			tell application "iTunes.app"
				previous track
			end tell
		end ignoring
	);
	$prev = qx(osascript -e '$prev');
	if ($witem)
	{
		$prev = qx(osascript -e '$get_track');
		$prev =~ s/\n//g;
		$prev =~ s/\t/ \- /g;
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', $prev);
	}
}

sub boot_itunes 
{
	my $boot = qq(
		ignoring application responses
			tell application "iTunes.app" to open
		end ignoring
	);
	$boot = qx(osascript -e '$boot');
}

sub quit_itunes 
{
	my $quit = qq(
		ignoring application responses
			tell application "iTunes.app" to quit
		end ignoring
	);
	$quit = qx(osascript -e '$quit');
}

sub play 
{
	my $play = qq(
		ignoring application responses
			tell application "iTunes.app" to play
		end ignoring
	);
	$play = qx(osascript -e '$play');
}

sub pause 
{
	my $pause = qq(
		ignoring application responses
			tell application "iTunes.app" to playpause
		end ignoring
	);
	$pause = qx(osascript -e '$pause');
}

sub stop 
{
	my $stop = qq(
		ignoring application responses
			tell application "iTunes.app" to stop
		end ignoring
	);
	$stop = qx(osascript -e '$stop');
}

sub rewind 
{
	my $rewind = qq(
		ignoring application responses
			tell application "iTunes.app" to back track
		end ignoring
	);
	$rewind = qx(osascript -e '$rewind');
}

sub search_itunes
{
	if ($witem)
	{
		my ($text_search,$what,$search_string) = split(/\s/,$data);
	
		if (($what ne "songs") &&  ($what ne "artists") &&  ($what ne "albums") && ($what ne "all"))
		{
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Error: You must tell me what to search for:  /itunes search songs/artists/albums/all \"search term\"");
			return 1;
		} else {
			if ($what ne "all")
			{
				$what = " only " . $what;
			} else {
				$what = "";
			}
		}

		if ($search_string eq "")
		{
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Error: You must tell me what to search for:  /itunes search songs/artists/albums/all \"search term\"");
			return 1;
		}
	
		my ($junk,$search_string) = split(/\"/,$data);
		$search_string =~ s/\"//g;

		my $command = qq(
			tell application "iTunes"
				set msg to "" as Unicode text
				set lib to library playlist 1
				set libName to name of library playlist 1
				set search_string to "$search_string" as Unicode text
				set found_tracks to (search playlist libName for search_string $what)
	
				set repeat_counter to 1
				repeat with something in found_tracks
		
					set firstTrack to item repeat_counter of found_tracks -- just in case more than 1 item is returned
					tell firstTrack -- now target that track
						set this_name to the name
						set this_artist to the artist
						set this_album to the album
						set this_rating to the rating
						set this_length to the time
						set this_key to the database ID
					end tell
					set msg to msg & this_artist & tab & this_name & tab & this_album & tab & this_key & "| "
		
					set repeat_counter to (repeat_counter + 1)
				end repeat
			end tell

			return msg
		);

		my $search_return = qx(osascript -e '$command');
	
		my @search_results = split(/\|\s/,$search_return);

		foreach my $track (@search_results)
		{
			my ($text_artist,$text_track,$text_album,$track_id) = split(/\t/,$track);

			if ($text_track ne "")
			{
				$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "'$text_track' by '$text_artist' from the album '$text_album'");
				my $what = "   To Play The Above Song Type: /itunes play track $track_id";
				$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', $what);
			}
		}
	}
}

sub repeat
{
	if ($witem)
	{
		my ($todo,$repeat_string,$rest) = split(/\s/,$data);
		my $which = "";
		lc($repeat_string);
		if ($repeat_string eq "all")
		{
			$which = "all";	
		} elsif($repeat_string eq "one") {
			$which = "one";
		} elsif($repeat_string eq "off") {
			$which = "off";
		} else {
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Repeat Command Unknown. Try: one, all, or off");
		}

		if ($which ne "")
		{
			my $command = qq(
				tell application "iTunes.app"
					set song repeat of current playlist to $which
				end tell
			);

			my $current_playlist = qx(osascript -e '$command');

			$current_playlist =~ s/\n//g;		
		
			$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Repeat Status Is Now: $which");
	
		}
	}

}

sub shuffle
{

	if ($witem)
	{
		my ($which, $text) = "";
		my $command = qq(
			tell application "iTunes"
				set shuffleStatus to shuffle of current playlist
			end tell
			return shuffleStatus
		);

		my $shuffle_status = qx(osascript -e '$command');

		$shuffle_status =~ s/\n//g;		

		if ($shuffle_status eq "true")
		{
			$which = "False";
			$text = "Off";
		} else {
			$which = "True";
			$text = "On";
		}

		my $command = qq(
			tell application "iTunes.app"
				set shuffle of current playlist to $which
			end tell
		);

		my $current_playlist = qx(osascript -e '$command');
		$current_playlist =~ s/\n//g;		
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Shuffle Status Is Now: $text");

	}
}

sub playlist
{
	if ($witem)
	{
		my ($text_playlist,$what,$playlist_string) = split(/\s/,$data);

		if ($what eq "list")
		{
			lc($playlist_string);
			if ($playlist_string eq "ipod")
			{

				my $ipod = &ipod_check;
			
				if ($ipod ne "")
				{

					my $command = qq(
					     tell application "iTunes"
					     	set myPlaylist to (name of current playlist)
					     end tell
					     return myPlaylist
					);

					my $current_playlist = qx(osascript -e '$command');
					$current_playlist =~ s/\n//g;
					$current_playlist =~ s/\t/ \- /g;

					#chop($current_playlist);

					my $command = qq(
						tell application "iTunes"
							repeat with i from 1 to the count of sources
							if the kind of source i is iPod then
								set theSource to the name of source i as text
							end if
							end repeat
							set msg to ""
							tell source theSource    
								set myPlaylists to (name of every playlist)
							end tell
							set msg to "" as Unicode text
							repeat with something in myPlaylists
								set msg to msg & something & "|"
							end repeat
						end tell
						return msg
					);

					my $playlist_return = qx(osascript -e '$command');

					$playlist_return =~ s/\n//g;
					$playlist_return =~ s/\t/ \- /g;

					my @playlist_results = split(/\|/,$playlist_return);

					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "List of current iPod platlists: ");

					my $add_string;

					foreach my $playlist (@playlist_results)
					{  

						if ($playlist ne "" || $playlist ne "\n"|| $playlist ne "\r\n" || $playlist ne " ")
						{
						   if ($current_playlist eq $playlist)
							{
								$add_string = "* Current Playlist";
							} else {
								$add_string = "";
							}
							$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "'$playlist'" , "      $add_string");
						}
					}
				} else {
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "No iPod Connected.");
				}		
			} else {

				my $command = qq(
				     tell application "iTunes"
				     	set myPlaylist to (name of current playlist)
				     end tell
				     return myPlaylist
				);

				my $current_playlist = qx(osascript -e '$command');
				$current_playlist =~ s/\n//g;
				$current_playlist =~ s/\t/ \- /g;
		
				#chop($current_playlist);

				my $command = qq(
			        tell application "iTunes"
			        	set myPlaylists to (name of every playlist)
			        end tell
			        set msg to "" as Unicode text
			        repeat with something in myPlaylists
			        	set msg to msg & something & "|"
			        end repeat
			        return msg
				);

				my $playlist_return = qx(osascript -e '$command');

				$playlist_return =~ s/\n//g;
				$playlist_return =~ s/\t/ \- /g;

				my @playlist_results = split(/\|/,$playlist_return);

				$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "List of current platlists: ");
	
				my $add_string;

				foreach my $playlist (@playlist_results)
				{  

					if ($playlist ne "" || $playlist ne "\n"|| $playlist ne "\r\n" || $playlist ne " ")
					{
					   if ($current_playlist eq $playlist)
						{
							$add_string = "* Current Playlist";
						} else {
							$add_string = "";
						}
						$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "'$playlist'" , "      $add_string");
					}
				}
			}
		} elsif($what eq "stats") {

			##|Where is this track being played?
			my $command = qq(
			tell application "iTunes"
				set myLocation to location of current track
				if myLocation is missing value then
					set myLocation to iPod
				end if
			end tell
			return myLocation
			);

			my $location = qx(osascript -e '$command');
			$location =~ s/\n//g;
			$location =~ s/\t/ \- /g;

			my $command = qq(
			     tell application "iTunes"
			     	set myPlaylist to (name of current playlist)
			     end tell
			     return myPlaylist
			);

			my $current_playlist = qx(osascript -e '$command');
			$current_playlist =~ s/\n//g;
			$current_playlist =~ s/\t/ \- /g;


			if ($location ne "iPod")
			{

				if ($current_playlist ne "Library")
				{
		
					my $command = qq(
					tell application "iTunes"
						set lib to user playlist "$current_playlist"
						set libName to name of user playlist "$current_playlist"
			
						if size of lib < 1.0E+9 then
							set my_size to (round (size of lib) / 1024 / 1024 * 100 as string) / 100 & " MB"
						else
							set my_size to ((round (size of lib) / 1024 / 1024 / 1024 * 100) / 100 as string) & " GB"
						end if
						set my_time to time of lib
						set my_count to (count tracks in lib)
					end tell
					return libName & tab & my_time & tab & my_count & tab & my_size
					);

					my $playlist_return = qx(osascript -e '$command');
					$playlist_return =~ s/\n//g;

					my ($libName,$mytime,$songs,$size) = split(/\t/,$playlist_return);
					$songs = add_commas($songs);
					
					if ($playlist_string ne "me")
					{
						my $my_string = "'s iTunes Playlist \"$libName\" is $mytime long, with $songs songs totaling $size";
						$witem->command("/ME $my_string");
					
					} else {
						my $my_string = "your iTunes Playlist \"$libName\" is $mytime long, with $songs songs totaling $size";
						$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "$my_string");
					
					}
					
				} else {
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "You Are Currently In Your Main Library.");
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "To View Your Main Library Stats type: /itunes stats");
				}

			} else {

				my $command = qq(
				tell application "iTunes"
					set theSources to kind of sources
					repeat with i from 1 to the count of sources
						if the kind of source i is iPod then
							set theSource to the name of source i as text
						end if
					end repeat
					set currentPlaylist to name of current playlist
					--return currentPlaylist
					if currentPlaylist is equal to theSource then
						return "iPod Library"
					else
						set lib to user playlist "$current_playlist" of source theSource
						set libName to name of user playlist "$current_playlist" of source theSource
						if size of lib < 1.0E+9 then
							set my_size to (round (size of lib) / 1024 / 1024 * 100 as string) / 100 & " MB"
						else
							set my_size to ((round (size of lib) / 1024 / 1024 / 1024 * 100) / 100 as string) & " GB"
						end if
						set my_time to time of lib
						set my_count to (count tracks in lib)
					end if
					
				end tell
				return libName & tab & my_time & tab & my_count & tab & my_size
				);

				my $playlist_return = qx(osascript -e '$command');
				$playlist_return =~ s/\n//g;

				my ($libName,$mytime,$songs,$size) = split(/\t/,$playlist_return);
				
				if ($libName ne "iPod Library")
				{
					$songs = add_commas($songs);
					
					if ($playlist_string ne "me")
					{
						my $my_string = "'s iPod Playlist \"$libName\" is $mytime long, with $songs songs totaling $size";
						$witem->command("/ME $my_string");
					} else {
					
						my $my_string = "your iPod Playlist \"$libName\" is $mytime long, with $songs songs totaling $size";
						$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "$my_string");
					}
	
				} else {
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "You Are Currently In Your Main Library of your iPod.");
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "To View Your Main iPod Stats type: /itunes stats ipod");
				}
			}
		} elsif($what eq "change") {
			##| Need to change to that specific Playlist
			my ($text_playlist,$what,$ipod_string) = split(/\s/,$data);
			my ($junk,$playlist_string) = split(/\"/,$data);

			lc($ipod_string);
			if ($ipod_string eq "ipod")
			{
				
				my $ipod = &ipod_check;
			
				if ($ipod ne "")
				{
					$playlist_string =~ s/\"//g;

					my $command = qq(
					tell application "iTunes"
						repeat with i from 1 to the count of sources
							if the kind of source i is iPod then
								set theSource to the name of source i as text
							end if
						end repeat
						set msg to ""
						tell source theSource
							set thePlaylist to playlist "$playlist_string"
							play first track of thePlaylist
						end tell
					end tell
					$get_track
					);

					my $current_playlist = qx(osascript -e '$command');

					$current_playlist =~ s/\n//g;
					$current_playlist =~ s/\t/ \- /g;
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', $current_playlist);			
				} else {
					$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_header', "No iPod Connected.");
				}
			
			} else {
				$playlist_string =~ s/\"//g;
		
				my $command = qq(
					tell application "iTunes"
					set thePlaylist to playlist "$playlist_string"
					play first track of thePlaylist
				end tell
				$get_track
				);
		
				my $current_playlist = qx(osascript -e '$command');
		
				$current_playlist =~ s/\n//g;
				$current_playlist =~ s/\t/ \- /g;
				$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', $current_playlist);
			}
		}
		
	}
}

sub play_track
{
	my ($text_play,$text_track,$track_id) = split(/\s/,$data);

	my $command = qq(
		set track_id to $track_id as integer
		tell application "iTunes"
			play (first track of library playlist 1 whose database ID is track_id)
		end tell
	);
	my $track = qx(osascript -e '$command');
	if ($witem)
	{
		$track = qx(osascript -e '$get_track');
		$track =~ s/\n//g;
		$track =~ s/\t/ \- /g;
		$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "Now Playing: $track");
	}
}

sub event_privmsg 
{
	my ($server, $data, $nick, $address) = @_;
	my ($target, $text) = split(/ :/, $data, 2);
	my $line = "";
	$text = lc("$text");

	if (Irssi::settings_get_str($IRSSI{'name'} . '_reply') =~ /yes/i)
	{
		if ($text eq '!itunes')
		{
			##| Check To See If iTunes is currently running
			my $command = qq(
				try 
					tell application "System Events" 
						set iTunesRunning to ((application processes whose name is equal to "iTunes") count) is greater than 0
					end tell 
					return iTunesRunning
				end try 
			);
		
			my $temp = qx(osascript -e '$command');
			$temp =~ s/\n//g;

			if ($temp eq "true")
			{
				$command = qq(
					tell application "iTunes.app"
						set iTunesStatus to player state
						set this_name to the name of current track
						set this_artist to the artist of current track
						set this_album to the album of current track
						set this_rating to the rating of current track
						set this_length to the time of current track
						set this_stream to the current stream title
					end tell
					return this_name & tab & this_artist & tab & this_rating & tab & this_length & tab & this_album & tab & iTunesStatus & tab & this_stream
				);

				$temp = qx(osascript -e '$command');
				$temp =~ s/\n//g;
			}

			$temp =~ s/\tmissing value\t/\t\t/g;	
			$temp =~ s/\tmissing value$/\t/g;
			my ($track,$player,$rate,$duration, $album, $status, $stream) = split(/\t/,$temp);

			if ($track eq "" || $track eq "false" || $status eq "stopped")
			{
				#print "$nick requested our iTunes info, but you did not reply."; # Uncomment this line to have the script show you when someone requests your track info.
				#$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "$nick requested our iTunes info, but you did not reply."); # Uncomment this line to have the script show you when someone requests your track info.
				return 1;
		
			} else {
				#print "$nick requested our iTunes info"; # Uncomment this line to have the script show you when someone requests your track info.
				#$witem->printformat(MSGLEVEL_CLIENTCRAP, 'itunes_format', "$nick requested our iTunes info"); # Uncomment this line to have the script show you when someone requests your track info.
				if ($stream !~ /^\s*$/) 
				{
					$line = 'I\'m Currently listening to "<stream>" on the Stream "<track>"';
					$line  =~ s/<track>/$track/gi;
					$line  =~ s/<stream>/$stream/gi;
				} else {
		
					$line = 'I\'m currently listening to "<track>" by "<player>" from the album "<album>" [<duration>]';
					$line  =~ s/<track>/$track/gi;
					$line  =~ s/<player>/$player/gi;
					$line  =~ s/<album>/$album/gi;
					$line  =~ s/<duration>/$duration/gi;
				}

				if (Irssi::settings_get_str($IRSSI{'name'} . '_reply_type') =~ /notice/i)
				{
					$server->command("/NOTICE $nick $line");
				} else {
					$server->command("/MSG $nick $line");
				}
			
				
				return 1;

			}
			
		}
	}	
}

Irssi::signal_add("event privmsg", "event_privmsg");

sub add_commas
{
   my ($text)=@_;
   $text=reverse $text;
   $text=~s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
   $text=scalar reverse $text;
   return $text;
}

sub ipod_check
{
	my $check = qq(
	set theSource to ""
	tell application "iTunes.app"
		repeat with i from 1 to the count of sources
			if the kind of source i is iPod then
				set theSource to the name of source i as text
			end if
		end repeat
	end tell
	return theSource
	);			

	my $ipod = qx(osascript -e '$check');
	$ipod =~ s/\n//g;

	return $ipod;

}