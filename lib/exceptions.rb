# This file contains RubyWiki Exceptions divided into modules and classes
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

# Initialize Error
class RubyWikiError < StandardError
	# Get the Error Code
	def to_i
		self.to_s.to_i
	end
end

# All sort of error raised by RubyWiki
module RbWikiErr
	# General Errors
	class General < RubyWikiError; end
	# Login Specific Errors
	class Login < RubyWikiError; end
	# Querying Module Errors
	module Query
		# General Query Errors
		class General < RubyWikiError; end
		# General Site Info Errors
		class GeneralSiteInfo < RubyWikiError; end
	end
end