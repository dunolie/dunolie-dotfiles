require 'rubygems'
require 'sqlite3'
require 'net/http'
require 'uri'
require 'date'

require 'rexml/document'
include REXML

today_quote = ""

begin
	dbh = SQLite3::Database.new("quote.db")
	dbh.execute("create table if not exists quotes (id integer primary key autoincrement, quote text, date text, author text);")	
     	# get server version string and display it
	
	rows = dbh.execute("SELECT quote, author FROM quotes WHERE date = '#{Date.today.to_s}'")
	if rows.length > 0
		today_quote = rows[0][0] 
		author = rows[0][1]
	else
		resp = Net::HTTP.get(URI.parse('http://www.quotedb.com/quote/quote.php?action=quote_of_the_day_rss'))
		doc = Document.new( resp )
		author = doc.elements["*/channel/item/title"].text
		today_quote = doc.elements["*/channel/item/description"].text	
		today_quote = today_quote[1..-2]
		today_quote = today_quote.gsub("\"", "&quot;")
		dbh.query("INSERT INTO quotes (quote, author, date) VALUES (\"#{today_quote}\", \"#{author}\", \"#{Date.today.to_s}\")")
	end
	if author == "Author Unknown"
		author = "Anonymous"
	end
	
	puts "\nQuote of the day:\n\"" + today_quote + "\"\n -- #{author}\n\n"
	
ensure
     	# disconnect from server
     	#dbh.close if dbh
end
