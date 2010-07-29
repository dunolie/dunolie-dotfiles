# -------------------------------------------------------------------------------
# Author: Robbie ( dunolie@gmail.com )
# Created: 03/10/09 @ 07:07:20
# Description: $(HOME)/.bash_profile
# Last modified: Sun 27 Dec 2009 22:26:06 pm GMT
# Comments: mac osx centred bash profile
# -------------------------------------------------------------------------------
#                            NOTES
# -------------------------------------------------------------------------------
#
# When you start an interactive shell (log in, open terminal or iTerm in OS X,
# or create a new tab in iTerm) the following files are read and run, in this order:
#     /etc/profile
#     /etc/bashrc
#     .bash_profile
#     .bashrc (only because this file is run (sourced) in .bash_profile)
#
# When an interactive shell, that is not a login shell, is started
# (when you run "bash" from inside a shell, or when you start a shell in
# xwindows [xterm/gnome-terminal/etc] ) the following files are read and executed,
# in this order:
#     /etc/bashrc
#     .bashrc
#
# -------------------------------------------------------------------------------
#                         SHELL SETTINGS
# -------------------------------------------------------------------------------
# colour values for use in scripts. Usage:  text
NC='\033[0m' # No Color
WHITE='\033[1;37m'
BLACK='\033[0;30m'
BLUE='\033[0;34m'
L_BLUE='\033[1;34m'
GREEN='\033[0;32m'
L_GREEN='\033[1;32m'
CYAN='\033[0;36m'
L_CYAN='\033[1;36m'
RED='\033[0;31m'
L_RED='\033[1;31m'
PURPLE='\033[0;35m'
L_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
L_YELLOW='\033[0;33m'
GRAY='\033[1;30m'
L_GRAY='\033[0;37m'
#

# source ~/.bashrc-dterm for the Dterm app
if [[ $TERM_PROGRAM = "DTerm" ]]; then
▷⋅⋅⋅source ~/.dunolie-dotfiles/dotfiles/.bashrc-dterm
▷⋅⋅⋅return
fi

# so iTerm likes the dircolors output
#export TERM=xterm-color
#if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
#▷⋅⋅⋅export TERM=xterm-color
#fi

# -------------------------------------------------------------------------------
#                        MY WELCOME MESSAGE
# -------------------------------------------------------------------------------
# List screen sessions. Attached or dettached
function screenON () {
SERVICEUP="screen"
if ps ax | grep -v grep | grep $SERVICEUP > /dev/null
then
	echo -e "=-=-=-=-= ${GREEN} $(screen -ls)${NC}"
	echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
else
	echo -e "=-=-=-=-= ${L_RED} There are no screen sessions on.${NC}"
	echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
fi
}
# Shows what the name of the bootup disk is
function bootdisk () {
/usr/sbin/disktool -l | awk -F"'" '$4 == "/" {print $8}'
}
#
#
echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo -e   "    \033[1;37m.\033[1;30m~\033[1;37m.\033[0;0m        OS X:${L_CYAN} $(sw_vers -productVersion)${NC}"
echo -en  "    \033[1;30m/\033[1;33mV\033[1;30m\\\\\033[0;0m    Computer:${L_CYAN} $(hostname) ${NC}"
echo ""
echo -en  "   \033[1;30m//\033[1;37m&\033[1;30m\\\\\\\\\033[0;0m   BootDisk:${L_CYAN} $(bootdisk)${NC}"
echo ""
echo -e   "  \033[1;30m/(\033[1;37m(@)\033[1;30m)\\\\\033[0;0m      User:${L_GREEN} $USER ${NC}"
echo -e   "   \033[1;33m^\033[1;30m\`~'\033[1;33m^\033[0;0m       Time:${L_GREEN} $(date +%H:%M)${NC} on ${L_GREEN}$(date +%A) $(date +%d\ %B\,\ %G)${NC} "
echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
#

# only show ical data if the term is xterm-color
if [ "$TERM" = "xterm-color" ]; then
	if [[ -f /usr/local/bin/icalBuddy ]]; then
		/usr/local/bin/icalBuddy -f -ec Weeknumbers eventsToday+1
		echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
	fi
fi

echo -e "$(screenON)"
echo -e "Bash Version: ${L_CYAN}${BASH_VERSION%.*}${NC} ~ ${L_CYAN}`which bash`${NC} Term: ${L_CYAN}`echo $TERM`${NC}"
echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
#

# if ~/.bashrc then source it
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
else
	echo -e "There is ${RED}no ~/.bashrc !!${NC}"
	echo -e "You can grab one here."
	echo -e "${GREEN}http://github.com/dunolie/dunolie-dotfiles${NC}"
	echo -e "If you have ${GREEN}git${NC} installed, run..."
	echo -e "${GREEN}git clone git://github.com/dunolie/dunolie-dotfiles.git${NC}"
	echo -e "Then copy the enclosed ${GREEN}.bashrc${NC} file to your ${GREEN}`echo $HOME` ${NC}dir"
	echo -e ""
	echo -e "Using the global ${GREEN}bashrc${NC} file from ${GREEN}/etc/bashrc${NC}"
fi

# set gnu-screen term to xterm-color so I get good titles in mocp and vim
if [ "$TERM" = "screen" ]; then
	export TERM=xterm-color
fi

# disable crashreporter. I find it hogs CPU usage
#if [[ `uname` = "Darwin" ]]; then
#	launchctl unload /System/Library/LaunchDaemons/com.apple.ReportCrash.plist
#fi