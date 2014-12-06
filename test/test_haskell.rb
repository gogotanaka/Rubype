require 'minitest_helper'
class TypePair
  def to_s
    "#{last_arg_type} >= #{rtn_type}"
  end
end
class TestHaskell < MiniTest::Unit::TestCase
  def setup
    @string  = 'str'
    @numeric = 1
    @symbol  = :test
    @array   = [1, 2, 3]
    @hash    = { test: :hash }
  end

  def test_type_list
    assert_equal_to_s "Numeric >= Numeric", Numeric >= Numeric
    assert_equal_to_s "Numeric >= Array", Numeric >= Array
    assert_equal_to_s "Array >= String", Array >= String
  end

  def test_correct_type
    assert_correct_type [Numeric >= Numeric], [@numeric], @numeric
    assert_correct_type [Numeric >= Array  ], [@numeric], @array
    assert_correct_type [Numeric >= String ], [@numeric], @string
    assert_correct_type [Numeric >= Hash   ], [@numeric], @hash
    assert_correct_type [Numeric >= Symbol ], [@numeric], @symbol
    assert_correct_type [Numeric >= Boolean], [@numeric], true
    assert_correct_type [Numeric >= Boolean], [@numeric], false

    assert_correct_type [Boolean, Numeric >= Numeric], [true, @numeric], @numeric
    assert_correct_type [Boolean, Array   >= Array  ], [true, @array  ], @array
    assert_correct_type [Boolean, String  >= String ], [true, @string ], @string
    assert_correct_type [Boolean, Hash    >= Hash   ], [true, @hash   ], @hash
    assert_correct_type [Boolean, Symbol  >= Symbol ], [true, @symbol ], @symbol
  end

  def test_wrong_return_type
    assert_wrong_rtn [Numeric >= Numeric], [@numeric], @array
    assert_wrong_rtn [Numeric >= Numeric], [@numeric], @string
    assert_wrong_rtn [Numeric >= Numeric], [@numeric], @hash
    assert_wrong_rtn [Numeric >= Numeric], [@numeric], @symbol
    assert_wrong_rtn [Numeric >= Numeric], [@numeric], true

    assert_wrong_rtn [Numeric, Numeric >= Numeric], [@numeric, @numeric], @array
    assert_wrong_rtn [Numeric, Numeric >= Numeric], [@numeric, @numeric], @string
    assert_wrong_rtn [Numeric, Numeric >= Numeric], [@numeric, @numeric], @hash
    assert_wrong_rtn [Numeric, Numeric >= Numeric], [@numeric, @numeric], @symbol
    assert_wrong_rtn [Numeric, Numeric >= Numeric], [@numeric, @numeric], true
  end

  def test_wrong_args_type
    assert_wrong_arg [Numeric >= Numeric], [@array ], @numeric
    assert_wrong_arg [Numeric >= Numeric], [@string], @numeric
    assert_wrong_arg [Numeric >= Numeric], [@hash  ], @numeric
    assert_wrong_arg [Numeric >= Numeric], [@symbol], @numeric
    assert_wrong_arg [Numeric >= Numeric], [true   ], @numeric

    assert_wrong_arg [Numeric, Numeric >= Numeric], [@numeric, @array ], @numeric
    assert_wrong_arg [Numeric, Numeric >= Numeric], [@numeric, @string], @numeric
    assert_wrong_arg [Numeric, Numeric >= Numeric], [@numeric, @hash  ], @numeric
    assert_wrong_arg [Numeric, Numeric >= Numeric], [@numeric, @symbol], @numeric
    assert_wrong_arg [Numeric, Numeric >= Numeric], [@numeric, true   ], @numeric
  end

  def test_any
    assert_correct_type [Any >= Any], [@array ], @numeric
    assert_correct_type [Any >= Any], [@string], @numeric
    assert_correct_type [Any >= Any], [@hash  ], @numeric
    assert_correct_type [Any >= Any], [@symbol], @numeric

    assert_correct_type [Any, Any >= Any], [@numeric, @array ], @numeric
    assert_correct_type [Any, Any >= Any], [@numeric, @string], @numeric
    assert_correct_type [Any, Any >= Any], [@numeric, @hash  ], @numeric
    assert_correct_type [Any, Any >= Any], [@numeric, @symbol], @numeric
  end

  private
    def assert_equal_to_s(str, val)
      assert_equal str, val.to_s
    end

    def assert_correct_type(type_list, args, val)
      assert_equal val, define_test_method(type_list, args, val).call(*args)
    end

    def assert_wrong_arg(type_list, args, val)
      assert_raises(ArgumentError) { define_test_method(type_list, args, val).call(*args) }
    end

    def assert_wrong_rtn(type_list, args, val)
      assert_raises(TypeError) { define_test_method(type_list, args, val).call(*args) }
    end

    def define_test_method(type_list, args, val)
      klass = Class.new.class_eval <<-RUBY_CODE
        def call(#{arg_literal(args.count)})
          #{obj_literal(val)}
        end
        type #{type_list.map(&:to_s).join(',')}, :call
      RUBY_CODE

      klass.new
    end

    def obj_literal(obj)
      "ObjectSpace._id2ref(#{obj.__id__})"
    end

    def arg_literal(count)
      ('a'..'z').to_a[0..count-1].join(',')
    end
end
