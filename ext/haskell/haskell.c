#include "haskell.h"

VALUE rb_mHaskell;

void
Init_haskell(void)
{
  rb_mHaskell = rb_define_module("Haskell");
}
