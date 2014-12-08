# Builtin Contracts
class  Any;     end
module Boolean; end
TrueClass.send(:include, Boolean)
FalseClass.send(:include, Boolean)

class Module
  private
  def __rubype__
    prepend (@__rubype__ = Module.new) unless @__rubype__
    @__rubype__
  end

  # @param hash [Hash] {method_name: [ArgClass1, ArgClass2, ... ArgClassn => RtnClass]}
  def typesig(hash)
    meth = hash.keys.first
    *arg_types, type_pair = hash.values.first

    __rubype__.send(:define_method, meth) do |*args, &block|
      ::Rubype.send(:assert_arg_type, self, meth, args, arg_types << type_pair.keys.first)
      rtn = super(*args, &block)
      ::Rubype.send(:assert_trn_type, self, meth, rtn, type_pair.values.first)
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

    # @param caller [Module]
    # @param meth [Symbol]
    # @param args [Array<Object>]
    # @param type_infos [Array<Class, Symbol>]
    def assert_arg_type(caller, meth, args, type_infos)
      args.each_with_index do |arg, i|
        case type_check(arg, type_infos[i])
        when :need_correct_class
          raise ArgumentTypeError,
            "Expected #{caller.class}##{meth}'s #{i+1}th argument to be #{type_infos[i]} but got #{arg.inspect} instead"
        when :need_correct_method
          raise ArgumentTypeError,
            "Expected #{caller.class}##{meth}'s #{i+1}th argument to have method ##{type_infos[i]} but got #{arg.inspect} instead"
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
          "Expected #{caller.class}##{meth} to have method ##{type_info} but got #{rtn.inspect} instead"
      end
    end

    # @param obj [Object]
    # @param type_info [Class, Symbol]
    # @return [Symbol]
    def type_check(obj, type_info)
      if type_info.is_a?(Module) && !(obj.is_a?(type_info) || type_info == Any)
        :need_correct_class
      elsif type_info.is_a?(Symbol) && !(obj.respond_to?(type_info))
        :need_correct_method
      end
    end
  end
end
