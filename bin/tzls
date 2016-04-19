#!/bin/sh
# =============================================================================
# tzls		List contents of a compressed unix-compatible file archive
# tzx		Unpack a compressed unix-compatible file archive
#
#		These utilities unpack and list only.  They DO NOT create
#		archives.  We do not want to make such a potentially damaging
#		activity too easy (yet :)
#
#	Version 1.05						2006-02-11
#
#	Usage:
#		tzls [ -v ] [ -y ] filename[.{tar|tar.Z|tar.gz|bz2|taz|tgz|zip|cpio|..}]
#		tzx  [ -v ] [ -y ] filename[.{tar|tar.Z|tar.gz|bz2|taz|tgz|zip|cpio|..}]
#
#	    Options:
#
#		-v	verbose output
#
#		The file type is checked before any action is taken, regardless
#		of the filename extension.
#
#		For safety reasons (and as with tar) only a single input file at a time
#		can be specified.
#
#		Non-compressed archives are also accepted.
#
#	Description:
#		As above.  For the simplest cases only.  For complex unpacks,
#		use commands specific to the archive, with the necessary options.
#
#		The commands listed above should be hard links to each other.
#
#	Primary Application:
#		Quick and EZ content-listing or unpacking of the most common
#		types of unix-compatible file archives, using existing unix
#		unix utilites within a unified wrapper.
#
#		Supported compression types (external to archive program):
#		  - compress	.Z
#		  - gnu zip	.gz
#		  - bzip2	.bz2
#		  - zip		.zip
#
#		Supported archive types:
#		  - tar		.tar
#		  - cpio	.cpio
#		  - zip		.zip
#		  - rar		.rar
#		  - arj		.arj
#
#		File types are auto-detected based on content.  If content type
#		is unknown, then an attempt is made to unpack based on the filename
#		extension.
#
#	Error and Alert Notification:
#		STDERR only.
#
#	Logging and Log Maintenance:
#		N/A
#
#	Files:
#		A single compressed (or non compressed) file archive as above.
#
#	Year 2000 Compliance
#		N/A
#
#	Remarks:
#		None.
#
#	Suggested enhancements:
#		- Add more file and compression formats as they appear
#		- Add a GUI?  Maybe... though it should then include archive
#		  creation as well as unpack.  In that case, I suggest Linzip.
#
#	Change History:
#		1.05	- Better detection of ZIP archives
#			- Fixed unzip options
#		1.04	- ARJ and RAR format now supported, if the required
#			  binaries exist on the system
#			- required archive and compression binaries now checked for
#			- filename extension check re-added, due to older file(1)
#			  commands reporting "data" for certain archive types
#			- file(1) on some systems cannot read from stdin; this
#			  is now handled
#			- bunzip2(1) on some systems requires a filename after -c,
#			  so -c is removed
#		1.03	- Some code cleanup
#			- removed some unused functionality
#		1.02	- Added support for cpio
#			- rewrote autodetect code
#			- removed filename extension checking
#		1.01	- Improved case patterns in autodetect code
#		1.00	- Initial working release
#
#	Author:
#		perdenab at yahoo dot co dot uk			2004-07-31
#		http://uk.geocities.com/perdenab
#		http://freshmeat.net/projects/tzls_tzx
#
#	Project ID:
#		N/A
# =============================================================================

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# GLOBAL CONSTANTS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

prog=`basename $0`

# possible awk programs to choose from
awkprogs="
	/usr/bin/nawk
	/bin/nawk
	/usr/bin/awk
	/bin/awk
	/usr/ucb/awk
	/usr/xpg4/bin/awk
	/usr/local/bin/gawk
"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# FUNCTIONS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#
# die()         Display the message in "$1" to stderr, then quit.
#
die () {
        echo "$prog: FATAL: $1" 1>&2
        exit 1
}

#
# warn()        Display the message in "$1" to stderr.
#
warn () {
        echo "$prog: WARNING: $1" 1>&2
}

#
# usage()	Display the top comment block for this script, to serve
#		as on-line documentation.
#
usage () {
	awk '{if(NR>1)print;if(NF==0)exit(0)}' < "$0" | sed '
		s|^#[ 	]||
		s|^#$||
	' | ${PAGER-more}
	exit 1
}

#
# vecho()	Echo $@ to stderr, but only if $verbose is set
#
vecho () {
	[ -z "$verbose" ] || echo "$@" 1>&2
}

