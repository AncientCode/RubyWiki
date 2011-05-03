# This file contains RubyWiki querying methods
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require File.dirname(__FILE__) + '/init.rb'

class RubyWiki
	# Fetches the General Wiki Info
	def site_info_general (type = nil)
		resp = get_api 'action=query&meta=siteinfo'
		unless resp.instance_of?Hash
			exception RbWikiErr::Query::General, 301, 'Can\'t Query'
		end
		if type
			exception RbWikiErr::Query::GeneralSiteInfo, 310, 'No Such Type' unless resp['query']['general'][type]
			return resp['query']['general'][type]
		else
			return resp['query']['general']
		end
	end
end
