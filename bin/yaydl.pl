#!/usr/bin/perl
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#***********************************************************************
#		If you receive an error like
#		"user@host ~ $ Can't locate XYZ.pm in @INC (@INC contains:)..."
#		you'll have to install the appropriate perl modules
#		On debian-based systems, you'll need to install 
#		the following packages:
#			libwww-perl
#			libgetopt-long-descriptive-perl
#			libmp3-info-perl
#			libterm-progressbar-perl
#
#		Alternative:  use "perl -MCPAN -e shell"...
#***********************************************************************
#		vim-settings:
#			set tabstop=4
#			set shiftwidth=4
#***********************************************************************

use strict;
use warnings;
use Getopt::Long;
use LWP::UserAgent;
use MP3::Info;
use Term::ProgressBar;
use FileHandle;
use File::Basename;
use Data::Dumper;
use URI::Escape;

Getopt::Long::Configure ("bundling", "gnu_compat");
STDOUT->autoflush;
$SIG{INT} = \&catcher;		#Catch Ctrl-C and exit

#********************************************************************
#Replace this with your desired download location or use the --path parameter
my $videopath = "/my/videopath/";
#*********************************************************************

my %INFO = (
	authors => "Haui",
	contact => "haui45\@web.de",
	date	=> "2009-08-03",
	version => "v1.3.5",
	license => "GPL",
	name	=> "yaydl - yet another youtube downloader",
);
my @supported_sites = qw(youtube myvideo clipfish metacafe vimeo video.google dailymotion sevenload);

my $ua;				#LWP user agent
my $filehandle ;	#filehandle for syswrite
my $currentsize = 0;# stuff
my $bit = 0;		# for
my $percent = 0;	# the
my $progress;		# progressbar
my $sigint = 0;		

#every link gets its own hash entry - the following ones are available:
#$urls{$link}{'link'} = $ARGV[x] 
#$urls{$link}{'download'} = downloadlink for the video
#$urls{$link}{'path'} = downloadpath
#$urls{$link}{'title'} = website "<title>"
#$urls{$link}{'encode'} = filename after the encoding-process
#$urls{$link}{'sound'} = filename after the ripping-process (sound)
#$urls{$link}{'error'} = contains the latest errormessage for $link
#$urls{$link}{'lasturl'} = used to discover redirections on video.google.com
#$urls{$base}{'ismp4'} = indicates that a file is a mp4 file, currently only set by video_youtube()
#							an video_dailymotion()
my %urls;

#commandline options...
my %options = (
	rename	=> '0',
	help	=> '0',
	sound	=> '0',
	version	=> '0',
	encode	=> '0',
	print	=> '0',
	tag		=> '0',
	quiet	=> '0',
	stdin	=> '0',
	forceflv =>'0',
	title 	=> '0',
	keep	=> '0',
	debug	=> '0',
	debugall =>'0',
);

sub catcher() {
	$sigint = 1;
	close $filehandle if (defined $filehandle);
	die "SIGINT recieved....exiting\n";
}