#
# getawk()	Figure out which version of AWK to use.
#
#		We check for NAWK on suns due to broken default solaris awk, feh
#
getawk () {
	awkprog=
	for a in $awkprogs ; do
		if [ -x "$a" ] ; then
			awkprog="$a"
			break
		fi
	done
	[ -z "$awkprog" ] && die "SANITY: no suitable AWK programs found on this system!"
	echo "$awkprog"
}

#
# getfbin()	Figure out which version of find(1) to use.
#
#		Some versions of file(1) cannot read from a pipe.  If that's true on
#		this system, we use our internal version tzfile() instead.
#
getfbin () {
	res=`echo foo | file - 2>&1`
	case $res in
	*cannot*open*)
		fbin=tzfile
		;;
	*)	fbin=file
		;;
	esac
	echo $fbin
}

#
# tzfile()	Internal version of file(1), for use on systems where file(1) cannot
#		read from a pipe
#
tzfile () {
	[ -z "$1" ] && die "INTERNAL ERROR: no filename passed to tzfile()"
	[ -z "$2" ] || die "INTERNAL ERROR: too many args passed to tzfile()"
	tmp="/tmp/.$prog.tzfile.$$"
	file="$1"
	case $file in
	-)	cat > "$tmp" || die "$tmp: cannot append"
		file "$tmp"
		rm -f "$tmp"
		;;
	*)	file "$file"
		;;
	esac
}

#
# gencmd()	Determine the data archive type, if any, of the archive file,
#		then echo back the full command that will run.
#
gencmd () {
	[ -z "$1" ] && die "INTERNAL ERROR: no filename passed to gencmd()"
	file="$1"
	ucmd=`genucmd "$file"`
	#
	# get the data archive type, uncompressing first if necessary
	#
	case "$ucmd" in
	cat)	type=`$fbin "$file" | $awk -F'[,:]' '{print substr($2,2,length($2)-1)}' | sed 's| |-|g'`
		;;
	*)	type=`$ucmd < "$file" | $fbin - | $awk -F'[,:]' '{print substr($2,2,length($2)-1)}' | sed 's| |-|g'`
		;;
	esac
	#
	# based on the data archive type, determine the command that will run
	#
	cmd=`gendcmd $type $file | sed "s|^ucmd |$ucmd |"`
	echo "exec $cmd"
}

#
# genucmd()	Determine the compression type, if any, of the archive file,
#		then echo back the correct uncompression command, or cat if none
#
genucmd () {
	[ -z "$1" ] && die "INTERNAL ERROR: no filename passed to genucmd()"
	type=`file "$1" | $awk -F'[,:]' '{print substr($2,2,length($2)-1)}'`
	case $type in
	*bzip2*data*)
		ucmd="`tzwhich bunzip2`"
		;;
	*gzip*data*)
		ucmd="`tzwhich gunzip` -c"
		;;
	*compress*data*)
		ucmd="`tzwhich uncompress` -c"
		;;
	*)      ucmd="`tzwhich cat`"
		;;
	esac
	echo "$ucmd"
}

