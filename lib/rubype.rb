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

    # @param type_info_hash [Hash] { method_name: [ArgInfo1, ArgInfo2, ... ArgInfon => RtnInfo] }
    # @return self
    def typesig type_info_hash
      meth, arg_types, rtn_type = *::Rubype.send(:strip_type_info, type_info_hash)

      __rubype__.send(:define_method, meth) do |*args, &block|
        ::Rubype.send(:assert_arg_type, self, meth, args, arg_types)
        rtn = super(*args, &block)
        ::Rubype.send(:assert_trn_type, self, meth, rtn, rtn_type)
        rtn
      end
      self
    end
end

module Rubype
  class ArgumentTypeError < ::TypeError; end
  class ReturnTypeError   < ::TypeError; end

  class << self
    private
      # @param type_info_hash [Hash] { method_name: [ArgInfo1, ArgInfo2, ... ArgInfon => RtnInfo] }
      # @return method_name [Symbol], arg_types [Array<Class, Symbol>], rtn_type [Class, Symbol]
      def strip_type_info(type_info_hash)
        meth, arr = type_info_hash.first
        *arg_types, type_pair = arr
        [meth, arg_types << type_pair.first[0], type_pair.first[1]]
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
