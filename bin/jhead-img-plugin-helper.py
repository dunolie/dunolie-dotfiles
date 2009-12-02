# http://the.taoofmac.com/space/CLI/jhead
# can be used as a plugin for the built-in Image Capture app.
from time import gmtime, strftime, localtime
import sys, os, re

pattern = re.compile(".+\.(jpg|mov|avi|mp4)$", re.IGNORECASE)
paths = []

def rename(f,p,c,e,alt=''):
  n = "%s/%s%s.%s" % (p,c,alt,e.lower())
  if f == n:
    print f
    return
  if os.path.exists(n):
    if alt is '':
      alt='a'
    else:
      alt=chr(ord(alt)+1)
    rename(f,p,c,e,alt)
  else:
    os.rename(f,n)
    print n

for f in sys.stdin:
  f = f.strip()
  matches = pattern.match(f)
  if matches:
    e = matches.group(1).lower()
    p = os.path.dirname(f)
    if p not in paths:
      paths.append(p)
    c = strftime("%Y%m%d%H%M%S",localtime(os.path.getmtime(f)))
    rename(f,p,c,e)
    

for p in paths:
  os.chdir(p)
  os.system('jhead -exonly -nf%Y%m%d%H%M%S *.jpg')
