# lastfm.pl -- last.fm now playing script for irssi
# Patroklos Argyroudis, argp at domain cs.tcd.ie
#
# This script polls the specified last.fm profile for the most recent
# audioscrobbled track every $timeout_seconds (default is 120).  The
# track is displayed in every channel specified in @channels or, if
# @channels is undefined, in the active window.  Start a new session
# with /lastfm start your_lastfm_username.

use strict;
use vars qw($VERSION %IRSSI);
use Irssi qw(command_bind active_win);
use LWP::UserAgent;
use utf8;

$VERSION = '0.2c';

# Changelog:
# 
# 0.2c (2006/11/08)
#   When a session is started while a previous one is active, the
#   old timeout handler is now removed.
# 0.2b (2006/11/02)
#   Initial public release.

%IRSSI =
(
 authors => 'Patroklos Argyroudis',
 contact => 'argp at domain cs.tcd.ie',
 name => 'last.fm now playing',
 description => 'displays the most recent audioscrobbled track',
 license => 'BSD',
 url => 'http://ntrg.cs.tcd.ie/~argp/software/attic/lastfm',
 changed => 'Wed Nov 8 12:25:26 IST 2006',
 commands => 'lastfm',
);

# be _very_ careful when changing this,
# too aggressive polling may get your IP blacklisted
my $timeout_seconds = 120;

my $timeout_flag;
my $username;
my $cached;

# if you want to display the track only in the active window
# remove the comment from the next line and comment the line
# after that, or specify the channels you want
# my @channels = undef;
my @channels = ("#gothic", "#industrial", "#neofolk");

sub show_help()
{
 my $help = "lastfm $VERSION
/lastfm start <username>
    start a last.fm now playing session
/lastfm stop
    stop the active last.fm now playing session";

 my $text = '';

 foreach(split(/\n/, $help))
 {
  $_ =~ s/^\/(.*)$/%9\/$1%9/;
  $text .= $_."\n";
 }

 Irssi::print("$text");
}

sub cmd_lastfm
{
 my ($argv, $server, $dest) = @_;
 my @arg = split(/ /, $argv);
 
 if($arg[0] eq "")
 {
  show_help();
 }
 elsif($arg[0] eq 'help')
 {
  show_help();
 }
 elsif($arg[0] eq 'stop')
 {
  if(defined($timeout_flag))
  {
   Irssi::timeout_remove($timeout_flag);
   $timeout_flag = undef;
   Irssi::print("last.fm now playing session ($username) stopped");
  }
 }
 elsif($arg[0] eq 'start')
 {
  if($arg[1] eq "")
  {
   show_help();
  }
  else
  {
   if(defined($timeout_flag))
   {
    Irssi::timeout_remove($timeout_flag);
    $timeout_flag = undef;
    Irssi::print("previous last.fm now playing session ($username) stopped");
   }

   $username = $arg[1];
   
   if($timeout_seconds)
   {
    $timeout_flag = Irssi::timeout_add(($timeout_seconds * 1000), "lastfm_poll", "");
   }

   Irssi::print("last.fm now playing session ($username) started");
  }
 }
}

sub lastfm_poll
{
 my $lfm_url = "http://ws.audioscrobbler.com/1.0/user/$username/recenttracks.txt";

 my $agent = LWP::UserAgent->new;
 $agent->agent('argp\'s last.fm irssi script');
 $agent->timeout(60);

 my $request = HTTP::Request->new(GET => $lfm_url);
 my $result = $agent->request($request);
 $result->is_success or return;

 my $str = $result->content;
 my @arr = split(/\n/, $str);
 my $new_track = '';
 $new_track = $arr[0];
 $new_track =~ s/^[0-9]*,//;
 $new_track =~ s/\xe2\x80\x93/-/;

 # I like my announcements in lowercase characters,
 # if you do too remove the comment
 # $new_track =~ tr/A-Z/a-z/;
 
 if($cached eq $new_track)
 {
  return;
 }
 else
 {
  if(defined($channels[0]))
  {
   foreach my $chan_name (@channels)
   {
    foreach my $chan (Irssi::channels())
    {
     if($chan_name eq $chan->{'name'})
     {
      $chan->window->command("/me np: $new_track");
     }
    }
   }
  }
  else
  {
   active_win->command("/me np: $new_track");
  }
  
  $cached = $new_track;
 }
}

Irssi::command_bind('lastfm', 'cmd_lastfm');
Irssi::print("last.fm now playing script v$VERSION, /lastfm help for help");
