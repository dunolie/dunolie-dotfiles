# -------------------------------------------------------------------------------
# Author: Robbie ( dunolie@gmail.com )
# Created: 03/10/09 @ 07:07:20
# Description: $(HOME)/.bash_profile
# Last modified:
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
#
# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi
#
# source ~/.bashrc-dterm for the Dterm app
if [[ $TERM_PROGRAM = "DTerm" ]]; then
	source ~/.bashrc-dterm
	return
fi
# -------------------------------------------------------------------------------
#                         SHELL COLOURS
# -------------------------------------------------------------------------------
#
# Setup some colors to use later in interactive shell or scripts
# better to out this in your $HOME/.aliases_bash
alias colorcodes="set | egrep 'COLOR_\w*'"  # Lists all the colors
export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[1;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'
#
export NC='\e[0m' # No Color
export WHITE='\e[1;37m'
export BLACK='\e[0;30m'
export BLUE='\e[0;34m'
export L_BLUE='\e[1;34m'
export GREEN='\e[0;32m'
export L_GREEN='\e[1;32m'
export CYAN='\e[0;36m'
export L_CYAN='\e[1;36m'
export RED='\e[0;31m'
export L_RED='\e[1;31m'
export PURPLE='\e[0;35m'
export L_PURPLE='\e[1;35m'
export YELLOW='\e[1;33m'
export L_YELLOW='\e[0;33m'
export GRAY='\e[1;30m'
export L_GRAY='\e[0;37m'
#
# -------------------------------------------------------------------------------
#                       SCREEN SETTINGS
# -------------------------------------------------------------------------------
#
# Automatically reattach to a screen session after logging in via ssh - http://tlug.dnho.net/?q=node/239
if [ $SSH_TTY ] && [ ! $WINDOW ]; then
	SCREENLIST=`screen -ls | grep 'Attached'`
	if [ $? -eq "0" ]; then
		echo -e "Screen is already running and attached:\n ${SCREENLIST}"
	else
		screen -U -R
	fi
fi
#
alias screen='/usr/local/bin/screen'
alias screen256='/usr/local/bin/screen -c ~/.screen/.screenrc.256'
# -------------------------------------------------------------------------------
#                       PATH SETTINGS
# -------------------------------------------------------------------------------
### Set important Libs
LD_LIBRARY_PATH="/opt/local/lib:/usr/lib:/usr/local/lib"
export LD_LIBRARY_PATH
# my paths
export PATH=/opt/local/bin:/opt/local/sbin:/opt/local/lib/mysql5/bin:/usr/X11/bin:~/bin:~/pbin:$PATH
export PATH=${PATH}:/bin:/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/games/:/usr/share/games
export PATH=$PATH:/Developer/usr/bin:/Developer/usr/sbin:/usr/local/mysql/bin:/System/library/Frameworks/Ruby.framework/Versions/1.8/usr/bin
export PATH=$PATH:/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/
export PATH=$PATH:/System/Library/Frameworks/Python.framework/Versions/Current/bin/
#
# my manual (man pages) paths
export MANPATH=/opt/local/share/man:/usr/local/man:/usr/local/share/man:/usr/share/man:$MANPATH
export MANPATH=$MANPATH:/Developer/usr/share/man:/Developer/usr/X11/man:/usr/X11/man:~/Sync/Bash/man
#
# perl paths
PERL5LIB="/opt/local/lib/perl5/5.8.8:/usr/bin/perl5.8.8"
export PERL5LIB
#
# Setting PATH for MacPython 2.5
# The orginal version is saved in .bash_profile.pysave
# PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
export PYTHONPATH="/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/"
export PYTHONPATH=$PYTHONPATH":/System/Library/Frameworks/Python.framework/Versions/Current/bin/"

## Ruby Paths
# unset RUBYOPT
# export GEM_HOME=/usr/local/lib/ruby/gems/1.8:/Library/Ruby/Gems/1.8
# export RUBYLIB=/usr/local/lib/ruby:/usr/local/lib/ruby/site_ruby/1.8
#export GEMDIR=`gem env gemdir`
export GEMDIR=/opt/local/lib/ruby/gems/1.8
# -------------------------------------------------------------------------------
#                        AUTO COMPLETION
# -------------------------------------------------------------------------------
#
bind "set completion-ignore-case on"
#
# Magical Auto Start-X on login &
# Auto logout on X-Closing
# (requires expect)
case `tty` in
	/dev/tty[1])
		echo -n "Start X [Yn]? "
			expect \
			-c 'stty raw' \
			-c 'set timeout 2' \
			-c 'expect -nocase n {exit 1} -re . {exit 0}'
		if [ $? = 0 ] ; then
			startx
			echo -n "Log out [Yn]? "
			expect \
				-c 'stty raw' \
				-c 'set timeout 5' \
				-c 'expect -nocase n {exit 1} -re . {exit 0}'
				if [ $? = 0 ] ; then
			logout
			fi
		fi
		echo
	;;
