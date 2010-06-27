#!/usr/bin/perl -w
use strict; $|++; use Getopt::Long;
###############################################################################
# Creates a list of your mp3 albums, based on iTunes XML. I assume things     #
# about how you id3 your collection, as well as how you want the output.      #
# The actual expectations are explained in the output, available online:      #
# http://www.disobey.com/detergent/lists/albums.html - fun for everyone!      #
#                                                                             #
#     v2.4: 2007-05-12, morbus@disobey.com, email me if you use/modify.       #
###############################################################################
# To run this script, use the Terminal to enter the following command         #
# (your library is usually at "~Music/iTunes/iTunes Music Library.xml"        #
# and if you don't specify your own path, this default is assumed):           #
#                                                                             #
#       perl itunes2html.txt > generated_output.html                          #
#                                                                             #
# More help is available with: perl itunes2html.txt --help                    #
###############################################################################
# changes (2007-05-12, version 2.4):                                          #
#   - add "Added" column with YYYY-MM-DD of album addition.                   #
#                                                                             #
# changes (2005-03-30, version 2.3):                                          #
#   - if artist has parens, treat it as an alias for previous artist.         #
#     (this will occasionally fail if you have no albums by the alias'        #
#     real monniker. this is a known, but low priority, bug.                  #
#                                                                             #
# changes (2004-08-11, version 2.2):                                          #
#   - tweaked help documentation a tiny bit. no worries.                      #
#   - if the new "Compilation" flag is set, use "Various Artists".            #
#   - artist-album's longer than 81 characters are now truncated.             #
#   - the proper "added within" date is now shown (from cmd flag).            #
#   - if a genre has less then ten artists, only display one header.          #
#                                                                             #
# changes (2003-12-08, version 2.1):                                          #
#   - we now attempt to detect which albums have VBR tracks.                  #
#   - we automatically skip over Griffin Technology peripherals.              #
#   - if an album name is not found, we use "Unknown Album" instead.          #
#   - if an artist name is not found, we use "Unknown Artist" instead.        #
#   - confirmed it works on Win32 (though you'll need ActiveState Perl).      #
#   - fixed bug with next'ing too quick for people with crappy id3 tags.      #
#   - fixed bug with assuming a "Disc Count" would exist. more crappy tags.   #
#   - a new --addedwithin option allows you to choose how many days ago an    #
#     added album should be considered "new" and thus colored in the HTML.    #
#                                                                             #
# changes (2003-09-01, version 2.0):                                          #
#   - you can now hardcode your library path in $library.                     #
#   - much stronger and more readable stylesheets/display.                    #
#   - fixed case-insensitive sorting bug. i'm a retard.                       #
#   - HTML comments for proper sorting no longer needed.                      #
#   - you can show non-alphanumeric albums is you want.                       #
#   - final file size shrunken even further.                                  #
#   - we now show lowest bitrate of an album.                                 #
#                                                                             #
# changes (2003-02-03, version 1.0):                                          #
#   - stylesheet built in, not off of disobey.com.                            #
#   - spelling and wording corrections.                                       #
#   - help dialog and command line options.                                   #
#   - can process songs that are missing track or disc numbers (at            #
#     the expense of losing some display features. fix 'em, dammit!).         #
#   - sorting comments are removed from output, making page size smaller.     #
#   - HTTP::Date is now optional (error is spit, but progress continues).     #
###############################################################################

# if you want to hardcode your library path,
# specify it here. command line overrides this.
my $library = "$ENV{HOME}/Music/iTunes/iTunes Music Library.xml";

# the following bitrates are used to determine whether a track
# should be consider variably encoded (a VBR). if the track bitrate
# does not match one of these, then we assume the rest of the album
# is encoded as a VBR, and we make note of that in the final HTML
# listing. this works around the misnomer that an album with a
# "lowest bitrate of 107" is actual "low quality". (note, this CAN
# be faulty is an album has been VBR'd with a minimum of something
# insane like 192k - in whic case, all tracks could be conceivably
# 192k, but still VBR. using JUST the iTunes XML, there's not much
# I can do about this, and a true solution is more complicated).
my $bitrates = "32 56 64 96 112 128 160 192 256 320";

