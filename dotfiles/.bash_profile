# -------------------------------------------------------------------------------
# Author: Robbie  --  dunolie (at) gmail (dot) com
# Created: Fri 18 Dec 2009 20:20:35 pm GMT
# Description: $(HOME)/.bash_profile
# Last modified: Fri 18 Dec 2009 20:20:45 pm GMT
# Comments: mac osx centred bash profile
#-------------------------------------------------------------------------------
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
NC='\e[0m' # No Color
WHITE='\e[1;37m'
BLACK='\e[0;30m'
BLUE='\e[0;34m'
L_BLUE='\e[1;34m'
GREEN='\e[0;32m'
L_GREEN='\e[1;32m'
CYAN='\e[0;36m'
L_CYAN='\e[1;36m'
RED='\e[0;31m'
L_RED='\e[1;31m'
PURPLE='\e[0;35m'
L_PURPLE='\e[1;35m'
YELLOW='\e[1;33m'
L_YELLOW='\e[0;33m'
GRAY='\e[1;30m'
L_GRAY='\e[0;37m'
#

# -------------------------------------------------------------------------------
#                        MY WELCOME MESSAGE
# -------------------------------------------------------------------------------
# List screen sessions. Attached or dettached
function screenON () {
SERVICEUP="screen"
if ps ax | grep -v grep | grep $SERVICEUP > /dev/null
then
	echo -e "=-=-=-=-= ${GREEN} $(screen -list)${NC}"
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
echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo -e   "    \033[1;37m.\033[1;30m~\033[1;37m.\033[0;0m        OS X:${L_CYAN} $(sw_vers -productVersion)${NC}"
echo -en  "    \033[1;30m/\033[1;33mV\033[1;30m\\\\\033[0;0m    Computer:${L_CYAN} $(hostname) ${NC}"
echo ""
echo -en  "   \033[1;30m//\033[1;37m&\033[1;30m\\\\\\\\\033[0;0m   BootDisk:${L_CYAN} $(bootdisk)${NC}"
echo ""
echo -e   "  \033[1;30m/(\033[1;37m(@)\033[1;30m)\\\\\033[0;0m      User:${L_GREEN} $USER ${NC}"
echo -e   "   \033[1;33m^\033[1;30m\`~'\033[1;33m^\033[0;0m       Time:${L_GREEN} $(date +%H:%M)${NC} on ${L_GREEN}$(date +%A) $(date +%d\ %B\,\ %G)${NC} "

# My welcome message with my @terminal todo's from my todo.txt, see lifehacker.com for more info on todo.txt
if [  -f ~/Sync/ToDo/todo.txt ]; then
	echo -e "=-=-=-=-=-=-=-=-=-=-${L_RED} todo's! ${NC}-=-=-=-=-=-=-=-=-=-==-=-=-=-="
	echo -e "${L_RED}$(grep @term ~/Sync/ToDo/todo.txt)${NC}"
	echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
else
	echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
fi
#if [[ -f ~/bin/weather-report ]]; then
#	if [ "ping -c 2 www.google.com > /dev/null -eq 0" ]; then
#		#echo -e "\033[1;32m The weather in Oban is currently, $(oban-forecast "EUR|UK|UK604|Oban")\033[0m"
#		echo -e "${GREEN}$(weather-report)${NC}"
#		echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
#	else
#		echo  -e "Internet connection is${RED} down${NC} ~ No weather report :("
#		echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
#	fi
#else
#	echo  -e "=-=-=-=-=${RED} No weather report file"${NC}
#	echo -e "=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
#fi
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

