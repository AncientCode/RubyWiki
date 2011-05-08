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
		#resp = get_api 'action=query&prop=info&intoken=edit&titles=' + urlencode(name)
		#puts resp
		#resp['query']['pages'].each do |page|
		#	if page['missing'] == false
		#		false
		#	else
		#		true
		#	end
		#end
		page_info_lastmod_token name
	end
	
	protected # These methods are for using inside the class
	def page_info_lastmod_token name
		resp = get_api 'action=query&prop=info|revisions&intoken=edit&titles=' + urlencode(name)
		puts YAML::dump resp
		resp['query']['pages'].each do |page|
			if page['missing'] == false
				false
			else
				true
			end
		end
	end
end
