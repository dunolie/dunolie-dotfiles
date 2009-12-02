#!/bin/bash
#
# Simple Rip Using
#   HandbrakeCLI
#
#
# Set Location of Source File 
input='/dev/dvd'
# Set Title Track to encode
title='1'
# Set Video encoder [x264, ffmpeg, xvid, theora]
videoencoder='x264'
# Set x264 options
x264opts='level=40:ref=2:mixed-refs:bframes=3:weightb:subme=9:direct=auto:b-pyramid:me=umh:analyse=all:no-fast-pskip:filter=-2,-1'
# Set Framerate [5, 10, 12, 15, 23.976, 24, 25, 29.97]
vrate='23.97'
# Set Bitrate
bitrate='1500'
# Set Audio Tracks to encode [1,2,3]
audio='0'
# Set Audio Name ["Main Audio","Downmixed Audio","Director's Commentary"]
aname='"Main Audio English"'
# Set Audio encoder [faac, lame, vorbis, ac3]
audioencoder='faac'
# Set Audio Samplerrate [auto, 22.05, 24, 32, 44.1, 48]
arate='auto'
# Set Audio Bitrate [auto, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384]
audiobitrate='auto'
# Set Formate for Surround Sound [auto, mono, stereo, dp11, dp12, 6ch]
mixdown='auto'
# File ext Format [mkv, mp4, avi, ogm]
format='mkv'
# Set Save Location
output='/mnt/rip/dvdrip/yourfile'
# Set File Size - Bitrate Can Control Size
size='1500'

sleep 2
echo " ...Starting HandBrakeCLI Rip... "
sleep 1
#
HandBrakeCLI -i $input -o $output.$format \
          -t $title \
          -e $videoencoder \
          -x $x264opts \
          -r $vrate \
          -b $bitate \
          -a $audio \
          -A $aname \
          -E $audioencoder \
          -R $arate \
          -B $audiobitrate \
          -6 $mixdown \
          -f $format \
          -2 -T\
          -S $size 

echo " ...Done... "
