# Idea based on queryresume.pl by Stefan Tomanek

### NOTES/BUGS
# - /set logresume_query_lines
# - /set logresume_channel_lines (set to 0 to make this script act more like queryresume.pl)
# - Coloured logs (/set autolog_colors ON) work perfectly well, and are recommended if you want it to look like you never left
# - If you have a /ignore #channel JOINS then the script won't work.  Fix it with: /ignore -except *!myident@myhost JOINS
# - bonus feature: /logtail 10 will print the last 10 lines of a log
# - bonus feature: /logview will open the log in your PAGER, or do e.g. /logview screen vim -R.  You'll need to be using irssi in screen.  Running the program without screen is possible, but you need to ^L to redraw after closing it, and if you look at it too long irssi blocks on output and all your connections will ping out
# - both of these fail when a QUERY has been open for a while.  You'll have to close and reopen the query.  Solutions welcome

use strict;
use Irssi;
use Fcntl qw( :seek O_RDONLY );

our $VERSION = "0.5";
our %IRSSI = (
  name        => "logresume",
  description => "print last n lines of logs when opening queries/channels",
  url         => "http://explodingferret.com/linux/irssi/logresume.pl",
  authors     => "ferret",
  contact     => "ferret(tA)explodingferret(moCtoD), ferret on irc.freenode.net",
  licence     => "Public Domain",
  changed     => "2008-12-08",
  changes     => "0.5: added /logtail and /logview"
               . "0.4: fixed problem with lines containing %, removed use warnings"
               . "0.3: swapped File::ReadBackwards for internal tail implementation",
  modules     => "",
  commands    => "logtail, logview",
  settings    => "logresume_channel_lines, logresume_query_lines",
);

Irssi::print "$IRSSI{name} version $VERSION loaded, see the top of the script for help";

Irssi::settings_add_int($IRSSI{name}, 'logresume_channel_lines', 15);
Irssi::settings_add_int($IRSSI{name}, 'logresume_query_lines',   20);

sub debug_print {
  Irssi::print $IRSSI{name} . ' %RDEBUG%n: ' . $_[0];
} 

sub witem_created {
  my ( $witem ) = @_;
  my $lines;

  if( $witem->{type} eq 'QUERY' ) {
    $lines = Irssi::settings_get_int('logresume_query_lines');
  } elsif( $witem->{type} eq 'CHANNEL' ) {
    $lines = Irssi::settings_get_int('logresume_channel_lines');
  } else {
    debug_print( "unknown window type $witem->{type} -- let the script author know if you get this and it's annoying" );
    return;
  }

  print_tail( $witem, $lines );
}

Irssi::signal_add_last( 'query created'  => \&witem_created );
Irssi::signal_add_last( 'channel joined' => \&witem_created );

sub print_tail {
  my ( $witem, $lines ) = @_; # witem is a channel or query or whatever

  return unless $lines > 0;

  my $log = get_log_filename( $witem );
  return unless defined $log;

  my $winrec = $witem->window(); # need to print to the window, not the window item

  for( tail( $lines, $log ) ) { # sub tail is defined below
    s/%/%%/g; # prevent irssi format notation being expanded
    $winrec->print( $_, MSGLEVEL_NEVER );
  }

  $winrec->print( '%K[%Clogresume%n ' . $log . '%K]%n' );
}


sub get_log_filename {
  my ( $tag, $name ) = ( $_[0]->{server}{tag}, $_[0]->{name} );

  my @logs = map { $_->{real_fname} } grep {
    grep {
      $_->{name} eq $name and $_->{servertag} eq $tag
    } @{ $_->{items} }
  } Irssi::logs();

  unless( @logs ) {
    debug_print( "no logfile for $tag, $name" );
    return undef;
  }

  debug_print( "surplus logfile for $tag, $name: $_" ) for @logs[1..$#logs];
  return $logs[0];
}


Irssi::command_bind 'logtail' => sub {
  my ( $lines ) = @_;
  if ( not $lines =~ /[1-9][0-9]*/ ) {
    debug_print( 'usage: /logtail <number>' );
  }

  print_tail( Irssi::active_win()->{active}, $lines );
};


Irssi::command_bind 'logview' => sub {
  my ( $args, $server, $witem ) = @_;

  my $log = get_log_filename( $witem );
  return unless defined $log;

  my $program = $_[0] || $ENV{PAGER} || 'screen less';

  system( split( / /, $program ), $log ) == 0 or do {
    if ( $? == -1 ) {
      debug_print( "logview: $program '$log' failed: $!" );
    } elsif ( $? & 127 ) {
      debug_print( "logview: $program '$log' died with signal " . ( $? & 127 ) );
    } else {
      debug_print( "logview: $program '$log' exited with status " . ( $? >> 8 ) );
    }
  };
};


sub tail {
  my ( $needed_lines, $filename ) = @_;
  return unless $needed_lines > 0;

  my $chunksize = 1 << 13; # 8 kB
  my @lines = ();

  sysopen( my $fh, $filename, O_RDONLY ) or return;
  binmode $fh;

  # start at the end of the file 
  my $pos = sysseek( $fh, 0, SEEK_END ) or return;

  # for the first chunk read a trailing partial block, so we start on what's probably a natural disk boundary
  # if there's no trailing partial block read a full one
  # Also guarantees that $pos will become zero before it becomes negative
  $pos -= $pos % $chunksize || $chunksize;

  # - 1 is because $lines[0] is partial
  while ( @lines - 1 < $needed_lines ) {
    # go to top of this chunk
    sysseek( $fh, $pos, SEEK_SET ) or last; # partial output better than none

    sysread( $fh, my $buf, $chunksize );
    last if $!;

    # ruin my lovely generic tail function
    $buf =~ s/^--- Log.*\n//mg;

    if ( @lines ) {
      splice @lines, 0, 1, split( /\n/, $buf . $lines[0], -1 );
    } else {
      @lines = split( /\n/, $buf, -1 );
      # unix philosophy (as tail, wc, etc.): trailing newline is not a line for counting purposes
      pop @lines if @lines and $lines[-1] eq "";
    }

    last if $pos == 0;

    $pos -= $chunksize;
  }

  return ( $needed_lines >= @lines ? @lines : @lines[ -$needed_lines .. -1 ] );
}
