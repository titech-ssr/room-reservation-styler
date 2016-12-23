require 'test/unit'
require 'pp'
require 'yaml'

require_relative '../lib/parse'
require_relative '../lib/datadef'

Dir.chdir "test/"

class To_yaml_test < Test::Unit::TestCase

  class << self
    def startup
    end
    
    def shutdown
    end
  end
  
  test "equal resevation" do
    assert_true( Reservation.new(start:1, range:1) == Reservation.new(start:1, range:1) )
  end

end
