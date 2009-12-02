use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "1.0.0";
%IRSSI = (
    authors => "Pieter-Bas IJdens",
    contact => "irssi-scripts\@nospam.mi4.org.uk",
    name    => "color",
    description => "Add some color! Now you can be a lamer too!",
    license => "GPLv2 or later",
    url     => "http://pieter-bas.ijdens.com/irssi/",
    changed => "2005-03-10"
);


###############################################################################
#
# AUTHOR:
# Pieter-Bas IJdens
# irssi-scripts@nospam.mi4.org.uk
#
# DESCRIPTION:
# Bug ugly hacked script to display some crap in color
# so I can be a lamer too. Use at own risk.
#
###############################################################################

# No      N               H       S       V
# 1       Black           160     0       0
# 14      B Black         160     0       80
# 5       Red             0       240     88
# 7       Yellow          40      240     88
# 3       Green           80      240     88
# 10      Cyan            120     240     88
# 2       Blue            160     240     88
# 6       Magenta         200     240     88
# 4       B Red           0       240     160
# 8       B Yellow        40      240     160
# 9       B Green         80      240     160
# 11      B Cyan          120     240     160
# 12      B Blue          160     240     160
# 13      B Magenta       200     240     160
# 15      White           160     0       176
# 16      B White         160     0       240

# zwart bruin rood oranje geel groen blauw violet grijs wit

my($ascii_dir) = "$ENV{HOME}/.irssi/ascii";

my @order = (1,14,5,7,3,10,2,6,4,8,9,11,12,13,15,16);
my @fg_colors = (14,5,7,3,10,2,6,4,8,9,11,12,13,15,16);
my @rainbow = (0, 0, 5, 4, 7, 8, 9, 3, 12, 2, 10, 11, 13, 6);
my @italian = (3, 16 ,5);

sub round_up
{
    my($num) = @_;

    if ($num - int($num) != 0)
    {
        return int($num + 1);
    }

    return int($num);
}

sub print_ls
{
    my($dir) = @_;

    my($file) = open(FILE, "ls $dir|");

    if (!$file)
    {
        Irssi::print("huh?");
        return;
    }

    my(@result) = <FILE>;

    chomp(@result);

    close(FILE);

    Irssi::print("Files: " . join(', ', @result) . ".");
}

sub figlet
{
    my($text, $font) = @_;

    if (!defined($font)) { $font = ""; } else { $font = "-f $font "; }
    my($file) = open(FILE, "figlet -w 64 $font '$text'|");

    if (!$file)
    {
        Irssi::print("Cannot open \"figlet -w 64 $font'$text'\"");
        return ();
    }

    my(@result) = <FILE>;

    chomp(@result);

    close(FILE);

    return @result;
}

sub ascii
{
    my($filename) = @_;

    my($file) = open(FILE, "$ascii_dir/$filename");

    if (!$file)
    {
        Irssi::print("Cannot open \"$ascii_dir/$filename\"");

        print_ls($ascii_dir);
        return ();
    }

    my(@result) = <FILE>;

    chomp(@result);

    close(FILE);

    return @result;
}

sub cmd_csay 
{
    my ($data, $server, $witem) = @_;
    if (!$server || !$server->{connected}) 
    {
        Irssi::print("Not connected to server");
        return;
    }

    my($i, $color, $result) = (0, 1, "");
    my(@chars) = split(//, $data);
    my($modulo) = round_up(scalar(@chars) / 14);

    foreach my $char (@chars)
    {
        if($i == 0)
        {
            $color++;
            if ($color >= scalar(@order)) { $color = scalar(@order) - 1; }
            $i = $modulo;
            $result .= "\003$order[$color]";
            if ($char =~ /[,]/) { $result .= ","; }
            elsif ($char =~ /[0-9]/) { $result .= ",01"; }
        }

        $result .= $char;

        $i--;
    }
    
    $witem->command("/SAY $result");
}

sub cmd_itsay
{
    my ($data, $server, $witem) = @_;
    if (!$server || !$server->{connected}) 
    {
        Irssi::print("Not connected to server");
        return;
    }

    my($i, $color, $result) = (0, 0, "");
    my(@chars) = split(//, $data);
    my($modulo) = round_up(scalar(@chars) / 3);

    foreach my $char (@chars)
    {
        if($i == 0)
        {
            if ($color >= scalar(@italian)) { $color = scalar(@italian) - 1; }
            $i = $modulo;
            $result .= "\003$italian[$color]";
            if ($char =~ /[,]/) { $result .= ","; }
            elsif ($char =~ /[0-9]/) { $result .= ",01"; }
            $color++;
        }

        $result .= $char;

        $i--;
    }
    
    $witem->command("/SAY $result");
}

sub cmd_rainbow
{
    my ($data, $server, $witem) = @_;
    if (!$server || !$server->{connected}) 
    {
        Irssi::print("Not connected to server");
        return;
    }

    my($i, $color, $result) = (0, 1, "");
    my(@chars) = split(//, $data);
    my($modulo) = round_up(scalar(@chars) / 14);

    foreach my $char (@chars)
    {
        if($i == 0)
        {
            $color++;
            if ($color >= scalar(@rainbow)) { $color = scalar(@rainbow) - 1; }
            $i = $modulo;
            $result .= "\003$rainbow[$color]";
            if ($char =~ /[,]/) { $result .= ","; }
            elsif ($char =~ /[0-9]/) { $result .= ",01"; }
        }

        $result .= $char;

        $i--;
    }
    
    $witem->command("/SAY $result");
}

sub cmd_figlet
{
    # Irssi::print("Disabled");
    # return;

    my ($data, $server, $witem) = @_;
    if (!$server || !$server->{connected}) 
    {
        Irssi::print("Not connected to server");
        return;
    }

    my(@figlet) = figlet($data);

    foreach my $line (@figlet)
    {
        if ($line =~ /\S/)
        {
            my($fg) = shift(@fg_colors);
            @fg_colors = (@fg_colors, $fg);

            $witem->command(
                "/SAY ".
                sprintf("\003%02d", $fg) .
                "$line"
            );
        }
    }
}

sub cmd_cascii
{
    my ($data, $server, $witem) = @_;
    if (!$server || !$server->{connected}) 
    {
        Irssi::print("Not connected to server");
        return;
    }

    my(@figlet) = ascii($data);

    foreach my $line (@figlet)
    {
        if ($line =~ /\S/)
        {
            my($fg) = shift(@fg_colors);
            @fg_colors = (@fg_colors, $fg);

            $witem->command(
            "/SAY ".
                sprintf("\003%02d", $fg) .
        $line);
        }
        else
        {
            $witem->command("/SAY     ");
        }
    }
}

sub cmd_ascii
{
    my ($data, $server, $witem) = @_;
    if (!$server || !$server->{connected}) 
    {
        Irssi::print("Not connected to server");
        return;
    }

    my(@figlet) = ascii($data);

    foreach my $line (@figlet)
    {
        if ($line =~ /\S/)
        {
            my($fg) = shift(@fg_colors);
            @fg_colors = (@fg_colors, $fg);

            $witem->command("/SAY $line");
        }
        else
        {
            $witem->command("/SAY     ");
        }
    }
}

Irssi::command_bind('csay', 'cmd_csay');
Irssi::command_bind('itsay', 'cmd_itsay');
Irssi::command_bind('rainbow', 'cmd_rainbow');
Irssi::command_bind('figlet', 'cmd_figlet');
Irssi::command_bind('ascii', 'cmd_ascii');
Irssi::command_bind('cascii', 'cmd_cascii');
