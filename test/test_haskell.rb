require 'minitest_helper'

class TestHaskell < MiniTest::Unit::TestCase
  def setup
  end

  def test_type_list
    assert_equal_to_s "Numeric -> Numeric", Numeric >= Numeric
    assert_equal_to_s "Numeric -> Numeric -> Array", Numeric >= Numeric >= Array
    assert_equal_to_s "Hash -> Symbol -> Numeric -> Array -> String", Hash >= Symbol >= Numeric >= Array >= String
  end

  private
    def assert_equal_to_s(str, val)
      assert_equal str, val.to_s
    end
end
