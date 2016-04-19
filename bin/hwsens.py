#!/usr/bin/env python
# http://unflyingobject.com/files/iohwsensor.html
import commands

ioreg = commands.getoutput ('/usr/sbin/ioreg -n IOHWSensor')

k = re.findall ("\"location\" = \"(.*?)\"", ioreg)

v = re.findall ("\"current-value\" = (\d*)", ioreg)

   

aDict = dict (zip ([lower (el) for el in k], [int (el) >> 16 for el in v]))
