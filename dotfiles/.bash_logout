# clear
history -a $HISTFILE
echo -e " \033[1;32m Tip of the day to you :) shell-fu.org style! \033[0m"
echo -e "$(links -dump "http://www.shell-fu.org/lister.php?random" | grep -A 100 -- ----)"
echo -e   "    \033[1;37m.\033[1;30m~\033[1;37m.\033[0;0m     "
echo -en  "    \033[1;30m/\033[1;33mV\033[1;30m\\\\\033[0;0m     "
echo ""
echo -en  "   \033[1;30m//\033[1;37m&\033[1;30m\\\\\\\\\033[0;0m    "
echo ""
echo -e   "  \033[1;30m/(\033[1;37m(@)\033[1;30m)\\\\\033[0;0m   "
echo -e   "   \033[1;33m^\033[1;30m\`~'\033[1;33m^\033[0;0m    "
echo -e "Logged out @ \033[1;32m $(date +%H:%M), on $(date +%A), $(date +%d\ %B\,\ %G) \033[0m"
echo ""
echo -e "\033[1;32mTotal Logged in Time:\033[0;0m `expr $SECONDS / 3600` hours `expr $SECONDS / 60` mins `expr $SECONDS % 60` secs\n"