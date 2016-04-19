#! /usr/bin/env python
#-------------------------------#
#		Created by Cam1337
#www.github.com/Cam1337/PyControl
#		  Python 2.6.4
#-------------------------------#
#Last edited [Today is 5/21/10. It is now 11:23 PM]
from commands import getoutput as rCMD
from time import asctime as atime
import sys
import urllib2
import re
import os

osabbr={"darwin":"Mac OSX",
		"linux2":"Linux",
		"win23":"Windows"}

class Lyrics:
	def __init__(self):
		self.HasRun=False
		self.OS=sys.platform
		self.CheckOS()
	def CheckOS(self):
		if self.OS == "darwin":
			self.TextPath="%s/.control/Lyrics"%os.path.expanduser("~")
			self.CheckForDir()
			self.CurrentTrack=self.CurrentItunes("Track")
			self.CurrentArtist=self.CurrentItunes("Artist")
			self.ParseArgs()
		else:
			print "I am sorry, I do not support %s yet."%self.OS
			sys.exit()
	def ParseArgs(self):
		self.args=sys.argv
		self.ArgsLen=len(self.args)
		try:
			if self.args[1]=="-i" and len(self.args)==2:self.GetLyrics("i")
			elif self.args[1]=="-s":self.GetLyrics("s")
			elif self.args[1]=="-v":self.ProgramInfo("v")
			elif self.args[1]=="-c":self.ProgramInfo("change")
		except IndexError:
			self.showHelp()	
	def ProgramInfo(self, x):
		if x=="v":
			print "Version 0.0.2"
		if x=="change":
			print self.TimeStamp()
	def GetLyrics(self, l_type):
		if l_type=="i":
			print self.Attempt_1(self.CurrentArtist, self.CurrentTrack)
		if l_type=="s":
			print "Please enter an artist and song"
			print self.Attempt_1(raw_input("Artist: "), raw_input("Song: "))	
	def Attempt_1(self, artist, song):
		self.LyricFile=("%s/%s _ %s.txt"%(self.TextPath,song,artist)).replace(" ","").replace(",","")
		try:
			print "Checking cache folder for lyrics"
			print self.OpenLyricFile()
			if self.OpenLyricFile()!="The file %s does not exist."%self.LyricFile:
				print "I found the cache file!"
				sys.exit()
			else:
				print "I couldn't find the cache file, I will try and get it form the internet"
				x=self.ComposeURL("1",artist,song)
				print "Trying once with %s"%x
				Page = self.OpenURL(x)
				Lyrics= self.ParseHTML("1",Page)
				if Lyrics=="error_page":
					return self.Attempt_2(artist, song)
				else:
					self.WriteToLyricFile(Lyrics)
					self.OpenLyricFile()
					return "First Try!"
		except (urllib2.HTTPError, IndexError), e:
			return self.Attempt_2(artist, song)		
	def Attempt_2(self, artist, song):
		try:
			x=self.ComposeURL("2",artist,song)
			print "Trying again with %s"%x
			Page = self.OpenURL(x)
			Lyrics= self.ParseHTML("2",Page)
			self.WriteToLyricFile(Lyrics)
			self.OpenLyricFile()
			return "I got the song on the second try!"
		except (urllib2.HTTPError, IndexError), e:
			return self.Attempt_3(artist, song)
	def Attempt_3(self, artist, song):
		try:
			x=self.ComposeURL("3",artist,song)
			print "Trying again with %s"%x
			Page = self.OpenURL(x)
			Lyrics= self.ParseHTML("3",Page)
			if Lyrics=="error_page":
				return "I have failed"
			else:
				self.WriteToLyricFile(Lyrics)
				self.OpenLyricFile()
				return "Third Try!"
		except (urllib2.HTTPError, IndexError), e:
			return "I have failed"
	def OpenURL(self, x):
		return (urllib2.urlopen(x)).read()
	def WriteToLyricFile(self, x):
		try:
			if self.OS=="darwin":
				open(self.LyricFile,"w")
			else:
				print self.OS_Error()
			print "I created %s"%self.LyricFile
			self.LyricText=open(self.LyricFile,"w")
			self.LyricText.write(x)
			self.LyricText.close()
		except IOError, e:
			print e
	def OpenLyricFile(self):
		if self.OS=="darwin":
			x=rCMD("open %s"%(self.LyricFile))
			return x
		else:
			return self.OS_Error()
	def ComposeURL(self, Attempt, artist, song):
		artist=self.CS(artist,"all")
		song=self.CS(song,"all")
		z=(song, artist)
		if Attempt=="1":	
			return ("http://www.lyrics.com/%s-lyrics-%s.html"%z).lower()
		if Attempt=="2":
			return ("http://www.azlyrics.com/lyrics/%s/%s.html"%(artist.replace("-"," "),song.replace("-",""))).lower()	
		if Attempt=="3":
			APIKey="9409c5a1f7bf7ecfd-temporary.API.access"
			return ("http://api.lyricsfly.com/api/api.php?i=%s&a=%s&t=%s"%(APIKey, artist.replace("-"," "),song.replace("-"," ")))
	def CS(self, x, a):
		if a=="all":
			return x.strip().replace(" ","-").replace("'","").replace(",","")
		if a=="track/artist":
			return x.split("(")[0].split("feat.")[0].split("featuring")[0].split("Feat.")[0].split("ft")[0].split("ft.")[0].split("feat")[0].split("Ft.")[0].split("remix")[0].split("Remix")[0].strip().replace("'","").replace("&","and").replace(".","")
	def ParseHTML(self, Attempt, Page):
		if Attempt=="1":
			x = Page.split('<div id="lyric_space">')[1].split("Lyrics powered by")[0].split("Lyrics submitted")[0].split("powered by")[0].replace("<br />","").replace("&#xD;","").replace("<!-- T_ID: T","").replace("-->","").replace("&#8217;","'")
			if "Sorry, we do not have the lyric for this song." in x:return "error_page"
			else:return x
		if Attempt=="2":
			return Page.split('</b>')[1].split('<i>')[0].replace("<br />","")
		if Attempt=="3":
			return "error_page"
			#if "Query not found" in Page:return "error_page"
			#else:return Page
	def showHelp(self):
		print "----------------------------"
		print "Python iTunes Lyrics Search"
		print "----------------------------"
		print "Syntax	: $lyrics [-s OR -i]"
		print "-s	: Display lyrics for prompted results."
		print " --Syntax: $lyrics -s"
		print "-i	: Current iTunes Song"
		print " --Syntax: $lyrics -i"
		print " -v for Version"
		print " -c for ChangeLog"
	def CheckForDir(self):
		isDirAlive=os.listdir(os.path.expanduser("~"))
		if ".control" in isDirAlive:
			pass
			#print "%s already exists - skipping creation"%self.TextPath
		else:
			os.mkdir(self.TextPath)
			print "I have made %s"%self.TextPath
	def CurrentItunes(self, a):
		if a=="Track":
			Track=rCMD("osascript -e 'tell application \"iTunes\" to name of current track as string'")
			Track=self.CS(Track,"track/artist")
			return Track
		if a=="Artist":
			Artist=rCMD("osascript -e 'tell application \"iTunes\" to artist of current track as string'")
			Artist=self.CS(Artist,"track/artist")
			return Artist
	def Say(self, x):
		if self.OS=="darwin":
			rCMD("say %s"%x.replace("'",""))
		else:
			print "I cannot support %s"%self.OS
	def OS_Error(self):
		try:
			return "This program does not work on %s"%osabbr[self.OS]
		except KeyError:
			return "This program does not work on %s"%self.OS
	
Lyrics()

