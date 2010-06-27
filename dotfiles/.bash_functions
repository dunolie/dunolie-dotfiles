#!/usr/bin/env bash
# -------------------------------------------------------------------------------
#         Author: Robbie -- dunolie (at) gmail (dot) com
#      File name: .bash_functions  ($HOME/.bash_functions)
#        Created: Fri 11 Jun 2010 03:05:37 am BST
#  Last Modified: Fri 11 Jun 2010 03:05:25 am BST
#    Description: my bash functions ~/.bash_functions
#       Comments: also sourcing ~/.fff for more functions
# -------------------------------------------------------------------------------
# open app = $ oa textedit foo.txt
function oa () {
if [[ -f ~/bin/launch ]]; then
	launch -a "$@"
else
	$app=`find /Applications/ -name “*.app” | grep $1`;
	shift;
	open -a “$app/” “$2″;
fi
}

# http://code.google.com/p/wkhtmltopdf
function web2pdf {
	wkhtmltopdf -q --ignore-load-errors "$1" "$2"
}

function wiki-search () { dig +short txt "$*".wp.dg.cx; }

function 500-500 () {
	sips -z 500 500 "$@" > /dev/null 2>&1
}

function 200-200 () {
	sips -z 200 200 "$@" > /dev/null 2>&1
}

function mirror () {
	rsync -avh "$1" "$2"
}

function mk-dir-date () {
	mkdir "$@"\ `date +%Y-%m-%d`
}

function mp3-add-cover () {
	eyeD3 --remove-images "$@" *.mp3 >/dev/null 2>&1
	cp "$@" tmpCover.jpg 
	#eyeD3 --add-image :FRONT_COVER *.mp3 >/dev/null 2>&1
	eyeD3 --add-image=tmpCover.jpg:FRONT_COVER *.mp3 >/dev/null 2>&1
	#
	echo "Cover images have been successfully added."
	growlnotify --image=tmpCover.jpg -s -t "Album art added" -m "$(echo $PWD)"
	#
	rm tmpCover.jpg
}

function cover-grab () {
	mkdir Art
	eyeD3 --write-images="`pwd`/Art/" "$@"
	if [[ -f "`pwd`/Art/FRONT_COVER.*" ]]; then
		cp `pwd`/Art/FRONT_COVER.* ../Cover.jpg
	fi
	if [[ -f "`pwd`/Art/OTHER.*" ]]; then
		cp `pwd`/Art/OTHER.* ../Cover.jpg
	fi
	growlnotify --image=Cover.jpg -t "Album art grabbed" -m "$(echo $PWD)"
}

function genre-mp3 () {
	eyeD3 -G "$@" *.mp3
}

function year-mp3 () {
	eyeD3 -Y "$@" *.mp3
}

function rm-images-mp3 () {
	eyeD3 --remove-images "$@" *.mp3
}

function rm-comments-mp3 () {
	eyeD3 --remove-comments "$@" *.mp3
}

# use the gimage script to download images from google to the $PWD
function gim () {
	gimage "$@"
	#ql *jpg
	#l *.jpg
}

function paste () {
	cat "$@" | pastebinit | pbcopy && echo "Link is in the clipboard"
}

function pasteclip () {
	pbpaste | pastebinit | pbcopy && echo "Link is in the clipboard"
}


# usage: helpme <program>
function helpme () { "$@" --help 2>&1 |less -S;}

# github clone  sorts close by /github-user/project
# http://openmonkey.com/articles/2009/07/fast-github-clone-bash-function
function ghclone () {
  gh_url=${1:-`pbpaste`}
  #co_dir=${HOME}/Code/sources/$(echo $gh_url | sed -e 's/^git:\/\/github.com\///; s/\//-/; s/\.git$//')
  co_dir=${HOME}/Code/sources/$(echo $gh_url | sed -e 's/^http:\/\/github.com\///; s/\//-/; s/\.git$//')
  if [ -d $co_dir ]; then
    cd $co_dir && git pull origin master
  else
    git clone "${gh_url}" "${co_dir}" && cd "${co_dir}"
  fi
}

function rename-ext () {
   local filename
   for filename in *."$1"; do
     mv "$filename" "${filename%.*}"."$2"
   done
}


function calculator () { awk "BEGIN{ print $* }" ;}

# If you issue 'h' on its own, then it acts like the history command.
# If you issue:h cdThen it will display all the history with the word 'cd'
function :h () { if [ -z "$1" ]; then history; else history | grep "$@"; fi;}

# view manpages with vim (manpageviewer vim script required)
function vman () {
 /usr/bin/whatis "$@" >/dev/null

 if [ $? -eq 0 ]; then
 vim -c "Man $*" -c 'silent! only' -c 'nmap q :q<CR>'
 else
 man "$@"
 fi
}

function gpush () {
if [[ $(local-ip) = "192.168.2.10" ]]; then
		git push origin master:dunolie-desktop
	else
		git push origin master:dunolie-laptop
fi
}

fpp () { osascript -e 'tell application "Finder" to get POSIX path of (target of window 1 as alias)' | pbcopy; }
fpwd () { osascript -e 'tell application "Finder" to get POSIX path of (target of window 1 as alias)'; }
md () { mkdir -p "$1" && cd "$1"; }

function    c                { clear; }
function    hc               { history -c; }
function    hcc              { hc;c; }

function    z                { suspend $@; }
function    j                { jobs -l $@; }
function    rmd              { rm -fr $@; }

function    mfloppy          { mount /dev/fd0 /mnt/floppy; }
function    umfloppy         { umount /mnt/floppy; }

function    mdvd             { mount -t iso9660 -o ro /dev/dvd /mnt/dvd; }
function    umdvd            { umount /mnt/dvd; }

function    mcdrom           { mount -t iso9660 -o ro /dev/cdrom /mnt/cdrom; }
function    umcdrom          { umount /mnt/cdrom; }

function    miso             { mount -t iso9660 -o ro,loop $@ /mnt/iso; }
function    umiso            { umount /mnt/iso; }

function    ff               { find . -name $@ -print; }

function    psa              { ps aux $@; }
function    psu              { ps  ux $@; }

function    lpsa             { ps aux $@ | p; }
function    lpsu             { ps  ux $@ | p; }

function    dub              { du -sclb $@; }
function    duk              { du -sclk $@; }
function    dum              { du -sclm $@; }
function    duh              { du -sclh $@; }

function    dfk              { df -PTak $@; }
function    dfm              { df -PTam $@; }
function    dfh              { df -PTah $@; }
function    dfi              { df -PTai $@; }

function    dmsg             { dmesg | p; }

function    kernfs           { p /proc/filesystems; }
function    shells           { p /etc/shells; }

function    lfstab           { p /etc/fstab; }
function    lxconf           { p /etc/X11/xorg.conf; }

if [ `id -u` -eq 0 ]; then
	function    efstab       { e /etc/fstab; }
	function    exconf       { e /etc/X11/xorg.conf; }
	function    txconf       { X -probeonly; }
fi

# ---------------------------------------------
# sudo vim
function svim {
	sudo vim $@
}

# create a directory and make it the working directory
function mkcd {
	mkdir -p $1
	cd $1
}

