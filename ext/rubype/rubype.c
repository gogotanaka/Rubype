#include "rubype.h"

VALUE rb_mRubype, rb_cContract, rb_eRubypeArgumentTypeError, rb_eRubypeReturnTypeError, rb_eInvalidTypesigError;
static ID id_to_s, id_meth, id_owner, id_arg_types, id_rtn_type, id_private_meth_p, id_protected_meth_p, id_private, id_protected, id_define_method;

#define error_fmt "\nfor %"PRIsVALUE"\nExpected: %"PRIsVALUE"\nActual:   %"PRIsVALUE""
#define unmatch_type_p(obj, type_info) !(match_type_p(obj, type_info))

int match_type_p(VALUE obj, VALUE type_info)
{
  switch (TYPE(type_info)) {
    case T_SYMBOL: return rb_respond_to(obj, rb_to_id(type_info));
                   break;

    case T_MODULE:
    case T_CLASS:  return (int)rb_obj_is_kind_of(obj, type_info);
                   break;

    default:       return 0;
                   break;
  }
}

VALUE expected_mes(VALUE expected)
{
  switch (TYPE(expected)) {
    case T_SYMBOL: return rb_sprintf("respond to #%"PRIsVALUE, expected);
                   break;

    case T_MODULE:
    case T_CLASS:  return rb_funcall(expected, id_to_s, 0);
                   break;

    default:       return rb_str_new2("");
                   break;
  }
}

#define assing_ivars VALUE meth_caller, meth, target;\
                     meth_caller = rb_ivar_get(self, id_owner);\
                     meth        = rb_ivar_get(self, id_meth);

static VALUE
rb_rubype_assert_args_type(VALUE self, VALUE args)
{
  assing_ivars
  int i;
  VALUE arg, arg_type;
  VALUE arg_types = rb_ivar_get(self, id_arg_types);

  for (i=0; i<RARRAY_LEN(args); i++) {
    arg      = rb_ary_entry(args, i);
    arg_type = rb_ary_entry(arg_types, i);

    if (unmatch_type_p(arg, arg_type)){
      target = rb_sprintf("%"PRIsVALUE"#%"PRIsVALUE"'s %d argument", meth_caller, meth, i+1);
      rb_raise(rb_eRubypeArgumentTypeError, error_fmt, target, expected_mes(arg_type), arg);
    }
  }
  return Qnil;
}

static VALUE
rb_rubype_assert_rtn_type(VALUE self, VALUE rtn)
{
  assing_ivars
  VALUE rtn_type = rb_ivar_get(self, id_rtn_type);

  if (unmatch_type_p(rtn, rtn_type)){
    target = rb_sprintf("%"PRIsVALUE"#%"PRIsVALUE"'s return", meth_caller, meth);
    rb_raise(rb_eRubypeReturnTypeError, error_fmt, target, expected_mes(rtn_type), rtn);
  }
  return rtn;
}

static VALUE
rb_rubype_initialize(VALUE self, VALUE arg_types, VALUE rtn_type, VALUE owner, VALUE meth)
{
  rb_ivar_set(self, id_owner,     owner);
  rb_ivar_set(self, id_meth,      meth);
  rb_ivar_set(self, id_arg_types, arg_types);
  rb_ivar_set(self, id_rtn_type,  rtn_type);
  return Qnil;
}

static VALUE
rb_rubype_add_typed_method_to_proxy(VALUE self, VALUE owner, VALUE meth, VALUE proxy_mod)
{
  VALUE body;
  body = rb_block_lambda();
  if ((int)rb_funcall(owner, id_private_meth_p, 1, meth)) {
    rb_funcall(proxy_mod, id_define_method, 2, meth, body);
    rb_funcall(proxy_mod, id_private, 1, meth);
  }
  else if ((int)rb_funcall(owner, id_protected_meth_p, 1, meth)) {
    rb_funcall(proxy_mod, id_define_method, 2, meth, body);
    rb_funcall(proxy_mod, id_protected, 1, meth);
  }
  else {
    rb_funcall(proxy_mod, id_define_method, 2, meth, body);
  }
  return Qnil;
}

void
Init_rubype(void)
{
  rb_mRubype  = rb_define_module("Rubype");

  rb_eRubypeArgumentTypeError = rb_define_class_under(rb_mRubype, "ArgumentTypeError",   rb_eTypeError);
  rb_eRubypeReturnTypeError   = rb_define_class_under(rb_mRubype, "ReturnTypeError",     rb_eTypeError);
  rb_eInvalidTypesigError     = rb_define_class_under(rb_mRubype, "InvalidTypesigError", rb_eTypeError);

  rb_cContract = rb_define_class_under(rb_mRubype, "Contract", rb_cObject);
  rb_define_method(rb_cContract, "initialize", rb_rubype_initialize, 4);
  rb_define_method(rb_cContract, "assert_args_type", rb_rubype_assert_args_type, 1);
  rb_define_method(rb_cContract, "assert_rtn_type", rb_rubype_assert_rtn_type, 1);
  rb_define_singleton_method(rb_mRubype, "add_typed_method_to_proxy", rb_rubype_add_typed_method_to_proxy, 3);


  id_meth      = rb_intern("@meth");
  id_owner     = rb_intern("@owner");
  id_arg_types = rb_intern("@arg_types");
  id_rtn_type  = rb_intern("@rtn_type");
  id_to_s      = rb_intern("to_s");

  id_private_meth_p   = rb_intern("private_method_defined?");
  id_protected_meth_p = rb_intern("protected_method_defined?");
  id_private          = rb_intern("private");
  id_protected        = rb_intern("protected");

  id_define_method    = rb_intern("define_method");
}
