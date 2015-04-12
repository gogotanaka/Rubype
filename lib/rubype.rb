require 'rubype/ordinal'
# === Rubype core === #
class Module
  private
    def __rubype__
      prepend (@__rubype__ = Module.new) unless @__rubype__
      @__rubype__
    end
    # typesig :__rubype__, [] => Rubype

    def typesig(meth, type_info_hash)
      ::Rubype.define_typed_method(self, meth, type_info_hash, __rubype__)
      self
    end
    # typesig :typesig, [Symbol, Hash] => Module
end

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
        super(*args, &block).tap do |rtn|
          ::Rubype.assert_rtn_type(self, meth, rtn, rtn_type, caller)
        end
      end
    end

    def assert_arg_type(meth_caller, meth, args, type_infos, caller_trace)
      args.zip(type_infos).each.with_index(1) do |(arg, type_info), i|
        unless match_type?(arg, type_info)
          raise ArgumentTypeError,
            error_mes("#{meth_caller.class}##{meth}'s #{i}#{ordinal(i)} argument", type_info, arg, caller_trace)
        end
      end
    end

    def assert_rtn_type(meth_caller, meth, rtn, type_info, caller_trace)
      unless match_type?(rtn, type_info)
        raise ReturnTypeError,
          error_mes("#{meth_caller.class}##{meth}'s return", type_info, rtn, caller_trace)
      end
    end

    def typed_method_info
      @@typed_method_info
    end

    private
      def match_type?(obj, type_info)
        case type_info
        when Module; (obj.is_a?(type_info) || type_info == Any)
        when Symbol; (obj.respond_to?(type_info))
        end
      end

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
# === end (only 79 lines :D)=== #

# Builtin Contracts
class  Any;     end
module Boolean; end
TrueClass.send(:include, Boolean)
FalseClass.send(:include, Boolean)

class Method
  def type_info
    if methods_hash = Rubype.typed_method_info[owner]
      methods_hash[name]
    end
  end
  typesig :type_info, [] => Hash

  def arg_types
    type_info.first.first if type_info
  end
  typesig :arg_types, [] => Array

  def return_type
    type_info.first.last if type_info
  end
  typesig :arg_types, [] => Any
end
