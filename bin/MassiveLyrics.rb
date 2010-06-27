#!/usr/bin/env ruby
# The MIT License
# http://www.creamdesign.it/blog/archives/37
# Copyright (c) 2009 Davide Candiloro 
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "rexml/document"
require "rubygems"
require "appscript"
require "curb"
include Curl
include Appscript
include REXML  # so that we don't have to prefix everything with REXML::...

selected = app('iTunes').selection.get

updated = 0
not_found = 0
already_there = 0

for a in selected
  if (a.lyrics.get.eql?("") and !a.artist.get.eql?("") and !a.name.get.eql?(""))

      theartist = a.artist.get
      thesong = a.name.get
      
      url = "http://lyricwiki.org/"
      song = theartist.downcase
      song += ":"
      song += thesong.downcase
      #song.gsub!(/^[a-z]|\s+[a-z']/) { |letter| letter.upcase }
      song.gsub!(/\'\s/,' ')
      song.gsub!(/\s+/,'_')
      song.gsub!(/^[a-z]|_+[a-z]|[:\(\)\[\]][a-z]|/) { |letter| letter.upcase }
      song.gsub!(/&/, 'And' )
      
      puts song
 
      url += song

      c = Curl::Easy.perform(url)      
      pagecontent = c.body_str.gsub!(/&/, 'And' )
      doc = Document.new c.body_str
 
      ln = doc.root_node.find_first_recursive {|node| node.name == "div" and node.attributes["class"] == "lyricbox"}
      
      if (ln == nil)
        puts "CANNOT FIND any lyrics for " + theartist + " - " + thesong
        not_found = not_found + 1
      else
        lyr = ln.to_s
                 
        lyr.gsub!(/<\/*\s*br\s*\/*>/, "\n") #STRIP brs
        lyr.gsub!(/<\/*\s*p\s*\/*>/, "\n") #STRIP p
        lyr.gsub!(/\<\s*(.*?)(\s*\>)/m, "") #STRIP any tag
        lyr.gsub!(/\n+\Z/, "\n") #STRIP final returns
        
        a.lyrics.set(lyr)
        puts "UPDATED lyrics for " + theartist + " - " + thesong
        updated += 1
      end
  else 
    already_there += 1
  end
end

puts "==============================================================="
puts "lyrics already present for " + already_there.to_s  + " song(s)"
puts "lyrics not found for " + not_found.to_s + " song(s)"
puts "updated " + updated.to_s + " song(s)"
puts "==============================================================="
