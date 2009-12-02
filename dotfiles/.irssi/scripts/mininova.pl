#!/usr/bin/perl
#
# irssi_mininova_rss.pl - A simple (XML/RSS Parser) Trigger Script for the Irssi IRC Client
#
# This perl script is intended to provide users in an IRC Channel with a simple way
# to search for torrents via the Mininova.org RSS Search Feed, using the '!tor' trigger.
#
# e.g. <fux> !tor Slackware Linux
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
# $Id: irssi_mininova_rss.pl,v 1.3 2008/01/14 18:13:18 seanodonnell Exp $
#

use strict;
use Irssi;
use XML::RSS::Parser;

# irssi Script-Specific Settings #
use vars qw{$VERSION %IRSSI};

$VERSION = "1.0.0";

%IRSSI = (
          name        => 'irssi_mininova_rss',
          authors     => 'Sean O\'Donnell',
          contact     => 'sean@seanodonnell.com',
          url         => 'http://www.seanodonnell.com/projects/irssi/',
          license     => 'GPL',
          description => 'Sean\'s IRC Torrent Search Script for the Irssi IRC Client',
          sbitems     => 'irssi_mininova_rss',
);

my $trigger = "!torrent";
my $feed_url = "http://www.mininova.org/rss/";
my $max = 3;

sub trigger_filter
{
    my ($server,$msg,$nick,$address,$target) = @_;

    if ($msg =~ "^$trigger")
    {
	my $query = $msg;

	$query =~ s/^$trigger //;

        #
        # parse the rss file
        #
	if ($query =~ "[a-zA-Z|0-9]") 
	{
        	my $parser = XML::RSS::Parser->new;
        	my $feed = $parser->parse_uri($feed_url . $query);
        
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
			$server->command("MSG ". $target ." Error: No results from query ($query).");
		}
        } 
        else
        {
            $server->command("MSG ". $target ." Error: RSS Feed (".$feed_url.") could not be parsed.");
        }
    }

    elsif ($msg =~ "^!torrent-help")
    {
        $server->command("MSG ". $target ." !torrent [file name] - Retrieves the top ". $max ." results from: ". $feed_url);
    }

    return;
}

Irssi::signal_add("message public","trigger_filter");
