##!/usr/bin/env perl
#
# DO NOT USE ON ORIGINALS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# http://skywind8.livejournal.com/281246.html?thread=569502
# ------------------------------------------------------------------------
# Perl script to go through a subdir tree and mogrify -quality Q -resize HxW *.jpg


$ENABLED = 1;  # 1 or 0 for whether to actually DO the mogrify command, vs just print it. (1=do,0=print)

$Q = 90; 	# Quality percentage for jpg compression
$H = 650; 	# Height (max) to resize to
$W = 650; 	# Width  (max) to resize to

$mogrify = "/opt/local/bin/mogrify"; 	# Path to the ImageMagick mogrify command

#@CWD = "";

print "This will mogrify all jpg images in subdirectories below '.' \n\n";
print "You can set ENABLED = 0 to do a trial run (print but not run mogrify).\n";
if ($ENABLED) { print "\nMOGRIFY IS CURRENTLY ENABLED!!\n"; }
print "Press Enter to begin...\n";

$ZZ = <STDIN>;


&Main();

# ------------------------------------------------------------------------

sub Main {
   opendir(CURRENTDIR, ".") || die "Couldn't open . -- $!";
   @topdirs = readdir(CURRENTDIR);
   closedir(CURRENTDIR);

   foreach $childdir (@topdirs) {
	next if ("." eq $childdir);
	next if (".." eq $childdir);

	if (-d $childdir) {
		chdir("$childdir") || die "$!\n";
		push(@CWD, $childdir);
		recurseAndResize();
		pop(@CWD);
		chdir("..") || die "$!\n";
	}
   }

}

# ------------------------------------------------------------------------
sub recurseAndResize() {
	my($child);
	my(@children);

	print "\n." . join("/", @CWD) . "\n";
	opendir(CURRENTDIR, ".") || die "Couldn't open . -- $!";
	@children = readdir(CURRENTDIR);
	closedir(CURRENTDIR);


	foreach $child (@children) {
		next if ("." eq $child);
		next if (".." eq $child);
		if (-f $child) {
			next unless ($child =~ m/.jpg$/i);
			$cmd = "$mogrify -quality $Q -resize ${H}x${W} $child";
			print "$cmd\n";
			if ($ENABLED) { print `$cmd`; }
		}
	}
	foreach $child (@children) {
		next if ("." eq $child);
		next if (".." eq $child);
		if (-d $child) {
			chdir("$child") || die "$!\n";
			push(@CWD, $child);
			recurseAndResize();
			pop(@CWD);
			chdir("..") || die "$!\n";
		}
	}	
}

# ------------------------------------------------------------------------
