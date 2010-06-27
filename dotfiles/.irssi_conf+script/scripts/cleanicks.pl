#!/usr/bin/perl
# created for irssi 0.8.6, Copyright (c) 2003 Guillaume SMET

# TODO
#
# - travailler avec des paramètres IRSSI -> en cours, mais lesquels? -> à voir à l'usage
# - retravailler cut_nick avec une regexp : done
# - filtrer les quit et les join, voire passer en param le level des messages à filtrer
# - filtrer les nicks lors du changement de nick même qd les cleanicks sont différents : ?
# - faire un hash pour les NICK_WARN_* et passer en param ?
#
# - documenter un peu le code
#
# - commande d'aide
# - commande qui affiche la configuration actuelle -> /set cleanicks
#

use strict;
use Irssi 20020324;
use Irssi::Irc;
use vars qw($VERSION %IRSSI);
$VERSION = "0.08";
%IRSSI   = (
    authors     => "Guillaume SMET, Mathieu DOIDY, Thomas ROUSSEL",
    contact     => "",
    name        => "Cleanicks",
    description => "Cut nicks when users bring their lives onto the channel (nick[eating]->nick[sleeping]->...) and redirect nick changes to wherever you want",
    license     => "GNU GPL v2",
    url         => "http://irssi.roulaize.net",
    changed     => "24/09/2003"
);

# ignore nick changes
use constant NICK_WARN_IGNORE => 'ignore';

# put nick changes in the cleanicks_window window without hl
use constant NICK_WARN_WINDOW_QUIET => 'window quiet';

# put nick changes in the cleanicks_window window with hl
use constant NICK_WARN_WINDOW => 'window';

# keep the standard behaviour
use constant NICK_WARN_KEEP => 'keep';

# this regexp is used to match (nick): foo bar
our $nickRegexp = '[^ :]*';

# separators used for the nicks
our $separatorRegexpClass = '\\\`_\[\]{}\-|';

# channels which cleanicks is active on
Irssi::settings_add_str( $IRSSI{name}, 'cleanicks_channels', '' );

# list of nicks pattern to replace, it should be a space separated string of pattern[>replacement]
Irssi::settings_add_str( $IRSSI{name}, 'cleanicks_nicks', '' );

# name of the window where nick changes are redirected to
Irssi::settings_add_str( $IRSSI{name}, 'cleanicks_window', 'changeNick' );

# nicks are not cut before min_length
Irssi::settings_add_int( $IRSSI{name}, 'cleanicks_min_length', 3 );

# avoid too long nickname, cutting them to max length
Irssi::settings_add_int( $IRSSI{name}, 'cleanicks_max_length', 14 );

# when turned on, only nick <-> nick* changes are filtered, when turned off, every change is filtered
Irssi::settings_add_bool( $IRSSI{name}, 'cleanicks_advanced_filtering', 1 );

# 0 : filter every nick change / 1 : advanced filtering
our $cleanicks_nickWarnMode = NICK_WARN_WINDOW_QUIET;

Irssi::theme_register( [ 'nick_changed_channel', '{channick $0} is now known as {channick_hilight $1}', 'nick_changed_window', '%W$2%n {channick $0} is now known as {channick_hilight $1}' ] );

