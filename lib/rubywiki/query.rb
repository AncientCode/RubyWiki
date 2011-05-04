# This file contains RubyWiki querying methods
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require '../rubywiki'
require './exceptions'
require './init'

class RubyWiki
	# Fetches the General Wiki Info
	def site_info_general (type = nil)
		resp = query_processor 'meta', 'siteinfo'
		if type
			exception RbWikiErr::Query::GeneralSiteInfo, 310, 'No Such Type' unless resp['query']['general'][type]
			resp['query']['general'][type]
		else
			resp['query']['general']
		end
	end
	
	protected
	def query_processor (type, mod, args = nil)
        query = "action=query&#{type}=#{mod}"
        if args
            args.each do |arg, value|
                query += "&#{arg}=#{value}"
            end
        end
        resp = get_api(query)
        unless resp.instance_of?Hash
            exception RbWikiErr::Query::General, 301, 'Can\'t Query'
        end
        resp['query']
	end
end
