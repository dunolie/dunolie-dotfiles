#!/usr/local/bin/ruby

require 'rubygems'
require 'rbosa'
require 'net/http'
require 'cgi'

def get_all_the_lyrics
  playlist = ITUNES.current_playlist
  
  found = 0
  not_found = 0
  already_had_lyrics = 0
  puts %{
    
*--------------------------------------------------------*
GONNA GET THE LYRICS FOR #{playlist.tracks.length} SONGS
*--------------------------------------------------------*

  }
  
  playlist.tracks.each do |track|
    lyric_artist = CGI.escape(track.artist.gsub(' ', '_').gsub('&', 'And'))
    lyric_song = CGI.escape(track.name.gsub(' ', '_').gsub('&', 'And'))
    @url = "http://lyricwiki.org/api.php?artist=#{lyric_artist}&song=#{lyric_song}&fmt=text"
    puts "#{track.name} already has lyrics" unless (!track.lyrics || track.lyrics.empty?)
    if track.lyrics && track.lyrics.empty?
      puts "gonna get the lyrics for #{track.name} by #{track.artist}"
      resp = Net::HTTP.get_response(URI.parse(@url))
      lyrics = resp.body
      # uncomment this line to edit your lyrics
      # lyrics.gsub!(/\bshit\b|fuck|\bass\b|asshole|damn|\bcock\b|pussy/i, '*edit*')
      if lyrics == 'Not found'
        puts "-- didn't find them --"
        not_found += 1
        track.lyrics = ''
      else
        puts "-- found them --"
        found += 1
        track.lyrics = lyrics
      end
    else
      already_had_lyrics += 1
    end   
  end
  
  puts %{  
*-------*
RESULTS:
*-------*

#{already_had_lyrics} songs already had lyrics
found lyrics for #{found} songs
could not find lyrics for #{not_found} songs

  }
  
end

ITUNES = OSA.app('iTunes')
get_all_the_lyrics
