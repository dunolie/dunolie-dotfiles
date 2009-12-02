use strict;

sub send_text {
    my ( $data, $server, $witem ) = @_;
    if ( $witem
        && ( ( $witem->{type} eq "CHANNEL" ) || ( $witem->{type} eq "QUERY" ) )
        && ( $data =~ /^:me (.*)$/ ) )
    {
	
        $witem->command("action $witem->{name} $1");
	Irssi::signal_stop();
    }
}

Irssi::signal_add 'send text' => 'send_text'

