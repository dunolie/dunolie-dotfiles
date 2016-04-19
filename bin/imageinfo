#!/usr/bin/env perl
# use the Exif module
use Image::ExifTool 'ImageInfo';
# if no filename is in @ARGS, exit
my $file = shift or die "Please specify filename";
# create an object for the file
my $info = ImageInfo($file);
foreach (sort (keys %$info) ) {
    # then print out the EXIF data
    print "$_ : " .  $info->{$_} . "\n";
}
