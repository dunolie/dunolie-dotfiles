################################################################
#
# url.pl - URL grabber 
#
# By Erik Hollensbe <erik@hollensbe.org>
#
# $Id: $
#
################################################################
#
# 2.0! Woot. Here's a list of the changes:
#
# - /urlview and /urllist now has an extended syntax and some slightly
#   different semantics:
#
#   - without parameters, /urllist will show the list fetched
#     from the current window, unless this is the system window.
#     then it will show all captures. (queries are caught too.)
#   - use the name of the window to show captures from that window
#   - likewise, /urlview has the same semantics. It will complain
#     if you try to leverage it from the system window without
#     a channel name.
#
# - the number of urls kept is now configurable and urls are
#   caught per-channel. This variable is called 'url_cache_size'
#   and defaults to 10.
#
# - /urllast will accept the -channel parameter which will view
#   the last url captured in this channel. Otherwise, it will view
#   the last url caught across all channels.
#
################################################################
#
# Usage: just throw this in autorun. It'll keep a running list
# of a configurable number of urls at any time, and allow you to 
# run netscape/moz or what you prefer by /urlview x, which is the
# number provided by /urllist. If you just want to view the last
# one, /urllist will bring it up in the browser automagically.
#
# Please see the above patch notes for more usage and configuration
# information.
#
# After running it for the first time, you'll want to configure
# the program you want to use to view urls. For instance on
# OS X:
#
# /set url_program open
#
# This will execute it as "open <url>".
#
# You may also want to configure the protocols your client
# catches. If you prefer to do this instead of using the
# defaults, configure the 'url_protocols' option:
#
# /set url_protocols http https ftp feed telnet
#
# Separate each protocol with a space, and no special characters
# such as http:// - just 'http'.
#
# Configuring the number of urls caught (per channel, not globally)
# is done by tweaking the 'url_cache_size' parameter.
#
################################################################

use strict;
use warnings;

use Irssi;

my $VERSION = '2.0.1';
my %IRSSI = (
    authors	=> 'Erik Hollensbe',
    contact	=> 'erik@hollensbe.org',
    name	=> 'URL Grabber',
    description	=> 'grabs URLs and allows you to view them in Irssi',
    license	=> 'Public Domain',
    url		=> 'http://svn.hollensbe.org/',
    changed	=> '$Date: 2004/05/11 06:53:42 $',
);

our %URL = ();
our $LAST_URL = "";

sub add_url { 
    my ($channel, $url) = @_;

    my $max = Irssi::settings_get_str("url_cache_size");

    notify_user("url_cache_size is not an integer: $max") unless ($max =~ /^[0-9]+/);

    $max = int($max);

    $URL{$channel} = [] unless ($URL{$channel});

    if (@{$URL{$channel}} == $max) { 
        shift @{$URL{$channel}};
    }

    push @{$URL{$channel}}, $url;
    $LAST_URL = $url;
}

sub trim {
    my ($param) = @_;

    $param =~ s/^\s*//;
    $param =~ s/\s*$//;
    
    return $param;
}

sub current_channel {
    return Irssi::active_win->{active}->{name};
}

sub notify_user {
    Irssi::active_win->printformat(MSGLEVEL_CLIENTCRAP, 'urllist', @_);
}

sub view_url {
    my $url = shift;

    my $url_program = Irssi::settings_get_str("url_program");

    system("$url_program '$url'");

    notify_user("$url viewed!");
}

sub cmd_urllast {
    my ($data) = @_;

    my $url;

    if ($data) {
        $data = trim($data);

        if ($data eq '-channel') {
            my $channel = current_channel;
            if ($channel) {
                $url = $URL{$channel}->[-1];
            } else {
                $url = $LAST_URL;
            }
        } else {
            notify_user("unrecognized parameter: $data");
        }
    } else {
        $url = $LAST_URL;
    }

    if ($url) {
        view_url($url);
    } else {
        notify_user("Last URL (depending on parameters) does not exist.");
    }
}

sub cmd_urlview {
    my ($data) = @_;

    my ($param, $num) = split(/\s+/, $data);
    
    if ($param =~ /^[0-9]+/ and !defined($num)) {
        $num   = $param;
        $param = undef;
    }

    if (defined($num) and $num =~ /^[0-9]+/) {
        $num = int($num); 

        if (!$param or $param eq '-current') {
            $param = current_channel;
        }

        if ($param) {
            if ($URL{$param} and $URL{$param}->[$num]) {
                view_url($URL{$param}->[$num]);
            } else {
                notify_user("$num is not a valid entry in the $param URL list.");
            }
        } else {
            notify_user("Please provide a channel list in the parameters");
        }
    } else { 
        notify_user("Please provide a number to visit");
    }
}

sub list_urls {
    my ($set) = @_;

    my @urls;

    if (!$set or $set eq '-current') {
        my $channel = current_channel;
      
        if ($channel) {
            list_urls($channel);
        } else {
            foreach my $key (keys %URL) {
                list_urls($key);
            }
        }
        
        return;
    } else {
        @urls = @{$URL{$set}} if ($URL{$set});
    }

    notify_user("$set:");

    if (@urls) {
        for (my $i = 0; $i < @urls; $i++) { 
            notify_user($i, $urls[$i]);
        }
    } else {
        notify_user("No URLs for $set");
    }
}

sub cmd_urllist {
    my ($data) = @_;

    if ($data) {
        list_urls(trim($data));
    } else {
        list_urls();
    }
}

sub event_privmsg {
    my ($server, $args, $sender_nick, $sender_addr) = @_;
    my ($origin, $msg) = $args =~ m/^([^ ]+) :(.*)$/;

    if (defined $msg) {
        foreach my $valid (split /\s+/, Irssi::settings_get_str("url_protocols")) {
            # TODO: work on this regex.
            my (@urls) = $msg =~ m!($valid://[^\s]+)!g;
            foreach my $url (@urls) {
                add_url($origin, $url);
            }
        }
    }
    
    return 1;
}


Irssi::settings_add_str("url", "url_program", "open");
Irssi::settings_add_str("url", "url_cache_size", 10); 
Irssi::settings_add_str("url", "url_protocols", "http https ftp feed");

Irssi::theme_register(
    [
     'urllist',
     '{line_start}{hilight [}$0{hilight ]} $1',
    ]);

Irssi::signal_add_last("event privmsg", "event_privmsg");
Irssi::command_bind("urllist", "cmd_urllist");
Irssi::command_bind("urlview", "cmd_urlview");
Irssi::command_bind("urllast", "cmd_urllast");
