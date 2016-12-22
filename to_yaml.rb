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
require_relative 'lib/to_yaml_lib.rb'

html = Oga.parse_html(ARGF.read)
