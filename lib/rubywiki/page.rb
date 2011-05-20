# This file contains RubyWiki page querying, editing releated methods
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require 'rubywiki'
require 'init'
require 'query'
require 'exceptions'
require 'data_class'
require 'yaml'

class RubyWiki
	def page_exists? name, inside = false
		resp = get_api 'action=query&prop=info|revisions&intoken=edit&titles=' + urlencode(name)
		puts YAML::dump resp
		page = resp['query']['pages'][0]
		if inside
			a = {
				'token' => page['edittoken'],
				'obtained' => page['starttimestamp'],
				'last' => 0,
				'exist' => page['missing'] == false ? false : true
			}
			for rev in page['revisions']
				a['last'] = rev['timestamp'] if rev['revid'] == page['lastrevid']
			end if a['exist']
			puts YAML::dump a
			a
		else
			if page['missing'] == false
				false
			else
				true
			end
		end
	end
	
	def get_page title, inside = nil
		resp = get_api "action=query&prop=revisions&titles=#{urlencode(title)}&rvprop=content"
		
		if resp
			resp['query']['pages'].each do |page|
				if page['missing']
					exception RubyWikiErr::Query::GetPage, 321, 'Missing', inside ? true : nil
				elsif page['invalid']
					exception RubyWikiErr::Query::GetPage, 322, 'Invalid Title', inside ? true : nil
				elsif page['special']
					exception RubyWikiErr::Query::GetPage, 323, 'Special Page', inside ? true : nil
				else
					if page['revisions'][0]['*'].is_a?String
						i = RubyWikiData::Page.new # Create a new WikiPage class
						i.content = page['revisions'][0]['*'] # Page text
						i.title = page['title'] # Title
						i.ns = page['ns'] # Namespace ID
						i.id = page['pageid'] # Page ID
						j = i.title.split ':'  # Namespace Name
						if j[0] == i.title
							i.nsname = true # The main namespace
						else
							i.nsname = j[0] # A page with named namespace
						end
						return i
					else
						exception RubyWikiErr::Query::GetPage, 320, 'Get Page Error', inside ? true : nil
					end
				end
			end
		else
			exception RubyWikiErr::Query::GetPage, 320, 'Get Page Error', inside ? true : nil
		end
	end
	
	def put_page name, content
		exist = page_exists? name, true
		
	end
	
	protected # These methods are for using inside the class
end
