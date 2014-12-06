module Haskell
  module AssertArgType
    extend Base

    def self.execute(meth, args, klasses)
      args.each_with_index do |arg, i|
        if wrong_type?(arg, klasses[i])
          raise ArgumentError, "Wrong type of argument, type of #{arg.inspect} should be #{klasses[i]}"
        end
      end
    end

  end
end
