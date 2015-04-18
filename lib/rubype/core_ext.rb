module Boolean; end
TrueClass.send(:include, Boolean)
FalseClass.send(:include, Boolean)
Any = BasicObject

class Module
  private

  def __rubype__
    prepend (@__rubype__ = Module.new) unless @__rubype__
    @__rubype__
  end

  def typesig(meth, type_info_hash)
    ::Rubype.define_typed_method(self, meth, type_info_hash, __rubype__)
    self
  end
end

class Method
  def type_info
    Rubype.typed_method_info[owner][name]
  end
  typesig :type_info, [] => Hash

  def arg_types
    type_info.first.first if type_info
  end
  typesig :arg_types, [] => Array

  def return_type
    type_info.first.last if type_info
  end
  typesig :arg_types, [] => Any
end
