use strict;
use Irssi 20081209; # Segmentation fault (bug #534) on tab before this date

our $VERSION = "0.02";
our %IRSSI = (
  name        => "tag.pl",
  description => "/tag networktag /command runs that /command with networktag as the active network",
  url         => "http://explodingferret.com/linux/irssi/tag.pl",
  authors     => "ferret",
  contact     => "ferret tA xelam teNtoD",
  licence     => "Public Domain",
  changed     => "2008-12-08",
  changes     => "0.02: tab completion fixes, added minimum irssi version requirement",
  modules     => "",
  commands    => "/tag",
);

our $k = Irssi::parse_special( '$k' ); # command start character, usually /
our $tagre = qr/^\Q${k}\Etag\b/io;

Irssi::signal_add_first 'complete word' => sub {
  my ( $complist, $windowrec, $word, $linestart, $want_space ) = @_;
  return unless $linestart =~ $tagre;

  if ( $linestart =~ s/^$tagre [^ ]+ *// ) {
  # if the first argument is present, remove it and trailing space

    # support "/tag servtag command" and "/tag servtag /command"
    if ( $linestart eq '' ) {
      index( $word, $k ) == 0 or $word = "$k$word";
    } else {
      index( $linestart, $k ) == 0 or $linestart = "$k$linestart";
    }

    Irssi::signal_continue( $complist, $windowrec, $word, $linestart, $want_space );

  } else {
  # tab complete the first argument

    @$complist = grep /^\Q${word}\E/i, map( $_->{tag}, Irssi::servers );
    Irssi::signal_stop();

  }
};

Irssi::command_bind 'tag' => sub {
  my ( $servtag, $command ) = split ' ', $_[0], 2;

  unless( defined $servtag and defined $command ) {
    Irssi::print "$IRSSI{name}: Usage: /tag server command";
    return;
  }
  
  my $server = Irssi::server_find_tag( $servtag );
  unless( $server ) {
    Irssi::print "$IRSSI{name}: Unknown server tag $servtag";
    return;
  }

  $server->command( $command );
};
