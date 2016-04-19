#!/usr/bin/env ruby
#
#        Author: Robbie - dunolie (at) gmail (dot) com
#     File name: 
#       Created: TIMESTAMP        
# Last Modified: TIMESTAMP
#   Description: 
#      Comments: http://eventless.net/scripts/automatic-itunes-lyrics-fetching-script-take-2
################################################################################
require 'rubygems'
require 'appscript'
require 'soap/wsdlDriver'
include Appscript

begin
  driver = SOAP::WSDLDriverFactory.new("http://lyricwiki.org/server.php?wsdl").create_rpc_driver
rescue
  raise "Could not connect to LyricWiki"
end

it = app('iTunes')

skipped = updated = errors = missing = 0

it.selection.get.each do |track|
  song = "%s - %s" % [track.artist.get, track.name.get]
  if track.lyrics.get == :missing_value
    puts "Skipped, not a song: %s" % song
    skipped += 1
    next
  end
  unless track.lyrics.get == "Not found" or track.lyrics.get.empty?
    puts "Skipped, already has lyrics: %s" % song
    skipped += 1
    next
  end
  begin
    lyrics = driver.getSong(track.artist.get,track.name.get).lyrics
  rescue
    puts "Lookup error: %s" % song
    puts "Error message: %s" % $!
    errors += 1
    next
  end
  if lyrics == "Not found"
    puts "Found nothing for: %s" % song
    missing += 1
    next
  end
  begin
    track.lyrics.set(lyrics)
    track.refresh
  rescue
    puts "Error, could not set lyrics for: %s" % song
    error +=1
    next
  end
  puts "Updated: %s" % song
  updated += 1
end

puts
puts "Summary"
puts "-------"
puts "Skipped: %i" % skipped
puts "Errors:  %i" % errors
puts "Missing: %i" % missing
puts "Updated: %i" % updated