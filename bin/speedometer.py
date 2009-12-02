#!/usr/bin/python

# speedometer.py
# Copyright (C) 2001-2006  Ian Ward
#
# This module is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This module is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

__version__ = "2.5"

import time
import sys
import os
import popen2
import string
import math
import re

__usage__ = """Usage: speedometer [options] tap [[-c] tap]...
Monitor network traffic or speed/progress of a file transfer.  At least one
tap must be entered.  -c starts a new column, otherwise taps are piled 
vertically.  

Taps:
  [-f] filename [size]        display download speed [with progress bar]
                              -f must be used if directly following another
			      file tap without an expected size specified
  -rx network-interface       display bytes received on network-interface
  -tx network-interface       display bytes transmitted on network-interface

Options:
  -i interval-in-seconds      eg. "5" or "0.25"   default: "1"
  -p                          use plain-text display (one tap only)
  -b                          use old blocky display instead of smoothed
                              display even when UTF-8 encoding is detected
  -z                          report zero size on files that don't exist
                              instead of waiting for them to be created
"""

__urwid_info__ = """
Speedometer requires Urwid 0.8.9 or later when not using plain-text display.
Version 0.9.1 or later is required for smoothed UTF-8 display.
Urwid may be downloaded from:  http://excess.org/urwid/
Urwid may be installed system-wide or in the same directory as speedometer.
"""

INITIAL_DELAY = 0.5 # seconds
INTERVAL_DELAY = 1.0 # seconds

try: True # old python?
except: False, True = 0, 1

LN_TO_LG_SCALE = 1.4426950408889634 # LN_TO_LG_SCALE * ln(x) == lg(x)

try:
	import urwid
	try:
		from urwid.raw_display import Screen
	except:
		from urwid.curses_display import Screen
	urwid.BarGraph
	URWID_IMPORTED = True
	URWID_UTF8 = False
	try:
		if urwid.get_encoding_mode() == "utf8":
			from urwid.raw_display import Screen
			URWID_UTF8 = True
	except: 
		pass
except:
	URWID_IMPORTED = False
	URWID_UTF8 = False
	

class Speedometer:
	def __init__(self,maxlog=5):
		"""speedometer(maxlog=5)
		maxlog is the number of readings that will be stored"""
		self.log = []
		self.start = None
		self.maxlog = maxlog
	
	def get_log(self):
		return self.log
	
	def update(self, bytes):
		"""update(bytes) => None
		add a byte reading to the log"""
		t = time.time()
		reading = (t,bytes)
		if not self.start: self.start = reading
		self.log.append(reading)
		self.log = self.log[ - (self.maxlog+1):]
		
	def delta(self, readings=0, skip=0):
		"""delta( readings=0 ) -> time passed, byte increase
		if readings is 0, time since start is given
		don't include the last 'skip' readings
		None is returned if not enough data available"""
		assert readings >= 0
		assert readings <= self.maxlog, "Log is not long enough to satisfy request"
		assert skip >= 0
		if skip > 0: assert readings > 0, "Can't skip when reading all"
		
		if skip > len(self.log)-1: return # not enough data
		current = self.log[-1 -skip]
		
		target = None
		if readings == 0: target = self.start
		elif len(self.log) > readings+skip: 
			target = self.log[-(readings+skip+1)]
		if not target: return  # not enough data
		
		if target == current: return
		byte_increase = current[1]-target[1]
		time_passed = current[0]-target[0]
		return time_passed, byte_increase
	
	def speed(self, *l, **d):
		d = self.delta( *l, **d )
		if d:	
			return delta_to_speed(d)


class EndOfData(Exception):
	pass

