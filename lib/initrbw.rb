# This file contains RubyWiki constant definitions that wikk help the main
# class RubyWiki load
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

INC = File.expand_path(File.dirname(__FILE__)) + '/'
require INC + 'exceptions.rb'

RBW_VERSION = '0.1'
WIN32 = (RUBY_PLATFORM.downcase.include?("mingw") or RUBY_PLATFORM.downcase.include?("mswin"))
if not defined?ConfigFile
	if ENV['RBWIKI_CFG']
		ConfigDir = ENV['RBWIKI_CFG'] + '/'
		ConfigFile = ConfigDir + 'rbwiki.yml'
	elsif not WIN32 and File.directory(ENV['HOME'] + '/.rbwikirc')
		ConfigDir = ENV['HOME'] + '/.rbwikirc'
		ConfigFile = ConfigDir + 'rbwiki.yml'
	elsif WIN32 and File.readable?(ENV['USERPROFILE'].gsub('\\', '/') + '/rbwikirc')
		ConfigDir = ENV['USERPROFILE'].gsub('\\', '/') + '/rbwikirc/'
		ConfigFile = ConfigDir + 'rbwiki.yml'
	elsif File.readable?(INC + '../config.yaml')
		ConfigDir = INC + '../'
		ConfigFile = ConfigDir + 'config.yaml'
	else
		raise RubyWikiError, '10 No Config'
	end
end