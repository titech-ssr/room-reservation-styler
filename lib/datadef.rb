class Room
  attr_reader :room, :url

  def initialize(room: "", url:"")
    @room = room
    @url  = url
  end
end

class Reservation
  attr_reader :circle, :responsible, :start, :range

  def initialize(circle:"", responsible:"", start:1, range:1)
    @circle       = circle
    @responsible  = responsible
    @start        = start
    @range        = range
  end
end