class MultiGraphDisplay:
	def __init__(self, cols, urwid_ui):
		if urwid_ui == "smoothed":
			smoothed = True
			self.palette = self.smoothed_palette
		else:
			smoothed = False
			self.palette = self.blocky_palette
		self.displays = []
		l = []
		for c in cols:
			a = []
			for tap in c:
				if tap.ftype == 'file_exp':
					d = GraphDisplayProgress(tap, smoothed)
				else:
					d = GraphDisplay(tap, smoothed)
				a.append(d)
				self.displays.append(d)
			l.append(a)
			
		graphs = urwid.Columns( [BoxPile(a) for a in l], 1 )
		graphs = urwid.AttrWrap( graphs, 'background' )
		title = urwid.Text("Speedometer "+__version__)
		title = urwid.AttrWrap( urwid.Filler( title ), 'title' )
		self.top = urwid.Overlay( title, graphs,
			('fixed left', 0), 16, ('fixed top', 0), 1 )

		self.urwid_ui = urwid_ui

	blocky_palette = [
		('background', 'dark gray', 'black'),
		('reading', 'light gray', 'black'),
		('1MB/s',   'dark cyan','light gray','standout'),
		('32KB/s',  'light gray', 'dark cyan','standout'),
		('1KB/s',   'dark blue','dark cyan','standout'),
		('32B/s',   'light cyan','dark blue','standout'),
		('bar:num', 'light gray', 'black' ),
		('ca:background', 'light gray','black'),
		('ca:c',    'yellow','black','standout'),
		('ca:a',    'dark gray','black','standout'),
		('ca:c:num','yellow','black','standout'),
		('ca:a:num','dark gray','black','standout'),
		('title',   'white', 'black','underline'),
		('pr:n',    'white', 'dark blue'),
		('pr:c',    'white', 'dark green','standout'),]
	
	smoothed_palette = [
		('background', 'dark gray', 'black'),
		('reading', 'light gray', 'black'),
		('bar:top', 'dark cyan', 'black' ),
		('bar',     'black', 'dark cyan','standout'),
		('bar:num', 'dark cyan', 'black' ),
		('ca:background', 'light gray','black'),
		('ca:c:top','dark blue','black'),
		('ca:c',    'black','dark blue','standout'),
		('ca:c:num','light blue','black'),
		('ca:a:top','light gray','black'),
		('ca:a',    'black','light gray','standout'),
		('ca:a:num','light gray', 'black'),
		('title',   'white', 'black','underline'),
		('pr:n',    'white', 'dark blue'),
		('pr:c',    'white', 'dark green','standout'),
		('pr:cn',   'dark green', 'dark blue'),
		]
		
		
	def main(self):
		self.ui = Screen()
		self.ui.set_input_timeouts( max_wait=INTERVAL_DELAY )
		
		self.ui.register_palette(self.palette)
		self.ui.run_wrapper( self.run )
	
	def run(self):
		try:
			self.update_readings()
		except EndOfData:
			return
		time.sleep(INITIAL_DELAY)
		resizing = False
		
		size = self.ui.get_cols_rows()
		while True:
			if not resizing:
				try:
					self.update_readings()
				except EndOfData:
					self.end_of_data()
					return
			resizing = False
			
			self.draw_screen(size)

			if isinstance(time,SimulatedTime):
				time.sleep( INTERVAL_DELAY )
				continue
				
			keys = self.ui.get_input()
			for k in keys:
				if k == "window resize":
					size = self.ui.get_cols_rows()
					resizing = True
				else:
					return
	
	def update_readings(self):
		for d in self.displays:
			d.update_readings()
	
	def end_of_data(self):
		# pause for taking screenshot of simulated data
		if isinstance(time, SimulatedTime):
			while not self.ui.get_input():
				pass

	def draw_screen(self, size):
		canvas = self.top.render( size, focus=True )
		self.ui.draw_screen( size, canvas )
	

class BoxPile: # like urwid.Columns, but with vertical separation of box widgets
	def __init__(self, widget_list):
		self.widget_list = widget_list
	
	def selectable(self):
		return False
	
	def render(self, (maxcol, maxrow), focus=False ):
		w = self.build_pile( self.widget_list,maxrow )
		return w.render((maxcol,maxrow))
		
	def build_pile(self, l, maxrow):
		if len(l) == 1:
			return l[0]
		rows = int( (float(maxrow)+0.5) / len(l) )
		if rows == 0:
			return self.build_pile( l[1:], maxrow-rows )
		return urwid.Frame( self.build_pile( l[1:], maxrow-rows ),
			header = urwid.BoxAdapter( l[0], rows ) )

