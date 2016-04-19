#!/usr/bin/perl -w
# http://forums.cacti.net/about30586.html

# ddwrt_nmb_wireless_clients.pl

# Simple script to count the number of associated wireless
# clients on DD-WRT v24
#
# Invoke with ddwrt_nmb_wireless_clients.pl <hostname> <snmp_community> <snmp_version> <snmp_port> <snmp_timeout>
# e.g. ddwrt_nmb_wireless_clients.pl 192.168.1.1 public 2 161 30

# Revision history
# v0.01 1/29/2009 Brian Rudy (brudyNO@SPAMpraecogito.com)
# Initial version based on original PHP script

#
use strict;
use SNMP;

my $status;
my $answer = "";
my $snmpkey=0;
my $snmpoid=0;
my $key=0;
my $community = "public";
my $port = 161;
my @snmpoids;
my $hostname;
my $session;
my $error;
my $response;
my %ddwrtstatus;
my $snmp_version = 2;
my $clients = 0;


my $vars = new SNMP::VarList(['.1.3.6.1.4.1.2021.255']);

# Just in case of problems, let's not hang poller
$SIG{'ALRM'} = sub {
		die ("ERROR: No snmp response from $hostname (alarm timeout)\n");
};
alarm($ARGV[4]);

$session = new SNMP::Session(
		DestHost    => $ARGV[0],
		Community   => $ARGV[1],
		RemotePort  => $ARGV[3],
		Version     => $ARGV[2]
			);

if ($session->{ErrorNum}) {
	$answer=$session->{ErrorStr};
	die ("$answer");
}

my @resp = $session->bulkwalk(0, 35, $vars);


if ($session->{ErrorNum}) {
		$answer=$session->{ErrorStr};
		die ("$answer with snmp version $snmp_version\n");
}

for my $vbarr ( @resp ) {
			for my $v (@$vbarr) {
				if ($v->tag =~ m/255\.3\.54\.1\.3\.32\.1\.1\./) {
			#print "Found tag=" . $v->tag . "\n";
			$clients++;
		}
		}
}
print $clients;
