require 'test_helper'

class GelfFormatterTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONF = %[
  ]

  def create_driver(conf = CONF)
    Fluent::Test::Driver::Formatter.new(Fluent::Plugin::GelfFormatter).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_true d.instance.use_record_host
    assert_false d.instance.add_msec_time
  end

  def test_format
    d = create_driver
    time = Time.now.to_i
    formatted = d.format('tag', time, {"message" => "gelf"})
    expected = Oj.dump({"_tag"          => "tag",
                          "timestamp"     => time,
                          "short_message" => "gelf",
                          "version"       => "1.0"}) + "\0"
    assert_equal expected, formatted
  end
end
