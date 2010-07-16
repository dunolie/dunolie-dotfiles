#!/usr/bin/perl
# http://www.seanodonnell.com/code/?id=59
# irssi_slashdot.pl (irssi Slashdot XML/RSS Parser Trigger), version 1.2
#
# This perl script is programmed to recognize the $trigger command and 
# then parse the $feed_url and print the top-$max items from the RSS feed, 
# to the IRC channel.
#
# default trigger:     !slashdot
# default feed_url:     http://rss.slashdot.org/Slashdot/slashdot
# default max:         3
#
# Copyleft (<) 2005, 2007 Sean O'Donnell <sean@seanodonnell.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# The complete text of the GNU General Public License can be found
# on the World Wide Web: <URL:http://www.gnu.org/licenses/gpl.html>
#
# $Id: irssi_slashdot.pl,v 1.2 2007/01/14 11:26:28 sod Exp $
#

use strict;
use Irssi;
use XML::RSS::Parser;

# irssi Script-Specific Settings #
use vars qw{$VERSION %IRSSI};

$VERSION = "1.0.0";

%IRSSI = (
          name        => 'irssi_slashdot',
          authors     => 'Sean O\'Donnell',
          contact     => 'sean@seanodonnell.com',
          url         => 'http://www.seanodonnell.com/projects/',
          license     => 'GPL',
          description => 'Sean\'s Slashdot \'Latest Headline via RSS\' Script for the Irssi IRC Client',
          sbitems     => 'irssi_slashdot',
);

my $trigger = "!slashdot";
my $feed_url = "http://rss.slashdot.org/Slashdot/slashdot";
my $max = 3;

sub trigger_filter
{
    my ($server,$msg,$nick,$address,$target) = @_;

    if ($msg =~ "^$trigger")
    {
        #
        # parse the rss file
        #
        my $parser = XML::RSS::Parser->new;
        my $feed = $parser->parse_uri($feed_url);
        
        if (!$feed)
        {
            $server->command("MSG ". $target ." Error parsing content");
            return;
        }

        my $count = $feed->item_count;

        # my $chan_title = $feed->query('/channel/title');
        # $server->command("MSG ". $target ." RSS Feed: ". $chan_title->text_content);
        
        if ($count > 0)
        {
            my $title;
            my $link;
            my $x = 0;

            foreach my $i ( $feed->query('//item') ) 
            { 
    
                $title = $i->query('title');
                $link = $i->query('link');
            
                if ($title->text_content)
                {
                    $server->command("MSG ". $target ." ". $title->text_content ." - ". $link->text_content);
                }

                $x++;

                if ($x eq $max)
                {
                    return;
                }
            }
        } 
        else
        {
            $server->command("MSG ". $target ." Error: slashdot Feed (".$feed_url.") could not be parsed.");
        }
    }

    elsif ($msg =~ "^!help")
    {
        $server->command("MSG ". $target ." !slashdot - retrieves the latest headline from slashdot (responds in the channel only)");
    }

    return;
}

Irssi::signal_add("message public","trigger_filter");