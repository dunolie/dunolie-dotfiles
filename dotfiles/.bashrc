# -------------------------------------------------------------------------------
#         Author: Robbie -- dunolie (at) gmail (dot) com
#      File name: my bashrc ($HOME/.bashrc)
#        Created: Fri 11 Dec 2009 14:33:12 pm GMT
#  Last Modified: Wed May 01, 2013  05:19am
# -------------------------------------------------------------------------------
#       Comments: my bashrc, mainly osx centric
#    Description:
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
# -------------------------------------------------------------------------------
#                         SHELL COLOURS
# -------------------------------------------------------------------------------
#
# fully escaped for use in prompts
E_WHITE='\[\033[1;37m\]'
E_BLACK='\[\033[0;30m\]'
E_BLUE='\[\033[0;34m\]'
E_L_BLUE='\[\033[1;34m\]'
E_GREEN='\[\033[0;32m\]'
E_L_GREEN='\[\033[1;32m\]'
E_CYAN='\[\033[0;36m\]'
E_L_CYAN='\[\033[1;36m\]'
E_RED='\[\033[0;31m\]'
E_L_RED='\[\033[1;31m\]'
E_PURPLE='\[\033[0;35m\]'
E_L_PURPLE='\[\033[1;35m\]'
E_YELLOW='\[\033[1;33m\]'
E_L_YELLOW='\[\033[0;33m\]'
E_GRAY='\[\033[1;30m\]'
E_L_GRAY='\[\033[0;37m\]'
E_NC='\[\033[0m\]'
#
# colours for use in scripts and notices
export NC='\033[0m' # No Color
export WHITE='\033[1;37m'
export BLACK='\033[0;30m'
export BLUE='\033[0;34m'
export L_BLUE='\033[1;34m'
export GREEN='\033[0;32m'
export L_GREEN='\033[1;32m'
export CYAN='\033[0;36m'
export L_CYAN='\033[1;36m'
export RED='\033[0;31m'
export L_RED='\033[1;31m'
export PURPLE='\033[0;35m'
export L_PURPLE='\033[1;35m'
export YELLOW='\033[1;33m'
export L_YELLOW='\033[0;33m'
export GRAY='\033[1;30m'
export L_GRAY='\033[0;37m'
#
KERNEL_NAME=`uname -s`
KERNEL_VERSION=`uname -r`

case $KERNEL_NAME in
	Darwin)
		SYSTEM='Mac'
		case $KERNEL_VERSION in
			8*) SYSTEM='Tiger' ;;
			9*) SYSTEM='Leopard' ;;
			10*) SYSTEM='Snow Leopard' ;;
		esac;;
	*) SYSTEM='Unknown' ;;
esac

export SYSTEM
export OSX='OS X 10.*'
export TIGER='OS X 10.4.*'
export LEOPARD='OS X 10.5.*'
export SNOW_LEOPARD='OS X 10.6.*'
export LION='OS X 10.7.*'
export MOUNTAIN_LION='OS X 10.8.*'
# --------------------------------------

#                       SCREEN SETTINGS
# -------------------------------------------------------------------------------
#
# Automatically reattach to a screen session after logging in via ssh - http://tlug.dnho.net/?q=node/239
if [ $SSH_TTY ] && [ ! $WINDOW ]; then
	SCREENLIST=`screen -ls | grep 'Attached'`
	if [ $? -eq "0" ]; then
		echo -e "${CYAN}Screen is already running and attached:${GREEN}\n ${SCREENLIST}${NC}"
	else
		screen -U -R
	fi
fi
#
# -------------------------------------------------------------------------------
#                       PATH SETTINGS
# -------------------------------------------------------------------------------
### Set important Libs
#LD_LIBRARY_PATH="/opt/local/lib:/usr/lib:/usr/local/lib"
#export LD_LIBRARY_PATH
# my paths

