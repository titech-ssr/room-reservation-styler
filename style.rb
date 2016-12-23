#!/usr/bin/env ruby
# coding:utf-8

require 'optparse'
require 'pp'

ARGV << '--help' if ARGV.empty?

OptionParser.new.instance_eval do
  %w[
  -a              asciidoc\ format
  -h              styled\ html
  -y\             yaml\ fomat
  -g\ config.yaml send\ to\ google\ calender
  -c\ cond.rb     cond
  ].each_slice(2){|ar| on(*ar)}

  parse(ARGV)
end

opt = ARGV.getopts("a:hyc:g:")

require 'oga'

html = Oga.parse_html(ARGF.read)

if opt[?h] then
  puts html.to_xml
elsif conf = opt[?y] then require_relative 'lib/parse.rb'
  f = if (file = File.exist?(opt[?c].to_s)) then
        eval(File.read(file))
      else
        ->(room:"", circle:"", responsible:"", start:1, range:1){ true }
      end
  pair = date_room_pair(html).map{|date, rooms|
    [date, rooms.map{|room| select_room_reservs(room, f)}.to_h]
  }.to_h

  puts pair.to_yaml
elsif conf = opt[?a] then
 require_relative 'lib/parse.rb'
 require_relative 'lib/to_adoc'
  f = if (file = File.exist?(opt[?c].to_s)) then
        eval(File.read(file))
      else
        ->(room:"", circle:"", responsible:"", start:1, range:1){ true }
      end
  pair = date_room_pair(html).map{|date, rooms|
    [date, rooms.map{|room| select_room_reservs(room, f)}.to_h]
  }.to_h
  puts to_adoc(hash: pair, circle: opt[?a])
elsif conf = opt[?g] then
  p conf
  puts ARGF.read
end
