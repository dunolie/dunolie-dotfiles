use strict;
use Irssi;
use Irssi::TextUI;
use HTML::TokeParser;
use vars qw($VERSION %IRSSI);
our $active_pid = undef;

$VERSION = "1.1";
%IRSSI=(
    author  => 'Marko Kivijärvi',
    contact => 'leethaksor@gmail.com',
    name    => 'Gets the title of recognized urls. Only youtube at the moment',
    license => 'GPL',
    url     => 'http://www.irssi.org'
);

my @domains = (
     "youtube.com"
    ,"tinyurl.com"
);

sub message_public {
    my ($server, $msg, $nick, $address, $target) = @_;

    foreach my $domain ( @domains ) {
        if ( $msg =~ qr#(.+)?(http://(?:.*?\.)?$domain[^\s]+)(.+)?# ){
            my $before  = $1;
            my $url     = $2;
            my $after   = $3;

            $before = "" if !$before;
            $after = "" if !$after;

            if ( $msg =~ / ==\( .+? \)/ ) {
#                print "DEBUG: returning because title already set";
                return;
            }

            my $title = get_title( $url );

            $msg = $before . $url . " ==( $title ) " . $after;

            # Stop the original message
            Irssi::signal_stop();

            # Emit new message with the url title in it
            Irssi::signal_emit("message public", ($server, 
                                                  $msg, 
                                                  $nick, 
                                                  $address, 
                                                  $target) );
        }
    }
}

sub get_title {
    my $url = shift;

    $url =~ s/^\s+//;
    $url =~ s/\s+$//;

    use LWP::UserAgent;
    my $browser = LWP::UserAgent->new(agent => 'Firefox/1.0.1 (Windows NT 5.1;); U; pl-PL)');
    $browser->max_size(1000);  #Max is 1M.

    #LWP::UserAgent doesn't like non-absolute URI's; fix.
    if ($url !~ /^(ht|f)tp/){
        $url = "http://$url"; #Assume http.
    }

    my $title = "";
    my $response = $browser->get( $url );
    if ( $response->is_success ) {
        my $stream = HTML::TokeParser->new( \$response->content );
        $title = $stream->get_trimmed_text( '/title' );

        # Get rid of the domain name from the title
        $title =~ s/\w+? - (.+)/$1/;

        if (!$title){
            $title = "No title.";
        }
    }

    return $title;
}

# Irssi Signal(s)
Irssi::signal_add('message public','message_public');
