module Haskell
  module AssertRtnType
    extend Base

    def self.execute(meth, rtn, klass)
      if wrong_type?(rtn, klass)
        raise TypeError, "Expected #{meth} to return #{klass} but got #{rtn.inspect} instead"
      end
    end

    def self.wrong_type?(obj, klass)
      !(obj.is_a?(klass) || klass == Any)
    end

  end
end
