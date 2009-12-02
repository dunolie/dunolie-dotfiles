#!/bin/bash

#	GeektoolScripts
#	by Jake Teton-Landis <just.1.jake@gmail.com>

#	Network Use script
#		original by chris helming.
#		chris dot helming at gmail
#		modified by Jake Teton-Landis

#	ABOUT
# 	This is a collection of scripts that one may find useful
# 	when using Geektool or similar system information tools

#	USAGE
#	Run the script with no args for usage information in an
#	easy to read format

scriptUsage () {
	echo "
`basename $0` is a collection of helpful Geektool scripts
usage: `basename $0` function (args...)
"
echo "
[ Time functions ]
	timeOfDay!displays the hour and the minute, ex: 03:45
	AMorPM!displays AM or PM depending on time, ex: PM
	dayOfWeek!displays the day, ex: Teusday
	dayOfMonth!displays the date, ex: 21
	monthOfYear!displays the month, ex: January
[ Resource use functions ]
	CPUuse!displays CPU use as a percent
	RAMuse!displays active physical memory as a percent of total memory
	RAMdetail!displays all physical memory information provided by top
	hdSpace!displays free space and percent used of devices.
	!    You will need to customize the script, open it with a text editor
	!    and scroll down to the line that reads \"function hdSpace\"" | column -t -s "!"
echo "[ The Watchlist ]
The watchlist function provides an easy way to display the size on disk
of folders or files. It reads from ~/.geektoolWatchlist a list of
files and folders and displays thier size on disk"
echo \
"	watchlist!displays disk size of files on the watchlist
	watchlist edit!opens the watchlist for editing. Use instead of add or remove.
	watchlist view!displays the list of files to watch
	watchlist add <file>!adds an item to the watchlist
	watchlist remove <file>!removes an item from the watchlist
[ Other ]
	weather <zipcode>!displays the current conditions for that zipcode
	networkUse <interface>!displays network usage on <interface>, defaults to en0
	networkUse <interface> in!displays incoming data in KB/second
	networkUse <interface> out!displays outgoing data in KB/second
	"  | column -t -s "!"
	exit 1
}

if [ -z "$1" ]; then scriptUsage; fi #if run with no arguments, display usage info




#	TIME - pretty self explanatory
function timeOfDay { date '+%I:%M'; }
function AMorPM { date '+%p'; }
function dayOfWeek { date '+%A'; }
function dayOfMonth { date '+%d'; }
function monthOfYear { date '+%B'; }


#	RESOURCE USE

# 	top is the terminal equivelant of /Utilities/Activity Monitor.app
#	usually it loops, but you can set number of runs using -l NUMBER
#	sed is a stream editor that transforms streams of text. I just script-kiddie it and use google
#	awk is like sed, useful for rearranging text
#	grep finds things

function CPUuse {
	myCPUuse=`top -l 2 | grep "CPU usage:" | sed '$!d' | awk {'print $7'} | sed -e 's/%$//'`
		#backquotes are command substitution 
	myCPUuse=$(echo "scale=3; 100-$myCPUuse" | bc) #bash can't floating point so we pipe some calculations to bc
#                    ^^^^^^^ number of decimal places
	echo $myCPUuse
}

function RAMuse {
	memStats=`top -l 1 | grep "PhysMem"`	#get the PhysMem line of top
	let "memTotal = $(echo $memStats | awk '{print $8}' | sed -e 's/M$//') + $(echo $memStats | awk '{print $10}' | sed -e 's/M$//')"
	memActive=$(echo $memStats | awk '{print $4}' | sed -e 's/M$//')
	echo "scale=5; $memActive/$memTotal*100" | bc
	
}

function RAMdetail {
	memStats=`top -l 1 | grep "PhysMem"`
	echo $memStats | awk '{print $2 " " $3}' | sed -e 's/,$//'		# this bit of sed code removes trailing commas
	echo $memStats | awk '{print $4 " " $5}' | sed -e 's/,$//'
	echo $memStats | awk '{print $6 " " $7}' | sed -e 's/,$//'
	echo $memStats | awk '{print $8 " " $9}' | sed -e 's/,$//'
	echo $memStats | awk '{print $10 " " $11}' | sed -e 's/.$//'	# or periods, here
}

