#!/usr/bin/perl


my $mocstat_dir = $ENV{HOME}."/.mocstat";
my $pid_file    = "$mocstat_dir/.pid";
my $cache_file  = "$mocstat_dir/.cache";

my $interval          = "0.5";
my $run_at_interval   = "$mocstat_dir/update";
my $run_at_songchange = "$mocstat_dir/songchange";



use strict;
use warnings;
use Encode;

my (%info, %last_info);
%last_info = read_info($cache_file); # make sure %last_info has all keys defined

my $myself = $0;
   $myself =~ s/^.*\///;



# this prevents multiple instances
if(-e $pid_file and (!defined($ARGV[0]) or $ARGV[0] ne '-f'))
{
    print STDERR "PID file found. This means that mocstat is already running.\n";
    print STDERR "Run mocstat -f to force starting it.\n";
    exit(2);
}
mkdir("$mocstat_dir");
qx"echo $$ > $pid_file";

# the pid file must be deleted if this script doesn't run anymore
$SIG{TERM} = sub { unlink($pid_file); print STDERR "$myself: Caught SIGTERM.\n"; exit(0); };
$SIG{INT}  = sub { unlink($pid_file); print STDERR "$myself: Caught SIGINT.\n";  exit(0); };



# loop until we get killed
while(1)
{
    # we can't wait less than one second with sleep() so we have to use select().
    select(undef, undef, undef, $interval);


    # read information about currently playing song
    %info = read_info();

    # this can update the playing status for an osd application or something like this
    run_command($run_at_interval);


    # we can skip the song change handling if moc is not playing
    next unless($info{State} eq 'PLAY');

    # run song change command if the current song has been playing for at least 30 seconds
    if($info{CurrentSec} > 30 and $last_info{SongTitle} ne $info{SongTitle})
    {
        run_command($run_at_songchange);

        # remember this song's information to distinguish it from the next song
        %last_info = %info;

        # make sure we don't loose the above information if we get killed and started again
        if(open(CACHE, ">$cache_file"))
        {
            foreach my $key (keys(%info)) { print CACHE encode('utf8', "$key: $info{$key}\n"); }
            close(CACHE);
        }
    }
}



sub read_info
{
    my $filename = shift;

    # set standard values
    my %new_info = (Artist => '', Album => '', SongTitle => '', Title => '', CurrentTime => '00:00',
                    TotalTime => '00:00', CurrentSec => '0', TotalSec => '0', TimeLeft => '00:00',
                    File => '', State => 'STOP');


    # read status information from a file ...
    if(defined($filename))
    { open(INFO, "<$filename") or return %new_info; }
    # ... or directly from mcop
    else
    { open(INFO, "mocp --info 2>&1 |") or die "Can't run 'mocp --info': $!"; }
    

    # parse each line
    while(<INFO>)
    { $new_info{$1} = decode('utf8', $2) if($_ =~ /^\s*(\w+)\s*:\s*(.*?)$/i); }
    close(INFO);

    # append the information about how much of the song already passed
    if($new_info{TotalSec} > 0 and $new_info{CurrentSec} > 0)
      { $new_info{PercentDone} = int(100 / ($new_info{TotalSec} / $new_info{CurrentSec})); }
    else
      { $new_info{PercentDone} = 0; }


    # if there is no title, we can at least show the file name as a substitution
    if(empty($new_info{Title}) and !empty($new_info{File}))
    {
        $new_info{Title} = $new_info{File};
        $new_info{Title} =~ s~^.*/(.*?)$~$1~;
    }


    return %new_info;
}


sub run_command
{
    my $command = shift;
    return unless($command and -x $command);

    # create environment variables according to `mocp --info`
    my $cmd_line = '';
    foreach my $key (keys(%info))
    { $cmd_line .= encode('utf8', uc($key)."=\"".escape_quotes($info{$key})."\" "); }
    $cmd_line .= $command;
    print qx"$cmd_line";
}


sub escape_quotes
{
    my $string = shift;
    $string =~ s/(?<!\\)\"/\\\"/sg;
    return $string;
}

sub empty
{ (!defined($_[0]) or $_[0] =~ /^\s*$/) ? return 1 : return 0; }
