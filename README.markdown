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
* Highline (if you want to type your password in a shell,
`gem install highline`)

Usages & Sample
---------------
Login and print MediaWiki Version:

```ruby
wiki = RubyWiki.new
puts wiki.site_info_general 'generator'
```
