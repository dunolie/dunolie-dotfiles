#!/usr/bin/env ruby
#-------------------------------------------------------------------------------
# Copyright 2005-2008 Michael Conrad Tadpol Tilstra <tadpol@tadpol.org>
# Copyright 2008 Ben Flaumenhaft <ben@alcedon.com>
# 
# This work is licensed under the Creative Commons Attribution-ShareAlike
# License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-sa/2.0/ or send a letter to
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#
# and really, I'd like to know what you've done if you go and make changes,
# but you're not required to tell me.
#-------------------------------------------------------------------------------
# parts of this are still kind of kludged together, But I thought I'd let it out
# for others to play with anyways.  It pretty much works, but the code is kind of
# ugly.
#-------------------------------------------------------------------------------

# This script is for NetNewsWire (NNW).
# This will, more or less, turn any web page into a new feed.  When ran,
# it checks to see if the page has changed.  If it has, it makes a new
# feed entry with the page.

# To use it, drop the script somewhere.  Make sure that the script is
# executable. ('chmod +x html2rss.rb' from Terminal is one way to do
# this.) Then in NNW, select the File > New Special Subscription >
# Script... menu item.  Pick the scipt. Then in the info panel for the
# script, set the script type to "Shell" and put the URL of the web page
# you want to track into the Args box. Repeat for as many pages as you
# want to monitor.

# This script wants ruby version 1.6 or later. (Ruby 1.6 is included with
# MacOS 10.3.7, possibly other versions of 10.3.)

# I use this script for web comics.  There are so many nifty ones that
# only update when the authors have time that it just sucks to continually
# check the page.  So I wrote this script.


require 'uri'
require 'net/http'
Net::HTTP.version_1_1
require 'time'
require 'cgi'  # for escaping  (stray & in xml sux.)
require 'md5'

HTTPTORSS_VERSION = 'HTTPtoRSS v0.5'
$LOG=$stderr

class BaseItem
	attr_reader :lastfetch, :guid, :title, :md5
	def initialize(pagedata)
		@title = 'empty'
		@lastfetch = Time.now
		@guid = @lastfetch.strftime('%a, %d %b %Y %H:%M:%S %Z')
		@link = ''
		@pagedata = pagedata
		$LOG.puts self.inspect if $DEBUG
		@md5 = Digest::MD5.new.update(@pagedata).to_s
	end
    def to_s  #for debuggin.
    	"#{@lastfetch} : #{@title} : #{@link} : #{@guid}"
    end
	def to_rss
    	# For NNW (2.0b10), Title and guid MUST be unique.
        "<item>\n" +
        " <title>#{@title.to_s} #{@lastfetch.strftime('%d %b %Y %H:%M:%S')}</title>\n" +
        ' <pubDate>' + @lastfetch.strftime('%a, %d %b %Y %H:%M:%S %Z') + "</pubDate>\n" +
        ' <link>' + @link.to_s + "</link>\n" +
        ' <guid isPermaLink="false">' + @guid + "</guid>\n" +
		" <!-- md5: #{@md5} -->\n" +
        " <description>\n" +
        "<![CDATA[<base href=\"" + @link + "\">\n" +
        @pagedata + "]]>\n" + 
        "</description>\n" +
        "</item>\n"
	end
    def <=>(foo)
        foo.lastfetch <=> self.lastfetch
    end
	def comppage(page)
		@md5 == page.md5
	end
end
class ErrorItem < BaseItem
	# NNW really wants RSS, so turn our errors into RSS items.
	def initialize(err, str='Unhandled exception: ')
		super(err.backtrace)
		@title = str + err.to_s
		@link = ''
		@pagedata = err.backtrace
	end
