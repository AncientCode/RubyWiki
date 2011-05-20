# This file contains RubyWiki page querying, editing releated methods
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require 'init'
require 'query'
require 'exceptions'
require 'data_class'
require 'yaml'

class RubyWiki
	def page_exists? name, inside = false
		resp = get_api 'action=query&prop=info|revisions&intoken=edit&titles=' + urlencode(name)
		resp['query']['pages'].each do |page|
			if page['missing'] == false
				false
			else
				if inside
					a = {
						'token' => page['edittoken'],
						'obtained' => page['starttimestamp'],
						'last' => 0,
						}
					for rev in page['revisions']
						a['last'] = rev['timestamp'] if rev['revid'] == page['lastrevid']
					end
				else
					true
				end
				
			end
		end
	end
	
	def get_page title
	end
	
	def put_page name, content
		exist = page_exists? name, true
	end
	
	protected # These methods are for using inside the class
end
