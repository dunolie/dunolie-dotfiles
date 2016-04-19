#!/bin/sh

dir=$HOME/xkcd

mkdir $dir
latest=$(wget -O- http://xkcd.com/|grep -Eo 'http://xkcd.com/[0-9]+/'|grep -Eo '[0-9]+')
cached=$(ls -r $dir|head -n 1|grep -Eo '^[0-9]+')

for i in $(seq $cached $latest)
do
  page=$(wget -O- http://xkcd.com/$i/)
  img=$(echo $page|grep -Eo 'http://imgs.xkcd.com/comics/[^<"]+'|head -n 1)
  title=$(echo $page|grep -Eo ' title="[^"]+" alt='|sed -E 's/.*"([^"]+)".*/\1/')
  mkdir "$dir/$(printf '%04d' $i) - $title"
  wget -NP "$dir/$(printf '%04d' $i) - $title" $img
done