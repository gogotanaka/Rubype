#include "rubype.h"

VALUE rb_mRubype, rb_cAny, rb_mBoolean, rb_cTypePair;

#define STR2SYM(x) ID2SYM(rb_intern(x))

static VALUE
rb_init_type_pair(VALUE self, VALUE x)
{
  return rb_funcall(rb_cTypePair, rb_intern("new"), 2, self, x);
}

void
Init_rubype(void)
{
  rb_mRubype  = rb_define_module("Rubype");
  rb_cAny     = rb_define_class("Any", rb_cObject);
  rb_mBoolean = rb_define_module("Boolean");
  rb_include_module(rb_cTrueClass, rb_mBoolean);
  rb_include_module(rb_cFalseClass, rb_mBoolean);
  rb_define_class(
    "TypePair",
    rb_funcall(rb_cStruct, rb_intern("new"), 2, STR2SYM("last_arg_type"), STR2SYM("rtn_type"))
  );
  rb_define_method(rb_cModule, ">=", rb_init_type_pair, 1);
}
