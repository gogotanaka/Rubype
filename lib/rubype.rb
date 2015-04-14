require_relative 'rubype/version'

module Rubype
  @@typed_method_info = Hash.new({})
  class ArgumentTypeError < ::TypeError; end
  class ReturnTypeError   < ::TypeError; end
  class << self
    def define_typed_method(owner, meth, type_info_hash, __rubype__)
      arg_types, rtn_type = *type_info_hash.first

      @@typed_method_info[owner][meth] = { arg_types => rtn_type }

      __rubype__.send(:define_method, meth) do |*args, &block|
        ::Rubype.assert_arg_type(self, meth, args, arg_types, caller)
        super(*args, &block).tap { |rtn| ::Rubype.assert_rtn_type(self, meth, rtn, rtn_type, caller) }
      end
    end

    def assert_arg_type(meth_caller, meth, args, type_infos, caller_trace)
      args.zip(type_infos).each.with_index(1) do |(arg, type_info), i|
        next if match_type?(arg, type_info)
        raise ArgumentTypeError,
          error_mes("#{meth_caller.class}##{meth}'s #{i}#{ordinal(i)} argument", type_info, arg, caller_trace)
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
      def match_type?(obj, type_info)
        case type_info
        when Module then obj.is_a?(type_info)
        when Symbol then obj.respond_to?(type_info)
        end
      end

      def error_mes(target, expected, actual, caller_trace)
        expected_mes = case expected
                       when Module then expected
                       when Symbol then "respond to :#{expected}"
        end
        <<-ERROR_MES
for #{target}
Expected: #{expected_mes},
Actual:   #{actual.inspect}

#{caller_trace.join("\n")}
        ERROR_MES
      end

      # Borrowed from ActiveSupport::Inflector
      def ordinal(number)
        if (11..13).include?(number % 100)
          "th"
        else
          case number % 10
            when 1; "st"
            when 2; "nd"
            when 3; "rd"
            else    "th"
          end
        end
      end
  end
end

require_relative 'rubype/core_ext'