export PATH=/usr/local/bin:/usr/X11/bin:~/bin:~/pbin:/usr/local/sbin:$PATH
export PATH=${PATH}:/bin:/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/games:/usr/share/games
export PATH=$PATH:/Developer/usr/bin:/Developer/usr/sbin:/usr/local/mysql/bin:/opt/X11/bin
#export PATH=$PATH:/System/library/Frameworks/Ruby.framework/Versions/1.8/usr/bin
#export PATH=$PATH:/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin
#export PATH=$PATH:/System/Library/Frameworks/Python.framework/Versions/Current/bin

#
# For non-root users, add the current directory to the search path:
if [ ! "`id -u`" = "0" ]; then
 PATH="$PATH:."
fi
#
#
# Ruby Version Manager
source /Users/robbie/.rvm/scripts/rvm
#
# my manual (man pages) paths
export MANPATH=/usr/local/share/man:$MANPATH
export MANPATH=${MANPATH}/opt/X11/share/man:/usr/local/man:/usr/share/man
export MANPATH=${MANPATH}/Developer/usr/share/man:/Developer/usr/X11/man:/usr/X11/man:~/Sync/Bash/man

#

#export DYLD_LIBRARY_PATH="/usr/local/mysql/lib:$DYLD_LIBRARY_PATH"
# perl paths
export ARCHFLAGS="-arch i386 -arch x86_64"
export VERSIONER_PERL_PREFER_32_BIT=no
# OSX Default perl paths. installed via sudo 
export PERL5LIB="/System/Library/Perl/5.12:/System/Library/Perl/5.10:/Library/Perl/5.12"
# My perl paths installed via homebrew
#export PERL5LIB="/Users/robbie/perl5/lib/perl5"
#

# Setting PATH for MacPython 2.5
# The orginal version is saved in .bash_profile.pysave
# PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
#export PYTHONPATH="/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/"
#export PYTHONPATH=$PYTHONPATH"/System/Library/Frameworks/Python.framework/Versions/2.7/bin/:/System/Library/Frameworks/Python.framework/Versions/Current/bin/"

## Ruby Paths
export PATH=$PATH:~/.gem/ruby/1.8/bin:~/.rvm/bin

export RBENV_ROOT=/usr/local/var/rbenv

#To enable shims and autocompletion add to your profile:
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
	
# unset RUBYOPT
# export GEM_HOME=/usr/local/lib/ruby/gems/1.8:/Library/Ruby/Gems/1.8
# export RUBYLIB=/usr/local/lib/ruby:/usr/local/lib/ruby/site_ruby/1.8
# export GEMDIR=`gem env gemdir`
# export GEMDIR=/opt/local/lib/ruby/gems/1.8

#git settings
# http://defunkt.io/hub/
if [[ -f /usr/local/bin/hub ]]; then
	alias git='/usr/local/bin/hub'
fi
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
if [ -f /usr/local/share/doc/git-core/contrib/completion/git-completion.bash ]; then
	source /opt/local/share/doc/git-core/contrib/completion/git-completion.bash
fi
#
if [ -f /usr/local/git/contrib/completion/git-completion.bash ]; then
	source /usr/local/git/contrib/completion/git-completion.bash
fi
#
if [ -f /usr/local/etc/bash_completion.d/git ]; then
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

# complete macports commands
#if [[ -f ~/.bash_completion.d/port ]]; then
#	source ~/.bash_completion.d/port
#fi

# complete todo script commands
if [[ -f ~/.bash_completion.d/todo_completer.sh ]]; then
	source ~/.bash_completion.d/todo_completer.sh
fi

#if [ -x /usr/libexec/path_helper ]; then
#	eval `/usr/libexec/path_helper -s`
#fi