esac
#
# completes ssh conections from my known hosts.
#complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh
#
# http://bit.ly/4nuREV
HOSTFILE=~/.hosts

function _ssh() {
  local cur
  cur=${COMP_WORDS[COMP_CWORD]}
  if [ "${cur:0:1}" != "-" ]; then
	COMPREPLY=( $(awk '/^Host '$2'/{print $2}' $HOME/.ssh/config) )
  fi		
  return 0
}

complete -F _ssh ssh sftp scp
complete -A hostname ssh sftp scp
#
if [ -f /opt/local/share/doc/git-core/contrib/completion/git-completion.bash ]; then
	source /opt/local/share/doc/git-core/contrib/completion/git-completion.bash
fi
#
if [ -f /usr/local/git/contrib/completion/git-completion.bash ]; then
	source /usr/local/git/contrib/completion/git-completion.bash
fi
#
if [ -f /opt/local/etc/bash_completion.d/git ]; then
	source /opt/local/etc/bash_completion.d/git
fi
#
## http://mernen.com/projects/completion-ruby
if [[ -d ~/.ruby-completion ]]; then
	source ~/.ruby-completion/completion-gem
	source ~/.ruby-completion/completion-jruby
	source ~/.ruby-completion/completion-rails
	source ~/.ruby-completion/completion-rake
	source ~/.ruby-completion/completion-ruby-all
fi
# -------------------------------------------------------------------------------
#                        HISTORY
# -------------------------------------------------------------------------------
#
# my history settings
export HISTIGNORE="&:[ ]*:exit:ll:cd:ls:bd:m:wr:soa:sof:sob:ea:eb:ebf:l:te:soar:soah:soax:"
export HISTSIZE=999
export HISTFILESIZE=999
# export HISTTIMEFORMAT="%s "
export HISTTIMEFORMAT='%a, %d %b %Y %l:%M:%S%p %z '
#
# --------------------------------------------------------------------------------
#                        TEXT EDIT
# --------------------------------------------------------------------------------
#
# Safe rm, cause sometimes things fuxor up (moves things to the trash insted of rm'ing)
# http://osxutils.sourceforge.net/http://osxutils.sourceforge.net/
if [ "$sw_vers -productVersion" != "10.*" ] ; then
		alias rm='/usr/local/bin/trash'
	else
		alias rm='rm -i'
fi
#
#alias tclsh='/usr/bin/tclsh8.4'
#export TCLSH='/usr/bin/tclsh8.4'
#
export EDITOR="vim"
export GIT_EDITOR='vim'
export VISUAL="vim"
#export PAGER="less"
# export VISUAL="less"
export LESS="-erX"
# Using my own colorscheme for vim. sometimes vim does not like to load it automatically
export MANPAGER='col -bx | vim -c "colorscheme dunolie" -c ":set ft=man nonu nolist" -R -'
# original version of vim man page viewer
# export MANPAGER='col -bx | vim -c ":set ft=man nonu nolist" -R -'
#
#
# --------------------------------------------------------------------------------
#
# set LC & LANG , iTerm does not handle UTF-8 fully otherwise :{
# export LC_ALL=C
export LC_CTYPE=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8
export INPUTRC="~/.inputrc"
export EVENT_NOKQUEUE=1               # for memcached
#export BASH_ENV=$HOME/.bashrc
#export PATH BASH_ENV
export FUNCTIONS=$HOME/.bash_functions
export ALIASES=$HOME/.aliases_bash:$HOME/.aliases_bash_robbie:$HOME/.aliases_bash_osx:$HOME/.aliases_bash_osx_home
export IFS=$' \t\n'
export MYSQL_DEFAULT_DB=mysql
export TZ='Europe/London'
export HELP=`echo -e "There is a bash help file: ${COLOR_GREEN}~/.bash_help${COLOR_NC} - or $ help<tab> from the shell"`
#
# -------------------------------------------------------------------------------
#                       COMPILING FLAGS
# -------------------------------------------------------------------------------
#  You might need to compile with this option too if you get errors.
#  ./configure --disable-dependency-tracking
# Compile for ppc
if [[ $(uname -p) = "powerpc" ]]; then
	export CFLAGS='-arch ppc'
	export LDFLAGS='-arch ppc'
