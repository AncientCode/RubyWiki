class RubyWikiError < StandardError
	def to_i
		self.to_s.to_i
	end
end

module RbWikiErr
	class General < RubyWikiError; end
	class Login < RubyWikiError; end
	module Query
		class General < RubyWikiError; end
		class SiteInfo < RubyWikiError; end
	end
end