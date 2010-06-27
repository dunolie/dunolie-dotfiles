# (c) 2002 by Gerfried Fuchs <alfie@channel.debian.de>
# Changed in 2007 by Erik Gregg <ralree@gmail.com>

use Irssi qw(command_bind command signal_add_last signal_stop settings_get_bool settings_add_bool signal_add signal_add_first signal_emit);
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = '2.4.0';

%IRSSI = (
  'authors'     => 'Erik Gregg, Gerfried Fuchs',
  'contact'     => 'ralree@gmail.com, alfie@channel.debian.de',
  'name'        => 'Kenny Speech',
  'description' => 'Adds /kenny, /dekenny for encoding/decoding kennies. Also adds /kennyadd, /kennydel, and /kennylist for managing the nicks to autokenny.  Allows enabling of autokenny based on the setting autokenny.  Based on Jan-Pieter Cornets signature version',
  'license'     => 'BSD',
  'url'         => 'http://modzer0.cs.uaf.edu/repos/hank/code/perl/irssi/kenny.pl',
  'changed'     => '2007-03-29',
);

# Patched and Hacked by:  Erik Gregg <ralree@gmail.com>
# Maintainer & original Author:  Gerfried Fuchs <alfie@channel.debian.de>
# Based on signature kenny from: Jan-Pieter Cornet <johnpc@xs4all.nl>
# Autodekenny-suggestion:        BC-bd <bd@bc-bd.org>

# Sugguestions from darix: Add <$nick> to [kenny] line patch

# This script offers you /kenny and /dekenny which both do the kenny-filter
# magic on the argument you give it.  Despite it's name *both* do kenny/dekenny
# the argument; the difference is that /kenny writes it to the channel/query
# but /dekenny only to your screen.

# Version-History:
# ================
# 2.4.0 -- by Erik Gregg
#          Changed Autokenny
#          Added Kenny tracking
#
# 2.3.1 -- fixed autodekenny in channels for people != yourself
#
# 2.3.0 -- fixed kenny in querys
#          fixed dekenny in status window
#
# 2.2.3 -- fixed pattern matching for autokenny string ("\w" != "a-z" :/)
#
# 2.2.2 -- first version available to track history from...

# TODO List
# ... currently empty
my %kennies;
my $translate = 0;

sub KennyIt {
   ($_)=@_;my($p,$f);$p=3-2*/[^\W\dmpf_]/i;s.[a-z]{$p}.vec($f=join('',$p-1?chr(
   sub{$_[0]*9+$_[1]*3+$_[2] }->(map {/p|f/i+/f/i}split//,$&)+97):('m','p','f')
   [map{((ord$&)%32-1)/$_%3}(9, 3,1)]),5,1)='`'lt$&;$f.eig;return ($_);
};


sub cmd_kenny {
   my ($msg, undef, $channel) = @_;
   $channel->command("msg $channel->{'name'} ".KennyIt($msg));
};


sub cmd_dekenny {
   my ($msg, undef, $channel) = @_;

   if ($channel) {
      $channel->print('[kenny] '.KennyIt($msg), MSGLEVEL_CRAP);
   } else {
      Irssi::print('[kenny] '.KennyIt($msg), MSGLEVEL_CRAP);
   }
};

sub cmd_kennyadd {
  my $nick = $_[0];
  $kennies{$nick} = 1;
  Irssi::command("/echo $nick is now a Kenny.");
};

sub cmd_kennydel {
  my $nick = $_[0];
  delete $kennies{$nick};
  Irssi::command("/echo $nick is no longer a Kenny.");
};

sub cmd_kennylist {
  my $peepstring = join(", ", (keys %kennies));
  Irssi::command("/echo Current Kennies: $peepstring");
};

sub sig_kenny {
  my ($server, $data, $nick, $mask, $target) = @_;
  return unless(Irssi::settings_get_bool('autokenny'));
  return unless($kennies{$nick} == 1);
  my $result = KennyIt($data);
  signal_emit("message public", $server, $result,
       $nick."[Kenny]", $mask, $target);
  signal_stop();
};

command_bind('kenny',   'cmd_kenny');
command_bind('dekenny', 'cmd_dekenny');
command_bind('kennyadd', 'cmd_kennyadd');
command_bind('kennydel', 'cmd_kennydel');
command_bind('kennylist', 'cmd_kennylist');

signal_add_first("message public", "sig_kenny");
settings_add_bool('misc', 'autokenny', 1);
