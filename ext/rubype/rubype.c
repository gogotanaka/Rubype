#include "rubype.h"

VALUE rb_mRubype, rb_cAny, rb_mBoolean;

#define STR2SYM(x) ID2SYM(rb_intern(x))
static ID id_is_a_p, id_to_s;
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

int match_type_p(VALUE obj, VALUE type_info)
{
  switch (TYPE(type_info)) {
    case T_SYMBOL:
      return rb_respond_to(obj, rb_to_id(type_info));
      break;
    case T_MODULE:
      return (int)rb_funcall(obj, id_is_a_p, 1, type_info);
      break;
    case T_CLASS:
      return (int)rb_funcall(obj, id_is_a_p, 1, type_info);
      break;
  }
  return 0;
}

static VALUE
rb_rubype_expected_mes(VALUE rubype, VALUE expected)
{
  VALUE str;

  switch (TYPE(expected)) {
    case T_SYMBOL:
      // TODO
      str = rb_id2str(SYM2ID(expected));
      return rb_str_cat2(rb_str_new2("respond to #"), StringValuePtr(str));
      break;
    case T_MODULE:
      return rb_funcall(expected, id_to_s, 0);
      break;
    case T_CLASS:
      return rb_funcall(expected, id_to_s, 0);
      break;
  }
  return rb_str_new2("");
}

// static VALUE
// rb_rubype_assert_rtn_type(VALUE rubype, VALUE meth_caller, VALUE meth, VALUE rtn, VALUE type_info, VALUE caller_trace)
// {
//   if (match_type_p(rtn, type_info)){
//     return Qtrue;
//   }
//   else {
//     rb_raise(rb_eTypeError, "not valid value");
//     return Qfalse;
//   }
// }

void
Init_rubype(void)
{
  id_is_a_p = rb_intern_const("is_a?");
  id_to_s = rb_intern_const("to_s");
  rb_mRubype  = rb_define_module("Rubype");
  rb_eMathDomainError = rb_define_class_under(rb_mRubype, "ArgumentTypeError", rb_eTypeError);
  rb_eMathDomainError = rb_define_class_under(rb_mRubype, "ReturnTypeError", rb_eTypeError);
  // rb_define_singleton_method(rb_mRubype, "assert_rtn_type", rb_rubype_assert_rtn_type, 5);
  rb_define_singleton_method(rb_mRubype, "match_type?", rb_rubype_match_type_p, 2);
  rb_define_singleton_method(rb_mRubype, "expected_mes", rb_rubype_expected_mes, 1);
  // rb_cAny     = rb_define_class("Any", rb_cObject);
  // rb_mBoolean = rb_define_module("Boolean");
  // rb_include_module(rb_cTrueClass, rb_mBoolean);
  // rb_include_module(rb_cFalseClass, rb_mBoolean);
}
