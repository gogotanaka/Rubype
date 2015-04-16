#include "rubype.h"

VALUE rb_mRubype, rb_cAny, rb_mBoolean;

#define STR2SYM(x) ID2SYM(rb_intern(x))
static ID id_is_a_p;
#define f_boolcast(x) ((x) ? Qtrue : Qfalse)

static VALUE
rb_rubype_match_type_p(VALUE rubype, VALUE obj, VALUE type_info)
{
  switch (TYPE(type_info)) {
    case T_SYMBOL:
      return f_boolcast(rb_respond_to(obj, rb_to_id(type_info)));
      break;
    case T_MODULE:
      return rb_funcall(obj, id_is_a_p, 1, type_info);
      break;
    case T_CLASS:
      return rb_funcall(obj, id_is_a_p, 1, type_info);
      break;
  }
  return Qfalse;
}

void
Init_rubype(void)
{
  id_is_a_p = rb_intern_const("is_a?");
  rb_mRubype  = rb_define_module("Rubype");
  rb_define_singleton_method(rb_mRubype, "match_type?", rb_rubype_match_type_p, 2);
  // rb_cAny     = rb_define_class("Any", rb_cObject);
  // rb_mBoolean = rb_define_module("Boolean");
  // rb_include_module(rb_cTrueClass, rb_mBoolean);
  // rb_include_module(rb_cFalseClass, rb_mBoolean);
  // rb_define_class(
  //   "TypePair",
  //   rb_funcall(rb_cStruct, rb_intern("new"), 2, STR2SYM("last_arg_type"), STR2SYM("rtn_type"))
  // );
}
