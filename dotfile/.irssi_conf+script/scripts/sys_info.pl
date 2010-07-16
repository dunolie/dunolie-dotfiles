#!/usr/bin/perl
#
# irssi_linadmin.pl - Linux Administration Tools for the irssi IRC client.
#
# This script is intended to provide linux system administrators
# with the ability to easily execute commands via IRC triggers.
#
# Due to obvious security implications, this script is limited to a
# few 'harmless' commands, until a secure method of communications
# can be established.
#
# Copyleft (<) 2008 Sean O'Donnell <sean@seanodonnell.com>
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
# $Id: irssi_linadmin.pl,v 1.5 2008/01/16 08:08:48 seanodonnell Exp $
#

use strict;
use Irssi;

# irssi Script-Specific Settings #
use vars qw{$VERSION %IRSSI};

$VERSION = "1.0.0";

%IRSSI = (
          name        => 'irssi_linadmin',
          authors     => 'Sean O\'Donnell',
          contact     => 'sean@seanodonnell.com',
          url         => 'http://www.seanodonnell.com/projects/irssi/',
          license     => 'GPL',
          description => 'Sean\'s Linux Administration Tools for the Irssi IRC Client',
          sbitems     => 'irssi_linadmin',
);

# declare static command-results below

# kernel info
my $kernel = `uname -orv`;

# cpu model info
my $cpu = `cat /proc/cpuinfo | grep -i "model name"`;
my @cpuname = split(/\n/,$cpu);
$cpuname[0] =~ s/model name\t\: //g;
my $cpu_model = $cpuname[0];

sub msg_meminfo
{
	my ($server,$msg,$nick,$address,$target) = @_;
	my $minfo = `cat /proc/meminfo`;
	my @meminfo = split(/\n/,$minfo);
	my $response;
	foreach my $mem (@meminfo)
	{
		$mem =~ s/ //g;
		if ($mem =~ /memtotal|memfree|swaptotal|swapfree|cache/i)
		{
			$response = $response ." (".$mem.") ";
		}
	}
	if (!$response)
	{
		$response = "Sorry, no memory information was returned. *weird*";
	}

	$server->command("MSG ". $target ." ". $response);
	return;
}

sub trigger_filter
{
	my ($server,$msg,$nick,$address,$target) = @_;

	if ($msg =~ /^!uptime/)
	{
		my $uptime = `uptime`;
		$server->command("MSG ". $target ." ". $uptime);
	}
	elsif ($msg =~ /^!mem/)
	{
		msg_meminfo(@_);
	}
	elsif ($msg =~ /^!kernel/)
	{
		$server->command("MSG ". $target ." ". $kernel);
	}
        elsif ($msg =~ /^!cpu/)
        {
		$server->command("MSG ". $target ." ". $cpu_model);
        }

	elsif ($msg =~ /^!help/)
	{
	        $server->command("MSG ". $target ." irssi::linadmin->triggers: !cpu !mem !uptime !kernel");
	}
	return;
}

Irssi::signal_add("message public","trigger_filter");
