require_relative 'ordinalize'
require 'rubype/rubype'

class Rubype::Contract
  attr_accessor :arg_types, :rtn_type

  def info
    { @arg_types => @rtn_type }
  end
end