sub sig_channel_event {
    my ( $signal, $chanIndex, $nickIndex, $msgIndex, $modeIndex, $msgType ) = @_;
    my ( $nick, $channel, $newNickRec );
    if ( $chanIndex > -1 && _is_channel_filtered( $signal->[$chanIndex] ) ) {
        $nick = $signal->[$nickIndex];
        $signal->[$nickIndex] = _cut_nick( $signal->[$nickIndex] ) if $nickIndex > -1;
        $signal->[$msgIndex] = _clean_message( $signal->[$msgIndex], $signal->[0], $signal->[$chanIndex] ) if $msgIndex > -1 && $chanIndex > -1;
        if ($modeIndex) { # it is a mode change
            my @mnicks = split( ' ', $signal->[$modeIndex] );
            $signal->[$modeIndex] = (shift @mnicks). ' ' . join (' ', map( { _cut_nick($_) } @mnicks));
        }
    }
    if (!defined($chanIndex) && $nickIndex) { # it is a quit msg
       my ($i, @added_nick_in_chan );
       foreach ( split( ' ', Irssi::settings_get_str('cleanicks_channels') ) ) {
           my $channel = $signal->[0]->channel_find($_);
           next unless defined($channel);
           my $nick = $channel->nick_find($signal->[$nickIndex]);
           next unless defined($nick);
           $_ = $nick;
           $channel->nick_remove ($_);
           $signal->[$nickIndex] = _cut_nick( $signal->[$nickIndex] );
           $newNickRec = $channel->nick_insert( $signal->[$nickIndex], $_->{op}, $_->{halfop}, $_->{voice}, 0 );
           $added_nick_in_chan[$i++]=$channel;
       }
       Irssi::signal_continue(@$signal);
       map { if ($_->nick_find($signal->[$nickIndex])) { 
                     $_->nick_remove($signal->[$nickIndex]) 
             } 
           } @added_nick_in_chan;
       return;
    }
    if ($nickIndex > -1 && $chanIndex > -1 && $signal->[$nickIndex] ne $nick & _is_channel_filtered($signal->[$chanIndex])) {
        # from tracknick.pl http://irssi.org/scripts/html/tracknick.pl.html (just added the halfop parameter)
        $channel = $signal->[0]->channel_find( $signal->[$chanIndex] );

        $_ = $channel->nick_find($nick);
        $newNickRec = $channel->nick_insert( $signal->[$nickIndex], $_->{op}, $_->{halfop}, $_->{voice}, 0 );
        Irssi::signal_continue(@$signal);
        $channel->nick_remove($newNickRec);
        return;
    } 
    Irssi::signal_continue(@$signal);
}

sub sig_nick {
    my ( $server, $newNick, $oldNick, $address ) = @_;

    if ( $cleanicks_nickWarnMode ne NICK_WARN_KEEP ) {

        my @channels                     = split( ' ', Irssi::settings_get_str('cleanicks_channels') );
        my $cleanicks_window             = Irssi::settings_get_str('cleanicks_window');
        my $cleanicks_advanced_filtering = Irssi::settings_get_bool('cleanicks_advanced_filtering');
        my $advancedFilter               = 1;

        my ( $cutOldNick, $cutNewNick, $length, $filteredChannelCount, $channelList );

        if ($cleanicks_advanced_filtering) {
            $cutOldNick = _cut_nick($oldNick);
            $cutNewNick = _cut_nick($newNick);
            $length     = (
                  length($cutOldNick) < length($cutNewNick)
                ? length($cutOldNick)
                : length($cutNewNick)
            );
            $advancedFilter = ( lc( substr( $cutOldNick, 0, $length ) ) eq lc( substr( $cutNewNick, 0, $length ) ) ? 1 : 0 );
        }

        foreach my $channel ( $server->channels() ) {
            my ( $msgChannel, $filter );
            my $channelName = $channel->{name};

            foreach ( $channel->nicks() ) {
                next unless $_->{nick} eq $newNick;
                $msgChannel = 1;
                last;
            }

            if ($msgChannel) {
                $filter = _is_channel_filtered($channelName);

                if ( !$filter || !$advancedFilter ) {
                    $channel->printformat( MSGLEVEL_NICKS, 'nick_changed_channel', $oldNick, $newNick );
                }
                elsif ( $cleanicks_nickWarnMode ne NICK_WARN_IGNORE ) {
                    $channelList .= ', ' if $filteredChannelCount++;
                    $channelList .= $channelName;
                }
            }
        }
        if ($filteredChannelCount) {
            my $window = Irssi::window_find_name($cleanicks_window);

            if ( !$window ) {
                $window = Irssi::Windowitem::window_create( $cleanicks_window, 1 );
                $window->set_name($cleanicks_window);
                $window->print( 'This window was created by ' . $IRSSI{name}, MSGLEVEL_NICKS );
            }
            if ( $cleanicks_nickWarnMode eq NICK_WARN_WINDOW ) {
                $window->printformat( MSGLEVEL_NICKS, 'nick_changed_window', $oldNick, $newNick, $channelList );
            }
            elsif ( $cleanicks_nickWarnMode eq NICK_WARN_WINDOW_QUIET ) {
                $window->printformat( MSGLEVEL_NO_ACT | MSGLEVEL_NICKS, 'nick_changed_window', $oldNick, $newNick, $channelList );
            }
        }
        Irssi::signal_stop();
    }
}

