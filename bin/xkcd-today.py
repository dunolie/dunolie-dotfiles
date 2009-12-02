#!/usr/bin/env python
#"""Script to extract the most recent comic from the webcomic RSS feed"""
# http://joshh.co.uk/index.php/2009/07/02/update-on-xkcdrsspy/
import urllib, feedparser, sys

if len(sys.argv) > 1:
    target = sys.argv[1]
else:
    target = '/Pictures/xkcd/xkcd-today.png'

feed = feedparser.parse('http://xkcd.com/rss.xml')
latest = feed.entries[0]['summary']
imgpart = latest.split()[1]
imgname = imgpart[5:-1]

filename, headers = urllib.urlretrieve(imgname,
                        target)