# no modification/reading below this line is necessary.
# dedicated to all those shareware people that charge
# money for relatively mindless tasks such as this.

###############################################################################
# our options matrix. see the comments here, or a -h on the command line.     #
###############################################################################
my %options; $options{addedwithin} = 30;      # default to last 30 days.
GetOptions(\%options, 'help|h|?',             # print out our help dialog.
                      'listallalbums',        # even non-alphanumeric ones.
                      'missingdiscnumbers',   # ignore missing disc numbers.
                      'missingtracknumbers',  # ignore missing track numbers.
                      'addedwithin=i',        # "new" albums in this many days.
);

###############################################################################
# spit out our help if necessary (either, it's been requested via the command #
# line, or no one filled in the path to the itunes library xml file.          #
###############################################################################
if ($options{help} or (!$library and !$ARGV[0])) { print <<"END_OF_HELP";
itunes2html - converts your music library into an html page.
Usage: perl itunes2html.txt [OPTION] [FILE]...
 (typically "~/Music/Itunes/iTunes Music Library.xml")

  -h, -?, --help         Display this message and exit.

  --addedwithin          An album added within this many days should be
                         considered "new" and is colored thusly in the
                         HTML display (assumes HTTP::Date is installed).

  --listallalbums        Normally, if an album title does NOT start with
                         letters or numbers, we would remove it from display.
                         If you'd like them to be listed anyways, use this.

  --missingdiscnumbers   If your tracks aren't labeled with the "disc # of #"
                         id3 tag, then they're normally ignored by itunes2html.
                         If you'd like itunes2html to accept tracks with this
                         missing information, use this flag. Turning on this
                         option will ignore "disc # of #" for ALL YOUR TRACKS.

  --missingtracknumbers  Tracks that don't have "track # of #" id3 tags are
                         normally ignored for not having "proper" id3 info.
                         If you'd like itunes2html to accept tracks without
                         track numbers, add this flag to your command line.
                         Turning on this option will ignore "track # of #"
                         for ALL YOUR TRACKS.

If you'd like certain albums or tracks not to be listed in the export,
add the pipe character (|) to the beginning of the track's album name.
This filtering is ignored if --listallalbums has been enabled.
Mail bug reports and suggestions to <morbus\@disobey.com>.
END_OF_HELP
exit ;}

###############################################################################
# check to see if the user has the non-default HTTP:: Date installed.         #
# if not, give an error about it and continue with no date checking.          #
###############################################################################
eval("use HTTP::Date;");
my $check_dates = 1; if ($@) {
   print STDERR "ERROR: HTTP::Date is not installed - ".
                "skipping \"last 30 days\" feature.\n";
   $check_dates = 0;
}

# get the path of our XML file and open the bad boy.
my $file = $ARGV[0] || $library; die "$file does not exist.\n" unless -e $file;
open (XML, "<$file") or die "$file could not be opened: $!.";

