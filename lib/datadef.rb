# Room class
#
# @attr [String] room room name
# @attr [String] url  room pdf url
class Room
  attr_reader :room, :url

  def initialize(room: "", url:"")
    @room = room
    @url  = url
  end

end

# Room Reservation class
#
# @attr [String] circle reserver circle name
# @attr [String] responsible person in charge to reserve room
# @attr [Fixnum] start start time
# @attr [Fixnum] range reservation time range
class Reservation
  attr_reader :circle, :responsible, :start, :range

  def initialize(circle:"", responsible:"", start:1, range:1)
    @circle       = circle
    @responsible  = responsible
    @start        = start
    @range        = range
  end
end

# Times module
# map number -> class start time, class end time, string of day of week
#
# @const [Array] Start po
module Times
  # num -> class start time
  Start = %w[9:00 9:45 10:45 11:30 13:20 14:05 15:05 15:50 16:50 17:35 18:30 19:15 昼休み].unshift(0)

  # num -> class end time
  Fin   = %w[9:45 10:30 11:30 12:15 14:05 15:50 15:50 16:35 17:35 18:20 19:15 20:00].unshift(0)

  # num -> day string
  WDay = %w[日 月 火 水 木 金 土]
end
