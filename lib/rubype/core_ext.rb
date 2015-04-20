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
    Rubype.typed_methods[owner][name].info
  end
  typesig :type_info, [] => Hash

  def arg_types
    Rubype.typed_methods[owner][name].arg_types
  end
  typesig :arg_types, [] => Array

  def return_type
    Rubype.typed_methods[owner][name].rtn_type
  end
  typesig :return_type, [] => Any
end