###############################################################################
# process each line of our XML file.                                          #
###############################################################################
my ($albums, $total_albums, $total_tracks);
$/ = "<dict>"; while (<XML>) {

   next unless /Artist/i; # skips starting <dict> instances.
   s/[\t\r\n\f]//g; # remove all tabs, newlines, and so forth.

   # used in our data structure.
   my ($artist)       = $_ =~ m!<key>Artist</key><string>(.*?)</string>!;
   my ($album)        = $_ =~ m!<key>Album</key><string>(.*?)</string>!;
   my ($track_number) = $_ =~ m!<key>Track Number</key><integer>(.*?)</integer>!;
   my ($disc_number)  = $_ =~ m!<key>Disc Number</key><integer>(.*?)</integer>!;
   my ($compilation)  = $_ =~ m!<key>Compilation</key><(true)/>!;
   next if $artist eq "Griffin Technology"; # itrip and other peripherals.
   $album  = "Unknown Album" unless $album; # holy crap! use a default.
   $artist = "Unknown Artist" unless $artist; # this sucks! use a default.

   # a nasty hack, but workable (thanks Dominic J. Thoreau!).
   if (defined($compilation)) { $artist = "Various Artists"; }

   # skip albums with | as the first char.
   next if ($album =~ /^\|/ && !$options{listallalbums});

   # spit an error if some of this stuff is missing.
   unless ($artist and $album and $track_number and $disc_number) {

      # there's probably a simpler way of doing this.
      my @missing; # a list of missing fields per track.
      push(@missing, "artist") unless defined($artist);
      push(@missing, "album") unless defined($album);
      push(@missing, "track_number") unless defined($track_number);
      push(@missing, "disc_number") unless defined($disc_number);

      # print out the error message to STDERR. boring code here.
      my ($file) = $_ =~ m!<key>Location</key><string>(.*?)</string>!;
      $file =~ s!(file://|localhost|Volumes)!!gi; # garbage for removal.
      $file =~ s/%20/ /g; # quickie URL encoding to happier reading.
      print STDERR "Missing ", join(", ", @missing), " for $file.\n";
   }

   # check our command line options. if either have been set,
   # then we use dummy track and disc numbers for this track.
   # this is regardless if some of the tracks have proper
   # information (hey... fix 'em or get crap, buddy). we
   # do this after we spit out an error to STDERR (above).
   if ($options{missingdiscnumbers}) { $disc_number = 1; }
   if ($options{missingtracknumbers}) { $track_number = 1; }

   # and continue on with some extra information.
   # no disc_count? default to the disc_number. feh.
   my ($disc_count) = $_ =~ m!<key>Disc Count</key><integer>(.*?)</integer>!;
   $albums->{$artist}{$album}{"Disc Count"} = $disc_count || $disc_number;

   # and now the rest of the fields in one fell swoop.
   $albums->{$artist}{$album}{$disc_number}{$track_number}{$1} = $3
     while (m!<key>(.*?)</key><(integer|string|date)>(.*?)</(integer|string|date)>!g);

$total_tracks++; } close(XML);

###############################################################################
# create aggregate information for the album (totals, globals, etc.)          #
###############################################################################
foreach my $artist ( keys %{$albums} ) {
   foreach my $album ( keys %{$albums->{$artist}} ) {

      # make impossible bit rate to start. we use
      # this to determine the smallest bitrate for
      # an entire album (which is then displayed).
      $albums->{$artist}{$album}{"Bit Rate"} = 999;

      # get track counts.
      my $album_total_tracks; # all tracks, regardless of disc.
      for (my $i = 1; $i <= $albums->{$artist}{$album}{"Disc Count"}; $i++) {
         foreach my $track ( keys %{$albums->{$artist}{$album}{$i}} ) {
            $album_total_tracks++; # increment the track counter.

            # has this track been played before? if so, add to the count.
            if ($albums->{$artist}{$album}{$i}{$track}{"Play Count"}) {
               my $play_count = $albums->{$artist}{$album}{$i}{$track}{"Play Count"};
               $albums->{$artist}{$album}{"Play Count"} += $play_count;
            }

            # other global values. we set them here to make our outputting code smaller.
            # we really should set these only if they're not set already. less work.
            $albums->{$artist}{$album}{Comments} = $albums->{$artist}{$album}{$i}{$track}{Comments} || undef;
            $albums->{$artist}{$album}{Genre} = $albums->{$artist}{$album}{$i}{$track}{Genre} || "(blank)";
            $albums->{$artist}{$album}{Year} = $albums->{$artist}{$album}{$i}{$track}{Year} || "????";
            $albums->{$artist}{$album}{"Date Added"} = $albums->{$artist}{$album}{$i}{$track}{"Date Added"};
            $albums->{$artist}{$album}{"Play Count"} |= 0; # if it's not defined, zero it out.

            # we show the lowest bitrate in our output, in hopes
            # this will spur people to find better quality mp3s.
            # some tracks iTunes can't figure out, so skip.
            next unless $albums->{$artist}{$album}{$i}{$track}{"Bit Rate"};
            $albums->{$artist}{$album}{VBR}++ if $bitrates !~ /$albums->{$artist}{$album}{$i}{$track}{"Bit Rate"}/;
            if ($albums->{$artist}{$album}{"Bit Rate"} > $albums->{$artist}{$album}{$i}{$track}{"Bit Rate"}) {
               $albums->{$artist}{$album}{"Bit Rate"} = $albums->{$artist}{$album}{$i}{$track}{"Bit Rate"};
            }
         }
      }

      # finalize our incrementers and totals.
      $albums->{$artist}{$album}{"Track Count"} = $album_total_tracks; $total_albums++;
   }
}

###############################################################################
# now, pretty print everything out. i want one script, so no templating.      #
###############################################################################

my $updated = localtime(time);
print <<EVIL_HEREDOC_HEADER_OF_ORMS_BY_GORE;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Albums in MP3 Format ($updated)</title>
  <style type="text/css">
    .new { background-color: #ffc; }
    h2 { padding-top: 25px; } a { text-decoration: none; }
    body { margin: 1em; font-family: arial, sans-serif; line-height: 1.2em; }
    th { border: 1px solid rgb(196,196,196); background-color: rgb(248,248,248); }
    tr, td { font-size: 12px; border: 1px solid rgb(235,235,235); border-top: 0px; }
    table { border: 1px; margin-left: 5px; margin-right: 5px; padding: 2px; width: 98%; }
    h1, h2, h3 { background-color: transparent; color: #001080; font-family: tahoma, sans-serif; }
  </style>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body>

<h1>Albums in MP3 Format</h1>

<p>Got a list of your own or have questions? Send email to &lt;<a
href="mailto:morbus\@disobey.com">morbus\@disobey.com</a>&gt;. The
below contains listings for <strong>$total_albums albums, comprising
$total_tracks total tracks</strong> and was last generated $updated.
It was <a href="http://www.disobey.com/d/perl/itunes2html.txt">created
by a Perl script from Morbus Iff</a> that reads the exported XML provided
by <a href="http://www.apple.com/itunes/">Apple's iTunes</a>. This
automation is only possible because Morbus is insanely ana... pedantic about the
quality of his id3 tags:</p>

<ul>
  <li>All tracks have <em>Title</em>, <em>Artist</em>, <em>Album</em>, <em>Year</em>, and <em>Track/Disk # of #</em>.</li>
  <li>All tracks have a "more info" URL in their <em>Comments</em>.</li>
  <li>These are full albums only - no singles.</li>
  <li>The script caters to <strong>large</strong> collections.</li>
</ul>
EVIL_HEREDOC_HEADER_OF_ORMS_BY_GORE

# if HTTP::Date is installed, spit out our color information.
if ($check_dates) { print "<p class=\"new\">Albums with this background color have been added in the past $options{addedwithin} days.</p>\n\n"; }

# now, go through each artist and album. we actually add all this stuff
# to genre specific arrays first, since we'll display them in those categories.
my (%genres, $current_genre); # we fixed our damn case sensitive sorting. wow!
foreach my $artist (sort cmp_titles keys %{$albums}) {

   my %pushed_header; # did we push this artist header for this genre?
   my $header = "<tr><th width=\"550\">Album</th><th>Year</th><th>Added</th>" . 
               (defined $options{missingdiscnumbers} ? "" : "<th>Discs</th>") .
              (defined $options{missingtracknumbers} ? "" : "<th>Trks</th>") .
             (defined($options{missingtracknumbers}) ? "" : "<th>Trks Played</th>") .
            "<th>Lowest Bit Rate</th></tr>\n"; # create the header early for pushing to genre.

   # does this artist have a parenthesis in their name? if so,
   # treat it as an alias which should be grouped with previous.
   if ($artist =~ /\(/ && $artist =~ /\)/) { $header = ''; }

   # now go through each album for this artist.
   foreach my $album (sort cmp_titles keys %{$albums->{$artist}}) {
      $current_genre = $albums->{$artist}{$album}{Genre}; # categories.
      $genres{$current_genre} = [] unless defined $genres{$current_genre};
      if (!$pushed_header{$current_genre}) {        # create the html header
         push @{$genres{$current_genre}}, $header;  # for this artist, if we
         $pushed_header{$current_genre}++;          # haven't already done so.
      }

      my $name = "$artist - $album"; # this used to be more uber-complicated.
      my $year = $albums->{$artist}{$album}{Year}; # filler comment! filler!!
      my $play_count = $albums->{$artist}{$album}{"Play Count"};       # shorter.
      my $disc_count = $albums->{$artist}{$album}{"Disc Count"};       # shorter.
      my $track_count = $albums->{$artist}{$album}{"Track Count"};     # shorter.
      my $bitrate =  $albums->{$artist}{$album}{"Bit Rate"} . " kbps"; # shorter.
         $bitrate .= " (VBR)" if $albums->{$artist}{$album}{VBR};      # is VBR?
      if ($bitrate eq "999 kbps") { $bitrate = "????"; } # whazzah wha? why is this?

      # get our comment string and make it a URL. if it's an Amazon
      # URL, make it an affiliate clickthrough. we, of course, only do
      # this if there's a Comments string to be had. bad id3er!
      my $link; if (defined $albums->{$artist}{$album}{Comments}) { 
         $albums->{$artist}{$album}{Comments} =~ s!(http://[^\s<]+)!$1!i;
         if ($albums->{$artist}{$album}{Comments} =~ /amazon.com/)
            { $albums->{$artist}{$album}{Comments} .= "disobeycom"; }
         $link = $albums->{$artist}{$album}{Comments}; # shorter.
         undef $link unless $link =~ /^http/; # if link isn't a url.
      } # this should really be in id3's URL, but iTunes doesn't support it.

      # create a shorter name if necessary and
      # create a linked name if a URL was found.
      if (length($name)>=81) { $name = substr($name,0,81)."..."; }
      if (defined $link) { $name = "<a href=\"$link\">$name</a>"; }

      # when was this album added? if it's within the
      # past 30 days, add a class="new" to our <tr> tag.
      my $class = ""; # turns to "new" if, indeed, it's new.
      if ($check_dates) { # only do this if HTTP::Date is installed.
         my $current_seconds = time; my $added_seconds = str2time($albums->{$artist}{$album}{"Date Added"});
         if (($current_seconds-$added_seconds) < ($options{addedwithin}*24*60*60)) { $class = " class=new"; }
      } my ($added) = $albums->{$artist}{$album}{"Date Added"} =~ m!(\d{4}-\d{2}-\d{2})!;
      # who wishes to rub the back of Morbus Iff?!!

      # now push to our genre array for later printing.
      push @{$genres{$current_genre}}, "<tr$class align=\"center\"><td align=\"left\">$name</td><td>$year</td><td>$added</td>" .
                                       (defined($options{missingdiscnumbers}) ? "" : "<td>$disc_count</td>") .
                                       (defined($options{missingtracknumbers}) ? "" : "<td>$track_count</td>") .
                                       (defined($options{missingtracknumbers}) ? "" : "<td>$play_count</td>") .
                                       "<td>$bitrate</td></tr>\n"; # i am master of 'leet whitespace!
   }
}

# now, print out each genre.
foreach my $genre (sort keys %genres) {

   # if this genre has ten or less albums, we don't
   # show a header for each album - we just merge them
   # all together. we count based on 20 rows (assuming
   # a worse case of ten separate artists and headers).
   if (scalar @{$genres{$genre}} < 20) { my @rgenres;
     push(@rgenres, $genres{$genre}[0]);
     foreach (@{$genres{$genre}}) {
        next if ($_ eq $genres{$genre}[0]);
        if (/<th>/) { next; } else { push(@rgenres, $_); }
   } $genres{$genre} = \@rgenres; } 

   # create a giant string for display.
   my $output = join ("", @{$genres{$genre}});

   # print this crazy chicken.
   print "<h2>$genre:</h2>\n\n"; # bacCoOOCkckck! bacooOCocock!
   print "<div align=\"center\"><table>$output</table></div>\n";
} print "</body>\n</html>";

# ignore non-worthy text.
# thanks Mark Donovan.
sub cmp_titles {
  my ($ta, $tb);
  ($ta = $a) =~ s/^(A|An|The) (.*)$/$2, $1/i;
  ($tb = $b) =~ s/^(A|An|The) (.*)$/$2, $1/i;
  return lc $ta cmp lc $tb;
}