# brew / homebrew completions
. $(brew --repository)/Library/Contributions/brew_bash_completion.sh
# -------------------------------------------------------------------------------
#                        HISTORY
# -------------------------------------------------------------------------------
#
# my history settings
export HISTIGNORE="&:[ ]*:exit:ll:ls:bd:m:wr:soa:sof:sob:ea:eb:ebf:l:te:soar:soah:soax:"
export HISTSIZE=9999
export HISTFILESIZE=9999
# export HISTTIMEFORMAT="%s "
export HISTTIMEFORMAT='%a, %d %b %Y %l:%M:%S%p %z '
#
# --------------------------------------------------------------------------------
#                        TEXT EDIT
# --------------------------------------------------------------------------------
#
# Safe rm, cause sometimes things fuxor up (moves things to the trash insted of rm'ing)
# http://osxutils.sourceforge.net/http://osxutils.sourceforge.net/
if [[ `uname` = "Darwin" && -f /usr/local/bin/trash ]]; then
		alias rm='/usr/local/bin/trash'
	else
		alias rm='rm -i'
fi
#
#alias tclsh='/usr/bin/tclsh8.4'
#export TCLSH='/usr/bin/tclsh8.4'
#
#if [[ `uname` = "Darwin" ]]; then
#	export EDITOR='mate -w'
#else
#	export EDITOR='vim'
#fi

# vim aliases as I can't get it loaded in .vimrc :/
alias vim='vim -c "colorscheme xoria256"'
alias vi='vim -c "colorscheme xoria256"'
alias v='vim -c "colorscheme xoria256"'

export EDITOR="vim -c 'colorscheme xoria256'"
export GIT_EDITOR="vim"
export VISUAL="vim"
export PAGER="less"
export LESS="-erX"
#export LESS="-e -i -M -R -X -F -S"
export LESSCHARSET="UTF-8"
#
# original version of vim man page viewer
# export MANPAGER='col -bx | vim -c ":set ft=man nonu nolist" -R -'
#
# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

#Set my Default Browser
export BROWSER="open -a FireFox.app"
# --------------------------------------------------------------------------------
#
# set LC & LANG , iTerm does not handle UTF-8 fully otherwise :{
#export LC_ALL="C"
#export LC_ALL='en_GB.UTF-8'
#export LC_ALL=""
#export LANG="en_GB.UTF-8"
export LC_COLLATE="en_GB.UTF-8"
#export LC_CTYPE="en_GB.UTF-8"
export LC_MESSAGES="en_GB.UTF-8"
export LC_MONETARY="en_GB.UTF-8"
export LC_NUMERIC="en_GB.UTF-8"
export LC_TIME="en_GB.UTF-8"
export LC_PAPER="en_GB.UTF-8"
export LC_NAME="en_GB.UTF-8"
export LC_ADDRESS="en_GB.UTF-8"
export LC_TELEPHONE="en_GB.UTF-8"
export LC_MEASUREMENT="en_GB.UTF-8"
#export LC_IDENTIFICATION="C"
#
export INPUTRC="~/.inputrc"
export EVENT_NOKQUEUE=1               # for memcached
export FUNCTIONS=$HOME/.bash_functions
export ALIASES=$HOME/.aliases_bash:$HOME/.aliases_bash_robbie:$HOME/.aliases_bash_osx:$HOME/.aliases_bash_osx_home
export IFS=$' \t\n'
export MYSQL_DEFAULT_DB=mysql
#export HELP=`echo -e "There is a bash help file: ${COLOR_GREEN}~/.bash_help${COLOR_NC} - or $ help<tab> from the shell"`
#
if [[ -z "${TZ}" ]] ; then
    export TZ='Europe/London'
fi

