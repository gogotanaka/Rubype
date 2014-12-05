# '>=' is left-associative ...
# LISP or Hash is better?
class TypeList
  attr_accessor :list

  def initialize(l, r)
    @list = [l, r]
  end

  def >=(r)
    @list << r
    self
  end

  def args
    @list[0..-2]
  end

  def rtn
    @list.last
  end

  def to_s
    @list.map(&:to_s).join(' -> ')
  end
end

class Module
  def >=(r)
    TypeList.new(self, r)
  end
end
