require 'oga'
require 'pp'
require 'yaml'
require 'date'

require_relative 'datadef'

module ToAdoc
  Start = %w[9:00 9:45 10:45 11:30 13:20 14:05 15:05 15:50 16:50 17:35 18:30 19:15 昼休み].unshift(0)
  Fin   = %w[9:45 10:30 11:30 12:15 14:05 15:50 15:50 16:35 17:35 18:20 19:15 20:00].unshift(0)
  WDay = %w[日 月 火 水 木 金 土]
end


def to_adoc(hash:{}, circle:"")
"""
= 部屋予約
#{DateTime.now}
#{circle}

""" +
  hash.map{|date, rooms|
    rooms = rooms.map{|room, resvs|
      "** #{room.room}\n" +
      resvs.map{|resv| "*** " + ToAdoc::Start[s=resv.start] + (s==13 ? "" : ?~ + ToAdoc::Fin[s + resv.range-1])}.join("\n")
    }.join("\n")
    date.strftime("* %Y/%m/%d (#{ToAdoc::WDay[date.wday]})\n") + rooms
  }.join("\n")
end
