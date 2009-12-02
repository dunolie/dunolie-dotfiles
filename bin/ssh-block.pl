#!/usr/bin/perl -w

use strict;
use Data::Dumper;

#sshd.*Failed password for invalid user
my @ips;
open MESSAGES, "tail -f /var/log/messages|";
while  (<MESSAGES>){
	chomp;
	if (/sshd.*(Failed password for|Invalid user) (\w+) from (?:::ffff:)?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/) {
	 print STDOUT "block.pl: $1 $2 from $3 \n";
		my $ip=$3;
		my @newips;
		my $found=0;
		foreach my $k (@ips){
			if ($$k{"ip"} eq $ip){
				$$k{"count"}++;
				print STDOUT "block.pl: tail: increasing count for $ip, now: ".$$k{"count"}."\n";
				$found=1;
			}
			push @newips, $k;
		}
		if ($found==0){
			print STDOUT "block.pl: tail: new logged: $ip\n";
			my %n;
			%n = (
				ip=>$ip,
				count=>1,
				logged=>time()
			     );
			push @newips, \%n;
		}
		undef @ips;
		@ips=@newips;
		my @newips2;
		foreach my $x (@ips){
			print STDOUT "block.pl: check: ".$$x{"ip"}." has ".$$x{"count"}." and last logged at ".$$x{"logged"}."\n";
			if ($$x{"count"} >= 10){
				print STDOUT "block.pl: check: blocking ".$$x{"ip"}."\n";
				`iptables -A INPUT --source $$x{"ip"} -j REJECT`;
				unlink "/tmp/blacklist.".$$x{"ip"} if -e "/tmp/blacklist.".$$x{"ip"};
				open FOO, ">/tmp/blacklist.".$$x{"ip"};
				print FOO "iptables -D INPUT --source $ip -j REJECT\n";
				close FOO;
				`at now + 1 hours -f /tmp/blacklist.$ip`;
				my %m;
				%m=(
					count=>0,
					logged=>time(),
					ip=>$$x{"ip"}
				);
				push @newips2, \%m;
			} elsif (time() - $$x{"logged"} > 3600){
				print STDOUT "block.pl: check: removing $ip after one hour of inactivity\n";
			} else {
				push @newips2, $x;
			}
		}
		undef @ips;
		@ips=@newips2;
	} elsif (/sshd.*Accepted (password|publickey) for (\w+) from (::ffff:)?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/) {
		my $ip;
		$ip = $4;
		print STDOUT "block.pl: successful logon of $2 from $4\n";
		my @newips3;
		foreach my $x (@ips){
			if ($$x{"ip"} eq $ip){
				print STDOUT "block.pl: check: removing $ip after successful login\n";
			} else {
				push @newips3, $x;
			}
		}
		undef @ips;
		@ips=@newips3;
	}
}
