require 'oga'
require 'pp'
require 'yaml'
require 'date'

require_relative 'datadef'

# select room preservations
#
# @param [Oga] tr tbody > tr that has room preservations 
# @return [void]
def select_room_reservs(tr, is_target)
  room  = Room.new(
    room: tr.at_xpath("td/span[@class='showAtPrint']/span").text,
    url:  tr.at_xpath("td/span[@class='hideAtPrint']/a").get("href")
  )

  reservs = tr.css("td.tdN").map{|reserv| 
    next if ((start = reserv.get("jigen").to_i) != 13 && !(tmp=reserv.get("colspan")) )
    td_content = Oga.parse_html( (reserv.at_xpath("div")||reserv).get("data-content"))

    circle      = td_content.at_xpath("h4").text
    responsible = td_content.at_xpath("div[@style='margin-bottom:4px']/span").text
    range       = tmp.to_i
    Reservation.new( 
      circle:     circle, 
      responsible:responsible, 
      start:      start, 
      range:      range 
    ) if is_target.(
      room:       room,
      circle:     circle, 
      responsible:responsible, 
      start:      start, 
      range:      range 
    )
  }.compact

  return room, reservs
end

# Make date room pair from html
# @param html [Oga]
# @param config [Hash] config should be a Hash for ex. { :timezone => "JST" }
# @return [Hash] returns { date => [rooms] } pair
def date_room_pair(html, config)

  trs   = html.css("table.table.table-bordered.ui-selectable tbody tr")
  trs
    .select{|n| Oga::XML::Element === n}
    .inject([{}, nil]){|(h,date), tr|
      if date_node = tr.at_xpath("td/h5") then
        date = DateTime.parse(date_node.text + " 0:00 #{config[:timezone]}")
      else
        next([h, date]) unless date
        h[date] = (h[date]||[]) << tr
      end
      [h, date]
    }
    .first
end


     