class GraphDisplay:
	def __init__(self,tap, smoothed):
		if smoothed:
			self.speed_graph = SpeedGraph( 
				['background','bar'],
				['background','bar'],
				{(1,0):'bar:top'} )
			
			self.cagraph = urwid.BarGraph(
				['ca:background', 'ca:c', 'ca:a'],
				['ca:background', 'ca:c', 'ca:a'],
				{(1,0):'ca:c:top', (2,0):'ca:a:top', } )
		else:
			self.speed_graph = SpeedGraph([
				('background', ' '),
				('1MB/s', '%'),
				('32KB/s', '#'),
				('1KB/s', '+'),
				('32B/s', ':'), ]
			)
			
			self.cagraph = urwid.BarGraph([
				('ca:background', ' '),
				('ca:c','c'),
				('ca:a','A'),]
			)
		
		self.last_reading = urwid.Text("",align="right")
		scale = urwid.GraphVScale([
			(15,' 1MB\n  /s'),
			(10,'32KB\n  /s'),
			(5,' 1KB\n  /s')], 20)
		footer = self.last_reading
		graph_cols = urwid.Columns( [('fixed', 4, scale), 
			self.speed_graph, ('fixed', 4, self.cagraph)],
			dividechars = 1 )
		self.top = urwid.Frame(graph_cols, footer=footer )

		self.spd = Speedometer(6)
		self.feed = tap.feed
		self.description = tap.description()
	
	def selectable(self):
		return False
	
	def render(self, size, focus=False):
		return self.top.render(size,focus)
	
	def update_readings(self):
		f = self.feed()
		if f is None: raise EndOfData
		self.spd.update(f)
		s = self.spd.speed(1) # last sample
		c = curve(self.spd) # "curved" reading
		a = self.spd.speed() # running average
		self.speed_graph.append_log( s )
		
		self.last_reading.set_text([ 
			('title', [self.description, "  "]),
			('bar:num', [readable_speed(s), " "]),
			('ca:c:num',[readable_speed(c), " "]),
			('ca:a:num',readable_speed(a)) ] )
		
		self.cagraph.set_data([
			[speed_scale(c),0],
			[0,speed_scale(a)],
			], 20)
		
			

class GraphDisplayProgress(GraphDisplay):
	def __init__(self, tap, smoothed):
		GraphDisplay.__init__(self, tap, smoothed)
		
		self.spd = FileProgress( 6, tap.expected_size )
		if smoothed:
			self.pb = urwid.ProgressBar('pr:n','pr:c',0,
				tap.expected_size, 'pr:cn')
		else:
			self.pb = urwid.ProgressBar('pr:n','pr:c',0,
				tap.expected_size )
		self.est = urwid.Text("")
		pbest = urwid.Columns([self.pb,('fixed',10,self.est)], 1)
		newfoot = urwid.Pile( [self.top.footer, pbest] )
		self.top.footer = newfoot
		
	def update_readings(self):
		GraphDisplay.update_readings(self)

		self.pb.set_completion(self.spd.progress()[0])
		e = self.spd.completion_estimate()
		if e is None:
			return
		self.est.set_text(readable_time(e,10))

