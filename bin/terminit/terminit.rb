#!/usr/bin/ruby
require 'rubygems'
require 'appscript'
require 'yaml'

include Appscript

class TermInit
  
  def initialize(project=nil)
    get_real_file
    do_config
    
    if project
      @terminal = app('Terminal')
      do_project(project)
    else
      usage
    end
  end # initialize
  
  def do_project(project)
    config_file = File.join(@config['projects_dir'], "#{project.sub(/\.yml$/, '')}.yml")
    tabs = YAML.load(File.read(config_file))
    
    tabs.each do |hash|
      tabname = hash.keys.first
      cmds = hash.values.first
      
      tab = new_tab
      cmds = [cmds].flatten
      cmds.each do |cmd|
        @terminal.do_script(cmd, :in => tab)
      end
    end
  end
  
  def usage
    puts "
    Usage:
    #{File.basename(@file)} project_name
      where project_name is the name of a terminit project yaml file 
      
    See the README for more information.
    "
    exit 0
  end
  
protected
  def do_config
    config_file = File.join(File.dirname(@file), "terminit.yml")
    
    default_config = {
      'projects_dir' => File.dirname(@file)
    }
    
    # don't attempt to load an empty file
    if File.exist?(config_file) && YAML.load(File.read(config_file))
      @config = default_config.merge(YAML.load(File.read(config_file)))
    else
      @config = default_config
    end
  end # do_config
  
  # stores name of the target file if __FILE__ is a symlink
  def get_real_file
    if File.lstat(__FILE__).symlink?
      @file = File.readlink(__FILE__)
    else
      @file = __FILE__
    end
  end # get_real_file
  
  # somewhat hacky in that it requires Terminal to exist,
  # which it would if we run this script from a Terminal,
  # but it won't work if called e.g. from cron.
  # The latter case would just require us to open a Terminal
  # using do_script() first with no :in target.
  # 
  # One more hack:  if we're getting the first tab, we return
  # the term window's only current tab, else we send a CMD+T
  def new_tab
    if @got_first_tab_already
      app("System Events").application_processes["Terminal.app"].keystroke("t", :using => :command_down)
    end
    @got_first_tab_already = true
    @terminal.windows[1].tabs.last.get
  end # new_tab
  
end # class

TermInit.new ARGV[0]