function RAMdetail2 {	#just an alternate way of doing the above, may be slightly faster
	memStats=`top -l 1 | grep "PhysMem"`
	echo $memStats | awk '{print $2 " " $3 "\n" $4 " " $5 "\n" $6 " " $7 "\n" $8 " " $9 "\n" $10 " " $11}' | sed -e 's/,$//'
}

networkUse () {
	# added by Jake: now takes network interface as an argument, because many computers have more than one
	if [ -z "$1" ] #if run with no arguments, default to en0
	then	
		interface="en0"
	else
		interface="$1"
	fi
	# get the current number of bytes in and bytes out
	myvar1=`netstat -ib | grep -e "$interface" -m 1 | awk '{print $7}'` #  bytes in
	myvar3=`netstat -ib | grep -e "$interface" -m 1 | awk '{print $10}'` # bytes out
	
	#wait one second
	sleep 1
	
	# get the number of bytes in and out one second later
	myvar2=`netstat -ib | grep -e "$interface" -m 1 | awk '{print $7}'` # bytes in again
	myvar4=`netstat -ib | grep -e "$interface" -m 1 | awk '{print $10}'` # bytes out again
	
	# find the difference between bytes in and out during that one second
	subin=$(($myvar2 - $myvar1))
	subout=$(($myvar4 - $myvar3))
	
	# convert bytes to kilobytes
	kbin=`echo "scale=2; $subin/1024;" | bc`
	kbout=`echo "scale=2; $subout/1024;" | bc`
	if [ -z "$2" ]; then echo "IN $kbin KB/s, OUT $kbout KB/s"
	else
		case "$2" in
		"in" ) 	echo "$kbin"	;;
		"out" )	echo "$kbout"	;;
		* )		echo "Unrecognized command."; scriptUsage ;;
		esac
	fi
}

#run df to show all your filesystems, then edit the script
function hdSpace {
	df -h | grep "/dev/disk0s2" | sed -e 's/Gi/GB/g' | awk {'print "SL: " $4 " free, " $5 " used"'}
#                 ^^^^^^^^^^^^ replace with your filesystem         ^^^ replace with your label
	df -h | grep "/dev/disk0s3" | sed -e 's/Gi/GB/g' | awk {'print "WD: " $4 " free, " $5 " used"'}
}

#	WATCHLIST
#	A watchlist of folders, using a file called ~/.geektoolWatchlist

watchlist () { #options: edit, add, remove.  Displays data when called without an arg
	if [ -z "$(cat ~/.geektoolWatchlist)" ]		#create ~/.geektoolWatchlist using home folder if not present
	then
		cd
		echo "$PWD" > ~/.geektoolWatchlist
#                   ^ this redirects the output to write a file
	fi
	
	watchList="$(cat ~/.geektoolWatchlist)"
	
	if [ -z "$1" ]                           # Is parameter #1 zero length?
 	then
 		echo "$watchList" |
 		while read myFile	#displays disk use information
 		do
 			echo `basename "$myFile"` $(du -hs "$myFile" | awk '{print $1}') | column -t #column -t makes nice columns, very usefull
 		done
 	else					#if not, it's a command and we parse it further
 		newWatchlist=""
 		case "$1" in		
#            ^^^^ argument 1
 			"edit" )
 				open -t ~/.geektoolWatchlist
 			;;
 			"add" )
 				newWatchlist="$(echo "$watchList"; echo -n "$2")"
 				echo "$2 added to the watchlist"
 				watchList=$newWatchlist
 			;;
 			"remove" )
 				watchList=`echo "$watchList" | sed -e "\|$2\$|d"`	# deletes anything that ends in entered
# 				watchList=`echo "$watchList" | sed -e "\|^$2\$|d"`	# deletes by line exactly
 			;;
 			"view" )
 				echo "$watchList"
 			;;
 			* )
 				echo "Unrecognized command."
 				scriptUsage
 				exit 1
  			;;
 		esac
 		echo -n "$watchList" > ~/.geektoolWatchlist
	fi
}

#	OTHER USEFUL SCRIPTS

#	weather
weather () {
	currentWeather="$(/opt/local/bin/lynx -dump http://printer.wunderground.com/cgi-bin/findweather/getForecast?query=$1 | awk '/Temp/ || /Wind/ || /Cond/ && !/Fore/ {printf $1 ": "; for (i=2; i<=10; i++) printf $i " " }' )"
	echo "$currentWeather"
}



#########################
#		RUN SCRIPT		#
#########################

"$1" "$2" "$3"