class SpeedGraph:
	def __init__(self, attlist, hatt=None, satt=None ):
		if satt is None:
			self.graph = urwid.BarGraph( attlist, hatt )
		else:
			self.graph = urwid.BarGraph( attlist, hatt, satt )
		# override BarGraph's get_data
		self.graph.get_data = self.get_data
		
		self.smoothed = satt is not None
		
		self.log = []
		self.bar = []
		
	def get_data(self, (maxcol,maxrow) ):
		bar = self.bar[ -maxcol:]
		if len(bar) < maxcol:
			bar = [[0]]*(maxcol-len(bar)) + bar
		return bar, 20, [15,10,5]
	
	def selectable(self):
		return False
	
	def render(self, (maxcol, maxrow), focus=False):
		
		left = max(0, len(self.log)-maxcol)
		pad = maxcol-(len(self.log)-left)
		
		topl = self.local_maximums(pad, left)
		yvals = [ max(self.bar[i]) for i in topl ]
		yvals = urwid.scale_bar_values(yvals, 20, maxrow)
		
		graphtop = self.graph
		for i,y in zip(topl, yvals):
			s = self.log[ i ]
			txt = urwid.Text( readable_speed( s ) )
			label = urwid.AttrWrap( urwid.Filler( txt ), 'reading')

			graphtop = urwid.Overlay( label, graphtop,
				('fixed left', pad+i-4-left), 9,
				('fixed top', max(0,y-2) ), 1 )
		
		return graphtop.render( (maxcol, maxrow), focus )

	def local_maximums(self, pad, left):
		"""
		Generate a list of indexes for the local maximums in self.log
		"""
		ldist, rdist = 4,5
		l = self.log
		if len(l) <= ldist+rdist: 
			return []
		
		dist = ldist+rdist
		highs = []
		
		for i in range(left+max(0, ldist-pad),len(l)-rdist+1):
			li = l[i]
			if li == 0: continue
			if i and l[i-1]>=li: continue
			if l[i+1]>li: continue
			highs.append( (li, -i) )
		
		highs.sort()
		highs.reverse()
		tag = [False]*len(l) 
		out = []
		
		for li, i in highs:
			i=-i
			if tag[i]: continue
			for k in range(max(0,i-dist), min(len(l),i+dist)):
				tag[k]=True
			out.append( i )

		return out
		
	def append_log(self, s):
		x = speed_scale(s)
		o = []
		if self.smoothed:
			o.append(x)
		else:
			prev = 20
			for segment in [15,10,5,0]:
				if x>segment:
					o.append( min(prev, x) )
				else:
					o.append(0)
				prev = segment
		self.bar = self.bar[-300:] + [o]
		self.log = self.log[-300:] + [s]


def speed_scale( s ):
	if s <= 0: return 0
	x = (math.log( s ) * LN_TO_LG_SCALE )
	x = min( 20, max( 0, x-5 ))
	return x


def delta_to_speed( delta ):
	"""delta_to_speed( delta ) -> speed in bytes per second"""
	time_passed, byte_increase = delta
	if time_passed <= 0: return 0
	if long(time_passed*1000) == 0: return 0
	
	return long(byte_increase*1000)/long(time_passed*1000)



def readable_speed( speed ):
	"""readable_speed( speed ) -> string
	speed is in bytes per second
	returns a readable version of the speed given"""
	
	if speed == None or speed < 0: speed = 0
	
	units = "B/s ", "KB/s", "MB/s", "GB/s", "TB/s"
	step = 1L
	
	for u in units:
	
		if step > 1:
			s = "%4.2f " %(float(speed)/step)
			if len(s) <= 5: return s + u
			s = "%4.1f " %(float(speed)/step)
			if len(s) <= 5: return s + u

		if speed/step < 1024:
			return "%4d " %(speed/step) + u
		
		step = step * 1024L
	
	return "%4d " % (speed/(step/1024)) + units[-1]
	


def graphic_speed( speed ):
	"""graphic_speed( speed ) -> string
	speed is bytes per second
	returns a graphic representing given speed"""
	
	if speed == None: speed = 0
	
	speed_val = [	0,    # KB/s
		2,	6,	13,	32,	76,	181,	431,	1024,
		2435,	5793,	13777,	32768,	77936,	185364,	440871,	1048576,
		2493948,	5931642,	14107901,	33554432 ]
	
	speed_gfx = [
		r"\                    ",
		r".\                   ",
		r"..\                  ",
		r"...\                 ",
		r"....\                ",
		r"....:\               ",
		r"....::\              ",
		r"....:::|             ",
		r"....::::|            ",
		r"....::::+|           ",
		r"....::::++|          ",
		r"....::::+++|         ",
		r"....::::++++|        ",
		r"....::::++++#|       ",
		r"....::::++++##/      ",
		r"....::::++++###/     ",
		r"....::::++++####/    ",
		r"....::::++++####%/   ",
		r"....::::++++####%%/  ",
		r"....::::++++####%%%/ ",
		r"....::::++++####%%%%/",
		]
		
	
	for i in range(len(speed_val)-1):
		low, high = speed_val[i], speed_val[i+1]
		if speed > high: continue
		if speed - low < high - speed:
			return speed_gfx[i]
		else:
			return speed_gfx[i+1]

	return speed_gfx[-1]



