# =============================================================================
# .fff		A set of shell functions and aliases that create the fff / ffl
#		quick file-find commands, for bash/ksh as well as tcsh/csh.
#
#	Version	1.04						2004-12-22
#
# -----------------------------------------------------------------------------
#	WEB USERS PLEASE NOTE:
#
#		If you save this file, please do it as a Save-As operation, and
#		NOT a copy/paste.  This is to preserve embedded tab characters
#		in some of the SED expressions below, which may be converted
#		into blanks during copy/paste.
# -----------------------------------------------------------------------------
#
#	Description:
#
#		This script can give you two new shell commands, for bash, ksh,
#		tcsh and csh:
#
#	  	  fff *some*pattern* [ *some*pattern* .. ] [ -{find-options} ]
#	  	  ffl *some*pattern* [ *some*pattern* .. ] [ -{find-options} ]
#
#		Any file, directory or other object whose name matches
#		*some*pattern*, in the current directory or its subdirectories,
#		is displayed on a line of output, preceded by a path.  ffl
#		displays absolute paths, ffl relative paths.
#
#		Wildcards do NOT need to be quoted (this is my favourite feature :)
#
#		Matches are case-insensitive.  Multiple patterns can be specified, e.g.
#
#		  fff foo* *.txt *.c *.h
#
#		Options to find(1) can be appended after the pattern list, if
#		desired.  It is assumed that the first option beginning with
#		'-' is the start of the find(1) options.  For example, to find
#		all directories below this one with the word "net" in their
#		names, and show ls(1) information for each of them, enter:
#
#		  fff *net* -type d -ls
#
#	Setup:
#
#	    bash / ksh
#
#		Save this file to $HOME/.fff or another name of your preference.
#
#		Edit your .bashrc, .bash_profile or .kshrc to source the file
#		you created above:
#
#		  . $HOME/.fff
#
#		You will now have the fff and ffl commands described above,
#		as well as the rxp() function below, which can be invoked as
#		a command (which I sometimes find handy for composing regex
#		expressions on the fly.)
#
#	    tcsh / csh
#
#		In your .cshrc or .tcshrc, create the following aliases, exactly
#		as shown:
#
#       	  alias fff '( set noglob ; setenv fff_searchdir "`/bin/pwd`" ; func_fff.ksh \!* )'
#       	  alias ffl '( set noglob ; setenv fff_searchdir . ; func_fff.ksh \!* )'
#
#		Next, create an executable func_fff.ksh file, which contains
#		just the following two lines:
#
#		  #!/bin/ksh
#		  . $HOME/.fff && func_fff "$*"
#
#		func_fff() is a "hidden" helper function, defined in this file.
#
#	Remarks:
#
#		These commands are meant as quick, easy file-find tools for the
#		simplest and most common type of file/dir search.  If you
#		require a more complex or rigorous search, the original find(1)
#		command should be used.
#
#	Author:	perdenab at yahoo dot co dot uk
#               http://uk.geocities.com/perdenab
#		http://freshmeat.net/projects/fff_ffl
#
#	Change history:
#		1.02 -> 1.03					2004-12-22
#		  - rxp() now returns unchanged any input
#		    expression that appears to already be in
#		    regex format
#		  - Improved documentation
#		1.01 -> 1.02					2004-12-17
#		  - Assured that $fff_awk is properly set
#		    ($awk unset in 1.01, sorry)
#		1.00 -> 1.01					2004-12-15
#		  - Now accepts multiple search patterns
#		1.00    Initial release				2004-12-10
# =============================================================================

#
# assure suitable version of awk for cross-platform portability;
#   required due to broken solaris /usr/bin/awk
#
fff_awk=
for a in /usr/bin/nawk /bin/nawk /usr/bin/awk /bin/awk ; do
	if [ -x "$a" ] ; then
		fff_awk="$a"
		break
	fi
done
[ -z "$fff_awk" ] && fff_awk=awk

#
# rxp()		expand a line of text, with alpha chars expanded their
#		regexp equivalents
#
#	usage:  rxp your text here 123
#
#	expands to:	[Yy][Oo][Uu][Rr] [Tt][Ee][Xx][Tt] [Hh][Ee][Rr][Ee] 123
#
rxp() {
        echo " $@" | $fff_awk '
                {
                        for (i=2;i<=length($0);++i) {
				c=substr($0,i,1)
				if (c=="["||c=="]") {
					print substr($0,2,length($0)-1)
					next
				}
			}
                        for (i=2;i<=length($0);++i) {
                                c=substr($0,i,1)
                                if ((c>="a"&&c<="z")||(c>="A"&&c<="Z"))
                                        printf("[%c%c]",toupper(c),tolower(c))
                                else
                                        printf("%c",c)
                        }
                        print""
                }
                '
}

#
# func_fff()	"hidden" helper function called by the fff and ffl aliases below;
#		NOT meant to be run directly
#
#		set -f MUST be set before calling (set noglob in tcsh/csh),
#		to prevent prior expansion of wildcards (globbing); this is
#		done in the fff and ffl aliases below, which actually call
#		this function
#
#       	If a CTRL-C signal is entered during the run, globbing is
#		re-enabled for bash/ksh prior to exit.  This happens
#		automatically in tcsh/csh as long as the fff and ffl alias
#		definitions are enclosed in ( parentheses ), as shown in
#		the Setup section above.
#
func_fff () {
	# force -f if called by tcsh/csh
	set -f
        trap "set +f ; trap 2" 2
        # the bracketed whitespace below is [<blank><tab>]
        exp=`echo " $@" | sed 's/[ 	][ 	]*-.*$//'`
        opt=`echo " $@" | sed 's/^[^-]*[ 	][ 	]*-/-/'`
        case $opt in
        -*)     ;;
        *)      opt= ;;
        esac
	for e in $exp ; do
        	find "$fff_searchdir" -name `rxp $e` $opt
	done
        set +f
        trap 2
}

#
# fff, ffl	helper aliases for func_fff above; these are the actual commands
#
alias   fff='fff_searchdir="`/bin/pwd`" ; set -f ; func_fff'
alias   ffl='fff_searchdir=. ; set -f ; func_fff'

# =============================================================================
# END of .fff
# =============================================================================
