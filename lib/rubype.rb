require_relative 'rubype/version'
require_relative 'rubype/ordinalize'
require 'rubype/rubype'

module Rubype
  @@typed_method_info = Hash.new({})
  class ArgumentTypeError < ::TypeError; end
  class ReturnTypeError   < ::TypeError; end
  class << self
    def define_typed_method(owner, meth, type_info_hash, __rubype__)
      arg_types, rtn_type = *type_info_hash.first

      @@typed_method_info[owner][meth] = { arg_types => rtn_type }

      method_visibility = get_method_visibility(owner, meth)
      __rubype__.send(:define_method, meth) do |*args, &block|
        caller_trace = caller_locations(1, 5)
        ::Rubype.assert_arg_type(self, meth, args, arg_types, caller_trace)
        super(*args, &block).tap { |rtn| ::Rubype.assert_rtn_type(self, meth, rtn, rtn_type, caller_trace) }
      end
      __rubype__.send(method_visibility, meth)
    end

    def get_method_visibility(owner, meth)
      case
      when owner.private_method_defined?(meth)
        :private
      when owner.protected_method_defined?(meth)
        :protected
      else
        :public
      end
    end

    def assert_arg_type(meth_caller, meth, args, type_infos, caller_trace)
      args.each_with_index do |arg, i|
        type_info = type_infos[i]
        next if match_type?(arg, type_info)
        raise ArgumentTypeError,
          error_mes("#{meth_caller.class}##{meth}'s #{ordinalize(i + 1)} argument", type_info, arg, caller_trace)
      end
    end

    def assert_rtn_type(meth_caller, meth, rtn, type_info, caller_trace)
      return if match_type?(rtn, type_info)
      raise ReturnTypeError,
        error_mes("#{meth_caller.class}##{meth}'s return", type_info, rtn, caller_trace)
    end

    def typed_method_info
      @@typed_method_info
    end

    private

      def expected_mes(expected)
        case expected
        when Module then expected
        when Symbol then "respond to :#{expected}"
        end
      end

      def error_mes(target, expected, actual, caller_trace)
        <<-ERROR_MES
for #{target}
Expected: #{expected_mes(expected)},
Actual:   #{actual.inspect}

#{caller_trace.join("\n")}
        ERROR_MES
      end
    end

end

require_relative 'rubype/core_ext'