def file_size_feed(filename):
	"""file_size_feed(filename) -> function that returns given file's size"""
	def sizefn(filename=filename,os=os):
		try:
			return os.stat(filename)[6]
		except:
			return 0
	return sizefn

def network_feed(device,rxtx):
	"""network_feed(device,rxtx) -> function that returns given device stream speed
	rxtx is "RX" or "TX"
	"""
	assert rxtx in ["RX","TX"]
	r = re.compile( r"^\s*" + re.escape(device) + r":(.*)$", re.MULTILINE )
	
	def networkfn(devre=r,rxtx=rxtx):
		f = open('/proc/net/dev')
		dev_lines = f.read()
		f.close()
		match = devre.search(dev_lines)
		if not match:
			return None
		
		parts = match.group(1).split()
		if rxtx == 'RX':
			return long(parts[0])
		else:
			return long(parts[8])
		
	return networkfn
		
def simulated_feed( data ):
	total = 0
	adjusted_data = [0]
	for d in data:
		d = int(d)
		adjusted_data.append( d + total )
		total += d
		
	def simfn( data=adjusted_data ):
		if data: 
			return long(data.pop(0))
		return None
	return simfn

class SimulatedTime:
	def __init__(self, start):
		self.t = start
	def sleep(self, length):
		self.t += length
	def time(self):
		return self.t


class FileProgress:
	"""FileProgress monitors a file's size vs time and expected size to
	produce progress and estimated completion time readings"""
	
	samples_for_estimate = 4
	
	def __init__(self, maxlog, expected_size):
		"""FileProgress( expected_size )
		expected_size is the file's expected size in bytes"""
		
		self.expected_size = expected_size
		self.speedometer = Speedometer( maxlog )
		self.current_size = None
		self.speed = self.speedometer.speed
		self.delta = self.speedometer.delta

	def update(self, current_size ):
		"""update( current_size )
		current_size is the current file size
		update will record the current size and time"""
		
		self.current_size = current_size
		self.speedometer.update(self.current_size)
		
	def progress(self):
		"""progress() -> (current size, expected size)
		current size will be None until update is called"""

		return self.current_size, self.expected_size

	def completion_estimate(self):
		"""completion_estimate() -> estimated seconds remaining
		will return None if not enough data is available"""
		
		d = self.speedometer.delta( self.samples_for_estimate )
		if not d: return None  # not enough readings
		(seconds,bytes) = d
		if bytes <= 0: return None  # currently stalled
		remaining = self.expected_size - self.current_size		
		if remaining <= 0: return 0  # all done -- no time remaining
		
		seconds_left = float(remaining)*seconds/bytes

		return seconds_left
	
	def average_speed(self):
		"""average_speed() -> bytes per second since start
		will return None if not enough data"""
		return self.speedometer.speed()
	
	def current_speed(self):
		"""current_speed() -> latest bytes per second reading
		will return None if not enough data"""
		return self.speedometer.speed(1)

	

def graphic_progress( progress, columns ):
	"""graphic_progress( progress, columns ) -> string
	progress is a tuple of ( value, max )
	columns is length of string returned
	returns a graphic representation of value vs. max"""
	value, max = progress

	f = float(value) / float(max)
	if f > 1: f = 1
	if f < 0: f = 0

	filled = int(f*columns)
	gfx = "#" * filled + "-" * (columns-filled)

	return gfx


