require File.dirname(__FILE__) + '/init.rb'
class RubyWiki
	def wiki_info (type = nil)
		resp = get_api()
		unless resp.instance_of?Hash
			exception RbWikiErr::Query, 301, 'Can\'t Query'
		end
		
	end
end