#
# gendcmd()	Based on the compression type ($1) and the filename ($2), determine
#		and echo back the correct unarchive command
#
gendcmd () {
	[ -z "$1" ] && die "INTERNAL ERROR: no compression type passed to gendcmd()"
	[ -z "$2" ] && die "INTERNAL ERROR: no filename passed to gendcmd()"
	[ -z "$3" ] || die "INTERNAL ERROR: too many args passed to gendcmd(): $1 $2 $3 $4 ..."
	type="$1"
	file="$2"
	case $type in
	*tar-archive*)
        	dcmd=`tzwhich tar`
		case $prog in
		*x)	cmd="ucmd < $file | $dcmd xf$verbose -"
			;;
		*ls)	cmd="ucmd < $file | $dcmd tf -"
			;;
		*)	die "SANITY: unknown script name in getdtype()"
			;;
		esac
		;;
	*cpio*)
        	dcmd=`tzwhich cpio`
		case $prog in
		*x)	cmd="ucmd < $file | $dcmd -id$verbose"
			;;
		*ls)	cmd="ucmd < $file | $dcmd -t$verbose"
			;;
		*)	die "SANITY: unknown script name in getdtype()"
			;;
		esac
		;;
	*[Zz][Ii][Pp]-archive*)
		dcmd=`tzwhich unzip`
		case $prog in
		*x)	cmd="$dcmd $file"
			;;
		*ls)	cmd="$dcmd -l$verbose $file"
			;;
		*)	die "SANITY: unknown script name in getdtype()"
			;;
		esac
		;;
	*[Aa][Rr][Jj]-archive*)
		dcmd=`tzwhich arj`
		case $verbose in
		"")	arjl="l"
			;;
		*)	arjl="v"
			;;
		esac
		case $prog in
		*x)	cmd="$dcmd e $file"
			;;
		*ls)	cmd="$dcmd $arjl $file"
			;;
		*)	die "SANITY: unknown script name in getdtype()"
			;;
		esac
		;;
	*[Rr][Aa][Rr]-archive*)
		dcmd=`tzwhich unrar`
		case $prog in
		*x)	cmd="$dcmd -x $file"
			;;
		*ls)	cmd="$dcmd -t $file"
			;;
		*)	die "SANITY: unknown script name in getdtype()"
			;;
		esac
		;;
	*)	case $file in
		*.[Rr][Aa][Rr])
			cmd=`gendcmd "RAR-archive" $file`
			;;
		*.[Aa][Rr][Jj])
			cmd=`gendcmd "ARJ-archive" $file`
			;;
		*)	die "cannot determine archive type: filetype is '$type'"
			;;
		esac
		;;
	esac
	echo "$cmd"
}

#
# tzwhich()	Internal version of which(), used for finding whether $1 is in
#		the user's path and executable
#
tzwhich () {
	[ -z "$1" ] && die "INTERNAL ERROR: tzwhich() called with no arguments"
	[ -z "$2" ] || die "INTERNAL ERROR: tzwhich() called with multiple arguments"
	prog="$1"
	pprog=`(
	IFS=":"
	for p in $PATH ; do
		fp="$p/$prog"
		if [ -f "$fp" -a -x "$fp" ] ; then
			echo "$fp"
			exit 0
		fi
	done
	)`
	[ -z "$pprog" ] && ( ( die "no $prog program found in user's PATH" ) ; kill -6 $$ )
	echo "$pprog"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# SIGNAL HANDLING
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

trap 'echo "Dying on signal[1]: Hangup" ; exit 1' 1
trap 'echo "Dying on signal[2]: Interrupt" ; exit 2' 2
trap 'echo "Dying on signal[3]: Quit" ; exit 3' 3
trap 'echo "Dying on signal[4]: Illegal Instruction" ; exit 4' 4
trap 'echo "Dying on signal[6]: Abort" ; exit 6' 6
trap 'echo "Dying on signal[8]: Arithmetic Exception" ; exit 8' 8
trap 'echo "Dying on signal[9]: Killed" ; exit 9' 9
trap 'echo "Dying on signal[10]: Bus Error" ; exit 10' 10
# trap 'echo "Dying on signal[11]: Segmentation Fault" ; exit 11' 11
trap 'echo "Dying on signal[12]: Bad System Call" ; exit 12' 12
trap 'echo "Dying on signal[13]: Broken Pipe" ; exit 13' 13
trap 'echo "Dying on signal[15]: Dying on signal" ; exit 15' 15
trap 'echo "Dying on signal[30]: CPU time limit exceeded" ; exit 30' 30
trap 'echo "Dying on signal[31]: File size limit exceeded" ; exit 31' 31

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARG AND SANITY CHECKS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

awk=`getawk`
fbin=`getfbin`

verbose=
verzip=q
yes=
while getopts vy c ; do
	case $c in
	v)	verbose=v
                verzip=
		;;
	y)	yes=true
		;;
	*)	usage
		;;
	esac
done
shift `expr $OPTIND - 1`
case $# in
1)	file="$1" ;;
*)	usage ;;
esac

case $file in
-)	die "sorry, no reading from pipes yet" ;;
*)	[ -f "$file" -a -r "$file" ] || die "$file: missing, unreadable or not a plain file" ;;	
esac

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# MAIN SECTION -- now just uncompress to a pipe and unpack
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#
# get the correct command sequence for this compression/archive type, then run it
#
cmd=`gencmd "$file"`
vecho "+ $cmd" 1>&2
echo "$cmd" | exec sh

# =============================================================================
# END of tzls
# =============================================================================