def time_as_units( seconds ):
	"""time_units( seconds ) -> list of (count, suffix) tuples
	returns a unit breakdown for the given number of seconds"""

	if seconds==None: seconds=0

	# ( multiplicative factor, suffix )
	units = (1,"s"), (60,"m"), (60,"h"), (24,"d"), (7,"w"), (52,"y")
	
	scale = 1L
	topunit = -1
	# find the top unit to use
	for mul, suf in units:
		if seconds / (scale*mul) < 1: break
		topunit = topunit+1
		scale = scale * mul
	
	# build the list reading backwards from top unit
	out = []
	for i in range(topunit, -1, -1):
		mul,suf = units[i]
		value = int( seconds/scale )
		seconds = seconds - value * scale
		scale = scale / mul
		out.append( (value, suf) )
		
	return out	
	
	
def readable_time( seconds, columns=None ):
	"""readable_time( seconds, columns=None ) -> string
	return the seconds as a readable string
	if specified, columns is the maximum length of the returned string"""

	out = ""
	for value, suf in time_as_units(seconds):
		new_out = out
		if out: new_out = new_out + ' '
		new_out = new_out + `value` + suf
		if columns and len(new_out) > columns: break
		out = new_out
	
	return out


class ArgumentError(Exception):
	pass


def console():
	"""Console mode"""
	try:
		cols, urwid_ui, zero_files = parse_args()
	except ArgumentError:
		sys.stderr.write(__usage__)
		if not URWID_IMPORTED:
			sys.stderr.write(__urwid_info__)
		sys.stderr.write("""
Python Version: %d.%d
Urwid >= 0.8.9 detected: %s  Urwid >= 0.9.1 and UTF-8 encoding detected: %s
""" % (sys.version_info[:2] + (["NO","yes"][URWID_IMPORTED],) +
		(["NO","yes"][URWID_UTF8],) ) )
		return
	
	if zero_files:
		for c in cols:
			a = []
			for tap in c:
				if hasattr(tap, 'report_zero'):
					tap.report_zero()
		
	try:
		# wait for every tap to be able to read
		wait_all(cols)
	except KeyboardInterrupt:
		return
			
	# plain-text mode
	if not urwid_ui:
		[[tap]] = cols
		
		if tap.ftype == 'file_exp':
			do_progress( tap.feed, tap.expected_size )
		else:
			do_simple( tap.feed )
		return
		
	do_display( cols, urwid_ui )


def do_display( cols, urwid_ui ):
	mg = MultiGraphDisplay( cols, urwid_ui )
	mg.main()


class FileTap:
	def __init__(self, name):
		self.ftype = 'file'
		self.file_name = name
		self.feed = file_size_feed( name )
		self.wait = True
	
	def set_expected_size(self, size):
		self.expected_size = long(size)
		self.ftype = 'file_exp'

	def report_zero(self):
		self.wait = False
		
	def description(self):
		return "FILE: "+ self.file_name
		
	def wait_creation( self):
		if not self.wait:
			return

		if not os.path.exists(self.file_name):
			sys.stdout.write("Waiting for '%s' to be created...\n" 
				% self.file_name)
			while not os.path.exists(self.file_name): 
				time.sleep(1)

class NetworkTap:
	def __init__(self, rxtx, interface):
		self.ftype = rxtx
		self.interface = interface
		self.feed = network_feed( interface, rxtx )
	
	def description(self):
		return self.ftype+": "+self.interface

	def wait_creation(self):
		if self.feed() is None:
			sys.stdout.write("Waiting for network statistics from "
				"interface '%s'...\n" % self.interface)
			while self.feed() == None: 
				time.sleep(1)



