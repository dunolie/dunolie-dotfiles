# This script is for currency conversion
#
# Originally Created On 01.15.05
# 

use SOAP::Lite;

use Irssi;

$VERSION = "1.1";
%IRSSI = (
    author => 'pleia2',
    contact => 'lyz@princessleia.com ',
    name => 'currencyConverter',
    description => 'script to convert worldwide currencies',
    license => 'GNU GPL v2 or later',
    url => 'http://www.princessleia.com'
);



sub event_privmsg {
	my ($server, $data) =@_;
	my ($target, $text) = $data =~ /^(\S*)\s:(.*)/;
	return if ( $text !~ /^!/i );

if ( $text =~ /^!convert /i ) {
		my ($amount, $from, $to) = $text =~ /!convert (\d*)\s*(\S+) (\S+)/;
			if ( $from =~ /^usd$|^sek$|^eur$|^aud$|^gbp$|^jpy$/i && $to =~ /^usd$|^sek$|^eur$|^aud$|^gbp$|^jpy$/i && $amount =~ /^\d\d\d$|^\d\d$|^\d$|^$/) {
				if ( $from =~ /^usd$/i ) { $currency1 = "us"; }
				elsif ( $from =~ /^sek$/i ) { $currency1 = "sweden";}
				elsif ( $from =~ /^eur$/i ) { $currency1 = "euro";}
				elsif ( $from =~ /^aud$/i ) { $currency1 = "australia";}
				elsif ( $from =~ /^gbp$/i ) { $currency1 = "uk";}
				elsif ( $from =~ /^jpy$/i ) { $currency1 = "japan";}
				if ( $to =~ /^usd$/i ) { $currency2 = "us"; }
				elsif ( $to =~ /^sek$/i ) { $currency2 = "sweden";}
				elsif ( $to =~ /^eur$/i ) { $currency2 = "euro";}
				elsif ( $to =~ /^aud$/i ) { $currency2 = "australia";}
				elsif ( $to =~ /^gbp$/i ) { $currency2 = "uk";}
				elsif ( $to =~ /^jpy$/i ) { $currency2 = "japan";}
				
				my $result = SOAP::Lite 
					->service('http://xmethods.net/sd/2001/CurrencyExchangeService.wsdl')
					->getRate("$currency1","$currency2");
				if ($amount =~ /^$/) { $newamount = $result; $amount = 1; }
				else { $newamount = sprintf( "%4.4f", ($amount * $result) ); }
				$server->command ( "MSG $target $amount $from is worth $newamount $to" );
			}
			else { $server->command ( "MSG $target The only currency types supported are USD EUR GBP SEK JPY and AUD, amounts must be under 1000 (and no decimals)" ); }
				
	}
}

Irssi::signal_add('event privmsg', 'event_privmsg');

