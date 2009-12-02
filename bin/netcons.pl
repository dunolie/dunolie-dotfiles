#!/usr/bin/perl                                                                                                         
# a little script to get your network status 
# http://www.keynote2keynote.com/2007/04/10/ultimate-geektool-setup-pimp-your-desktop-part-2/                                                                     

$en0_info = `ifconfig en0 | grep "inet" | grep -v 127.0.0.1`;
$en1_info = `ifconfig en1 | grep "inet" | grep -v 127.0.0.1`;
$airport_info = `/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I`;

if($en0_info)
{
    $en0_info =~ /inet (.*) netmask/s;
    $output .= "ETHERNET IP   : $1\n";

}
else
{ $output .= "ETHERNET IP   : INACTIVE\n";}


if($en1_info)
{
    $en1_info =~ /inet (.*) netmask/s;
    $en1_info = $1;
    $airport_info =~ /lastTxRate: (\d )/s;
    $airport_rate = $1;
    $airport_info =~ /BSSID(.*?)SSID: (.*?)\n/s;
    $airport_SSID = $2;
    $output .= "AIRPORT  STATUS: CONNECTED\n";
    $output .= "         SSID : $airport_SSID\n";
    $output .= "         RATE : $airport_rate Mb/s\n";
    $output .= "AIRPORT  IP    : $en1_info\n";
}
else
{ $output .= "AIRPORT  STATUS: INACTIVE\n";}

print "$output";