# download and untargz
function dtgz {
if [ $# -gt 0 ]; then
	for l in $@; do
		curl $l | tar -xz
	done
	else
		echo "Usage: dtgz url [url2, url3, ...]" 1>&2
fi
}

# ---------------------------------------------

# Displays the titles and their length in a VIDEO_TS folder
function dvdinfo() {
	mplayer dvd:// -dvd-device $1 -identify -ao null -vo -null -frames 0 | grep '^ID_DVD'
}

# ---------------------------------------------

# Set hostname in hardstatus line in screen
#if [ “$TERM” == “screen” ]; then
#function ssh() {
#	echo -n -e “\033k$1\033\134″
#		/usr/bin/ssh $@
#	echo -n -e “\033k`hostname -s`\033\134″
#}

#function telnet() {
#	echo -n -e “\033k$1\033\134″
#	/usr/bin/telnet $@
#	echo -n -e “\033k`hostname -s`\033\134″
#}

# We’re on localhost
#	echo -e “\033k`hostname -s`\033\134″
#fi

# ---------------------------------------------

# ---------------------------------------------

# save bookmarks to folders = cd foo
# list your "bookmarks" with the show command = show foo
if [ ! -f ~/.dirs ]; then  # if doesn't exist, create it
	touch ~/.dirs
fi

alias show='cat ~/.dirs'
save (){
	command sed "/!$/d" ~/.dirs > ~/.dirs1; mv ~/.dirs1 ~/.dirs; echo "$@"=\"`pwd`\" >> ~/.dirs; source ~/.dirs ; 
}

source ~/.dirs  # Initialization for the above 'save' facility: source the .sdirs file
shopt -s cdable_vars # set the bash option so that no '$' is required when using the above facility

# bash completion settings (actually, these are readline settings)
bind "set completion-ignore-case on" # note: bind is used instead of setting these in .inputrc.  This ignores case in bash completion
bind "set bell-style none" # No bell, because it's damn annoying
bind "set show-all-if-ambiguous On" # this allows you to automatically show completion without double tab-ing

# Turn on advanced bash completion if the file exists (get it here: http://www.caliban.org/bash/index.shtml#completion)
if [ -f /etc/bash_completion ]; then
     . /etc/bash_completion
fi

# ---------------------------------------------

# grepfind: to grep through files found by find, e.g. grepf pattern '*.c'
# note that 'grep -r pattern dir_name' is an alternative if want all files 
grepfind () { find . -type f -name "$2" -print0 | xargs -0 grep "$1" ; }

# enquote: surround lines with quotes (useful in pipes) - from mervTormel
enquote () { /usr/bin/sed 's/^/"/;s/$/"/' ; }

# fixlines: edit files in place to ensure Unix line-endings
fixlines () { /usr/bin/perl -pi~ -e 's/\r\n?/\n/g' "$@" ; }

# ffs: to find a file whose name starts with a given string
ffs () { /usr/bin/find . -name "$@"'*' ; }

# ffe: to find a file whose name ends with a given string
ffe () { /usr/bin/find . -name '*'"$@" ; }

# zipf: to create a ZIP archive of a folder
zipf () { zip -r "$1".zip "$1" ; }

word () { grep $1 /usr/share/dict/web2 grep $1 /usr/share/dict/web2a ; }

clock () { echo "===========";date +"%r";echo "===========" ; }

# ---------------------------------------------
##-- GNU GPG -----------

encrypt ()
{
gpg -se -r $USER "$1"
}

decrypt ()
{
gpg -d "$1"
}

# ---------------------------------------------

##-- GO -----------

function go {
	go_is_on_path="`\which go`"
	if test -e "$go_is_on_path"; then
		export GO_SHELL_SCRIPT=$HOME/.__tmp_go.sh
		python `\which go` $*
		if [ -f $GO_SHELL_SCRIPT ] ; then
			source $GO_SHELL_SCRIPT
		fi
	else
		echo "ERROR: could not find 'go' on your PATH"
	fi
}

# ---------------------------------------------
#function pushd () {
    #builtin pushd "$@" > /dev/null
#}


# Automatically do an ls after each cd
function cd () {
	if [ -n "$1" ]; then
		builtin cd "$@" && ls && pushd . > /dev/null
	else
		builtin cd ~ && ls && pushd . > /dev/null
	fi
}

# ---------------------------------------------

# Copy and paste from the command line
function ccopy () {
	cp $1 /tmp/ccopy.$1;
}

# cpaste is in ~/.aliases.bash
# alias cpaste="ls /tmp/ccopy* | sed 's|[^\.]*.\.||' | xargs -I % mv /tmp/ccopy.% ./%"

# ---------------------------------------------

# SSH Enviroments
# if ($?SSH_CLIENT) then
#     eval `/usr/local/bin/parseEnvironmentPlist.rb`
#  endif
# fi

# ---------------------------------------------

weather ()
{
declare -a WEATHERARRAY
WEATHERARRAY=( `lynx -dump http://google.com/search?q=weather+$1 | grep -A 5 '^ *Weather for' | grep -v 'Add to'`)
echo ${WEATHERARRAY[@]}
}
# ---------------------------------------------

#Translate a Word  - USAGE: translate house spanish  # See dictionary.com for available languages (there are many).
translate () { 
	lng1="$1";lng2="$2";shift;shift; wget -qO- "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=${@// /+}&langpair=$lng1|$lng2" | sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/';
}

# ---------------------------------------------

# Define a word - USAGE: define dog
define ()
{
lynx -dump "http://www.google.com/search?hl=en&q=define%3A+${1}&btnG=Google+Search" | grep -m 3 -w "*"  | sed 's/;/ -/g' | cut -d- -f1 > /tmp/templookup.txt
			if [[ -s  /tmp/templookup.txt ]] ;then	
				until ! read response
					do
					echo "${response}"
					done < /tmp/templookup.txt
				else
					echo "Sorry $USER, I can't find the term \"${1} \""				
			fi	
rm /tmp/templookup.txt
}

# ---------------------------------------------

# pman -- create, print, save, view PDF man pages

# Author: ntk
# License: The MIT License, Copyright (c) 2007 ntk
# Description: (batch) convert man pages into PDF documents and save them to a specified directory; (batch) print or view PDF man pages from the # command line
# Platform: Mac OS X 10.4.10; man bash
# Installation: put pman() into ~/.bash_login (or alternatives)


# Usage:
## pman ls; pman getopts                                 # convert a single man page to a PDF file, save and open it
## pman 8 sticky                                         # same with manual section number
## pman m toe
## pman -b ls 'open(2)' dd "chmod(2)" curl 'open(n)'     # batch convert man pages into PDF files
## pman -p rm srm open\(2\) 'toe(m)' 'ncurses(3)'        # print man pages using the default printer


pman() {
section="$1"
manpage="$2"

mandir="/Users/Shared/pdf-man-pages"    #  save the created PDF man pages to the specified directory


# batch process man pages to PDF files with the "-b" switch and save them to $mandir
# example: pman -b ls 'open(2)' dd 'chmod(2)' 'open(n)' 'sticky(8)'
# cf. man -aW open for "man n open"

if [[ "$1" = "-b" ]]; then

if [[ ! -d $mandir ]]; then
   mkdir -p $mandir
   chmod 1777 $mandir
fi

shift   # remove "-b" from "$@"

for manfile in "$@"; do

# example for $manfile: open(2)
manpage="`echo $manfile | grep -Eos '^[^\(]+'`"                              # extract name of man page
section="`echo $manfile | grep -Eos '\([^\)]+\)' | grep -Eos '[^\(\)]+'`"    # extract section of man page

if [[ ! "$section" ]]; then
   section="1"
fi

if [[ ! -f "`man ${section} -W ${manpage} 2>/dev/null`" ]]; then
#if [[ ! -f "`man -W ${section} ${manpage} 2>/dev/null `" ]]; then
   echo "No such man page: man ${section} ${manpage}"
   continue
fi

manfile="${mandir}/${manpage}(${section}).pdf"
echo "$manfile"

if [[ ! -f "$manfile" ]]; then
   man $section -t $manpage 2>/dev/null | pstopdf -i -o "$manfile" 2>/dev/null
   chmod 1755 "$manfile"
   # hide file extension .pdf
   if [[ -f /Developer/Tools/SetFile ]]; then /Developer/Tools/SetFile -a E "$manfile"; fi
fi

done

return 0

fi          # END of batch processing man pages to PDF files



# print PDF man pages using the default printer (see man lpr and man lpoptions)
# if necessary, create the specified PDF man pages and save them to $mandir
# example: pman -p rm srm

if [[ "$1" = "-p" ]]; then

if [[ ! -d $mandir ]]; then
   mkdir -p $mandir
   chmod 1777 $mandir
fi

shift   # remove "-p" from "$@"

for manfile in "$@"; do

# example for $manfile: open(2)
manpage="`echo $manfile | grep -Eos '^[^\(]+'`"                              # extract name of man page
section="`echo $manfile | grep -Eos '\([^\)]+\)' | grep -Eos '[^\(\)]+'`"    # extract section of man page

if [[ ! "$section" ]]; then
   section="1"
fi

if [[ ! -f "`man ${section} -W ${manpage} 2>/dev/null`" ]]; then
   echo "No such man page: man ${section} ${manpage}"
   continue
fi

manfile="${mandir}/${manpage}(${section}).pdf"
echo "$manfile"

if [[ ! -f "$manfile" ]]; then
   man -t $section $manpage 2>/dev/null | pstopdf -i -o "$manfile" 2>/dev/null
   chmod 1755 "$manfile"
   # hide file extension .pdf
   if [[ -f /Developer/Tools/SetFile ]]; then /Developer/Tools/SetFile -a E "$manfile"; fi
   lpr "$manfile"
else
   lpr "$manfile"
fi

done

return 0

fi          # END of printing man pages using the default printer



# convert a single man page to a PDF file, save it to $mandir and then open it in a PDF viewer

if [[ -z "$1" ]] || [[ $# -gt 2 ]]; then       # check number of arguments
#if [[ -z "$1" || $# -gt 2 ]]; then
#if [ -z "$1" -o $# -gt 2 ]; then
  echo "Wrong number of arguments!"
  return 1
fi 

if [[ ! "$manpage" ]]; then     # turn "pman ls" into "pman 1 ls"
   manpage="$section"         # if $manpage is an empty string because there has been no "$2" then $manpage is set to "$section" and ...
   section="1"                # ... $section is set to "1"
fi

if [[ ! -f "`man ${section} -W ${manpage} 2>/dev/null`" ]]; then
   echo "No such man page: man ${section} ${manpage}"
   return 1
fi

if [[ ! -d $mandir ]]; then
   mkdir -p $mandir
   chmod 1777 $mandir
fi

manfile="${mandir}/${manpage}(${section}).pdf"

if [[ -f "$manfile" ]]; then
   open "$manfile"
else
   man $section -t $manpage 2>/dev/null | pstopdf -i -o "$manfile" 2>/dev/null
   chmod 1755 "$manfile"
   # hide file extension .pdf
   if [[ -f /Developer/Tools/SetFile ]]; then /Developer/Tools/SetFile -a E "$manfile"; fi
   open "$manfile"
fi

return 0

}

# ---------------------------------------------

# Store a directory name to come back to

function sd () {
	export $1=$PWD;
}

# ---------------------------------------------

# Just #@$% do it!
# Name means "JUST #@$% DO IT!"
# Function to force a command to try until it works.
function JFDI () {
	COMMAND=$*
	while ! $COMMAND ; do echo "Retrying..." ; done
}

# ---------------------------------------------


# resource forks goodness for osx 
#function rsync () {
#	if [[ "$sw_vers -productVersion" != "10.*"  ]]; then
#		alias rsync='rsync -E'
#	fi
#}

# quick lunching of different screen profiles
# ~/.screen/screenrc.*foo*
function sc () {
    RED='\e[0;31m'
	NC='\e[0m'
	CYAN='\e[1;36m'
	SC_SESSION=$(screen -ls | egrep -e "\.$1.*Detached" | \
	awk '{ print $1 }' | head -1);
	if [ -n "$SC_SESSION" ]; then
		xtitle $1;
		screen -R $SC_SESSION;
	elif [ -f ~/.screen/.screenrc.$1 ]; then
    	xtitle $1;
    	screen -S $1 -c ~/.screen/.screenrc.$1
	else
		echo -e "${RED}Unknown screen session:${CYAN} '$1'${NC}"
fi
}
# ---------------------------------------------

function addpath () {
# Add argument to $PATH if:
# - it is not already present
# - it is a directory
# - we have execute permission on it
#
# This snippet is public domain; you may use it freely.  Death to copyright, patents,
# and all other forms of intellectual monopoly.
#
  _folder=$1
  echo " $PATH " | sed 's/:/ /g' | grep " $_folder " > /dev/null
  [ $? -ne 0 ] && [ -d $_folder ] && [ -x $_folder ] && PATH=$PATH:$_folder
  export PATH
}

# ---------------------------------------------
# random useful functions
function ds() {
    echo 'size of directories in MB'
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo 'you did not specify a directy, using pwd'
        DIR=$(pwd)
        find $DIR -maxdepth 1 -type d -exec du -sm \{\} \; | sort -nr
    else
        find $1 -maxdepth 1 -type d -exec du -sm \{\} \; | sort -nr
    fi
}

# ---------------------------------------------

function repeat () {
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
    eval "$@";
    done
}

# ---------------------------------------------

function psg () {
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo grep running processes
        echo usage: psg [process]
    else
        ps aux | grep USER | grep -v grep
        ps aux | grep -i $1 | grep -v grep
    fi
}

# ---------------------------------------------

# useful for paging through long directories, mulitple directories, etc.
function lsl () { ls $@ | less; }

# ---------------------------------------------

function whoisg () {
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo grep whois lookups for status
        echo usage: whoisg [domain name]
    else
        whois $1 | grep -i -B 3 -A 3 status
    fi
}

# ---------------------------------------------

function gg () {
    echo "searching google for $*"
    SEARCH=$(echo $* | sed -e 's/ /\%20/g')
    echo "translating search to URL speak...  $SEARCH"
    www www.google.com/search?q="$SEARCH"
}

# ---------------------------------------------

# 256-colors test
function test256 () {
    echo -e "\e[38;5;196mred\e[38;5;46mgreen\e[38;5;21mblue\e[0m"
}

# ---------------------------------------------

# Converts a PDF to a fold-able booklet sized PDF
# Print it double-sided and fold in the middle

function bookletize () {
    if which pdfinfo && which pdflatex; then
        pagecount=$(pdfinfo $1 | awk '/^Pages/{print $2+3 - ($2+3)%4;}')

        # create single fold booklet form in the working directory
        pdflatex -interaction=batchmode \
        '\documentclass{book}\
        \usepackage{pdfpages}\
        \begin{document}\
        \includepdf[pages=-,signature='$pagecount',landscape]{'$1'}\
        \end{document}' 2>&1 >/dev/null
    fi
}

# ---------------------------------------------

# smile :)
function smiley () { echo -e ":\\$(($??50:51))"; }

# ---------------------------------------------

# cal with coloured day
function month() {
/usr/bin/cal | sed -E -e 's/^/ /' -e 's/$/ /' -e "s/ $(/bin/date +%e) /$(printf '\033[1;31m&\033[m')/"
return 0
}

# ---------------------------------------------

# download and untargz
function dtgz () {
         if [ $# -gt 0 ]; then
                 for l in $@; do
                         curl $l | tar -xz
                 done
         else
                 echo "Usage: dtgz url [url2, url3, ...]" 1>&2
         fi
}

# ---------------------------------------------

# sudo vim
function svim () {
	sudo vim $@
}

# ---------------------------------------------

# create a directory and make it the working directory
function mkcdr () {
	mkdir -p $1
	cd $1
}

# ---------------------------------------------
# functions so you don't have to type '&' for graphical binaries
function locategrep () {
	if [ "${#}" != 2 ] ; then
		echo "Usage: locategrep [string to locate] [string to grep]";
		return 1;
	else
		echo "locate -i '${1}' | grep -i '${2}'";
		command locate -i '${1}' | grep -i '${2}';
	fi;
}

# ---------------------------------------------
# extract most file types
function extract () {
		if [ -f $1 ] ; then
			case $1 in
             *.tar.bz2)   tar xjf $1     ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1     ;;
             *.rar)       unrar e $1     ;;
             *.gz)        gunzip $1      ;;
             *.tar)       tar xf $1      ;;
             *.tbz2)      tar xjf $1     ;;
             *.tgz)       tar -xvf $1    ;;
             *.zip)       unzip $1       ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1        ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# ---------------------------------------------

