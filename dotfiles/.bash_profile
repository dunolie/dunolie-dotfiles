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
export NC='\e[0m' # No Color
export GREEN='\e[0;32m'
export RED='\e[0;31m'

export L_GRAY='\e[0;37m'
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
else
	echo -e "There is ${RED}no ~/.bashrc !!${NC}"
	echo -e "You can grab one here."
	echo -e "${GREEN}http://github.com/dunolie/dunolie-dotfiles${NC}"
	echo -e "If you have ${GREEN}git${NC} installed, run..."
	echo -e "${GREEN}git clone git://github.com/dunolie/dunolie-dotfiles.git${NC}"
	echo -e "Then copy the enclosed ${GREEN}.bashrc${NC} file to your ${GREEN}~/ dir${NC}"
fi