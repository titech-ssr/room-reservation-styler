require 'yaml'
require 'pp'
require 'mathn'
require 'fileutils'

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'


require_relative 'calelib'
require_relative 'datadef'

TZ = "Japan"

def to_query(date:nil, rooms:[], start:1, range:1)
  start_ = Times::Start[start].split(?:).map(&:to_i)
  fin_   = Times::Fin[start + range - 1].split(?:).map(&:to_i)

  if start != 13 then
    day_time_start = (date + start_.first/24 + start_.last/(24*60)).iso8601
    day_time_fin   = (date + fin_.first/24 + fin_.last./(24*60)).iso8601 
    return {
              summary: rooms.join("\n"),
              start:{
                date_time: day_time_start,
                time_zone: TZ
              },
              end:{
                date_time: day_time_fin,
                time_zone: TZ
              }
          }
  else
    day_time_start = (date + 12/24+15/(24*60)).iso8601
    day_time_fin   = (date + 13/24+20/(24*60)).iso8601 
    return {
             summary: rooms.join("\n"),
             description: "昼休み",
             start:{
               date_time: day_time_start,
               time_zone: TZ
             },
             end:{
               date_time: day_time_fin,
               time_zone: TZ
             }
         }
  end
end

