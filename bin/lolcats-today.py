#!/usr/bin/env python
"""Script to extract the most recent comic from the webcomic RSS feed"""

import urllib, feedparser, sys

if len(sys.argv) > 1:
    target = sys.argv[1]
else:
    target = '/Pictures/lolcats/lolcats-today.png'

feed = feedparser.parse('http://feeds.feedburner.com/ICanHasCheezburger?format=xml')
latest = feed.entries[0]['summary']
imgpart = latest.split()[1]
imgname = imgpart[5:-1]

filename, headers = urllib.urlretrieve(imgname,
                        target)