# -------------------------------------------------------------------------------
#                       COMPILING FLAGS
# -------------------------------------------------------------------------------
#  You might need to compile with this option too if you get errors.
#  ./configure --disable-dependency-tracking
# Compile for ppc
# if [[ $(uname -p) = "powerpc" ]]; then
# 	export CFLAGS='-arch ppc'
# 	export LDFLAGS='-arch ppc'
# fi
# # Compiling code with GCC enabled for Core 2 Duo only
# if [[ $(uname -p) = "i386" ]]; then
# 	export ARCHFLAGS='-arch i386'
# 	export CFLAGS=' -march=nocona -O2 -pipe -mtune=nocona '
# 	# some binaries need both arch's
# 	# export ARCHFLAGS='-arch i386 -arch ppc'
# fi
#
# -------------------------------------------------------------------------------
#                       COLOUR ~ LS -- SETTINGS
# -------------------------------------------------------------------------------
#
#export CLICOLOR="yes"
export CLICOLOR=1
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'
#
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
#
# If dircolors, part of the coreutils suite is installed via macports then use that,
# otherwise use default OSX colours
# $ sudo port install coreutils
if [[ `uname` = "Darwin" ]]; then
	if [[ -f /usr/local/bin/gls ]]; then
		#export LS_OPTIONS='--color=auto'
		eval `/usr/local/bin/gdircolors ~/.dir_colors`
		#ls aliases for use with dircolors
		alias l='gls --color=auto -lAhF'
		alias l.='gls --color=auto -d .*'
		alias ls='gls --color=auto -hF'
		alias la='gls --color=auto -A'
		alias lf='gls --color=auto -Ff'
		alias ll='gls --color=auto -lhF'
		alias ld='gls --color=auto -daf'
		alias lll='gls --color=auto -all'
		alias lsd='gls --color=auto -d */'
		alias lss='gls --color=auto -Slh'                 #Size
		alias lst='gls --color=auto -altrhF'              #Time
		alias lsx='gls --color=auto -alh|sort'            #chmod
		alias lsf='gls --color=auto -lhF|grep -v /'       #Files
		alias lle='gls --color=auto -alhF| less'
		alias acl='/bin/ls -le' # View and validate the ACL modifications with the ls command
	else
		# http://www.infinitered.com/blog/?p=19
		#export LS_COLORS=gxgxcxdxbxegedabagacad
		#export LS_COLORS=cxfxcxdxBxegedabagacad
		# a black
		# b red
		# c green
		# d brown
		# e blue
		# f magenta
		# g cyan
		# h light grey
		# A bold black, usually shows up as dark grey
		# B bold red
		# C bold green
		# D bold brown, usually shows up as yellow
		# E bold blue
		# F bold magenta
		# G bold cyan
		# H bold light grey; looks like bright white
		# x default foreground or background
		# Order: dir - symlink - socket - pipe - exec - block special - char special - exec
		# setuid - exec setgid - public dir sticky bit - public dir no sticky bit
		export LSCOLORS=GxfxcxdxbxGgGdabagacad
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
		alias acl='/bin/ls -le' # View and validate the ACL modifications with the ls command
	fi
fi
#
if [[ `uname` = "Linux" ]]; then
	eval `dircolors ~/.dir_colors`
	# ls aliases
	alias l='ls --color=auto -lAhF'
	alias l.='ls --color=auto -d .*'
	alias ls='ls --color=auto -hF'
	alias la='ls --color=auto -A'
	alias lf='ls --color=auto -Ff'
	alias ll='ls --color=auto -lhF'
	alias ld='ls --color=auto -daf'
	alias lll='ls --color=auto -all'
	alias lsd='ls --color=auto -d */'
	alias lss='ls --color=auto -Slh'                 #Size
	alias lst='ls --color=auto -altrhF'              #Time
	alias lsx='ls --color=auto -alh|sort'            #chmod
	alias lsf='ls --color=auto -lhF|grep -v /'       #Files
	alias lle='ls --color=auto -alhF| less'
fi
#
# -------------------------------------------------------------------------------
#                        WATCH PROCESSES
# -------------------------------------------------------------------------------
#
if [ `uname` = "Darwin" ] ; then
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
if [[ -f ~/.aliases_bash_robbie  ]]; then
	source ~/.aliases_bash_robbie
