# This file contains the main RubyWiki class, which contains all you need to
# perform actions on a wiki. All requests are done with API and YAML (built-in
# version in the standard library)
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

ver = RUBY_VERSION.split('.')
RubyMajorVersion = ver[0].to_i
RubyMinorVersion = ver[1].to_i
RubyBuildVersion = ver[2].to_i
if RubyMajorVersion >= 1 and RubyMinorVersion >= 9 and RubyBuildVersion >= 2
    $: << File::expand_path(File::dirname(__FILE__))
    $: << File::expand_path(File::dirname(__FILE__) + '/rubywiki')
end

require 'rubygems'
require 'yaml'
require 'curb'
require 'tempfile'
require 'initrbw'

# Load basic class
require 'init'
require 'query'
require 'page'