def parse_args():
	args = sys.argv[1:]
	tap = None
	if URWID_UTF8:
		urwid_ui = 'smoothed'
	else:
		urwid_ui = 'blocky'
	zero_files = False
	interval_set = False
	cols = []
	taps = []

	def push_tap(tap, taps):
		if tap is None: return
		taps.append( tap )
	
	i = 0
	while i < len(args):
		op = args[i]
		if op in ("-h","--help"):
			raise ArgumentError
		elif op in ("-i","-rx","-tx","-f"):
			# combine two part arguments with the following argument
			try:
				if op != "-f":
					args[i+1] = op + args[i+1]
			except IndexError:
				raise ArgumentError
			push_tap(tap, taps)
			tap = None
		elif op == "-s":
			# undocumented simulation option
			simargs = []
			i += 1
			while i < len(args) and args[i][:1] != "-":
				simargs.append( args[i] )
				i += 1
			tap.feed = simulated_feed( simargs )
			global time
			time = SimulatedTime( time.time() )
			continue
		elif op == "-p":
			# disable urwid ui
			urwid_ui = False
		elif op == "-b":
			urwid_ui = 'blocky'
		elif op == "-z":
			zero_files = True
		elif op[:2] == "-i":
			if interval_set: raise ArgumentError
			
			global INTERVAL_DELAY
			global INITIAL_DELAY
			try:
				INTERVAL_DELAY = float(op[2:])
			except:
				raise ArgumentError
				
			if INTERVAL_DELAY<INITIAL_DELAY:
				INITIAL_DELAY=INTERVAL_DELAY
			interval_set = True
			
		elif op[:3] == "-rx":
			push_tap(tap, taps)
			tap = NetworkTap("RX", op[3:])
		elif op[:3] == "-tx":
			push_tap(tap, taps)
			tap = NetworkTap("TX", op[3:])
		elif op == "-c":
			push_tap(tap, taps)
			if not taps:
				raise ArgumentError
			cols.append(taps)
			taps = []
			tap = None
		elif tap == None:
			tap = FileTap(op)
		elif tap and tap.ftype == 'file':
			try:
				tap.set_expected_size(op)
				push_tap(tap, taps)
				tap = None
			except:
				raise ArgumentError
		else:
			raise ArgumentError
		
		i += 1

	if urwid_ui and not URWID_IMPORTED:
		raise ArgumentError

	if not urwid_ui and (taps or cols):
		raise ArgumentError
			
	push_tap(tap, taps)
	if not taps:
		raise ArgumentError
	cols.append(taps)

	return cols, urwid_ui, zero_files
		

def do_simple( feed ):
	try:
		spd = Speedometer(6)
		f = feed()
		if f is None: return
		spd.update(f)
		time.sleep(INITIAL_DELAY)
		while 1:
			f = feed()
			if f is None: return
			spd.update(f)
			s = spd.speed(1) # last sample
			c = curve(spd) # "curved" reading
			a = spd.speed() # running average
			show(s,c,a)
			time.sleep(INTERVAL_DELAY)
	except KeyboardInterrupt:
		pass

def curve( spd ):
	"""Try to smooth speed fluctuations"""
	val = [ 2, 4, 4, 3, 2, 1 ] # speed sampling relative weights
	wtot = 0 # total weighting
	ws = 0.0 # weighted speed
	for i in range(len(val)):
		d = spd.delta(1,i)
		if d==None: 
			break # ran out of data
		t, b = d
		v = val[i]
		wtot += v
		ws += float(b)*v/t
	return delta_to_speed( (wtot, ws) )
	

def show( s, c, a, out = sys.stdout.write ):
	out( "[.]" + readable_speed(s) )
	out( " [c]" + readable_speed(c) )
	out( " [A]" + readable_speed(a) )
	out( " (" + graphic_speed(s)+")" )
	out('\n')	


def do_progress( feed, size ):
	try:
		fp = FileProgress( 4, long(size) )
		out = sys.stdout.write

		f = feed()
		if f is None: return
		fp.update(f)
		time.sleep(INITIAL_DELAY)
		while 1:
			f = feed()
			if f is None: return
			fp.update(f)
			out( '('+graphic_speed(fp.current_speed())+')' )
			out( readable_speed(fp.current_speed()) )
			out( ' ['+graphic_progress(fp.progress(), 36)+']' )
			out( '  '+readable_time(fp.completion_estimate()) )
			out( '\n' )
			current, expected = fp.progress()
			time.sleep(INTERVAL_DELAY)
	except KeyboardInterrupt:
		pass


def wait_all(cols):
	for c in cols:
		for tap in c:
			tap.wait_creation()

	
if __name__ == "__main__":
	console()
	
