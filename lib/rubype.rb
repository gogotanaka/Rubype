require 'rubype/ordinal'

# Builtin Contracts
class  Any;     end
module Boolean; end
TrueClass.send(:include, Boolean)
FalseClass.send(:include, Boolean)

class Module
  private
    # @return [Module]
    def __rubype__
      prepend (@__rubype__ = Module.new) unless @__rubype__
      @__rubype__
    end

    # @param meth [Symbol]
    # @param type_info_hash [Hash] { [ArgInfo_1, ArgInfo_2, ... ArgInfo_n] => RtnInfo }
    # @return self
    def typesig(meth, type_info_hash)
      ::Rubype.send(:define_typed_method, self, meth, type_info_hash, __rubype__)
      self
    end
end

class Method
  # @return [Hash]: { [ArgInfo_1, ArgInfo_2, ... ArgInfo_n] => RtnInfo }
  def type_info
    if methods_hash = Rubype.typed_method_info[owner]
      methods_hash[name]
    end
  end

  # @return [Array<Class, Symbol>]: [ArgInfo_1, ArgInfo_2, ... ArgInfo_n]
  def arg_types
    type_info.first.first if type_info
  end

  # @return [Class, Symbol]: RtnInfo
  def return_type
    type_info.first.last if type_info
  end
end

module Rubype
  class ArgumentTypeError < ::TypeError; end
  class ReturnTypeError   < ::TypeError; end
  @@typed_method_info = Hash.new({})

  class << self
    def typed_method_info
      @@typed_method_info
    end

    private
       # @param caller [Object]
       # @param type_info_hash [Hash] { [ArgInfo_1, ArgInfo_2, ... ArgInfo_n] => RtnInfo }
       # @param module [Module]
      def define_typed_method(owner, meth, type_info_hash, __rubype__)
        arg_types, rtn_type = *strip_type_info(type_info_hash)
        @@typed_method_info[owner][meth] = {
          arg_types => rtn_type
        }
        __rubype__.send(:define_method, meth) do |*args, &block|
          ::Rubype.send(:assert_arg_type, self, meth, args, arg_types, caller)
          rtn = super(*args, &block)
          ::Rubype.send(:assert_trn_type, self, meth, rtn, rtn_type, caller)
          rtn
        end
      end

      # @param type_info_hash [Hash] { [ArgInfo_1, ArgInfo_2, ... ArgInfo_n] => RtnInfo }
      # @return arg_types [Array<Class, Symbol>], rtn_type [Class, Symbol]
      def strip_type_info(type_info_hash)
        arg_types, rtn_type = type_info_hash.first
        [arg_types, rtn_type]
      end

      # @param caller [Module]
      # @param meth [Symbol]
      # @param args [Array<Object>]
      # @param type_infos [Array<Class, Symbol>]
      # @params caller_trace [Array<String>]
      def assert_arg_type(meth_caller, meth, args, type_infos, caller_trace)
        args.zip(type_infos).each.with_index(1) do |(arg, type_info), i|
          unless type_check(arg, type_info)
            raise ArgumentTypeError,
              error_mes("#{meth_caller.class}##{meth}'s #{i}#{ordinal(i)} argument", type_info, arg, caller_trace)
          end
        end
      end

      # @param caller [Module]
      # @param rtn [Object]
      # @param type_info [Class, Symbol]
      # @params caller_trace [Array<String>]
      def assert_trn_type(meth_caller, meth, rtn, type_info, caller_trace)
        unless type_check(rtn, type_info)
          raise ReturnTypeError,
            error_mes("#{meth_caller.class}##{meth}'s return", type_info, rtn, caller_trace)
        end
      end

      # @param obj [Object]
      # @param type_info [Class, Symbol]
      # @return [Symbol]
      def type_check(obj, type_info)
        case type_info
        when Module; (obj.is_a?(type_info) || type_info == Any)
        when Symbol; (obj.respond_to?(type_info))
        end
      end

      # @return [String]
      def error_mes(target, expected, actual, caller_trace)
        expected_mes = case expected
        when Module; expected
        when Symbol; "respond to :#{expected}"
        end
        <<-ERROR_MES
for #{target}
Expected: #{expected_mes},
Actual:   #{actual.inspect}

#{caller_trace.join("\n")}
        ERROR_MES
      end
  end
end
