#!/usr/bin/env ruby
# coding:utf-8

require 'optparse'
require 'pp'

ARGV << '--help' if ARGV.empty?

args =  OptionParser.new.instance_eval {
  %w[
  -a\ config.yaml  asciidoc\ format
  -h               styled\ html
  -y\ config.yaml  yaml\ fomat
  -g\ config.yaml  send\ to\ google\ calendar
  -c\ cond.rb      cond
  ].each_slice(2){|ar| on(*ar)}

  parse(ARGV)
}

opt = ARGV.getopts("a:hy:c:g:")

require 'oga'


if opt[?h] then
  html = Oga.parse_html(ARGF.read)
  puts html.to_xml
elsif conf = opt[?y] then require_relative 'lib/parse.rb'
  html = Oga.parse_html(ARGF.read)
  f = if (file = File.exist?(opt[?c].to_s)) then
        eval(File.read(file))
      else
        ->(room:"", circle:"", responsible:"", start:1, range:1){ true }
      end
  pair = date_room_pair(html, YAML.load_file(conf)).map{|date, rooms|
    [date, rooms.map{|room| select_room_reservs(room, f)}.to_h]
  }.to_h

  puts pair.to_yaml
elsif conf = opt[?a] then
 require_relative 'lib/parse.rb'
 require_relative 'lib/to_adoc'
  html = Oga.parse_html(ARGF.read)
  f = if (file = File.exist?(opt[?c].to_s)) then
        eval(File.read(file))
      else
        ->(room:"", circle:"", responsible:"", start:1, range:1){ true }
      end
  pair = date_room_pair(html, YAML.load_file(conf)).map{|date, rooms|
    [date, rooms.map{|room| select_room_reservs(room, f)}.to_h]
  }.to_h
  puts to_adoc(hash: pair, circle: opt[?a])
elsif conf = opt[?g] then

h=if (file=args.first) =~ /.+\.html/ then
    require_relative 'lib/parse.rb'
    html = Oga.parse_html(File.read(file))
    f = if (file = File.exist?(opt[?c].to_s)) then
          eval(File.read(file))
        else
          ->(room:"", circle:"", responsible:"", start:1, range:1){ true }
        end
    pair = date_room_pair(html, YAML.load_file(conf)).map{|date, rooms|
      [date, rooms.map{|room| select_room_reservs(room, f)}.to_h]
    }.to_h
  elsif file =~ /.+\.yaml/ then
    require 'yaml'
    require_relative 'lib/datadef'
    YAML.load_file(file) 
  else
    $stderr.puts "Format error"
    exit 1
  end

  config = YAML.load_file(conf)

  require_relative 'lib/calendar'
  hash = h.map{|date, rooms|
    [
      date, 
      rooms.inject({}){|h, (room,resvs)| 
        resvs.each{|rsv| 
          pair = [rsv.start, rsv.range]
          h[pair] = (h[pair]||[]) << room.room
        }
        h
      }.map{|pair, rooms| 
        to_query(date:date, rooms:rooms, start:pair.first, range:pair.last)
      }
    ]
  }.to_h

  puts "Data loaded..."
  sleep 0.5
  
  IO.popen("less", ?w){|pipe| pipe << PP.pp(hash, '', `tput cols`.to_i)}

  print "Send to Google calendar? >>"
  unless $stdin.gets =~ /y(?:es)?/i then
    puts "canceled"
    exit 1
  end

  sleep 0.5
  puts <<-"CAL"

==================
= send to Google =
==================

CAL
  sleep 0.5

  require_relative 'lib/calelib'
  cal = GCal.new(config[:calendar_id])
  
  hash.each{|date, queries|
    puts date.offset
    puts date.to_s,""
    sleep 0.3
    queries.each{|query|
      puts query,""
      cal.insert_event(query)
      sleep 0.1
    }
  }
      
end
