#include "rubype.h"

VALUE rb_mRubype, rb_cContract, rb_eRubypeArgumentTypeError, rb_eRubypeReturnTypeError, rb_eInvalidTypesigError;
static ID id_is_a_p, id_to_s, id_meth, id_owner, id_arg_types, id_rtn_type;

#define f_boolcast(x) ((x) ? Qtrue : Qfalse)
#define error_fmt "\nfor %"PRIsVALUE"\nExpected: %"PRIsVALUE"\nActual:   %"PRIsVALUE""
#define unmatch_type_p(obj, type_info) !(match_type_p(obj, type_info))

int match_type_p(VALUE obj, VALUE type_info)
{
  switch (TYPE(type_info)) {
    case T_SYMBOL: return rb_respond_to(obj, rb_to_id(type_info));
                   break;

    case T_MODULE: return (int)rb_funcall(obj, id_is_a_p, 1, type_info);
                   break;

    case T_CLASS:  return (int)rb_funcall(obj, id_is_a_p, 1, type_info);
                   break;

    default:       return 0;
                   break;
  }
}

static VALUE
expected_mes(VALUE expected)
{
  switch (TYPE(expected)) {
    case T_SYMBOL: return rb_sprintf("respond to #%"PRIsVALUE, expected);
                   break;

    case T_MODULE: return rb_funcall(expected, id_to_s, 0);
                   break;

    case T_CLASS:  return rb_funcall(expected, id_to_s, 0);
                   break;

    default:       return rb_str_new2("");
                   break;
  }
}

static VALUE
rb_rubype_assert_type(VALUE self, VALUE args, VALUE rtn)
{
  int i;
  VALUE target;
  VALUE meth_caller, meth, arg_types, arg_type, rtn_type, arg;
  meth_caller = rb_ivar_get(self, id_owner);
  meth        = rb_ivar_get(self, id_meth);
  arg_types   = rb_ivar_get(self, id_arg_types);
  rtn_type    = rb_ivar_get(self, id_rtn_type);

  Check_Type(meth, T_SYMBOL);
  Check_Type(arg_types, T_ARRAY);

  for (i=0; i<RARRAY_LEN(args); i++) {
    arg      = rb_ary_entry(args, i);
    arg_type = rb_ary_entry(arg_types, i);

    if (unmatch_type_p(arg, arg_type)){
      target = rb_sprintf("%"PRIsVALUE"#%"PRIsVALUE"'s %d argument", meth_caller, meth, i+1);
      rb_raise(rb_eRubypeArgumentTypeError, error_fmt, target, expected_mes(arg_type), arg);
    }
  }

  if (unmatch_type_p(rtn, rtn_type)){
    target = rb_sprintf("%"PRIsVALUE"#%"PRIsVALUE"'s return", meth_caller, meth);
    rb_raise(rb_eRubypeReturnTypeError, error_fmt, target, expected_mes(rtn_type), rtn);
  }
  return rtn;
}

void
Init_rubype(void)
{
  rb_mRubype  = rb_define_module("Rubype");

  rb_eRubypeArgumentTypeError = rb_define_class_under(rb_mRubype, "ArgumentTypeError",   rb_eTypeError);
  rb_eRubypeReturnTypeError   = rb_define_class_under(rb_mRubype, "ReturnTypeError",     rb_eTypeError);
  rb_eInvalidTypesigError     = rb_define_class_under(rb_mRubype, "InvalidTypesigError", rb_eTypeError);

  rb_cContract = rb_define_class_under(rb_mRubype, "Contract", rb_cObject);
  rb_define_method(rb_cContract, "assert_type", rb_rubype_assert_type, 2);

  id_meth      = rb_intern("@meth");
  id_owner     = rb_intern("@owner");
  id_arg_types = rb_intern("@arg_types");
  id_rtn_type  = rb_intern("@rtn_type");
  id_is_a_p = rb_intern_const("is_a?");
  id_to_s   = rb_intern_const("to_s");
}
