require_relative 'ordinalize'
require 'rubype/rubype'

class Rubype::Contract
  attr_accessor :arg_types, :rtn_type
  def initialize(arg_types, rtn_type, owner, meth)
    @owner = owner
    @meth = meth
    @arg_types = arg_types
    @rtn_type = rtn_type
  end

  def info
    { @arg_types => @rtn_type }
  end
end