fi
# if OS X then source ~/.aliases_bash_osx
if [[ `uname` = "Darwin" ]]; then
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
#if [[ $USER = "robbie" ]]; then
# 	if [ ! -d "${HOME}/bin" ]; then
# 		mkdir ${HOME}/bin
# 		chmod 700 ${HOME}/bin
# 		echo -e "${CYAN}${ARROW19} ${HOME}/bin${NC} was missing. I created it for you. ${CYAN}:)${NC}"
# 	fi
# 	if [ ! -d "${HOME}/Documents" ]; then
# 		if ! [  -d "${HOME}/data" ]; then
# 			mkdir ${HOME}/data
# 			chmod 700 ${HOME}/data
# 			echo -e "${CYAN}${ARROW19} ${HOME}/data${NC} was missing. I created it for you. ${CYAN}:)${NC}"
# 		fi
# 	fi
# 	if [ ! -d "${HOME}/tmp" ]; then
# 		mkdir ${HOME}/tmp
# 		chmod 700 ${HOME}/tmp
# 		echo -e "${CYAN}${ARROW19} ${HOME}/tmp${NC} was missing. I created it for you. ${CYAN}:)${NC}"
# 	fi
#fi
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
# prevent creation of the ._filename files when using tar
export COPYFILE_DISABLE=true
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
# bash completion settings (actually, these are readline settings)
bind "set completion-ignore-case on" # note: bind used instead of sticking these in .inputrc
bind "set bell-style none"
bind "set show-all-if-ambiguous on"
bind Space:magic-space
#
# -------------------------------------------------------------------------------
#                        COMPLETIONS
# -------------------------------------------------------------------------------
#
# auto completion for sudo
SUDO_COMPLETE=( $(echo $PATH | sed 's/:/\n/g' | xargs ls 2>/dev/null) )
complete -o default -W "${SUDO_COMPLETE[*]}" sudo
complete -F _sudo s
complete -cf sudo
#
complete -A setopt set
complete -A user groups id
complete -A binding bind
complete -A helptopic help
complete -A alias {,un}alias
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
# Todo scripts completion
complete -F _todo_sh -o default todo
complete -F _todo_sh -o default t
complete -F _todo_sh -o default td

# Compression
complete -f -o default -X '*.+(zip|ZIP)'  zip
complete -f -o default -X '!*.+(zip|ZIP)' unzip
complete -f -o default -X '*.+(z|Z)'      compress
complete -f -o default -X '!*.+(z|Z)'      uncompress
complete -f -o default -X '*.+(gz|GZ)'      gzip
complete -f -o default -X '!*.+(gz|GZ)'   gunzip
complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract

# Documents - Postscript,pdf,dvi.....
complete -f -o default -X '!*.+(ps|PS)'  gs ghostview ps2pdf ps2ascii
complete -f -o default -X '!*.+(dvi|DVI)' dvips dvipdf xdvi dviselect dvitype
complete -f -o default -X '!*.+(pdf|PDF)' acroread pdf2ps
complete -f -o default -X \
'!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv
complete -f -o default -X '!*.texi*' makeinfo texi2dvi texi2html texi2pdf
complete -f -o default -X '!*.tex' tex latex slitex
complete -f -o default -X '!*.lyx' lyx
complete -f -o default -X '!*.+(htm*|HTM*)' lynx html2ps
complete -f -o default -X \
'!*.+(doc|DOC|xls|XLS|ppt|PPT|sx?|SX?|csv|CSV|od?|OD?|ott|OTT)' soffice

# Multimedia
complete -f -o default -X \
'!*.+(gif|GIF|jp*g|JP*G|bmp|BMP|xpm|XPM|png|PNG)' xv gimp ee gqview
complete -f -o default -X '!*.+(mp3|MP3)' mpg123 mpg321
complete -f -o default -X '!*.+(ogg|OGG)' ogg123
complete -f -o default -X \
'!*.@(mp[23]|MP[23]|ogg|OGG|wav|WAV|pls|m3u|xm|mod|s[3t]m|it|mtm|ult|flac)' xmms
complete -f -o default -X \
'!*.@(mp?(e)g|MP?(E)G|wma|avi|AVI|asf|vob|VOB|bin|dat|vcd|\
ps|pes|fli|viv|rm|ram|yuv|mov|MOV|qt|QT|wmv|mp3|MP3|ogg|OGG|\
ogm|OGM|mp4|MP4|wav|WAV|asx|ASX)' xine

