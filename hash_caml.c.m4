/* -*- mode: c -*- */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#include "cudd_caml.h"

FUN_2(hash,_create,int,int,hash__t,
[[
xr = malloc(sizeof(struct CuddauxHash));
xr->hash = NULL;
xr->arity = x1
xr->initialsize = x2;
xr->man = NULL;
]])

value camlidl_cudd_hash_arity(vhash)
{
  hash__t hash = cudd_caml_hash__t_ml2c(vhash);
  return Val_int(hash->arity);
}
FUN_1(hash,cuddauxHashClear,hash__t,unit)