fi
# Compiling code with GCC enabled for Core 2 Duo only
if [[ $(uname -p) = "i386" ]]; then
	export ARCHFLAGS='-arch i386'
	export CFLAGS=' -march=nocona -O2 -pipe -mtune=nocona '
	# some binaries need both arch's
	# export ARCHFLAGS='-arch i386 -arch ppc'
fi
#
# -------------------------------------------------------------------------------
#                       COLOUR SETTINGS
# -------------------------------------------------------------------------------
#
export CLICOLOR="yes"
#export CLICOLOR=1
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
#
# If dircolors, part of the coreutils suite is installed via macports then use that, otherwise use default OSX colours
# $ sudo port install coreutils
if [[ "$sw_vers -productVersion" != "10.*" ]]; then
	if [[ -f /opt/local/bin/gls ]]; then
		export LS_OPTIONS='--color=auto'
		eval `dircolors ~/.dir_colors`
		#ls aliases for use with dircolors
		alias l='gls $LS_OPTIONS -lAhF'
		alias l.='gls $LS_OPTIONS -d .*'
		alias ls='gls $LS_OPTIONS -hF'
		alias la='gls $LS_OPTIONS -A'
		alias lf='gls $LS_OPTION -Ff'
		alias ll='gls $LS_OPTIONS -lhF'
		alias ld='gls $LS_OPTIONS -daf'
		alias lll='gls $LS_OPTIONS -all'
		alias lsd='gls $LS_OPTIONS -d */'
		alias lss='gls $LS_OPTIONS -Slh'                 #Size
		alias lst='gls $LS_OPTIONS -altrhF'              #Time
		alias lsx='gls $LS_OPTIONS -alh|sort'            #chmod
		alias lsf='gls $LS_OPTIONS -lhF|grep -v /'       #Files
		alias lle='gls $LS_OPTIONS -alhF| less'
	else
		# http://www.infinitered.com/blog/?p=19
		#LS_COLORS=gxgxcxdxbxegedabagacad
		LS_COLORS=cxfxcxdxBxegedabagacad
		export LS_COLORS
		#ls aliases for use with OS X default colours
		alias l='ls -lAhF'
		alias l.='ls -d .*'
		alias ls='ls -CG'
		alias la='ls -A'
		alias lf='ls -Ff'
		alias ll='ls -af'
		alias ld='ls -daf'
		alias lll='ls -all'
		alias lsd='ls -d */'
		alias lss='ls -Slh'                          # Size
		alias lst='ls -altrhF'                       #Time
		alias lsx='ls -alh|sort'                     #chmod
		alias lsf='ls -lhF|grep -v /'                #Files
		alias lle='ls -alhF| less'
	fi
fi
#
# linux ls colors, see: http://www.linux-sxs.org/housekeeping/lscolors.html
#
# http://www.pixelbeat.org/scripts/l
# Add a fancy symlink arrow
#if echo "$LANG" | grep -i "utf-*8$" >/dev/null; then
#	SYM_ARROW="▪▶"
#else
#
#	SYM_ARROW="->"
#fi
# needs a fix :/
#
# -------------------------------------------------------------------------------
#                        WATCH PROCESSES
# -------------------------------------------------------------------------------
#
if [ "$sw_vers -productVersion" != "10.*" ] ; then
	alias top='top -o cpu' # os x
else
	alias processes_all='ps -aulx'
fi
#
# -------------------------------------------------------------------------------
#                        SOURCED FILES
# -------------------------------------------------------------------------------
#
# source my bash functions
if [[ -f ~/.bash_functions  ]]; then
	source ~/.bash_functions
