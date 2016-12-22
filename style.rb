#!/usr/bin/env ruby
# coding:utf-8

if ARGV.size.zero? then
  $stderr.puts <<-"USAGE"
style html format
$ style.rb hoge.html
USAGE
  exit 1
end

require 'oga'

html = Oga.parse_html(ARGF.read)
puts html.to_xml
