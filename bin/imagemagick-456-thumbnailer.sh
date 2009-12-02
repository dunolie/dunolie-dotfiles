#!/bin/bash
echo "thumbnailer.sh - thumbnail for blog using ImageMagick's convert"
echo "Copyright (c) mypapit 2008. Website: http://blog.mypapit.net "
echo "This Free Software is licensed under the terms of WTFPL"
echo ""
if (($# ==0))
then
	echo "Usage: convert [graphic files] ..."
	exit
fi


while (($# !=0 ))
do
	echo "converting $1 ..."
	#scale the image, width*height, we are only interested
	#in standard blog size image which is 450-462 pixel width
	convert -scale 456 $1 tn-$1
	shift
done

