#include "rubype.h"

VALUE rb_mRubype;

void
Init_rubype(void)
{
  rb_mRubype = rb_define_module("Rubype");
}