complete -f -o default -X '!*.pl'  perl perl5

########
# This is a 'universal' completion function - it works when commands have
# a so-called 'long options' mode , ie: 'ls --all' instead of 'ls -a'
# Needs the '-o' option of grep
#  (try the commented-out version if not available).

# First, remove '=' from completion word separators
# (this will allow completions like 'ls --color=auto' to work correctly).

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}


_get_longopts() 
{ 
    #$1 --help | sed  -e '/--/!d' -e 's/.*--\([^[:space:].,]*\).*/--\1/'| \
#grep ^"$2" |sort -u ;
    $1 --help | grep -o -e "--[^[:space:].,]*" | grep -e "$2" |sort -u 
}

_longopts()
{
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}

    case "${cur:-*}" in
       -*)      ;;
        *)      return ;;
    esac

    case "$1" in
      \~*)      eval cmd="$1" ;;
        *)      cmd="$1" ;;
    esac
    COMPREPLY=( $(_get_longopts ${1} ${cur} ) )
}
complete  -o default -F _longopts configure bash
complete  -o default -F _longopts wget id info a2ps ls recode

_tar()
{
    local cur ext regex tar untar

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    # If we want an option, return the possible long options.
    case "$cur" in
        -*)     COMPREPLY=( $(_get_longopts $1 $cur ) ); return 0;;
    esac

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $( compgen -W 'c t x u r d A' -- $cur ) )
        return 0
    fi

    case "${COMP_WORDS[1]}" in
        ?(-)c*f)
            COMPREPLY=( $( compgen -f $cur ) )
            return 0
            ;;
            +([^Izjy])f)
            ext='tar'
            regex=$ext
            ;;
        *z*f)
            ext='tar.gz'
            regex='t\(ar\.\)\(gz\|Z\)'
            ;;
        *[Ijy]*f)
            ext='t?(ar.)bz?(2)'
            regex='t\(ar\.\)bz2\?'
            ;;
        *)
            COMPREPLY=( $( compgen -f $cur ) )
            return 0
            ;;

    esac

    if [[ "$COMP_LINE" == tar*.$ext' '* ]]; then
        # Complete on files in tar file.
        #
        # Get name of tar file from command line.
        tar=$( echo "$COMP_LINE" | \
               sed -e 's|^.* \([^ ]*'$regex'\) .*$|\1|' )
        # Devise how to untar and list it.
        untar=t${COMP_WORDS[1]//[^Izjyf]/}

        COMPREPLY=( $( compgen -W "$( echo $( tar $untar $tar \
                    2>/dev/null ) )" -- "$cur" ) )
        return 0

    else
        # File completion on relevant files.
        COMPREPLY=( $( compgen -G $cur\*.$ext ) )

    fi

    return 0

}

complete -F _tar -o default tar

