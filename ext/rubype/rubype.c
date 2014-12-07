#include "rubype.h"

VALUE rb_mRubype, rb_cAny, rb_mBoolean, rb_cTypePair;

#define STR2SYM(x) ID2SYM(rb_intern(x))

static VALUE
rb_mod_prepend(int argc, VALUE *argv, VALUE module)
{
  int i;
  ID id_prepend_features, id_prepended;

  CONST_ID(id_prepend_features, "prepend_features");
  CONST_ID(id_prepended, "prepended");
  for (i = 0; i < argc; i++)
    Check_Type(argv[i], T_MODULE);
    while (argc--) {
      rb_funcall(argv[argc], id_prepend_features, 1, module);
      rb_funcall(argv[argc], id_prepended, 1, module);
    }

  return module;
}

void
Init_rubype(void)
{
  // rb_mRubype  = rb_define_module("Rubype");
  // rb_cAny     = rb_define_class("Any", rb_cObject);
  // rb_mBoolean = rb_define_module("Boolean");
  // rb_include_module(rb_cTrueClass, rb_mBoolean);
  // rb_include_module(rb_cFalseClass, rb_mBoolean);
  // rb_define_class(
  //   "TypePair",
  //   rb_funcall(rb_cStruct, rb_intern("new"), 2, STR2SYM("last_arg_type"), STR2SYM("rtn_type"))
  // );
  rb_define_method(rb_cModule, "prepend", rb_mod_prepend, -1);
}
