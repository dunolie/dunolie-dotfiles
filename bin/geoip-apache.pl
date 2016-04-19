#!/usr/bin/perl 
# http://feeds.dzone.com/~r/dzone/snippets/~3/254333926/5255
# $Id$

# Split Apache logs according to GeoIP country 

use strict; 
use warnings; 

## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars) 
our ($VERSION) = '$Revision$' =~ m{ \$Revision: \s+ (\S+) }xms; 
## use critic 

use Geo::IP; 

my $gi = Geo::IP->open('/usr/local/share/GeoIP/GeoIPCity.dat', GEOIP_STANDARD); 

my @logs = @ARGV; 

my %record_for; 

foreach my $log (@logs) { 
die "Can't read $log\n" if !-r $log; 

my %fh_for; 
my $num_lines_parsed = 0; 

my $log_fh; 
if ($log =~ m/ \.gz \z /xms) { 
open $log_fh, "gzip -cd $log |" or die "Can't open gzip pipe\n"; 
} 
else { 
open $log_fh, '<', $log or die "Can't open $log\n"; 
} 

my $log_base = $log; 
$log_base =~ s/ \.gz \z //xms; 

while (my $line = <$log_fh>) { 
$num_lines_parsed++; 
if (!($num_lines_parsed % 1000)) { 
print STDERR "Parsed $num_lines_parsed lines of $log\n"; 
} 

my ($host) = $line =~ m/ \A (\S+) \s /xms; 

if (!exists $record_for{$host}) { 
my $record = $gi->record_by_name($host); 
$record_for{$host} = $record || 0; 
} 

my $country = 'unknown'; 
if (exists $record_for{$host} && $record_for{$host}) { 
$country = lc($record_for{$host}->country_name()); 
$country =~ s/\W+/_/gxms; 
} 

if (!exists $fh_for{$country}) { 
open $fh_for{$country}, '>', "$log_base.$country.out" 
or die "Can't write to $log_base.$country.out\n"; 
} 

print {$fh_for{$country}} $line; 
} 

foreach my $fh (values %fh_for) { 
close $fh; 
} 

close $log_fh; 
} 
