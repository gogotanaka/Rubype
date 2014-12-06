class TypePair < Struct.new(:last_arg_type, :rtn_type); end

class Module
  def >=(r)
    TypePair.new(self, r)
  end
end
