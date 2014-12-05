require 'haskell/entity'
require 'haskell/type_list'
require 'pry'

module Kernel
  def Haskell(&block)
    Haskell::Entity.eval(&block)
  end
end
