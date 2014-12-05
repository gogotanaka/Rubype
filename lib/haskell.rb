require 'haskell/type_list'

module Haskell
  class << self
    def assert_arg_type(meth, args, klasses)

      args.each_with_index do |arg, i|
        if wrong_type?(arg, klasses[i])
          raise ArgumentError, "Wrong type of argument, type of #{arg.inspect} should be #{klasses[i]}"
        end
      end
    end

    def assert_rtn_type(meth, rtn, klass)
      if wrong_type?(rtn, klass)
        raise TypeError, "Expected #{meth} to return #{klass} but got #{rtn.inspect} instead"
      end
    end

    def wrong_type?(obj, klass)
      !(obj.is_a?(klass) || klass == Any)
    end
  end
end

class Module
  private
    def __haskell__
      prepend (@__haskell__ = Module.new) unless @__haskell__
      @__haskell__
    end

    def type(type_list, meth)
      __haskell__.send(:define_method, meth) do |*args, &block|
        ::Haskell.assert_arg_type(meth, args, type_list.args)
        rtn = super(*args, &block)
        ::Haskell.assert_rtn_type(meth, rtn, type_list.rtn)
        rtn
      end
      self
    end
end

class Any; end
