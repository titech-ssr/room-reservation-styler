require 'test/unit'
require 'pp'
require 'yaml'

require_relative '../lib/parse'

Dir.chdir "test/"

class Conf
  HTML    = Oga.parse_html(File.read("test.html")) rescue (->(){puts $!; exit 1}).()
  Config  = YAML.load_file("config.yaml")
end

class To_yaml_test < Test::Unit::TestCase

  class << self
    def startup
    end
    
    def shutdown
    end
  end

  test "date room pair, date test" do
    date_room_pair(Conf::HTML, {timezone:'JST'}).each{|key, val|
      assert_equal(DateTime, key.class)
    }
  end

  test "select_room_reservs test" do
    f = ->(room:"", circle:"", responsible:"", start:1, range:1){ circle == Conf::Config[:circle] }
    pair = date_room_pair(Conf::HTML, {timezone:'JST'}).map{|date, rooms|
      [date, rooms.map{|room| select_room_reservs(room, f)}.to_h]
    }.to_h.each{|date, rooms|
      rooms.each do |room, resvs|
        assert_equal(Room, room.class)
        resvs.each{|resv| 
          assert_equal(Conf::Config[:circle], resv.circle)    # test circle name
          assert_true(1 <= resv.start && resv.start <= 13)    # test start class time
          assert_true(0 <= resv.range && resv.range <= 12)    # test class range
        }
      end
    }

    #puts pair.to_yaml
  end
    

end
