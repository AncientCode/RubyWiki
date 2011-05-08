# This file contains RubyWiki constant definitions that wikk help the main
# class RubyWiki load
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

# Include Path
INC = File.expand_path(File.dirname(__FILE__) + '/..') + '/'
# Exceptions are thrown in this file, loading it
require 'exceptions'

# RubyWiki version
RBW_VERSION = '0.1'
# Is it running on Windows??
WIN32 = (RUBY_PLATFORM.downcase.include?("mingw") or RUBY_PLATFORM.downcase.include?("mswin"))

if not defined?ConfigFile or not defined?ConfigDir
	if ENV['RBWIKI_CFG']
		# Configuration Directory
		ConfigDir = ENV['RBWIKI_CFG'] + '/'
		# Configuration File
		ConfigFile = ConfigDir + 'rbwiki.yml'
	elsif not WIN32 and File.directory(ENV['HOME'] + '/.rbwikirc')
		ConfigDir = ENV['HOME'] + '/.rbwikirc/'
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