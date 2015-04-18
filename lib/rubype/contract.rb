require_relative 'ordinalize'

class Rubype::ArgumentTypeError < ::TypeError; end
class Rubype::ReturnTypeError   < ::TypeError; end
class Rubype::Contract
  attr_accessor :arg_types, :rtn_type
  def initialize(arg_types, rtn_type, owner, meth)
    @meth = meth
    @owner = owner
    @arg_types = arg_types
    @rtn_type = rtn_type
    @trace = caller_locations(1, 5)
  end

  def info
    { @arg_types => @rtn_type }
  end

  def assert_rtn_type(meth_caller, rtn)
    return if match_type?(rtn, @rtn_type)
    raise Rubype::ReturnTypeError,
          error_mes("#{meth_caller.class}##{@meth}'s return", @rtn_type, rtn, @trace)
  end

  def assert_arg_types(meth_caller, args)
    args.size.times do |i|
      arg = args[i]
      type = @arg_types[i]
      next if match_type?(arg, type)
      raise Rubype::ArgumentTypeError,
            error_mes("#{meth_caller.class}##{@meth}'s #{ordinalize(i + 1)} argument", type, arg, @trace)
    end
  end

  private
  def error_mes(target, expected, actual, caller_trace)
    <<-ERROR_MES
for #{target}
Expected: #{expected_mes(expected)},
Actual:   #{actual.inspect}

#{caller_trace.join("\n")}
    ERROR_MES
  end

  def match_type?(obj, type_info)
    case type_info
    when Module then obj.is_a?(type_info)
    when Symbol then obj.respond_to?(type_info)
    end
  end

  def expected_mes(expected)
    case expected
    when Module then expected
    when Symbol then "respond to :#{expected}"
    end
  end
end