#removes the extension of a given argument
#returns the argument without extension ;)
# foo.bar returns foo
# .foobar returns .foobar
sub removeextension($) {
	my $arg = shift;
	my $copy = $arg;
	if($arg !~ m#\.#){
		# $arg doesn't contain an extension, i.e. foobar
		return $arg;
	}
	if(scalar(grep(/\./,split(//,$arg))) == 1 && $arg =~ m#^\.#){
		#$arg doesn't contain a valid extension, i.e. if $arg =  .foobar
		return $arg;
	}
	$arg =~ s#\.[^.]*$##;
	return $copy if ($arg=~m#^\.$# or $arg=~m#^\.\.$#);
	return $arg;
}

sub checkargs {
	#parse the commadline options
	GetOptions ("rename|r" => \$options{'rename'}, 
				"help|h" => \$options{'help'},
				"sound|s" => \$options{'sound'}, 
				"version|v" => \$options{'version'}, 
				"encode|e" => \$options{'encode'},
			   	"print|n" => \$options{'print'},
				"tag|t"=>\$options{'tag'},
				"path|p=s" => \$videopath,
				"stdin|x" => \$options{'stdin'},
				"quiet|q"=>\$options{'quiet'},
				"forceflv|f"=> \$options{'forceflv'},
				"title|i"	=> \$options{'title'},
				"keep|k"	=> \$options{'keep'},
				"debug|d"	=> \$options{'debug'},
				"debug-all|a"	=> \$options{'debugall'},

				) or die "Check your command-line!";
	if ($options{'version'} == 1){
		version();
		exit 0;
	}
	if ($options{'help'} == 1){
		help();
		exit 0;
	}	
	if($options{'tag'}){
		$options{'sound'} = 1;
	}
	if ($options{'stdin'} == 1){
		$options{'quiet'} = 1;
		$options{'rename'} = 0;
		$options{'tag'} = 0;
		readurls();
	}

	if ($#ARGV +1 == 0){
		warn "No URL specified\n";
		exit;
	}
	if ($videopath =~ m#/my\/videopath/# or $videopath eq ""){
		$videopath = $ENV{"HOME"} || 
			die "Please set a proper videopath!\n";
	}
	$videopath .= "/" unless ($videopath =~ m#/$#);
	if (! -e $videopath){
		die "Videopath doesn't exist!\n";
	}
	if (! -w $videopath){
		die "You don't have write permissions for $videopath!\n";
	}
#print "@{[ %options ]}\n";
}

sub readurls {
	print "Insert one link per line:\n";
	foreach my $arg (<STDIN>){
		chomp $arg;
		$arg =~ s#\s+##g; #remove all whitespaces
		next if ($arg =~ m#^$#);
		push @ARGV, $arg;
	}
}

#Replacement for the `which`-systemcalls..
#we don't need an extra perl module for this ;-)
#returns 0 on success
#		 1 else
sub which($) {
	my $programname = shift;
	my $path = $ENV{'PATH'} or return 1;
	my @paths = split(/:/, $path);
	foreach $path (@paths){
		$path .= "/$programname";
		if (-e $path){
			return 0;
		}
	}
	return 1;
}
#Extracts the <title> information from the html source stored in @_
#and returns a valid filename (max 100 chars), with all non-\w-characters replaced 
#by a underscore or "no_title_tag_found_" . time() on errors
#Html::Parser would be a better solution, but it's another module, which would bloat 
#the sourcecode even more
sub gettitle(@) {
	my @title = grep /<title>.+<\/title>/, @_;
	if (! (scalar @title)){
			return "no_title_tag_found" . time();
	}
	$title[0] =~ s#.*<title>(.+)</title>.*#$1#;
	$title[0] =~ s#[^\w]+#_#g;
	$title[0] =~ tr/[A-Z]/[a-z]/;
	return substr($title[0], 0, 100);	
}

#prints $urls{$base}{'error'} to stderr and additionally dumps
#$urls{$base} if --debug is defined
sub raise_error($) {
	my $base = shift;
	print STDERR "An Error occurred while processing $base " .
			"- see the following error message for further information:\n"; 
	print STDERR "\t" . $urls{$base}{'error'};
	print STDERR "\nIf you believe, the error was caused by this script, then rerun yaydl with the " .
					"--debug parameter and send a bugreport to haui45\@web.de\nDon't forget to ".
					"include the dumped debugging output!\n";
	if ($options{'debug'}){
		print STDERR "---BEGIN DEBUG INFO---\nMailto: $INFO{'contact'}\n";
		print Dumper($urls{$base});
		print STDERR "---END DEBUG INFO---\n";
	}
}

# calls the methods for the given urls
sub choose(){
	my ($dec, $retval, $stars);
	$stars = "[***************]";
	if ( ! $options{'quiet'}){
		print "\nImportant notice: All links must be quoted correctly ->" . 
		" \"http://www.youtube.com...\"\n";
		print "Type \"y\" to proceed\n";
		print "[y/n]\n";
		$dec = <STDIN>;
		chomp $dec;
		unless ($dec =~ m/^y(es)?$/i){
			warn "Quitting...\n";
			exit 1;
		}
	}
	$ua = LWP::UserAgent->new();
	$ua->agent('Mozilla/5.0');
	foreach my $link (@ARGV){
		last if ($sigint == 1);
		print "---\n";
		$urls{$link}{'link'} = $link;
		if ($link =~ m#^(http://)?(\w+\.)?youtube\.com/#){
			$retval = video_youtube($link);
		}
		elsif ($link =~ m#^http://(www\.)?myvideo\.de\/watch#){
			$retval = video_myvideo($link);
		}
		elsif (($link =~ m#^(http://)?(www\.)?clipfish\.de/#)){
			 $retval = video_clipfish($link);
		}
		elsif (($link =~ m#^(http://)?(www\.)?metacafe.com/watch/.*#)){
			 $retval = video_metacafe($link);
		}
		elsif (($link =~ m#^(http://)?(www.)?vimeo.com/#)){
			 $retval = video_vimeo($link);
		}
		elsif (($link =~ m#^(http://)?(www\.)?video\.google\.(de|com)/#)){
			 $retval = video_google($link);
		}
		elsif (($link =~ m#^(http://)?(www\.)?dailymotion\.com/#)){
			 $retval = video_dailymotion($link);
		}
		elsif (($link =~ m#^(http://)?(\w+\.)?sevenload\.com/#)){
			 $retval = video_sevenload($link);
		}
		else{
			warn "$link: Not a valid Link!\n";
			print Dumper($urls{$link}) if ($options{'debugall'});
			delete $urls{$link};
			next;
		}
		if ($retval != 0){
			raise_error($link);
			print Dumper($urls{$link}) if ($options{'debugall'} && !$options{'debug'});
			delete $urls{$link};
			next;
		}
		#just print the downloadlink...
		if($options{'print'}){
			print "Downloadlink: ".  $urls{$link}{'download'} . "\n";
			print Dumper($urls{$link}) if ($options{'debugall'});
			delete $urls{$link};
			next;
		}

		print "Download in progress - this may take a while\n";
		if (download($link) != 0){
			raise_error($link);
			print Dumper($urls{$link}) if ($options{'debugall'} && !$options{'debug'});
			delete $urls{$link};
			next;
		}
		print "\nSaved file $stars $urls{$link}{'path'} $stars\n\n";

		if($options{'encode'} == 1){
			if (encode($link) != 0){
				raise_error($link);
			}
			else{
				print "\n$stars Encoded file $urls{$link}{'encode'} $stars\n\n";
			}
		}
		if($options{'sound'} == 1){
			if (sound($link) != 0){
				raise_error($link);
			}
			else{
				print "\n$stars Encoded file $urls{$link}{'sound'} $stars\n\n" ;
				if ($options{'tag'}){
					if(tag($link)){
						raise_error($link);
					}
					else{
						print "\n$stars Successfully tagged $urls{$link}{'sound'} $stars\n\n" ;

					}
				}
			}
		}
		if (($options{'sound'} == 1 || $options{'encode'} == 1) && ! $options{'keep'} ){
			#delete the original file if we encoded something
			unlink($urls{$link}{'path'});
		}
		if ($options{'rename'} || $options{'title'}){
			if(my_rename($link)){
				raise_error($link);
			}
		}
		print Dumper($urls{$link}) if ($options{'debugall'});
		delete $urls{$link};
	}
	print "---\n";
}

#returns 0 on success - the number of errors else
#sets $urls{$base}{'error'} if an error occurrs!
sub my_rename {
	my $base = shift;
	my $retval = 0;
	my $newname;
	$urls{$base}{'error'} = "";
	print "Pleas notice, that\na.) you *can't* change the actual location of the renamed " .
	"files by passing a full path and\nb.) this script will remove the file extension" .
   	"from avi/mp3 files and replace it with the appropriate one and\n" .
	"c.) empty filenames will be replaced by the current unix time!\n"
				if(! $options{'title'})	;

	if($options{'encode'}){
		$newname = $videopath . $urls{$base}{'title'} . ".avi";
		$newname = $videopath . removeextension(get_stdin($urls{$base}{'encode'})) . ".avi" if (! $options{'title'});
		if (! rename($urls{$base}{'encode'}, $newname)){
			$urls{$base}{'error'} .= "Couldn't rename $urls{$base}{'encode'} -> $newname\n";
			$retval++;
		}
		else{
			print "Renamed $urls{$base}{'encode'} -> $newname\n";
			$urls{$base}{'encode'} = $newname;
		}
	}
	if($options{'sound'}){
		$newname = $videopath . $urls{$base}{'title'} . ".mp3";
		$newname = $videopath . removeextension(get_stdin($urls{$base}{'sound'})) . ".mp3" if (! $options{'title'});
		if (! rename($urls{$base}{'sound'}, $newname)){
			$urls{$base}{'error'} .= "Couldn't rename $urls{$base}{'sound'} -> $newname\n";
			$retval++;
		}
		else{
			print "Renamed $urls{$base}{'sound'} -> $newname\n";
			$urls{$base}{'sound'} = $newname;
		}
	}
	if( (! $options{'sound'} && ! $options{'encode'}) || $options{'keep'}){
		$newname = $videopath . $urls{$base}{'title'} . ".flv";
		$newname = $videopath . get_stdin($urls{$base}{'path'}) if (! $options{'title'});
		if (! rename($urls{$base}{'path'}, $newname)){
			$urls{$base}{'error'} .= "Couldn't rename $urls{$base}{'path'} -> $newname\n";
			$retval++;
		}
		else{
			print "Renamed $urls{$base}{'path'} -> $newname\n";
			$urls{$base}{'path'} = $newname;
		}
	}
	return $retval;
}
#reads a filename from stdin and removes the basename
#of the filename without the extension
#or the current unix time if no filename was entered
sub get_stdin($) {
	my $originalname = shift;
	print "\nEnter a new filename for $originalname\n";
	my $name = <STDIN>;
	chomp($name);
	$name = time() if ($name eq "");
	return basename($name);
}

#returns0 on success
#sets $urls{$base}{'error'} if an error occurrs!
sub download($) {
	my $base = shift;
	print "Downloalink: " . $urls{$base}{'download'} . "\n";
	print "File: " . $urls{$base}{'path'} . "\n";
	my ($request, $response);
	my $chunksize=1024;
	my $filesize=0;
	$percent = 0;
	$currentsize = 0;
	$bit = 0;
	undef $progress;
	undef $filehandle;

	$request = HTTP::Request->new('HEAD', $urls{$base}{'download'});
	$response = $ua->request($request);
	#HEAD response ok, i.e. we do have the filesize!
	if ($response->is_success()){
		if (int($response->header('Content-Length')) == 0){
			$urls{$base}{'error'} = "Filesize 0 byte....stopping method!\n\n";
			return -1;
		}
		print "Filesize: " . int($response->header('Content-Length')/1024)."kb\n";
		$filesize=$response->header('Content-Length');
	}
	#HEAD failed
	else{
		#try simple download
		warn "!!!\nFallback to simple download - the progressbar doesn't work in this mode!\n!!!\n";
		$request = HTTP::Request->new('GET', $urls{$base}{'download'});
		$response = $ua->request($request, $urls{$base}{'path'});
		if ($response->is_success()){
			return 0;
		}
		$urls{$base}{'error'} = "Error code   : " .  $response->code() .  "\n" .
		 	 "Error message:  " .  $response->message() . "\n";
		return -1;
	}
	$bit = int ($response->header('Content-Length')/100); 
	$request = HTTP::Request->new('GET', $urls{$base}{'download'});
	open $filehandle, '>', $urls{$base}{'path'} or return -1;
	$progress = Term::ProgressBar->new (100);
	$response = $ua->request($request, \&callback, $chunksize);

	if ( $response->is_error() ) {
		$urls{$base}{'error'} =  "Error code    : " .  $response->code() . "\n" .
			"Error message:  " . $response->message() . "\n";
		return 1;
	}
	close $filehandle;	
	print "\n";

	return 0;
}

#handles the progressbar and the filewriting process
#don't mess with this...
sub callback($) {
	my $data = shift;
	my $length = length $data;
	$currentsize += $length;
	if($currentsize >= $percent*$bit){
		$percent++;
		$progress->update ($percent-1);
	}
	syswrite $filehandle, $data, $length; 
}

#requires 2 arguments: the site to download and the $base-link!
#sets $urls{$base}{'error'} if an error occurrs!
sub getpage($$) {
	my $link = shift;
	my $base = shift;

	my @site_content;
	my $request = HTTP::Request->new('GET', $link);
	my $response = $ua->request($request);
	print "Retrieving http-page...\n";
	if ( $response->is_error() ) { 
		$urls{$base}{'error'} =  "Error code    : ". $response->code() . "\n" .
			"Error message:  " .  $response->message() . "\n";
		return ();
	}
	else {
		#print Dumper($response);
		@site_content = split /\n/,  $response->content();
		$urls{$base}{'lasturl'} = $response->request->uri;
		return @site_content;
	}
}

#returns 0 on success
#		-1 else
#sets $urls{$base}{'error'} if an error occurrs!
#ffmpeg or mencoder are required in order to encode the videos to avi
#ffmpeg is preferred
sub encode($){
	my $base = shift;
	my $source = $urls{$base}{'path'};
	my $encode = removeextension($source) . ".avi";
	$urls{$base}{'encode'} = $encode;
	my $ffmpeg = which "ffmpeg";
	my $mencoder = which "mencoder";
	my @commands;
	my $return;
	if(! $ffmpeg){
		push (@commands, "ffmpeg -i \"$source\" \"$encode\"");
		print "ffmpeg: found\n";
	}
	if (! $mencoder){
		push(@commands, "mencoder \"$source\" -oac mp3lame -lameopts abr:br=92" .
			" -ovc xvid -xvidencopts bitrate=150 -o \"$encode\"");
		print "mencoder: found\n";
	}
	if($ffmpeg && $mencoder){
		$options{'encode'} = 0;
		$urls{$base}{'error'} = 
					 "mencoder: not found!\nffmpeg: not found!\nencoding disabled\n";
		return -1;
	}
	foreach my $command(@commands){
		$return = system($command);
		if ($return == 0){
			print "success\n";
			last;
		}
	}
	if ($return != 0){
		$options{'encode'} = 0;
		$urls{$base}{'error'} =  "error - encoding disabled\n";
		return -1;
	}

	return 0;
}

#returns 0 on success
#		-1 else
#sets $urls{$base}{'error'} if an error occurrs!
sub sound($) {
	my $base = shift;
	my $source = $urls{$base}{'path'};
	my $return = 0;
	my $encode = removeextension($source) . ".mp3";
	my $wavfile = removeextension($source) . ".wav";
	$urls{$base}{'sound'} = $encode;
	my $ffmpeg = which "ffmpeg";
	my $mplayer = which "mplayer";
	my $lame = which "lame";
	if ($mplayer && $ffmpeg){
		$options{'sound'} = 0;
		$urls{$base}{'error'} = "ffmpeg and mplayer not found - encoding disabled";
		return -1;
	}
	#ffmpeg preferred for mp4 videos from youtube/dailymotion
	#however, a combination of mplayer and lame will work as well
	if(defined $urls{$base}{'ismp4'}){
		if ($ffmpeg == 0){
			$return = system("ffmpeg -i \"$source\" -vn -acodec libmp3lame -ab 192k \"$encode\"");
		}
		elsif(($return || $ffmpeg) && (! $mplayer && ! $lame)) {
			$return = system("mplayer -vo null -ao pcm:file=\"$wavfile\" \"$source\"");
			$return = system("lame -b 192kbps \"$wavfile\" \"$encode\"");
			unlink($wavfile);
		}
		else {
			$urls{$base}{'error'} = "ffmpeg or mplayer *and* lame are required in order to encode mp4 videos!\n";
			return -1
		}
	}
	#not mp4, i.e. flv format, try mplayer as default because it's faster or ffmpeg if this fails
	else {
		if ($mplayer == 0 ){
			$return = system("mplayer -dumpaudio -dumpfile \"$encode\" \"$source\"");
		}
		elsif ($ffmpeg == 0 && ($return || $mplayer)){
			$return = system("ffmpeg -i \"$source\" -vn -acodec libmp3lame -ab 192k \"$encode\"");
		}
	}	
	if ($return != 0){
		$options{'sound'} = 0;
		$options{'tag'} = 0;
		$urls{$base}{'error'} = "ripping error - sound-encoding/tagging disabled\n";
		return -1;
	}
	return 0;
}


#returns 0 on succes, a number != 0 else
#sets $urls{$base}{'error'} if an error occurrs!
sub tag($){
	my $base = shift;
	eval {
		print "Please enter the new song information below:\n";
		print "Enter new title: ";
		my $title = <STDIN>;
		print "Enter new artist: ";
		my $artist = <STDIN>;
		print "Enter new album: ";
		my $album = <STDIN>;
		chomp($title, $artist, $album);
		my $mp3 = new MP3::Info $urls{$base}{'sound'};
		$mp3->title($title);
		$mp3->artist($artist);
		$mp3->album($album);
		return 0;
	};
	if($@){
		$urls{$base}{'error'} = "tagging error - tagging disabled\n";
		$options{'tag'} = 0;
		return 1;
	}
}


sub help {
	print "Usage: yaydl  [-esrtpnqxfikdahv] \"link1\" \"link2\" ...\n".

	"\nImportant notice: all links must be quoted correctly!\n".
	"In order to get the full functionality you either need ffmpeg *or*\n" .
    "mplayer *and* mencoder *and* lame.\n" .	
	"Parameters:\n".
	"   -e, --encode \t Encode the videos from *.flv to *.avi.\n". 
	"    \t\t\t Uses ffmpeg as default encoder, or mencoder if ffmpeg is not available\n".
	"    \t\t\t yaydl -e \"http://youtube...\"\n".
	"   -s, --sound\t\t Extract the soundtracks from all downloaded videos.\n".
	"    \t\t\t Uses mplayer as default encoder for flv files, or ffmpeg if mplayer is not available.\n".
	"    \t\t\t In order to encode non-flv files (mp4) you either need ffmpeg (recommended) or\n" .
    "	 \t\t a combination of mplayer and lame.\n" . 	
	"    \t\t\t yaydl -s \"http://youtube...\"\n".
	"   -r, --rename \t Rename the downloaded/encoded files\n" .
	"   -t, --tag\t\t Provides a basic way for tagging the extracted sound files (activates --sound)\n" .
	"   -p, --path PATH \t Change the default download path to PATH\n" . 
	"   -n  --print \t\t Display the downloadlinks and exit\n" . 
	"   -q, --quiet\t\t Don't wait for the user's confirmation\n".
	"   -x  --stdin\t\t Read URLs from STDIN (activates --quiet and deactivates --rename/tag)\n".
	"   -f, --forceflv\t Choose flv over HD (youtube/dailymotion only)\n" .
	"   -i, --title\t\t Rename the videos according to the website's title (overrides --rename)\n".
	"   -k, --keep\t\t Never delete the downloaded files\n" . 
	"   -d, --debug\t\t Dumps additional debugging information on errors\n" .
	"   -a  --debug-all\t Always dump the debugging infos - you should never use this one\n" . 
	"   -h, --help   \t Show this help.\n".
	"   -v, --version \t Prints the version and a list of all supported videosites.\n";

	return 0;
}
sub version() {
	print "yaydl - yet another youtube downloader \nversion $INFO{'version'}".
   		"	- $INFO{'date'}\n". 
		"Author: $INFO{'authors'}, contact $INFO{'contact'}\n" .
		"This script support the following \"videotubes\":\n";
		foreach my $site(@supported_sites){
			print "\t[*] $site\n";
		}
	
	return 0;
}

#====================================================================
# all subroutines for the different websites return 0 on success	=
# and a number > 0 if an error occurred:							=
# \@arg: the $base-link to access the hash entries					=
# Some basic rules:													=
#	*Store the filepath for the download in $urls{$base}{'path'}	=
#	*Store the downloadlink in $urls{$base}{'download'}				=
#	*Don't forget to store the title in $urls{$base}{'title'}		=
#	*NEVER EVER modify $base i.e. always keep an unmodified copy	=
# If an error occurrs:												=
#	*If needed, store the error message in $urls{$base}{'error'}	=
#	*return a number != 0											=
#====================================================================

################
#   youtube    #
################
sub video_youtube($) {
	my $url = shift;
	my $base = $url; #required to access the hash-pair
	my @site_content;
	my $youtube_get_video = "http://youtube.com/get_video?video_id="; 

	$url =~ s#^.*youtube#http://www.youtube#;

	if (! (@site_content = getpage($url, $base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);
	my @hires = grep /var isHDAvailable/, @site_content;
	my @testme = grep (/^.*var swfArgs.*, "t": ".*",.*/, @site_content);

	unless(defined $testme[0]){
		$urls{$base}{'error'} = "Error: testme[0] undefined! Are you sure, " .
								"that this site contains a video?\n\n";
		return 2;
	}
	my $vidid =	my $id = $testme[0];
	
	$id =~ s/^.*, "t": "([^"]+)",.*/$1/; # get the "long" video id
	$vidid =~ s/.*"video_id": "([^"]+)",.*/$1/;	# get the short video id
	
	# concat the download-url 
	$urls{$base}{'download'} = $youtube_get_video . $vidid . "\&t=" . $id;	

	#add the fmt-codes to the download-url 
	#nothing 	= flv
	#fmt=18 	= h264 with AAC stereo
	#fmt=22 	= 1280 x 720, 30fps, 2000kbps video AVC, 232kbps audio AAC
	#note: most videos do not support fmt=22 yet
	if (! $options{'forceflv'}){
		$urls{$base}{'ismp4'} = 1;
		$urls{$base}{'path'} = $videopath . $vidid . ".mp4"; # build the downloadpath
		if($hires[0] =~ m#true#){
			$urls{$base}{'download'} .= "&fmt=22";
		}
		else{
			$urls{$base}{'download'} .= "&fmt=18";
		}
	}
	else {
		$urls{$base}{'path'} = $videopath . $vidid . ".flv"; # build the downloadpath
	}
	return 0;
}

################
#   google    #
################
sub video_google($) {
	my $url = shift;
	my $base = $url;
	my $copy = $url;
	my @site_content;	
	$url = "http://" . $url unless ($url =~ m#^http://#);
	if ($url =~ m#http://video.google.com/videosearch.*#){
		$urls{$base}{'error'} =  "This link seems to be a preview page. ".
						"Please select the right video and rerun yaydl!\n";
		return 1;
	}
	
	if (! (@site_content = getpage($url, $base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);
	$url =~ s#.*docid=([-\d\w]*)&?.*#$1#;
	$urls{$base}{'path'} = $videopath . $url . ".mp4";
	
	#test, if the video is embedded from an other site
	# => extract the original source an append it to our videolist -
	# maybe it's supported by this script :)
	my @external_source = grep(/document.getElementById\('external_page'\).src = '/, 
								@site_content);
	if (defined $external_source[0]){
		$external_source[0] =~ s#.*\('external_page'\)\.src = '(.*)';#$1#;
		#replace all occurrences of hexadecimal numbers like "\x3d"
		#with their corresponding ascii-symbol
		$external_source[0] =~ s#(\\x..)#chr(hex substr($1, 2, 2))#eg;
		$urls{$base}{'error'} =  "Well, not a real error, I just " .
								"enqueued $external_source[0] in your videolist\n" .
								"Maybe it's supported by this script\n";
		push @ARGV, $external_source[0];
		return 2;
	}
	#redirection handling
	if ($base ne $urls{$base}{'lasturl'}){
		push @ARGV, $urls{$base}{'lasturl'};
		$urls{$base}{'error'} =  "Well, not a real error, I just " .
								"enqueued $urls{$base}{'lasturl'} in your videolist\n" .
								"Maybe it's supported by this script\n";
		return 2;
	}

	my @testme = grep (/http:\/\/.+\.com\/videoplayback\?id=/, 
						@site_content);
	if (! defined($testme[0])){
		$urls{$base}{'error'} =  "google: Varibale testme[0] undefined\n";
		return 2;
	}
	$testme[0] =~ 
	s#.*http://([^>]+).*#http://$1#;
	$urls{$base}{'ismp4'} = 1;
	$urls{$base}{'download'} = $testme[0]; 
	return 0;
}


################
#    vimeo     #
################
sub video_vimeo($) {
	my $url = shift;
	my $base = $url;
	my @site_content;
	my $vidid;
	$url = "http://" . $url unless ($url =~ m#^http://#);
	if(! (@site_content = getpage($url, $base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);
	undef @site_content;

	#extract the first video-id and
	#download the page, that contains
	#the timestamp and the request_signature for the 
	#video
	$url =~ s#(http://)?(www\.)?vimeo.com/(\d*).*#$3#;
	$vidid = $url;	
	$urls{$base}{'path'} = $videopath . $url . ".mp4";
	$url = "http://vimeo.com/moogaloop/load/clip:" . $url;
	if (! (@site_content = getpage($url, $base))){
		return 1;
	}
	my $request_sig = (grep(/request_signature/, @site_content))[0];
	my $expires = (grep(/request_signature_expires/, @site_content))[0];
	if (! defined($request_sig) || ! defined($expires)){
		$urls{$base}{'error'} =  "vimeo: important variable undefined...stopping method\n\n";
		return 2;
	}
	$request_sig =~ s#.*<request_signature>(.*)</request_signature>.*#$1#s;
	$expires =~ s#.*<request_signature_expires>(.*)</request_signature_expires>.*#$1#s;
	$urls{$base}{'ismp4'} = 1;

	#that's is the downloadlink for the video :-)
	$urls{$base}{'download'} = "http://vimeo.com//moogaloop/play/clip:" . $vidid 
		. "/" . $request_sig . "/" . $expires . "/?q=sd";

	return 0;
}


################
#   clipfish   #
################
sub video_clipfish($) {
	my $url = shift;
	my $base = $url;
	my @site_content;
	my $server = "http://www.clipfish.de/video_n.php?p=0|DE&vid="; 
	$url = "http://" . $url unless ($url =~ m#^http://#);
	if (! (@site_content = getpage($url, $base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);
	#get the first videoid 
	my @array = grep /var video\s*=\s/, @site_content;
	unless (defined $array[0]){
		$urls{$base}{'error'} = 
			 "clipfish: array[0] undefined...maybe the site doesn't contain a video?\n\n";
		return 2;
	}
	#extract the first videoid
	$array[0] =~ s#^.*id:\s*(\d*) , .*#$1#;
	$server .= $array[0];
	undef @site_content;
	#we retrieve a second webpage, that contains
	#the downloadlink for the video
	if (! (@site_content = getpage($server, $base))){
		$urls{$base}{'error'} .= "\nclipfish: Error: failed to get the encrypted id!\n\n";
		return 1;
	}
	my $id = $site_content[0];
	$id =~ s#^.*http#http#;
	$id =~ s#flv.*#flv#;
	$urls{$base}{'download'} = $id;
	$urls{$base}{'path'} =  $videopath . $array[0] . ".flv";
	return 0;
}

################
#   metacafe   #
################
sub video_metacafe($){
	my $url = shift;
	my $base = $url;
	my $path = $url;
	my @site_content;
	$url = "http://" . $url unless ($url =~ m#^http://#);
	if (! (@site_content = getpage($url, $base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);
	my @ids = grep (/so\.addParam\("flashvars",/, @site_content);
	unless (defined $ids[0]){
		$urls{$base}{'error'} = "metacafe: grep failed!\n\n";
		return 2;
	}
	$path =~ s#(http://)?(www\.)?metacafe.com/watch/([^/]+)/?.*#$3#;
	##pure metacafe-video
	if ($path =~ m#^[0-9]+$#){
		#pretty ugly....
		$ids[0] =~ s#.*mediaURL=##;
		$ids[0] =~ s#&postRollContentURL.*##;
		$ids[0] =~ s#(%..)#chr(hex substr($1, 1, 2))#eg;
		$ids[0] =~ s#&#\?#g;
		$ids[0] =~ s#gdaKey#__gda__#;
		$urls{$base}{'path'} = $videopath . $path . ".flv";
		$urls{$base}{'download'} = $ids[0];
	}
	else { #video is embedded from another site
		my $vendorid = $path;
		$vendorid =~ s#^(..).+#$1#; #get the first 2 characters
		$path =~ s#...##; # delete the first three characters
		if ($vendorid =~ m/yt/){
			$vendorid = "http://youtube.com/watch?v=$path";
			push @ARGV, $vendorid;
			$urls{$base}{'error'} = "Well, not a real error - I just enqueued " .
									"the following url in you downloadlist:\n$vendorid\n";
			return 2;
		}
		else {
			$urls{$base}{'error'} =  "ID: \"$vendorid\"  not yet supported\n".
									"Please contact me and include" .
									" the following information: \n" . 
									"URL: $url\nID: $vendorid\nPath: $path\n";
			return 2;
		}
	}
	return 0;
}

################
#   myvideo    #
################
sub video_myvideo($){
	my $url = shift;
	my $base = $url;
	my @site_content;
	$url = "http://" . $url unless ($url =~ m#^http://#);

	if (! (@site_content = getpage($url, $base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);

	$url =~ s#(http://)?(www\.)?myvideo\.de/watch/([^/]+)/?.*#$3#;
	$urls{$base}{'path'} = $videopath . $url . ".flv";

	my @swfargs = grep /SWFObject\(/, @site_content;
	my @server = grep /<link rel='image_src' href='.*\.jpg.*><link/ , @site_content;
	unless (defined($swfargs[0]) && defined($server[0])) {
		$urls{$base}{'error'} =  "myvideo: variable swfargs/server undefined" .
									"...stopping method\n\n"; 
		return 2;
	}
	# extract the server-location from the link of an image- 
	#not very nice, but it works ;)
	$server[0] =~ s#.*link rel='image_src' href='##;
	$server[0] =~ s#thumbs/.*.jpg.*##;

	$swfargs[0] =~ s#.*p.addVariable\('_videoid','([^']+)'\).*#$1#;
	$urls{$base}{'download'} = $server[0] . $swfargs[0] . ".flv";
	return 0;
}

################
# dailymotion  #
################
sub video_dailymotion($){
	my $url = shift;
	my $base = $url;
	my @site_content;
	$url = "http://" . $url unless ($url =~ m#^http://#);
	if (! (@site_content = getpage($url,$base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);

	my @testme = grep /addVariable\("video"/, @site_content;
	if (! defined($testme[0])){
		$urls{$base}{'error'} = "dailymotion: testme[0] undefined\n";
		return 2;
	}
	$testme[0] =~ s#.*addVariable\("video",\s+"([^"]+)".*#$1#;
	$testme[0] = uri_unescape $testme[0];
	my @avail = split /\|\|/, $testme[0];
	foreach (@avail){
		$_ =~ s#@@.*##;
	}
	(my $key = $avail[0]) =~ s#.+key=##;
	$urls{$base}{'path'} = $videopath . "dm_" . $key;
	if (! $options{'forceflv'} && grep(/H264/, @avail) != 0){
		my $h264 = (grep(/H264/, @avail))[0];
		$urls{$base}{'download'} = $h264;	
		$urls{$base}{'ismp4'} = 1;
		$urls{$base}{'path'} .= ".mp4";
	}
	else {
		$urls{$base}{'download'} = $avail[0];
		$urls{$base}{'path'} .= ".flv";
	}
	return 0;
}

sub video_sevenload {
	my $url = shift;
	my $base = $url;
	my @site_content;
	$url = "http://" . $url unless ($url =~ m#^http://#);
	if (! (@site_content = getpage($url,$base))){
		return 1;
	}
	$urls{$base}{'title'} = gettitle(@site_content);
	my $str = join "", @site_content;
	if ($str !~ m#configPath=.+"#){
		$urls{$base}{'error'} = "sevenlaod: configPath not found..." .
			"are you sure the site contains a video?";
		return 2;
	}
	$str =~ s#.+configPath=([^"]+)".+#$1#;
	$str = uri_unescape($str);
	if (! (@site_content = getpage($str,$base))){
		return 1;
	}
	($str = join("", @site_content)) =~ s#.*<location seeking="yes">\s*([^<]+)\s*<.*#$1#;
	$urls{$base}{'download'} = $str;
	$urls{$base}{'path'} = $videopath . basename($str);
	return 0;	
}

checkargs();
choose();

