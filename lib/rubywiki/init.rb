# This file contains the main RubyWiki class. Well, it's not the entire class
# but the basic part. These are the parts included:
# * Log level constants
# * Class initializer
# * Class finalizer
# * Logger
# * Login function
# * Logout function(todo)
# * cURL Controller
# * Exception thrower
# * URL decoder/encoder
#
# Author::  Xiaomao Chen
# Copyright:: SoftX Technologies Inc.
# License:: GNU General Public License version 3

require 'rubygems'
require 'yaml'
require 'curb'
require 'initrbw'

# This is the main RubyWiki class, it contains all you need to perform actions
# on a wiki. All requests are done with API and YAML (built-in version in the
# standard library)
class RubyWiki
	# Debug Information Log Level, e.g.
	# * RubyWiki Started
	# * OS: Microsoft Windows 7 Ultimate Edition
	# * Ruby Version 1.9.2-p180
	LL_DEBUG	= 0
	# Information Log Level, e.g.
	# * User "foo" logged into wiki "bar"
	LL_INFO		= 1
	# Notice Log Level, any information that have more powerful
	# meaning that normal information
	LL_NOTICE	= 2
	# Warning Log Level, errors that happened but RubyWiki can handle it
	LL_WARN		= 3
	# Error Log Level, any error that can be caught with rescue
	LL_ERROR	= 4
	# Fatal Error Log Level, any error that exits immediately
	LL_FATAL	= 5
	# End of line
	EOL = WIN32 ? "\r\n" : "\n"
	# Map all log levels to their name
	@@loglevelname = {
		LL_DEBUG => 'Debug Info',
		LL_INFO => 'Info',
		LL_NOTICE => 'Notice',
		LL_WARN => 'Warning',
		LL_ERROR => 'Error',
		LL_FATAL => 'Fatal Error',
	}
	# Bug tracker address
	@@bugtrac = 'http://sproj.tk/rbw/newticket'
	
	# Initialize the whole class, populate class variables with data and login.
	# Wiki::	The wiki specification to load
	# User::	The user to use for that wiki
	# Agent::	The User-Agent to use
	# max_lag::	Importance of data so MediaWiki knows how to adjust slave DBs to prevent lag
	def initialize(wiki = nil, user = nil, pass = nil, agent = nil, max_lag = nil)
		# Read Configuration file defined in "initrbw.rb"
		@conf = YAML::load_file ConfigFile
		# Get the wiki name to use, from the argument if defined or the configuration
		@wikid = wiki ? wiki : @conf['wiki']

		# Load the wiki's configuration
		begin
			if File.readable?(ConfigDir + 'wikis/' + @wikid + '.yaml')
				@wikiconf = YAML::load_file(ConfigDir + 'wikis/' + @wikid + '.yaml')
			else
				@wikiconf = YAML::load_file(INC + '../wikis/' + @wikid + '.yaml')
			end
		rescue ArgumentError
			raise RubyWikiError, 12, 'Invalid Wiki Config'
		rescue Errno::ENOENT
			raise RubyWikiError, 13, 'Wiki doesn\'t exist'
		end
		
		# Get Wiki Data
		# Wiki Name
		@wikiname = @wikiconf['name']
		# Replicate DB lag level
		@max_lag = @wikiconf['maxlag']
		# Edit per minute
		@epm = @wikiconf['epm']
		# Wiki Protocol
		@proto = @wikiconf['protocol']
		# Wiki Domain
		@host = @wikiconf['domain']
		# Path to wiki installation directory relative to @host
		@path = @wikiconf['path']
		# Article Path relative to @host
		@article = @wikiconf['article']
		# API.php filename
		@api_script = @wikiconf['api']
		# End of Get Wiki Data
		
		# Merge wiki configuration to make the absolute URL to API.php
		@api_url = @proto + '://' + @host + @path + '/' + @api_script
		# Generate the User-Agent of the Bot
		@useragent = agent ? agent : (
			@conf['useragent'] == 'default' ?
				'RubyWiki/' + RBW_VERSION :
				@conf['useragent']
			)
		# Figure out the log level
		@loglevel = RubyWiki::const_get(@conf['loglevel'])
		
		# Username and password
		# Get the username to use, from the argument if defined or the configuration
		if user
			@user = user
		elsif @conf['user']
			if @conf['users'][@wikid].include?@conf['user']
				@user = @conf['user']
			elsif @conf['users'][@wikid][0]
				@user = @conf['users'][@wikid][0]
			else
				exception RubyWikiError, 11, 'No Such User'
			end
		else
			if @conf['users'][@wikid][0]
				@user = @conf['users'][@wikid][0]
			else
				exception RubyWikiError, 11, 'No Such User'
			end
		end
		# Get password
		if pass
			@pass = pass
		elsif @conf['pass'][@wikid][@user]
			@pass = @conf['pass'][@wikid][@user]
		else
			require 'highline/import'
			@pass = ask("Type in the password for #{@user}@#{@wikiname}:") { |q| q.echo = "*" }
		end
		# End of Username and password
		
		# Open the log file
		@log = File.open(ConfigDir + 'rubywiki.log', 'a')
		
		# Max Slave DB lag level
		if max_lag 
			@max_lag = max_lag
		else
			@max_lag = 5
		end
		
		# Define Destructor
		ObjectSpace.define_finalizer(self, self.method(:finalize).to_proc)
		
		# Initialize cURL Handles
		init_curl!
		
		# Debug Log
		log "RubyWiki/#{RBW_VERSION} started", LL_DEBUG
		log "Ruby Version #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}", LL_DEBUG
		
		# Login
		login!
	end
	
	# Finalizer, destory the temperory file and close the log file
	def finalize
		@log.close
		@temp_handle.unlink
	end
	
	# URL Encode a string, copied from cgi/utils.rb, CGI::escape
	def urlencode(string)
		string.gsub(/([^ a-zA-Z0-9_.-]+)/) do
			'%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
		end.tr(' ', '+')
	end
	
	# URL Decode a string, copied from cgi/utils.rb, CGI::unescape
	def urldecode(string)
		str=string.tr('+', ' ').force_encoding(Encoding::ASCII_8BIT).gsub(/((?:%[0-9a-fA-F]{2})+)/) do
			[$1.delete('%')].pack('H*')
		end.force_encoding('UTF-8')
		str.valid_encoding? ? str : str.force_encoding(string.encoding)
	end
	
	protected # Protected Methods
	# Internal method to log into the wiki
	def login!
		resp = post_api({
				'action' => 'login',
				'lgname' => @user,
				'lgpassword' => @pass,
			})
		case resp['login']['result'] 
			when 'Success'
				# Unpatched server, all done. (See bug #23076, April 2010)
				log "\"#{@user}\" logged into wiki \"#{@wikiname}\"", LL_INFO
			when 'NeedToken'
				resp = post_api({
						'action'     => 'login',
						'lgname'     => @user,
						'lgpassword' => @pass,
						'lgtoken'    => resp['login']['token'],
					})
				login_code_check! resp
			else
				login_code_check! resp
		end
	end
	
	# Check the login response and log/throw exception
	def login_code_check! (resp)
		case resp['login']['result']
			when 'Success'
				log "\"#{@user}\" logged into wiki \"#{@wikiname}\"", LL_INFO
			when 'Throttled'
				log "\"#{@user}\" needs to wait #{resp['login']['wait']} seconds to log into wiki \"#{@wikiname}\"!", LL_WARN
				sleep resp['login']['wait']
				login!
			when 'EmptyPass', 'WrongPass', 'WrongPluginPass'
				exception RbWikiErr::Login, 102, 'Wrong Password'
			when 'Blocked', 'CreateBlocked'
				exception RbWikiErr::General, 32, 'Blocked'
			when 'NotExists'
				exception RbWikiErr::General, 31, 'No Such User'
			when 'Illegal'
				exception RbWikiErr::Login, 101, 'Illegal User'
			else
				puts 'This is an error that wasn\'t handled by RubyWiki. This'
				puts 'might indicate a bug. Please report it to:'
				puts @@bugtrac
				puts 'The following is an error dump, attach it to the report:'
				puts YAML::dump(resp)
				exception RbWikiErr::Login, 100, 'Login Error'
		end
	end
	
	# Internal Functions
		
	# cURL Handles Initiailzers
	def init_curl!
		@cookie_file = File.expand_path ConfigDir + @conf['cookie']
		@get = Curl::Easy.new()
		@post = Curl::Easy.new(@api_url)
		@get.enable_cookies = @post.enable_cookies = true
		@get.useragent  = @post.useragent  = @useragent
		@get.cookiejar = @cookie_file
		@post.cookiejar = @get.cookiefile = @post.cookiefile = @get.cookiejar
		@get.headers    = @post.headers    = [
			'Connection: keep-alive',
			'Keep-Alive: 300',
			]
		@get.encoding   = @post.encoding   = 'gzip, deflate'
	end
	
	# Perform a get request to API, please urlencode the query string
	def get_api(query)
		@get.url = "#{@api_url}?#{query}&maxlag=#{@max_lag}&format=yaml"
		begin
			@get.http_get
			YAML::load(@get.body_str)
		rescue
			false
		end
	end
	
	# Perform a post request to API, please use an array
	def post_api(data, multipart = false)
		query = ''
		data.each do |var, content|
			query += var + '=' + urlencode(content) + '&'
		end
		query += 'format=yaml'
		begin
			@post.http_post query
			YAML::load(@post.body_str)
		rescue
			false
		end
	end
	
	# Log an error with level of `level' and a strftime 
	def log(data, level = LL_INFO, fmt = '%Y-%m-%d %H-%M-%S.%L')
		if @loglevel <= level
			write = Time.now.strftime(fmt) + ' - ' + data
			@log.write write + EOL
			$stderr.puts write
		end
	end
	
	# Throw an exception in the way of RubyWiki
	def exception(type, code, message, nolog=nil)
		if /^(.+?):(\d+)(?::in `(.*)')?/ =~ caller()[0]
			method = Regexp.last_match[3]
		end
		log("Exception #{type.to_s} raised in '#{method}'!!!", LL_ERROR) unless nolog
		raise type, code.to_s + message
	end
end