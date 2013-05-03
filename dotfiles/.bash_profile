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
# -------------------------------------------------------------------------------
#                        MY WELCOME MESSAGE
# -------------------------------------------------------------------------------
echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo -e   "OS X:    ${L_GREEN} $(sw_vers -productVersion)${NC}"
echo -e  "Computer:${L_GREEN} $(scutil --get ComputerName) ${NC}"
echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

# only show ical data if the term is xterm-color
if [ "$TERM" = "xterm-256color" ]; then
	if [[ -f /usr/local/bin/icalBuddy ]]; then
		/usr/local/bin/icalBuddy -f -ec F1 -ec Weeknumbers -eep notes eventsToday+2
	fi
fi
# -------------------------------------------------------------------------------

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
#if [ "$TERM" = "screen" ]; then
#	export TERM=xterm-color
#fi

# disable crashreporter. I find it hogs CPU usage
#if [[ `uname` = "Darwin" ]]; then
#	launchctl unload /System/Library/LaunchDaemons/com.apple.ReportCrash.plist
#fi

# Ruby Version manager
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