fi

if [[ -f ~/.fff  ]]; then
	source ~/.fff
fi
#
# bash help file
if [[ -f ~/.bash_help ]]; then
	source ~/.bash_help
fi
#
# source my netrc (for FTP connections)
# source ~/.netrc
#
# -------------------------------------------------------------------------------
#                          Sourcing Aliases
# -------------------------------------------------------------------------------
# source my bash aliases (for general nix* & public use)
if [[ -f ~/.aliases_bash  ]]; then
	source ~/.aliases_bash
fi
#
# source my aliases for files on my computer (desktop or laptop)
# my private (local comp and pivate aliases)
if [[ $USER = "robbie" ]]; then
	if [[ -f ~/.aliases_bash_robbie  ]]; then
		source ~/.aliases_bash_robbie
	fi
fi
# if OS = OS X then (source ~/.aliases_bash_osx)
if [[ "$sw_vers -productVersion" != "10.*" ]]; then
	if [[ -f ~/.aliases_bash_osx  ]]; then
		source ~/.aliases_bash_osx
	fi
fi
# if @home network then source ~/.aliases_bash_home
if [[ "$ipconfig getifaddr en0" != "192.168.2.1*" ]]; then
	if [[ -f ~/.aliases_bash_home  ]]; then
		source ~/.aliases_bash_home
	fi
fi
#
# -------------------------------------------------------------------------------
#                          Make $HOME comfy
# -------------------------------------------------------------------------------
#
if [ ! -d "${HOME}/bin" ]; then
	mkdir ${HOME}/bin
	chmod 700 ${HOME}/bin
	echo "${HOME}/bin was missing.  I created it for you."
fi
if [ ! -d "${HOME}/Documents" ]; then
	if ! [  -d "${HOME}/data" ]; then
		mkdir ${HOME}/data
		chmod 700 ${HOME}/data
		echo "${HOME}/data was missing.  I created it for you."
	fi
fi
if [ ! -d "${HOME}/tmp" ]; then
	mkdir ${HOME}/tmp
	chmod 700 ${HOME}/tmp
	echo "${HOME}/tmp was missing.  I created it for you."
fi
#
# -------------------------------------------------------------------------------
#                        GPG
# -------------------------------------------------------------------------------
#
if [[ $USER = "robbie" ]]; then
	export GPGKEYID="2249A56B"
fi
#
# -------------------------------------------------------------------------------
#                        GENERAL
# -------------------------------------------------------------------------------
#
umask 077
ulimit -c 0
#
# exclude resource forks when making tar|zip|gz files
export COPY_EXTENDED_ATTRIBUTES_DISABLE=true