_make()
{
    local mdef makef makef_dir="." makef_inc gcmd cur prev i;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in
        -*f)
            COMPREPLY=($(compgen -f $cur ));
            return 0
        ;;
    esac;
    case "$cur" in
        -*)
            COMPREPLY=($(_get_longopts $1 $cur ));
            return 0
        ;;
    esac;

    # make reads `GNUmakefile', then `makefile', then `Makefile'
    if [ -f ${makef_dir}/GNUmakefile ]; then
        makef=${makef_dir}/GNUmakefile
    elif [ -f ${makef_dir}/makefile ]; then
        makef=${makef_dir}/makefile
    elif [ -f ${makef_dir}/Makefile ]; then
        makef=${makef_dir}/Makefile
    else
        makef=${makef_dir}/*.mk        # Local convention.
    fi


    # Before we scan for targets, see if a Makefile name was
    # specified with -f ...
    for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
        if [[ ${COMP_WORDS[i]} == -f ]]; then
           # eval for tilde expansion
           eval makef=${COMP_WORDS[i+1]}
           break
        fi
    done
    [ ! -f $makef ] && return 0

    # deal with included Makefiles
    makef_inc=$( grep -E '^-?include' $makef | \
    sed -e "s,^.* ,"$makef_dir"/," )
    for file in $makef_inc; do
        [ -f $file ] && makef="$makef $file"
    done


    # If we have a partial word to complete, restrict completions to
    # matches of that word.
    if [ -n "$cur" ]; then gcmd='grep "^$cur"' ; else gcmd=cat ; fi

    COMPREPLY=( $( awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ \
                                {split($1,A,/ /);for(i in A)print A[i]}' \
                                $makef 2>/dev/null | eval $gcmd  ))

}

complete -F _make -X '+($*|*.[cho])' make gmake pmake

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
ARROW19="▪▶"
YINYANG="☯"
#
# -------------------------------------------------------------------------------
#                         AtomicParsley
# -------------------------------------------------------------------------------
# AtomicParsley options for mp4 art
export PIC_OPTIONS="MaxDimensions=500:DPI=72:MaxKBytes=150:AddBothPix=true:AllPixJPEG=true"
export PIC_OPTIONS="SquareUp:removeTempPix"
export PIC_OPTIONS="ForceHeight=999:ForceWidth=333:removeTempPix"
# -------------------------------------------------------------------------------
#                         PROMPTS
# -------------------------------------------------------------------------------
# Xterm title bar
case $TERM in
	xterm*|rxvt|Eterm|eterm|vt100)
		XTITLE='\[\033k\033\\\]\[\e]0;`echo $STY` [\u@\h] (\!) (\#) [\w] \@ \007\]';
		;;
	screen*)
		#XTITLE='\033_`echo $STY` (\!) (\#) [\u@\h] [\w] \@ \033\\'
		XTITLE='\033]0;`echo $STY` [\u@\h] (\!) (\#) [\w] \@ \007'
		
		;;
	*)
		XTITLE="";
	;;
esac

#
if [[ "$TERM" = "dumb" ]]; then
	# Stripped the colour codes for terminals without colour
	PS1="\033${XTITLE}[\!] (\#) \u@\h \W \$ "
	PS2="${XTITLE}[\!][PS2] (\#) \u@\h \W > "
fi
#
if [[ -f ~/.bash_prompt ]]; then
	. ~/.bash_prompt
else
	PS1='\u@\h \W \$ '
	PS2='\u@\h \W » '
	SUDO_PS1='SUDO - \u@\h \W \$ '
fi
#
# -------------------------------------------------------------------------------
#                        AUTOJUMP
# -------------------------------------------------------------------------------

#set $_Z_NO_PROMPT_COMMAND
source /usr/local/bin/z.sh
# -------------------------------------------------------------------------------
## http://jeetworks.org/node/52
gcd() {
    if [[ $(which git 2> /dev/null) ]]
    then
        STATUS=$(git status 2>/dev/null)
        if [[ -z $STATUS ]]
        then
            return
        fi
        TARGET="./$(git rev-parse --show-cdup)$1"
        #echo $TARGET
        cd $TARGET
    fi
}
_gcd()
{
    if [[ $(which git 2> /dev/null) ]]
    then
        STATUS=$(git status 2>/dev/null)
        if [[ -z $STATUS ]]
        then
            return
        fi
        TARGET="./$(git rev-parse --show-cdup)"
        if [[ -d $TARGET ]]
        then
            TARGET="$TARGET/"
        fi
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}$2"
        dirnames=$(cd $TARGET; compgen -o dirnames $2)
        opts=$(for i in $dirnames; do  if [[ $i != ".git" ]]; then echo $i/; fi; done)
        if [[ ${cur} == * ]] ; then
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
        fi
    fi
}
complete -o nospace -F _gcd gcd


# ----------------------------------------------------------------------------
#                          FINAL-CLOSING STUFF
# ----------------------------------------------------------------------------
# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs
# -------------------------------------------------------------------------------
#               END OF BASHRC - Robbie - dunolie (at) gmail (dot) com
# -------------------------------------------------------------------------------
