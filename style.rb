#!/usr/bin/env ruby
# coding:utf-8

require 'optparse'

OptionParser.new do |opt|
opt.instance_eval{
  on('-a',  'asciidoc format')
  on('-h html',  'styled html')
  on('-y',  'yaml')
  parse(ARGV)
}
end

opt = ARGV.getopts("ahy")

require 'oga'

if opt[?h] then
  html = Oga.parse_html(ARGF.read)
  puts html.to_xml
end
#require_relative 'lib/to_yaml_lib.rb'