end
class Pages < BaseItem
	# actually just a page, but details.
	def initialize(uri, resp, data)
		super(data)
		if resp.key?('last-modified')
			@lastfetch=Time.parse(resp['last-modified'])
		else
			@lastfetch = Time.new
		end
		# use the wayback machine in links?
		#@link = 'http://web.archive.org/web/' + @lastfetch.strftime('%Y%m%d') + '*/' + uri.to_s
		# doesn't quite work the way I thought it would. skipping.
		@link = CGI.escapeHTML(uri.to_s)
		mt = %r{<title>([^<]+)</title>}.match(data) #might need better regexp.
		if mt != nil and mt.length > 2 and mt[1].length > 0
			@title = mt[1].gsub(/\&[^;]*;/,'')
		else
			@title= @link
		end
		if resp.key?('etag') #http1.1 allows for unqiue page identifiers!!
			@guid = resp['etag'].gsub(/\"/,'') if resp.key?('etag')
		else # we can fake soemthing too if needed.
			@guid=@lastfetch.strftime('%Y-%m-%d-%H:%M:%S') + ':' + @link 
		end
		#@pagedata=data
		#@md5 = Digest::MD5.new(@pagedata).to_s
	end
end

begin
	uri = URI.parse(ARGV[0])
rescue
# handling this error here this way is LAME.  fix.
puts <<EOHERE
<?xml version="1.0" encoding="iso-8859-1" ?>
<rss version="2.0">
  <channel>
    <title>URI Error</title>
    <link>http://localhost/</link>
    <generator>#{HTTPTORSS_VERSION}</generator>
    <description>URI Error</description>
    <item>
      <title>Error</title>
      <link>http://localhost/</link>
      <description>
      #{$!.to_s}
      #{$!.backtrace}
      </description>
    </item>
  </channel>
</rss>
EOHERE
exit
end
lastfetch=nil

# Find and Setup the pageStore.
# hope this directory is unique.
psdir = ENV['HOME'] + '/Library/Application Support/HTMLtoRSS/'
psloc = psdir + uri.host + uri.request_uri.gsub(/[\\\/:]/,'_')
if File.exists?(psdir) and not File.stat(psdir).directory?
	File.delete(psdir)
end
if not File.exists?(psdir)
	Dir.mkdir(psdir)
end
if File.exists?(psloc) and not File.stat(psloc).file?
	File.delete(psloc)
end
if File.exists?(psloc)
	r = IO.readlines(psloc, nil)
	# i'd like to use something other than mashalling, but that's all that is
	# included with ruby1.6, and I want to keep this script self standing.
	# (and don't want to write my own storage system.)
	pagestore = Marshal.load(r[0])
	pagestore.sort!
	if pagestore.length > 0
		lastfetch = pagestore[0].lastfetch
	end
else
	pagestore = Array.new
end

# build request headers
headers = Hash.new
headers['Host'] = uri.host.to_s + ':' + uri.port.to_s
# other headers?
# some pages might need a faked user-agent line.
if lastfetch != nil
	headers['If-Modified-Since'] = lastfetch.strftime('%a, %d %b %Y %H:%M:%S %Z')
end

# fetch latest page
begin
	Net::HTTP.start( uri.host, uri.port ) do |http|
		resp, data = http.get( uri.request_uri, headers )
		
		np = Pages.new(uri, resp, data)
#		$stderr.puts np.to_s
#		$stderr.puts "pagestore: #{pagestore.length.to_s}"
#		$stderr.puts pagestore[0].to_s unless pagestore.length == 0
		if pagestore.length == 0
			# First time we're looking at this site.
			pagestore << np
		elsif not pagestore[0].comppage(np)
			# if the page is different, store it.
			pagestore << np
		end
	end
rescue Net::ProtoRetriableError => err
	head = err.data
	case head.code
	when /30[123]/
		# Not where we thought it was.
		uri = URI.parse(head['location'])
		retry
	when "300"
		# if the tell us where else to look, go there.
		if head.key? 'location'
			uri = URI.parse(head['location'])
			retry
		else
			$stderr.puts "HTMLtoRSS.rb: #{head.code} #{head.message}" + $!.to_s
			pagestore << ErrorItem.new($!, "#{head.code} #{head.message}")
		end
	when "304"
		# no change, nothing to save.
	else
		$stderr.puts 'HTMLtoRSS.rb: Net::ProtoRetriableError ' + $!.to_s
		pagestore << ErrorItem.new($!, 'Net::ProtoRetriableError')
	end
rescue TimeoutError
	# Don't change the rss for this.
	# It would be nice If I could get messages into NNW's Error window.
	$stderr.puts "HTMLtoRSS.rb: Timed out trying to fetch #{uri.to_s}"
rescue
	$stderr.puts "HTMLtoRSS.rb: Unhandled exception: " + $!.to_s
	pagestore << ErrorItem.new($!)
end

# limit feed to 10 copies. If ppl want more, they can either hack this,
# Or turn on presistence for this feed.
pagestore = pagestore.sort[0..10]

# save pages.
File.open(psloc, "w") do |file|
	file << Marshal.dump(pagestore)
end

# Now, build a RSS2 feed from the PageStore.
puts <<EOHERE
<?xml version="1.0" encoding="iso-8859-1" ?>
<rss version="2.0">
  <channel>
    <title>#{pagestore[0].title}</title>
    <link>#{CGI.escapeHTML(uri.to_s)}</link>
    <generator>#{HTTPTORSS_VERSION}</generator>
    <description>Feed Generated from checking for changes to #{CGI.escapeHTML(uri.to_s)}
    </description>
EOHERE

pagestore.each {|i| puts i.to_rss }

puts "</channel></rss>"

