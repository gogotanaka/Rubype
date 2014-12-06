require 'haskell/type_list'
require 'haskell/base'
require 'haskell/assert_arg_type'
require 'haskell/assert_rtn_type'

module Haskell; end

# New Class(Type)
class  Any;     end
module Boolean; end
TrueClass.send(:include, Boolean)
FalseClass.send(:include, Boolean)

class Module
  private
    def __haskell__
      prepend (@__haskell__ = Module.new) unless @__haskell__
      @__haskell__
    end

    def type(type_list, meth)
      __haskell__.send(:define_method, meth) do |*args, &block|
        ::Haskell::AssertArgType.execute(meth, args, type_list.args)
        rtn = super(*args, &block)
        ::Haskell::AssertRtnType.execute(meth, rtn, type_list.rtn)
        rtn
      end
      self
    end
end
