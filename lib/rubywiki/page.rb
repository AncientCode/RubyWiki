# This file contains RubyWiki page querying, editing releated methods
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require 'init'
require 'query'
require 'exceptions'
require 'yaml'

class RubyWiki
	def page_exists? name
		resp = get_api 'action=query&prop=info&titles=' + urlencode(name)
		puts YAML::dump resp
	end
end
