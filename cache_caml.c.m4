/* -*- mode: c -*- */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#include "cudd_caml.h"

FUN_3(cache,_create,int,int,int,cache__t,
      [[
	xr = malloc(sizeof(struct CuddauxCache));
	xr->cache = NULL;
	xr->arity = x1;
	xr->initialsize = x2;
	xr->maxsize = x3;
	xr->man = NULL;
	]]
      )
value cudd_caml_cache_arity(value vcache)
{
  cache__t cache = cudd_caml_cache__t_ml2c(vcache);
  return Val_int(cache->arity);
}
FUN_1(cache,clear,cache__t,unit,
      [[
	if (x1->cache){
	  cuddLocalCacheQuit(x1->cache);
	  x1->cache = NULL;
	}
	]])
