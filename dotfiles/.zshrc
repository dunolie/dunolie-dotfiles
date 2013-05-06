# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#  dpoggi  gianu  pygmalion  crunch
ZSH_THEME="dunolie"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git brew textmate osx vim rails ruby)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
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
#                         AtomicParsley
# -------------------------------------------------------------------------------
# AtomicParsley options for mp4 art
export PIC_OPTIONS="MaxDimensions=500:DPI=72:MaxKBytes=150:AddBothPix=true:AllPixJPEG=true"
export PIC_OPTIONS="SquareUp:removeTempPix"
export PIC_OPTIONS="ForceHeight=999:ForceWidth=333:removeTempPix"
# -------------------------------------------------------------------------------

#set $_Z_NO_PROMPT_COMMAND
source /usr/local/bin/z.sh
# -------------------------------------------------------------------------------
#git settings
# http://defunkt.io/hub/
if [[ -f /usr/local/bin/hub ]]; then
	alias git='/usr/local/bin/hub'
fi
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
#
# my manual (man pages) paths
export MANPATH=/usr/local/share/man:$MANPATH
export MANPATH=/opt/X11/share/man:/usr/local/man:/usr/share/man:$MANPATH
export MANPATH=/Developer/usr/share/man:/Developer/usr/X11/man:/usr/X11/man:~/Sync/Bash/man
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