sub _clean_message {
    my ($msg, $server, $channel) = @_;
    if ( $channel && $msg =~ /^($nickRegexp)([: ]+.*)$/ ) {
        foreach ( $server->channel_find($channel)->nicks() ) {
            next unless $_->{nick} eq $1;
            $msg = _cut_nick($1) . $2;
            last;
        }
    }
    return $msg;
}

sub _cut_nick {
    my $nick = shift ;
    return $nick if $nick =~ /[@.]/; # this is not a nick but a hostmask or a server

    my $cleanicks_min_length = Irssi::settings_get_int('cleanicks_min_length');
    my $cleanicks_max_length = Irssi::settings_get_int('cleanicks_max_length');

    $nick = substr( $nick, 0, $cleanicks_max_length );

    ### my $nickre = '^[' . $separatorRegexpClass . ']*([^' . $separatorRegexpClass . '].{' . ( $cleanicks_min_length - 1 ) . '}[^' . $separatorRegexpClass . ']*)[' . $separatorRegexpClass . ']?.*';

    my $nickre = '^[^[:alnum:]]*([[:alnum:]].{'.($cleanicks_min_length - 1).'}[[:alnum:]]*)[^[:alnum:]]?.*$';

    $nick =~ s/$nickre/\1/ ;

    foreach ( split( ' ', Irssi::settings_get_str('cleanicks_nicks') ) ) {
        my ( $pattern, $fake ) = split( '>', $_ );
        $fake = $fake ? $fake : $pattern;
        $nick = $fake if $nick =~ /$pattern/;
    }

    return $nick;
}

sub _is_channel_filtered {
    my $channel = shift;
    my @channels = split( ' ', Irssi::settings_get_str('cleanicks_channels') );
    foreach (@channels) {
        next unless $channel eq $_;
        return 1;
    }
    return 0;
}

sub cmd_addchan {
    my $chanlist = Irssi::settings_get_str('cleanicks_channels').' '.(shift);
    Irssi::settings_set_str( 'cleanicks_channels' => $chanlist );
}

sub cmd_addnick {
    my $nicklist = Irssi::settings_get_str('cleanicks_nicks').' '.(shift);
    Irssi::settings_set_str( 'cleanicks_nicks' => $nicklist );
}

Irssi::command_bind('cleanicks addchannel',\&cmd_addchan);
Irssi::command_bind('cleanicks addnick',\&cmd_addnick);
# style ripped from coekie's trigger.pl
Irssi::command_bind 'cleanicks' => sub {
    my ( $data, $server, $item ) = @_;
    $data =~ s/\s+$//g;
    Irssi::command_runsub ( 'cleanicks', $data, $server, $item ) ;
};

Irssi::signal_add_last( 'message public',     sub { sig_channel_event( \@_, 4, 2,  1 ) } );
Irssi::signal_add_last( 'message own_public', sub { sig_channel_event( \@_, 2, -1, 1 ) } );
Irssi::signal_add_last( 'message irc action', sub { sig_channel_event( \@_, 4, 2,  -1 ) } );
Irssi::signal_add_last( 'message kick',       sub { sig_channel_event( \@_, 1, 2,  -1 ) } );
Irssi::signal_add_last( 'message topic',      sub { sig_channel_event( \@_, 1, 3,  -1 ) } );
Irssi::signal_add( 'message irc mode', sub { sig_channel_event( \@_, 1, 2, -1, 4 ) } );
Irssi::signal_add_last( 'message nick', 'sig_nick' );
Irssi::signal_add_last( 'message join', sub { sig_channel_event( \@_, 1, 2, -1 ) } );
Irssi::signal_add_last( 'message part', sub { sig_channel_event( \@_, 1, 2, -1 ) } );

### the handling of quit messages is a bit buggy 
### Irssi::signal_add_first( 'message quit', sub { sig_channel_event( \@_, undef, 1, -1 ) } );
### Irssi::signal_add_first( 'event quit', sub { sig_channel_event( \@_, undef, 2, -1 ) } );

print CLIENTCRAP '%B>>%n ' . $IRSSI{name} . ' ' . $VERSION . ' loaded';
