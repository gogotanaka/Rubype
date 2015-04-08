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
  def type_info
    if methods_hash = Rubype.typed_method_info[owner]
      methods_hash[name]
    end
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
      def define_typed_method(meth_caller, meth, type_info_hash, __rubype__)
        arg_types, rtn_type = *strip_type_info(type_info_hash)
        @@typed_method_info[meth_caller][meth] = {
          arg_types => rtn_type
        }
        __rubype__.send(:define_method, meth) do |*args, &block|
          ::Rubype.send(:assert_arg_type, meth_caller, meth, args, arg_types)
          rtn = super(*args, &block)
          ::Rubype.send(:assert_trn_type, meth_caller, meth, rtn, rtn_type)
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
      def assert_arg_type(caller, meth, args, type_infos)
        args.zip(type_infos).each.with_index(1) do |(arg, type_info), i|
          case type_check(arg, type_info)
          when :need_correct_class
            raise ArgumentTypeError,
              "Expected #{caller.class}##{meth}'s #{i}th argument to be #{type_info} but got #{arg.inspect} instead"
          when :need_correct_method
            raise ArgumentTypeError,
              "Expected #{caller.class}##{meth}'s #{i}th argument to have method ##{type_info} but got #{arg.inspect} instead"
          end
        end
      end

      # @param caller [Module]
      # @param rtn [Object]
      # @param type_info [Class, Symbol]
      def assert_trn_type(caller, meth, rtn, type_info)
        case type_check(rtn, type_info)
        when :need_correct_class
          raise ReturnTypeError,
            "Expected #{caller.class}##{meth} to return #{type_info} but got #{rtn.inspect} instead"
        when :need_correct_method
          raise ReturnTypeError,
            "Expected #{caller.class}##{meth} to return object which has method ##{type_info} but got #{rtn.inspect} instead"
        end
      end

      # @param obj [Object]
      # @param type_info [Class, Symbol]
      # @return [Symbol]
      def type_check(obj, type_info)
        case type_info
        when Module
          :need_correct_class unless (obj.is_a?(type_info) || type_info == Any)
        when Symbol
          :need_correct_method unless (obj.respond_to?(type_info))
        end
      end
  end
end
