#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/lib/console_searcher")

ConsoleSearcher.realm(:github).search do
  list
  puts search_url
end
