require 'test/unit'
require 'pp'
require 'yaml'
require 'oga'
require 'date'

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

  test "room reservation date test" do
    tds = Conf::HTML.xpath("//tbody/tr/td[@colspan='16' and @style='border: medium none; padding: 6px 4px;']")
    assert_not_nil(tds)
    assert_false(tds.size.zero?)
    tds.each{|td|
      assert_equal("h5", (h5=td.children.first).name)
      assert_equal(Date, Date.parse(h5.text).class)
    }
  end

  test "room name test" do
    spans = Conf::HTML.xpath("//tbody/tr/td/span[@class='showAtPrint']/span")
    assert_not_nil(spans)
    assert_false(spans.size.zero?)
    spans.each{|span|
      assert_match(/[A-Z]\d{3}/, span.text)
    }
  end

  test "room url test" do
    as = Conf::HTML.xpath("//tbody/tr/td/span[@class='hideAtPrint']/a")
    assert_not_nil(as)
    assert_false(as.size.zero?)
    as.each{|a|
      assert_true(URI.parse(a.get("href")).kind_of?(URI::HTTP))
    }
  end

  test "get reservation test" do
    tds = Conf::HTML.xpath("//tbody/tr/td[@class='tdN']")
    assert_not_nil(tds);
    assert_false(tds.size.zero?)

    tds.each{|td|
    
      col = td.get("colspan").to_i
      jig = td.get("jigen").to_i
      assert_true( 1<= jig && jig <= 13 )
      assert_true( 0<= col && col <= 12 )

      data_content = nil
      unless div = td.at_xpath("div") then
        assert_not_nil(data_content = td.get("data-content"))
      else
        assert_not_nil(data_content = div.get("data-content"))
      end

      data_content = Oga.parse_html(data_content)

      assert_not_empty(data_content.at_xpath("h4").text)
      assert_not_empty(data_content.at_xpath("div[@style='margin-bottom:4px']/span").text)
    }
  end
end
