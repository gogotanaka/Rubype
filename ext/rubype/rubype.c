#include "rubype.h"

VALUE rb_mRubype, rb_eRubypeArgumentTypeError, rb_eRubypeReturnTypeError, rb_eInvalidTypesigError;

#define STR2SYM(x) ID2SYM(rb_intern(x))
static ID id_is_a_p, id_to_s, id_plus;
#define f_boolcast(x) ((x) ? Qtrue : Qfalse)

int unmatch_type_p(VALUE obj, VALUE type_info)
{
  int check;
  switch (TYPE(type_info)) {
    case T_SYMBOL: check = rb_respond_to(obj, rb_to_id(type_info));
                   break;

    case T_MODULE: check = (int)rb_funcall(obj, id_is_a_p, 1, type_info);
                   break;

    case T_CLASS:  check = (int)rb_funcall(obj, id_is_a_p, 1, type_info);
                   break;

    default:       check = 0;
                   break;
  }
  return !check;
}

static VALUE
expected_mes(VALUE expected)
{
  VALUE str;

  switch (TYPE(expected)) {
    case T_SYMBOL:
      str = rb_id2str(SYM2ID(expected));
      return "can't convert %"PRIsVALUE" into Integer", str;
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

VALUE make_error_mes(VALUE target, VALUE expected, VALUE actual, VALUE caller_trace) {
  return expected_mes(expected);
}

static VALUE
rb_rubype_assert_args_type(VALUE rubype, VALUE meth_caller, VALUE meth, VALUE args, VALUE type_infos, VALUE caller_trace)
{
  int i;
  VALUE arg, type_info, error_mes;
  for (i=0; i<RARRAY_LEN(args); i++) {
    arg       = rb_ary_entry(args, i);
    type_info = rb_ary_entry(type_infos, i);

    if (unmatch_type_p(arg, type_info)){
      error_mes = make_error_mes(meth, type_info, arg, caller_trace);
      //rb_funcall(meth_caller, id_plus, 1, rb_funcall(rb_str_new2("#"), id_plus, 1, meth));
      rb_raise(rb_eRubypeArgumentTypeError, "can't convert %"PRIsVALUE" into Integer", rb_str_new2(""));

      // error_mes("#{meth_caller.class}##{meth}'s #{ordinalize(i + 1)} argument", type_info, arg, caller_trace)
    }
  }
  return Qtrue;
}
static VALUE
rb_rubype_assert_rtn_type(VALUE rubype, VALUE meth_caller, VALUE meth, VALUE rtn, VALUE type_info, VALUE caller_trace)
{
  if (unmatch_type_p(rtn, type_info)){
    rb_raise(rb_eRubypeReturnTypeError, "not valid value");
    // error_mes("#{meth_caller.class}##{meth}'s return", type_info, rtn, caller_trace)
  }
  return Qtrue;
}

void
Init_rubype(void)
{
  id_is_a_p = rb_intern_const("is_a?");
  id_to_s = rb_intern_const("to_s");
  id_plus = rb_intern_const("+");
  rb_mRubype  = rb_define_module("Rubype");
  rb_eRubypeArgumentTypeError = rb_define_class_under(rb_mRubype, "ArgumentTypeError", rb_eTypeError);
  rb_eRubypeReturnTypeError = rb_define_class_under(rb_mRubype, "ReturnTypeError", rb_eTypeError);
  rb_eInvalidTypesigError = rb_define_class_under(rb_mRubype, "InvalidTypesigError", rb_eTypeError);
  rb_define_singleton_method(rb_mRubype, "assert_args_type", rb_rubype_assert_args_type, 5);
  rb_define_singleton_method(rb_mRubype, "assert_rtn_type", rb_rubype_assert_rtn_type, 5);
}
