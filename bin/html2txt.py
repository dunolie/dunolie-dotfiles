# python
"""
Feed with a HTML string
Return the text
20020829	0.0.1	first version
"""

__author__ = "Francois Granger, <fgranger@altern.org>"
__date__ = "2002 09 30"
__version__ = "$Revision: 0.0.1 $"

import re
import sys, macfs
from mac import xstat

p = re.compile('(<p.*?>)|(<tr.*?>)', re.I)
t = re.compile('<td.*?>', re.I)
comm = re.compile('<!--.*?-->', re.M)
tags = re.compile('<.*?>', re.M)

def html2txt(s, hint = 'entity', code = 'ISO-8859-1'):
	"""Convert the html to raw txt
	- suppress all return
	- <p>, <tr> to return
	- <td> to tab
	Need the foolwing regex:
	p = re.compile('(<p.*?>)|(<tr.*?>)', re.I)
	t = re.compile('<td.*?>', re.I)
	comm = re.compile('<!--.*?-->', re.M)
	tags = re.compile('<.*?>', re.M)
	version 0.0.1 20020930
	"""
	s = s.replace('\n', '') # remove returns time this compare to split filter join
	s = p.sub('\n', s) # replace p and tr by \n
	s = t.sub('\t', s) # replace td by \t
	s = comm.sub('', s) # remove comments
	s = tags.sub('', s)	# remove all remaining tags
	s = re.sub(' +', ' ', s) # remove running spaces this remove the \n and \t
	# handling of entities
	result = s
	pass
	return result

def main1(files):
	s = """azer  tyuiop<p>q sd<tr>fg  hj<P>wxc<TR>vb   n<>p<td>"""
	txt = html2txt(s)
	pass

def main(files):
	for one in files:
		html = file(one).read()
		txt = html2txt(html)
		fp = file(one +'txt', 'w')
		fp.write(txt)
		fp.close()
		pass

if __name__ == '__main__':
	if len(sys.argv) > 1:
		files = sys.argv[1:]	# all but first wich is script file name
	else:
		files = []
		fs, flag = macfs.PromptGetFile('Choose a file to convert')
		if flag:
			files.append(fs.as_pathname())
		else:
			sys.exit(0)
	main(files)
	pass
