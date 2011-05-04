SoftX RubyWiki
==============
This is a high-performance MediaWiki bot written in entirely Ruby with:

* Fast Connection Speed done with
  * Keep-Alive
  * Sharing cURL Handles
* Bandwidth Saving with Keep-Alive
* cURL for HTTP is faster than Net::HTTP

Requirements
------------
* Curb (taf2/curb on GitHub, `gem install curb`)
* YAML (bundled with Ruby)
* Tempfile (bundled with Ruby, only if you want one time login and
forbid others to use your account)
* Highline (if you want to type your password in a shell,
`gem install highline`)
* Backports (on Ruby 1.8.x because we used require_relative which works for
1.9.x `gem install backports`)

Usages & Sample
---------------
Login and print MediaWiki Version:

    wiki = RubyWiki.new
    puts wiki.site_info_general 'generator'