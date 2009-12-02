#!/bin/bash
#Sum the number of bytes in a directory listing

TBytes = ^ls -l | awk 'BEGIN {sum=0} /^-/ {sum+=$5} END {print sum}'#
for Bytes in $(ls -l | grep "^-" | awk '{ print $5 }')
do
    let TBytes=$TBytes+$Bytes
done
TotalMeg=$(echo -e "scale=3 \n$TBytes/1048576 \nquit" | bc)
echo -n "$TotalMeg"