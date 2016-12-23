require 'oga'
require 'pp'
require 'yaml'
require 'date'

require_relative 'datadef'

def to_adoc(hash:{}, circle:"")
"""
= 部屋予約
#{DateTime.now}
#{circle}

""" +
  hash.map{|date, rooms|
    rooms = rooms.map{|room, resvs|
      "** #{room.room}\n" +
      resvs.map{|resv| "*** " + Times::Start[s=resv.start] + (s==13 ? "" : ?~ + Times::Fin[s + resv.range-1])}.join("\n")
    }.join("\n")
    date.strftime("* %Y/%m/%d (#{Times::WDay[date.wday]})\n") + rooms
  }.join("\n")
end
