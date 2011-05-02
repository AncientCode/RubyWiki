require File.dirname(__FILE__) + '/init.rb'
class RubyWiki
	def site_info_general (type = nil)
		resp = get_api 'action=query&meta=siteinfo'
		unless resp.instance_of?Hash
			exception RbWikiErr::Query::General, 301, 'Can\'t Query'
		end
		if type
			exception RbWikiErr::Query::SiteInfo, 310, 'No Such Type' unless resp['query']['general'][type]
			return resp['query']['general'][type]
		else
			return resp['query']['general']
		end
	end
end