# roll - archive wrapper
# usage: roll <foo.tar.gz> ./foo ./bar
function roll () {
  FILE=$1
  case $FILE in
    *.tar.bz2) shift && tar cjf $FILE $* ;;
    *.tar.gz) shift && tar czf $FILE $* ;;
    *.tgz) shift && tar czf $FILE $* ;;
    *.zip) shift && zip $FILE $* ;;
    *.rar) shift && rar $FILE $* ;;
  esac
}


function makepasswords () {
    # suggest a bunch of possible passwords. not suitable for really early perl
    # versions that don't do auto srand() things.
    perl <<EOPERL
        my @a = ("a".."z","A".."Z","0".."9",(split //, q{#@,.<>$%&()*^}));
        for (1..10) {
            print join "", map { \$a[rand @a] } (1..rand(3)+7);
            print qq{\n}
        }
EOPERL
}

# ---------------------------------------------

function vh () {
# search the vim reference manual for a keyword
# usage: vh <keyword>
	vim --cmd ":silent help $@" --cmd "only"; }

function mkmine () {
	# mkmine - recursively change ownership to $USER:$USER
	# usage:  mkmine, or
	#         mkmine <filename | dirname>
	sudo chown -R ${USER}:${USER} ${1:-.};
}

function sanitize () {
	# sanitize - set file/directory owner and permissions to normal values (644/755)
	# usage: sanitize <file>
	chmod -R u=rwX,go=rX "$@"
	chown -R ${USER}:users "$@"
}
function sanitize-osx () {
	chmod -R u=rwX,go=rX "$@"
	chown -R ${USER}:everyone "$@"
}
# ---------------------------------------------
function bak () {
# back up file as filename(time&date).bak
for i in file; do
	cp "$1" "$1"_`date +%H-%M%p_%d_%m_%y`.bak
done
}

# ---------------------------------------------
function vimless () {
# alias less=vimless (use this alias) ~/.aliases_bash
# have a nice pager using vim as a replacement for less
if test $# = 0; then
	vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' -
else
	vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' "$@"
fi
}
# ---------------------------------------------

function mqusedatabase () {
	export MYSQL_DEFAULT_DB=$@
}

function mqrun () {
	mysql -u root -t -D ${MYSQL_DEFAULT_DB} -vvv -e "$@" | highlight blue '[|+-]'
}

function mqrunfile () {
	mysql -u root -t -vvv ${MYSQL_DEFAULT_DB} < $@ | highlight blue '[|+-]'
}

function mqrunfiletofile () {
	mysql -u root -t -vvv ${MYSQL_DEFAULT_DB} < $1 >> $2
}

function mqrunfiletoeditor () {
	mysql -u root -t -vvv ${MYSQL_DEFAULT_DB} < $1 | vim -
}

alias mqlistdatabases='mqrun "show databases"'
alias mqlisttables='mqrun  "show tables"'

function mqlistfields () {
	mqrun "describe $@"
}

function mqcreatedatabase () {
	mysqladmin -u root create $@
	echo "$@ Created" | highlight blue '.*'
}

function mqdropdatabase () {
	echo Warning | highlight red '.*'
	mysqladmin -u root drop $@
}

# ---------------------------------------------

function start () {
for arg in $*; do
	sudo /etc/rc.d/$arg start
done
}

function stop () {
for arg in $*; do
	sudo /etc/rc.d/$arg stop
done
}

function restart () {
for arg in $*; do
	sudo /etc/rc.d/$arg restart
done
}

function reload () {
for arg in $*; do
	sudo /etc/rc.d/$arg reload
done
}

# ---------------------------------------------

function ansi () {
       # Display ANSI colours.
       # Shows the colors in a kewl way...party stolen from HH :)
    esc="\033["
    echo -e "\t  40\t   41\t   42\t    43\t      44       45\t46\t 47"
    for fore in 30 31 32 33 34 35 36 37; do
        line1="$fore  "
        line2="    "
        for back in 40 41 42 43 44 45 46 47; do
            line1="${line1}${esc}${back};${fore}m Normal  ${esc}0m"
            line2="${line2}${esc}${back};${fore};1m Bold    ${esc}0m"
        done
        echo -e "$line1\n$line2"
    done

    echo ""
    echo "# Example:"
    echo "#"
    echo "# Type a Blinkin TJEENARE in Swedens colours (Yellow on Blue)"
    echo "#"
    echo "#           ESC"
    echo "#            |  CD"
    echo "#            |  | CD2"
    echo "#            |  | | FG"
    echo "#            |  | | |  BG + m"
    echo "#            |  | | |  |         END-CD"
    echo "#            |  | | |  |            |"
    echo "# echo -e '\033[1;5;33;44mTJEENARE\033[0m'"
    echo "#"
    echo "# Sedika Signing off for now ;->"
}

# ---------------------------------------------

# Inspect a website like a string in Ruby
unset -f inspect_url
function inspect_url () {
   /usr/bin/curl -L -s --max-time 10 "${@}" | ruby -n -e 'p $_.to_s'
   return 0
}

#inspect_url http://www.ruby-forum.com

# ---------------------------------------------,
#  OS X ONLY FUNCTIONS                          \
# _______________________________________________\

# http://codesnippets.joyent.com/posts/show/1551
# Bash functions to get some current ipfw ruleset information.
# ipfwdump
# ipfwdump -n
# ipfwdump -n | grep 7400
# ipfwdump -n | grep allow
# ipfwdump -n | grep deny

# ipfwto
# ipfwto -n | grep deny
# ipfwfrom -n
# ipfwfrom | grep allow
#

unset -f ipfwfrom
function ipfwfrom() {

   declare sudo=/usr/bin/sudo ipfw=/sbin/ipfw
   declare IF CIF ipnum rule url num

   OPATH=$PATH; OIFS=$IFS
   export PATH="/usr/bin:/bin:/usr/sbin:/sbin"; export IFS=$' \t\n'

   /usr/sbin/ipconfig waitall

   IF="en0"
   CIF="$(/sbin/route -n get default | grep interface | awk '{ print $NF }')"   # current default interface
   #CIF="$(/usr/sbin/netstat -rn | grep default | awk '{ print $NF }')"          # current default interface

   if [[ "$1" = "-n" ]]; then    # print IP numbers

      $sudo $ipfw -de list | awk '/ \(.*\) / { print $1, $7 }'  | sort -n | uniq | while read -d $'\n' line; do
         ipnum="${line##* }"
         rule="$(/usr/bin/sudo /sbin/ipfw list ${line%% *} )"
         printf "%-27s %s\n" "${ipnum}" "${rule}"
      done

   else

      if [[ "${IF}" != "${CIF}" ]]; then echo "No internet connection!"; return 1; fi

      $sudo $ipfw -de list | awk '/ \(.*\) / { print $1, $7 }'  | sort -n | uniq | while read -d $'\n' line; do
         ipnum="${line##* }"
         url="$(/usr/bin/dig +short +time=3 +tries=2 -x ${ipnum} | head -n 1)"
         if [[ -z "${url}" ]]; then url=${ipnum}; fi
         rule="$(/usr/bin/sudo /sbin/ipfw list ${line%% *} )"
         printf "%-27s %-45s %s\n" "${ipnum}" "${url}" "${rule}"
      done

   fi

   export PATH=$OPATH; export IFS=$OIFS

   return 0
}
export -f ipfwfrom


unset -f ipfwto
function ipfwto() {

   declare sudo=/usr/bin/sudo ipfw=/sbin/ipfw
   declare IF CIF ipnum rule url num

   OPATH=$PATH; OIFS=$IFS
   export PATH="/usr/bin:/bin:/usr/sbin:/sbin"; export IFS=$' \t\n'

   /usr/sbin/ipconfig waitall

   IF="en0"
   CIF="$(/sbin/route -n get default | grep interface | awk '{ print $NF }')"   # current default interface

   if [[ "$1" = "-n" ]]; then    # print IP numbers

      $sudo $ipfw -de list | awk '/ \(.*\) / { print $1, $10 }'  | sort -n | uniq | while read -d $'\n' line; do
         ipnum="${line##* }"
         rule="$(/usr/bin/sudo /sbin/ipfw list ${line%% *} )"
         printf "%-27s %s\n" "${ipnum}" "${rule}"
      done

   else

      if [[ "${IF}" != "${CIF}" ]]; then echo "No internet connection!"; return 1; fi

      $sudo $ipfw -de list | awk '/ \(.*\) / { print $1, $10 }'  | sort -n | uniq | while read -d $'\n' line; do
         ipnum="${line##* }"
         url="$(/usr/bin/dig +short +time=3 +tries=2 -x ${ipnum} | head -n 1)"
         if [[ -z "${url}" ]]; then url=${ipnum}; fi
         rule="$(/usr/bin/sudo /sbin/ipfw list ${line%% *} )"
         printf "%-27s %-45s %s\n" "${ipnum}" "${url}" "${rule}"
      done

   fi

   export PATH=$OPATH; export IFS=$OIFS

   return 0
}
export -f ipfwto

unset -f ipfwdump
function ipfwdump() {
	declare sudo=/usr/bin/sudo ipfw=/sbin/ipfw
	declare IF CIF ipnum rule url num ipfrom ipto ip1 ip2
	OPATH=$PATH; OIFS=$IFS
	export PATH="/usr/bin:/bin:/usr/sbin:/sbin"; export IFS=$' \t\n'
	/usr/sbin/ipconfig waitall
	IF="en0"
	CIF="$(/sbin/route -n get default | grep interface | awk '{ print $NF }')"   # current default interface
	if [[ "$1" = "-n" ]]; then    # print IP numbers
		$sudo $ipfw -de list | awk '/ \(.*\) / { print $1,$7,$10 }' | sort -n | uniq | while read -d $'\n' line; do
		read num ipfrom ipto <<< "${line}"
		rule="$(/usr/bin/sudo /sbin/ipfw list ${num} )"
		printf "%-45s %s\n" "${ipfrom}  ->  ${ipto}" "${rule}"
	done
	else
	if [[ "${IF}" != "${CIF}" ]]; then echo "No internet connection!"; return 1; fi
		$sudo $ipfw -de list | awk '/ \(.*\) / { print $1,$7,$10 }' | sort -n | uniq | while read -d $'\n' line; do
		read num ipfrom ipto <<< "${line}"
		rule="$(/usr/bin/sudo /sbin/ipfw list ${num})"
		ip1="$(/usr/bin/dig +short +time=3 +tries=2 -x ${ipfrom} | head -n 1)"
		ip2="$(/usr/bin/dig +short +time=3 +tries=2 -x ${ipto} | head -n 1)"
		if [[ -z "${ip1}" ]]; then ip1=${ipfrom}; fi
		if [[ -z "${ip2}" ]]; then ip2=${ipto}; fi
		printf "%-65s %s\n" "${ip1}  ->  ${ip2}" "${rule}"
	done
	fi
	export PATH=$OPATH; export IFS=$OIFS
	return 0
}
export -f ipfwdump

# ---------------------------------------------

function ifont () {
	# Increase the font size (OS X)
	/usr/bin/osascript <<__END__
	tell application "System Events" to tell process "Terminal" to keystroke "+" using command down
__END__
	return 0
}

function dfont () {
	# Decrease the font size (OS X)
	/usr/bin/osascript <<__END__
	tell application "System Events" to tell process "Terminal" to keystroke "-" using command down
__END__
	return 0
}

# ---------------------------------------------

function whatserver () {
	# what is a server running. Usage: whatserver (address, |http|ftp|)
	wget $1 –spider -d 2>&1 | grep Server:
}

# ---------------------------------------------
#
# Inspired by: http://codesnippets.joyent.com/posts/show/1516
# - Re-size and Move with Escape Sequences, http://www.osxfaq.com/tips/unix-tricks/week99/monday.ws
# - Define Aliases and Functions, http://www.osxfaq.com/tips/unix-tricks/week99/tuesday.ws
# - Focus and Dock with Escape Sequences, http://www.osxfaq.com/Tips/unix-tricks/week99/wednesday.ws
# Author: Adrian Mayo, http://101.1dot1.com and http://www.peachpit.com/title/0321374118
# also see: http://en.wikipedia.org/wiki/ANSI_escape_code

function title () { if [[ $# -eq 1 && -n "$@" ]]; then printf "\e]0;${@}\a"; fi; return 0; }  
function title () { if [[ -n "$@" ]]; then printf "\033]0;${1}\007"; fi; return 0; }
function docktw () { printf "\e[2t"; return 0; }
function docktw () { printf "\e[2t"; sleep 5; printf "\e[5t"; return 0; }
function bgtw () { printf "\e[6t"; return 0; }
function bgtw () { printf "\e[6t"; sleep 5; printf "\e[5t"; return 0; }    # background the Terminal window



# positive integer test (including zero)
function positive_int () { return $(test "$@" -eq "$@" > /dev/null 2>&1 && test "$@" -ge 0 > /dev/null 2>&1); }

# move the Terminal window
function mvtw () {
	if [[ $# -eq 2 ]] && $(positive_int "$1") && $(positive_int "$2"); then 
		printf "\e[3;${1};${2};t"
		return 0
	fi
		return 1
}

# resize the Terminal window
function sizetw () {
   if [[ $# -eq 2 ]] && $(positive_int "$1") && $(positive_int "$2"); then 
      printf "\e[8;${1};${2};t"
      /usr/bin/clear
      return 0
   fi
   return 1
}

# full screen
function fscreen () { printf "\e[3;0;0;t\e[8;0;0t"; /usr/bin/clear; return 0; }

# default screen
function dscreen () { printf "\e[8;35;150;t"; printf "\e[3;300;240;t"; /usr/bin/clear; return 0; }

# max columns
function maxc () { printf "\e[3;0;0;t\e[8;50;0t"; /usr/bin/clear; return 0; }

# max rows
function maxr () { printf "\e[3;0;0;t\e[8;0;100t"; /usr/bin/clear; return 0; }

# show number of lines & columns
function lc () { printf "lines: $(/usr/bin/tput lines)\ncolums: $(/usr/bin/tput cols)\n"; return 0; }

# move cursor
function mvc () {
   if [[ $# -eq 2 ]] && $(positive_int "$1") && $(positive_int "$2"); then 
      /usr/bin/tput cup "$1" "$2"
      /usr/bin/tput el  # clear to end of line
      #/usr/bin/tput ed
      return 0
   fi
   return 1
}

# wrap lines according to the number of columns of the Terminal window
function wraptw () {
	declare str var=$(/usr/bin/tput cols)
	if [[ -s /dev/stdin ]]; then str="$(</dev/stdin)"; else str="$@"; fi 
		printf "%s\n" "$str" | /usr/bin/fmt -w $var
		#printf "%s\n" "$str" | /usr/bin/fold -w $(/usr/bin/tput cols)
	return 0
}

# ---------------------------------------------

# Alias helpers !!
# showa: to remind yourself of an alias (given some part of it)
# these are functions and should be in ~/.bashrc
function aliases () { /usr/bin/grep -i -a1 $@ ~/.aliases_bash | grep -v '^\s*$' ; }
function showalias () { /usr/bin/grep -i -a1 $@ ~/.aliases_bash | grep -v '^\s*$' ; }
function salias () { /usr/bin/grep -i -a1 $@ ~/.aliases_bash | grep -v '^\s*$' ; }
function showa () { /usr/bin/grep -i -a1 $@ ~/.aliases_bash | grep -v '^\s*$' ; }
function showa1 () { /usr/bin/grep -i -a1 $@ ~/.bashrc | grep -v '^\s*$' ; }
function showa2 () { /usr/bin/grep -i -a1 $@ /etc/bashrc | grep -v '^\s*$' ; }
function showa3 () { /usr/bin/grep -i -a1 $@ ~/.aliasrc | grep -v '^\s*$' ; }
function showa4 () { /usr/bin/grep -i -a1 $@ /etc/aliases.bash | grep -v '^\s*$' ; }
function showa5 () { /usr/bin/grep -i -a1 $@ /etc/aliasrc | grep -v '^\s*$' ; }

# ----------------------------------

function pchmod () {
    echo "-----------------------------";
    echo -e "\e[1;35m chmod permissions \e[0m";
    echo "-----------------------------";
    echo;
    echo -e "\e[1;35m Options: \e[0m";
    echo -e "\e[0;32m 000 \e[0m = \e[0;32m --------- \e[0m no one can read write or execute (example only)";
    echo -e "\e[0;32m 400 \e[0m = \e[0;32m r-------- \e[0m owner can read";
    echo -e "\e[0;32m 440 \e[0m = \e[0;32m r--r----- \e[0m owner and group can read";
    echo -e "\e[0;32m 444 \e[0m = \e[0;32m r--r--r-- \e[0m every one can read";
    echo -e "\e[0;32m 500 \e[0m = \e[0;32m r-x------ \e[0m owner can read and execute";
    echo -e "\e[0;32m 550 \e[0m = \e[0;32m r-xr-x--- \e[0m owner and group can read and execute";
    echo -e "\e[0;32m 555 \e[0m = \e[0;32m r-xr-xr-x \e[0m everyone can read and execute";
    echo -e "\e[0;32m 600 \e[0m = \e[0;32m rw------- \e[0m owner can read and write";
    echo -e "\e[0;32m 640 \e[0m = \e[0;32m rw-r----- \e[0m owner can read and write, group can read";
    echo -e "\e[0;32m 644 \e[0m = \e[0;32m rw-rw-r-- \e[0m owner can read and write, everyone can read";
    echo -e "\e[0;32m 660 \e[0m = \e[0;32m rw-rw---- \e[0m owner and group can read and write";
    echo -e "\e[0;32m 664 \e[0m = \e[0;32m rw-rw-r-- \e[0m owner and group can read and write, everyone can read";
    echo -e "\e[0;32m 666 \e[0m = \e[0;32m rw-rw-rw- \e[0m everyone can read and write";
    echo -e "\e[0;32m 700 \e[0m = \e[0;32m rwx------ \e[0m owner can read, write and execute";
    echo -e "\e[0;32m 740 \e[0m = \e[0;32m rwxr----- \e[0m owner and group can read, write and execute. group can read";
    echo -e "\e[0;32m 744 \e[0m = \e[0;32m rwxr--r-- \e[0m owner and group can read, write and execute. everyone can read";
    echo -e "\e[0;32m 754 \e[0m = \e[0;32m rwxr-xr-- \e[0m owner can read, write and execute. group can read and execute, everyone can read";
    echo -e "\e[0;32m 754 \e[0m = \e[0;32m rwxr-xr-- \e[0m owner can read, write and execute, everyone can read and execute";
    echo -e "\e[0;32m 760 \e[0m = \e[0;32m rwxrw---- \e[0m owner and group can read, write and execute. group can read and write";
    echo -e "\e[0;32m 764 \e[0m = \e[0;32m rwxrw-r-- \e[0m owner and group can read, write and execute. group can read and wtite. everyone can read";
    echo -e "\e[0;32m 766 \e[0m = \e[0;32m rwxrwxrw- \e[0m owner and group can read, write and execute. everyone can read and write";
    echo -e "\e[0;32m 770 \e[0m = \e[0;32m rwxrwx--- \e[0m owner and group can read, write and execute";
    echo -e "\e[0;32m 774 \e[0m = \e[0;32m rwxrwxr-- \e[0m owner and group can read, write and execute. everyone can read";
    echo -e "\e[0;32m 776 \e[0m = \e[0;32m rwxrwxrw- \e[0m owner and group can read, write and execute. everyone can read and write";
    echo -e "\e[0;32m 777 \e[0m = \e[0;32m rwxrwxrwx \e[0m everyone can read, write and execute";
    echo;
}

# ---------------------------------------------
# using alias qlf='qlmanage -p "$@" >& /dev/null'
#function ql () {
#  (qlmanage -p “$@” > /dev/null 2>&1 &
#  local ql_pid=$!
#  read -sn 1
#  kill ${ql_pid}) > /dev/null 2>&1
#}
# Display any filetype as plain text
function qlt () {
	(qlmanage -p -c public.plain-text “$@” > /dev/null 2>&1 &
	local ql_pid=$!
	read -sn 1
	kill ${ql_pid}) > /dev/null 2>&1
}

# ---------------------------------------------

# http://codesnippets.joyent.com/posts/show/1715
function machelp() { /usr/bin/open '/System/Library/CoreServices/Help Viewer.app'; return 0; }

# ---------------------------------------------

# http://hayne.net/MacDev/Bash/aliases.bash
function cdf ()
{
    currFolderPath=$( /usr/bin/osascript <<"    EOT"
        tell application "Finder"
            try
                set currFolder to (folder of the front window as alias)
            on error
                set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
    EOT
    )
    echo "cd to \"$currFolderPath\""
    cd "$currFolderPath";
    count
}
# http://snipplr.com/view.php?codeview&id=1692
# count option (saved as script in path)

# ---------------------------------------------

# showTimes: show the modification, metadata-change, and access times of a file
function show-times () { stat -f "%N:   %m %c %a" "$@" ; }

# finderComment: show the SpotLight comment for a file
function finder-comment () { mdls "$1" | grep kMDItemFinderComment ; }

# ---------------------------------------------
# gnu screens rotated automatically
function screen_rotate () {
		local session_name=${1:?"missing session name"}
		local sleep_duration=${2:-5}
	while true; do
		screen -S $session_name -X next
		sleep $sleep_duration
	done
}

# ---------------------------------------------

function bootdisk () {
	/usr/sbin/disktool -l | awk -F"'" '$4 == "/" {print $8}' ;
}

# ---------------------------------------------
# Git functions
function gitsearch {
	for branch in `git branch | sed 's/\*//'`; do echo $branch:; git ls-tree -r --name-only $branch | grep "$1"; done
}

function gitco () {
	if [ -z "$1" ]; then
		git checkout master
	else
		git checkout $1
	fi
}
# ---------------------------------------------

function newest () {
	candidate='' ; for i in "$@"; do [[ -f $i ]] || continue ; [[ -n $candidate ]] || { candidate="$i" ; continue ;} ; [[ $i -nt $candidate ]] && candidate="$i" ; done ; echo "$candidate";
}

# ---------------------------------------------
# using better history function now
#hf(){
#  grep "$@" ~/.bash_history
#}

# ---------------------------------------------

function turl () {
tiny-url $1 | pbcopy
echo -e "Link Copied To Clipboard:\e[0;31m $(pbpaste)\e[0m"
}

# ---------------------------------------------

function die () {
    kill -9 "$1"
}

# ---------------------------------------------
function screen-2 () {
    [[ -f ~/.screenrc ]] && sed -i -e "s!hardstatus string \".*\"!hardstatus string \"%h - $(hostname)\"!" \
        ~/.screenrc
    $(which screen ) "$@"
}

# ---------------------------------------------
function targpg () {
for f in "$@"
do
dir=`dirname "${f}"`
name=`basename "${f}"`
cd "${dir}"
# export GPGKEYID="123ZZ321" ~ for your .bashrc
tar pcvf - "${name}" | gpg --encrypt --batch -z 6 -r robbie -o "${name}.tgz.gpg"
done
}

# ---------------------------------------------
# mktar - tarball wrapper
# usage: mktar <filename | dirname>
function mktar () {
    tar pcvf "${1%%/}.tgz" "${1%%/}/"
}

# ---------------------------------------------
function add-to-path ()
{
    path_list=`echo $PATH | tr ':' ' '`
    new_dir=$1
    for d in $path_list
    do
    	if [ $d == $new_dir ]
    	then
    		return 0
    	fi
    done
    export PATH=$new_dir:$PATH
}

# ---------------------------------------------
function yt () {
	if [[ "$PWD" = ~/Desktop ]]; then
    	youtube-dl -t -b "$@"
		growlnotify -s -t "youtube DL's Finished" -m "~/Desktop"
	else 
    	cd ~/Desktop; youtube-dl -t -b "$@"
		growlnotify -s -t "youtube DL's Finished" -m "~/Desktop"
	fi
}

# ---------------------------------------------
# generate a password. ie: $ gp 64
function gp () {
    local l=$1
    [ "$l" == "" ] && l=20
    tr -dc A-Za-z0-9\-_~\!@#$%^\&*\(\)\\\`\+\[\{\]\}\|\;:\",\/?\= < /dev/urandom | head -c ${l} | xargs
}


function JPG-2-jpg () {
	find $PWD -name '*.JPG' -exec bash -c 'mv "$1" "${1/%.JPG/.jpg}"' -- {} \;
}

# ---------------------------------------------

# here you can do stuff like:   --check errors $ err 23
function err ()
{
    grep --recursive --color=auto --recursive -- "$@" /usr/include/*/errno.h
    if [ "${?}" != 0 ]; then
        echo "Not found."
    fi
}

# repeat any command at a regular interval
# = rept 2 ls -l bootpage-20040921.zip (2=seconds)
function rept ()
{
    delay=$1;
    shift;
    while true; do
        eval "$@";
        sleep $delay;
    done
}

# ---------------------------------------------
# RUBY #
# use: cdgem <gem name>, cd's into your gems directory and opens gem that best
# matches the gem name provided
function cdgem () {
  cd $GEMDIR/gems
  cd `ls | grep $1 | sort | tail -1`
}
function cdgemcomplete () {
  COMPREPLY=($(compgen -W '$(ls $GEMDIR/gems)' -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

# use: gemdoc <gem name>, opens gem docs from the gem docs directory that best
# matches the gem name provided
# (hat tip: http://stephencelis.com/archive/2008/6/bashfully-yours-gem-shortcuts)
function gemdoc () {
	open -a firefox $GEMDIR/doc/`ls $GEMDIR/doc | grep $1 | sort | tail -1`/rdoc/index.html
}
function gemdocomplete () {
	COMPREPLY=($(compgen -W '$(ls $GEMDIR/doc)' -- ${COMP_WORDS[COMP_CWORD]}))
	return 0
}
# use: vimgem <gem name>, cd's into your gems directory and opens gem that best
# matches the gem name provided in gvim
function vimgem () {
	gvim -c NERDTree $GEMDIR/gems/`ls $GEMDIR/gems | grep $1 | sort | tail -1`
}
function mategem () {
	mate $GEMDIR/gems/`ls $GEMDIR/gems | grep $1 | sort | tail -1`
}
# RUBY
complete -o default -o nospace -F cdgemcomplete cdgem
complete -o default -o nospace -F gemdocomplete gemdoc
complete -o default -o nospace -F cdgemcomplete vimgem mategem

# ---------------------------------------------

# select from 10 different BBC stations. When one is chosen, it streams it with mplayer.
# Requires: mplayer with wma support.
function bbcradio () {
local s;echo "Select a station:";select s in 1 2 3 4 5 6 7 1x "Asian Network an" "Nations & Local lcl";do break;done;mplayer -playlist "http://www.bbc.co.uk/radio/listen/live/r"$(echo "$s"|awk '{print $NF}')".asx";
}

# ---------------------------------------------
# get the full path of a file
function fp () { readlink -f "$1"; }
# copy the full path of a file to the osx clipboard
function fpc () { readlink -f "$1" | pbcopy; }


#If used without arguments, returns own IP info.
#If used with argument, returns info about the parsed argument.
function geoip () {
curl -s "http://www.geoiptool.com/?IP=$1" | html2text | egrep --color 'City:|IP Address:|Country:'
}

# show a growl message for completed commands, scripts. usage: command; gdone
# handy for compiles/makes that might fail
function gdone ()
{
if [ $? -eq 0 ]; then
    growlnotify -s -t 'Command has completed' -m ''
else
	growlnotify -s --priority "2" -t 'Command has completed' -m 'There was an error! :/'
fi
}
# ---------------------------------------------
# cd with sed
# example:
# /usr/lib/foo$ scd lib src
# /usr/src/foo$
function scd () {
 local cd="$PWD"
 while [ $1 ]; do
  cd="$(echo $cd | sed "s/$1/$2/")"
  shift; shift
 done
 shopt -s cdspell
 cd $cd
 shopt -u cdspell
}


# taken from http://github.com/bryanl/zshkit/
function git-track () {
    local BRANCH=`git branch 2> /dev/null | grep \* | sed 's/* //'`
git config branch.$BRANCH.remote origin
git config branch.$BRANCH.merge refs/heads/$BRANCH
echo "tracking origin/$BRANCH"
}
function github-url () { git config remote.origin.url | sed -En 's/git(@|:\/\/)github.com(:|\/)(.+)\/(.+).git/https:\/\/github.com\/\3\/\4/p'; }
function github-go () { open $(github-url); }
function git-scoreboard () { git log | grep '^Author' | sort | uniq -ci | sort -r; }

# http://www.guyslikedolls.com/git-on-macosx
newgit()
{
if [ -z $1 ]; then
echo "usage: $FUNCNAME project-name.git"
else
gitdir="/Library/WebServer/Documents/git/$1"
mkdir $gitdir
pushd $gitdir
git --bare init
git --bare update-server-info
chmod a+x hooks/post-update
touch git-daemon-export-ok
popd
fi
}
# ---------------------------------------------

function mancomplete () {
	ITEMS=$(man -W | sed -e 's/:/ /g')
	for i in $ITEMS; do
		HITS=$i/*/$2*
		for j in $HITS; do
			NAME=$(basename $j)
			echo $NAME
		done
	done
}
# ---------------------------------------------
# Kill the line with the given number in the ssh known hosts file.
# Useful after a host public key change.
function kill-ssh-known-hosts-line () {
	sed -ie "$1d" ~/.ssh/known_hosts
}
# ---------------------------------------------

# fuzzy 'cd': cd into first directory matching the substring, case insensitive
function cdfuz () {
	shopt -q nocasematch || resetcase=1
	shopt -s nocasematch
	for i in *; do [ -d "$i" ] && [[ "$i" == *"$1"* ]] && cd "$i" && echo "$i" && break; done
	[ $resetcase ] && shopt -u nocasematch
}
# ---------------------------------------------

function mdlocate () {
	echo mdfind "kMDItemFSName == '$1'"
	mdfind "kMDItemFSName == '$1'"
}

function spot () { mdfind "kMDItemDisplayName == '$@'wc"; }

function clearquarantine () {
	[ "$1" -a -d "$1" ] || { echo need a directory argument; return 1; }
	echo find "'$1'" -type f -print0 \| xargs -n 100 -0 sudo xattr -d com.apple.quarantine
	find "$1" -type f -print0 | xargs -n 100 -0 sudo xattr -d com.apple.quarantine
}

# ---------------------------------------------
# make back up of file , prepend '__' to the backup
function __ () {
  cp $1 __$1
}

function t256 () {
  if [ "$TERM" != "xterm-256color" ]; then
    echo "TERM: $TERM -> xterm-256color"
    export TERM="xterm-256color"
  fi
}

# ---------------------------------------------

# fcd: cd's to frontmost window of Finder
function fcd ()
{
    currFolderPath=$( /usr/bin/osascript <<"    EOT"
        tell application "Finder"
            try
		set currFolder to (folder of the front window as alias)
            on error
		set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
    EOT
    )
    # echo "cd to \"$currFolderPath\""
    cd "$currFolderPath"
}

# locateql: search using Spotlight and show a "Quick Look" of matching files
locateql ()
{
    locatemd "$@" | enquote | xargs qlmanage -p >& /dev/null &
}

# when i want to tail some out put to growl, ls | growl
function growl () {
if [[ $(hostname) = "server" ]]; then
	growlnotify -s -H "mbook.local" -P "123" -t "growl: $USER @ $(hostname) `date +%H:%M`"
else
	growlnotify -s -t "growl: $USER @ $(hostname) `date +%H:%M`"
fi
}

function spam-hosts-update () {
	wget -q -O - http://someonewhocares.org/hosts/ | grep ^127 >> ~/Desktop/hosts;
	sudo cat ~/Desktop/hosts >> /etc/hosts;
	growlnotify -s -t "Spam list updated!" -m "new entries in /etc/hosts"
}

function gdot () {
	cp "$@" /Users/robbie/git/projects/dunolie-dotfiles/dotfiles/
	growlnotify -t "+ dunolie-dotfiles/dotfiles" -m "copied, git add later"
}


# ---------------------------------------------
# KEEP AS LAST FUNCTION IT BREAKS THE SYNTAX COLOURING!!!
# ---------------------------------------------
# teach shell to treat aliases like symbolic links rather than files
# http://www.macosxhints.com/article.php?story=20050828054129701
function cda () {
	if [ ${#1} == 0 ]; then
		builtin cd
	elif [[ -d "${1}" || -L "${1}" ]]; then	# regular link or directory
		builtin cd "${1}"
	elif [ -f "${1}" ]; then	# file: is it an alias?
		# Redirect stderr to dev null to suppress OSA environment errors
		exec 6>&2 # Link file descriptor 6 with stderr so we can restore stderr later
		exec 2>/dev/null # stderr replaced by /dev/null
		path=$(osascript << EOF
tell application "Finder"
set theItem to (POSIX file "${1}") as alias
if the kind of theItem is "alias" then
get the posix path of ((original item of theItem) as text)
end if
end tell
EOF
)
		exec 2>&6 6>&-      # Restore stderr and close file descriptor #6.
		
		if [ "$path" == '' ];then # probably not an alias, but regular file
			builtin cd "${1}"	# will trigger regular shell error about cd to regular file
		else	# is alias, so use the returned path of the alias
			builtin cd "$path"
		fi
	else	# should never get here, but just in case.
		builtin cd "${1}"
	fi
}

# ---------------------------------------------
# ###############################################
# THE END !!
# ###############################################
