# This file contains RubyWiki user information querying methods
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require 'exceptions'
require 'init'
require 'query'

class RubyWiki
	def user_rights
        resp = query_processor 'meta', 'userinfo', {'uiprop' => 'rights'}
        return resp['userinfo']['rights']
	end
	
	def user_pref
		resp = query_processor 'meta', 'userinfo', {'uiprop' => 'options'}
		return resp['userinfo']['options']
	end
	
	def user_id
		
	end
end