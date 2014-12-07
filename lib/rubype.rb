require "rubype/rubype"

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

  def typesig(hash)
    meth = hash.keys.first
    *arg_types, type_pair = hash.values.first

    __rubype__.send(:define_method, meth) do |*args, &block|
      ::Rubype.assert_arg_type(meth, args, arg_types << type_pair.keys.first)
      rtn = super(*args, &block)
      ::Rubype.assert_trn_type(meth, rtn, type_pair.values.first)
      rtn
    end
    self
  end
end

module Rubype
  class << self
    def assert_arg_type(meth, args, klasses)
      args.each_with_index do |arg, i|
        if wrong_type?(arg, klasses[i])
          raise ArgumentError, "Wrong type of argument, type of #{arg.inspect} should be #{klasses[i]}"
        end
      end
    end

    def assert_trn_type(meth, rtn, klass)
      if wrong_type?(rtn, klass)
        raise TypeError, "Expected #{meth} to return #{klass} but got #{rtn.inspect} instead"
      end
    end

    def wrong_type?(obj, klass)
      !(obj.is_a?(klass) || klass == Any)
    end
  end
end
