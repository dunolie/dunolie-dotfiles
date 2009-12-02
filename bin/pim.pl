#!/usr/bin/perl -w
use strict;

#### Update these constants if you like ####################
my $PIM_PATH = "./pim/";
my $TMP_TXT_FILE = "tmp.txt";
my $TMP_PS_FILE = "tmp.ps";

my $EDITOR = "vim";
my $VIEWER = "less";
my $PS_VIEWER = "/Applications/Preview.app";
my $MONTHS_IN_CAL = 12;
my $FILE_PATH = "./pim";
my $CONTACT_FILE = "contacts.txt";
my $TASK_FILE = "tasks.txt";
my $WORDS_FILE = "word_list.txt";
my $NOTEBOOK_FILE = "notebook.txt";
my $QUOTES_FILE = "quotes.txt";
############################################################

for(;;) {
    system("clear");
    print "=======================\n";
    print "My PIM (Ctrl-C to edit)\n";
    print "=======================\n";
    print "1. Edit reminders \n";
    print "2. Edit contacts\n";
    print "3. Edit tasks\n";
    print "4. Show tasks\n";
    print "5. View calendar (ps)\n";
    print "6. View calendar (txt)\n";
    print "7. Print calendar\n";
    print "8. Show system cal\n";
    print "9. Show todays reminders\n";
    print "-------------------\n";
    print "-1. Edit word list\n";
    print "-2. Edit notebook\n";
    print "-3. Edit quotes\n";
    print "-4. View quotes\n";
    print "=======================\n";
    print "-> ";
    my $s = <STDIN>;
    chop($s);

    if ($s == 1) {
	system($EDITOR . " ~/.reminders");
    }
    elsif ($s == 2) {
	my $file = $FILE_PATH . $CONTACT_FILE;
	system($EDITOR . " $file");
    }
    elsif ($s == 3) {
	my $file = $FILE_PATH . $TASK_FILE;
	system($EDITOR . " $file");
    }
    elsif ($s == 4) {
		system("clear");
		show_tasks();
    }
    elsif ($s == 5) {
	my $file = $FILE_PATH . $TMP_PS_FILE;
	system("remind -p$MONTHS_IN_CAL ~/.reminders | rem2ps -l -sd 18 > $file");
	system("open $PS_VIEWER $file");
    }
    elsif ($s == 6) {
	my $file = $FILE_PATH . $TMP_TXT_FILE;
	print("remind -c$MONTHS_IN_CAL ~/.reminders > $file");
	system($VIEWER . " $file");
    }
    elsif ($s == 7) {
	my $file = $FILE_PATH . $TMP_PS_FILE;
	system("lpr $file");
    }
    elsif ($s == 8) {
	system("cal");
    }
    elsif ($s == 9) {
	system("rem");
    }
    elsif ($s == -1) {
	my $file = $FILE_PATH . $WORDS_FILE;
	system($EDITOR . " $file");
    }
    elsif ($s == -2) {
	my $file = $FILE_PATH . $NOTEBOOK_FILE;
	system($EDITOR . " $file");
    }
    elsif ($s == -3) {
	my $file = $FILE_PATH . $QUOTES_FILE;
	system($EDITOR . " $file");
    }
    elsif ($s == -4) {
	my $file = $FILE_PATH . $QUOTES_FILE;
	system($EDITOR . " $file");
    }
    print "** press return to continue **\n";
    $s = <STDIN>;

}

sub show_tasks {
    
    my $file = $FILE_PATH . getPrefVal("tasks-file");
    open(INPUT, "< $file")
	|| die "could not open file in $file: $!\n";

    my $tmpFile = $FILE_PATH . getPrefVal("tasks-file") . ".tmp";
    open(OUTPUT, "> $tmpFile")
	or die "could not open file out $tmpFile: $!\n";

    my $cnt = 0;
    my @open_tasks = "";
    my @closed_tasks = "";
    my $status = "";
    my $item = "";
    my $description = "";
    while(<INPUT>) {
	my $line = $_;
	chop($line);
	my $token = substr($line, 0, 1);
	
	if ($token eq "-") {
	    $cnt++;
	}

	if ($cnt == 3) {
	    $cnt = 0;

	    $item .= "\n".$description;

	    if ($status eq "open") {
		push(@open_tasks, $item);
	    }
	    elsif ($status eq "closed") {
		push(@closed_tasks, $item);
	    }
	    else {
		print "error\n";
		exit;
	    }
	}
	
	if ($line ne "") {
	    my @chunk = split(/:/, $line);
	        
	    if ($chunk[0] eq "Item") {
		$item = trim($chunk[1]);
		$item .= ":";
	    }
	    elsif ($chunk[0] eq "Status") {
		$status = trim($chunk[1]);
		$item .= $chunk[1];
		$item .= ":";
	    }
	    elsif ($chunk[0] eq "Catagory") {
		$item .= $chunk[1];
		$item .= ":";
	    }
	}
    }

    my $t = time;
    my $s = localtime($t);

    print OUTPUT "----------\n";
    print OUTPUT "Task List: $s\n";

    print OUTPUT "\n";
    print OUTPUT "Open Tasks\n";
    print OUTPUT "----------\n";
    foreach $item (@open_tasks) {
	if ($item ne "") {
	    my @chunk = split(/:/, $item);
	    $chunk[1] = trim($chunk[1]);
	    print OUTPUT "  * $chunk[0] ($chunk[1])\n";
	}
    }
    print OUTPUT "\n";
    print OUTPUT "Closed Tasks\n";
    print OUTPUT "------------\n";
    foreach $item (@closed_tasks) {
	if ($item ne "") {
	    my @chunk = split(/:/, $item);
	    $chunk[1] = trim($chunk[1]);
	    print OUTPUT "  * $chunk[0] ($chunk[1])\n";
	}
    }
    
    print OUTPUT "----------\n";
    close INPUT;
    close OUTPUT;
    
    system($VIEWER . " " . $tmpFile);
}


# Log an error and exit; adds newline to message.
sub logExit {
    my ($msg) = @_;
    print "$msg\n";
    exit;
}


# From the PerlCookbook, 1st edition, p. 30.
sub trim {
    my @out = @_;
    for (@out) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @out : $out[0];
}