# set UTF-8 encoding for pbcopy/pbpaste
export __CF_USER_TEXT_ENCODING=0x1F5:0x8000100:0x8000100
#
# -------------------------------------------------------------------------------
#                        KEY BINDINGS
# -------------------------------------------------------------------------------
#
bind '"\C-t": possible-completions' # replaces 'transpose-chars'
bind '"\M-t": menu-complete'        # replaces 'transpose-words'
#
# -------------------------------------------------------------------------------
#                        SHELL VARIABLES
# -------------------------------------------------------------------------------
#
set -o noclobber
set -o physical
shopt -s cdspell
shopt -s extglob
shopt -s dotglob
shopt -s cmdhist
shopt -s lithist
shopt -s progcomp
shopt -s checkhash
shopt -s histreedit
shopt -s promptvars
shopt -s cdable_vars
shopt -s checkwinsize
shopt -s hostcomplete
shopt -s expand_aliases
shopt -s interactive_comments
shopt -s histverify
#
# -------------------------------------------------------------------------------
#                        TEXT HELPERS
# -------------------------------------------------------------------------------
# bash completion settings (actually, these are readline settings)
bind "set completion-ignore-case on" # note: bind used instead of sticking these in .inputrc
bind "set bell-style none"
bind "set show-all-if-ambiguous On"
bind Space:magic-space
#
# -------------------------------------------------------------------------------
#                        COMPLETIONS
# -------------------------------------------------------------------------------
#
# auto completion for sudo
SUDO_COMPLETE=( $(echo $PATH | sed 's/:/\n/g' | xargs ls 2>/dev/null) )
complete -o default -W "${SUDO_COMPLETE[*]}" sudo
#
complete -A setopt set
complete -A user groups id
complete -A binding bind
complete -A helptopic help
complete -A alias {,un}alias}
complete -A signal -P '-' kill
complete -A stopped -P '%' fg bg
complete -A job -P '%' jobs disown
complete -A variable readonly unset
complete -A file -A directory ln chmod
complete -A user -A hostname finger pinky
complete -A directory find cd pushd {mk,rm}dir
complete -A file -A directory -A user chown
complete -A file -A directory -A group chgrp
complete -o default -W 'Makefile' -P '-o ' qmake
complete -A command man which whatis whereis sudo info apropos
complete -A file {,z}cat pico nano vi {,{,r}g,e,r}vi{m,ew} vimdiff elvis emacs {,r}ed e{,x} joe jstar jmacs rjoe jpico {,z}less {,z}more p{,g}
#
# -------------------------------------------------------------------------------
#                        SHH - GNU SCREEN
# -------------------------------------------------------------------------------
#
#if [ -n "$SSH_CONNECTION" ] && [ -z "$SCREEN_EXIST" ]; then
#    export SCREEN_EXIST=1
#    screen -DR
#fi
#
# ----------------------------------------------------------------------------
#                          SYMBOLS
# ----------------------------------------------------------------------------
#Arrows: → ↛ ⇾ ↝ ↠ ↣ ↦ ↬ ⇒ ⇛ ⇢ ⇥ ⇨ ⇰ ⇸ ⇾ ↳ ↪
ARROW1="→"
ARROW2="↛"
ARROW3="⇾"
ARROW4="↝"
ARROW5="↠"
ARROW6="↣"
ARROW7="↦"
ARROW8="↬"
ARROW9="⇒"
ARROW10="⇛"
ARROW11="⇢"
ARROW12="⇥"
ARROW13="⇨"
ARROW14="⇰"
ARROW15="⇸"
ARROW16="⇾"
ARROW17="↳"
ARROW18="↪"
YINYANG="☯"
#
# -------------------------------------------------------------------------------
#                        MY WELCOME MESSAGE
# -------------------------------------------------------------------------------
# List screen sessions. Attached or dettached
function screenON () {
SERVICEUP="screen"
if ps ax | grep -v grep | grep $SERVICEUP > /dev/null
then
	echo -e "=-=-=-=-= ${GREEN} $(scrl)${NC}"
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
#
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
#
# -------------------------------------------------------------------------------
#                         PROMPTS
# -------------------------------------------------------------------------------
# Xterm title bar
case $TERM in
	xterm*)
		XTITLE='\[\e]0; (\!) (\#) [\u@\h] [\w] \@ \007\]';
		;;
	*)
		XTITLE="";
	;;
esac

# add the time to the prompt, useful to see how long commands are taking
PTIME="`date +%H:%M`"

if [[ "$TERM" = "dumb" ]]; then
	# Stripped the colour codes for terminals without colour
	PS1="${XTITLE}[\!] (\#) \u@\h \W \$ "
	PS2="${XTITLE}[\!][PS2] (\#) \u@\h \W > "
fi

if [[ -f ~/.bash_prompt ]]; then
	. ~/.bash_prompt
else
	PS1='[http://bit.ly/4wngdq]\u@\h \W \$ '
	PS2='[http://bit.ly/4wngdq]\u@\h \W » '
	SUDO_PS1='SUDO!: \u@\h \W ☯ '
fi

#. ~/.git_svn_bash_prompt
# -------------------------------------------------------------------------------
#         WINDOW TITLE SETTINGS
# -------------------------------------------------------------------------------
#
# Prompt command for screenrc
# PROMPT_COMMAND='echo -n -e "\033k\033\134"'
# ----------------------------------------------------------------------------
#                          FINAL-CLOSING STUFF
# ----------------------------------------------------------------------------
# Try to keep environment pollution down, EPA loves us.
# unset use_color safe_term match_lhs
#
# -------------------------------------------------------------------------------
#               END OF BASHRC - Robbie - dunolie@gmail.com
# -------------------------------------------------------------------------------
