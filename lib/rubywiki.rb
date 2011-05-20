# This file contains the main RubyWiki class, which contains all you need to
# perform actions on a wiki. All requests are done with API and YAML (built-in
# version in the standard library)
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require 'rubygems'
require 'yaml'
require 'curb'
require 'tempfile'
require 'initrbw'

# Load basic class
require 'init'
require 'query'
require 'page'
require 'user_info'
