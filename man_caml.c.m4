/* -*- mode: c -*- */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#include "caml/fail.h"
#include "caml/alloc.h"
#include "caml/custom.h"
#include "caml/memory.h"
#include "caml/callback.h"
#include "cudd_caml.h"

FUN_2(hash,_create,int,int,hash__t,
[[
xr = malloc(sizeof(struct CuddauxHash));
xr->hash = NULL;
xr->arity = x1;
xr->initialsize = x2;
xr->man = NULL;
]])

value camlidl_cudd_hash_arity(value vhash)
{
  hash__t hash = cudd_caml_hash__t_ml2c(vhash);
  return Val_int(hash->arity);
}
FUN_1(hash,cuddauxHashClear,hash__t,unit)

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


FUN_1_unsafe(man,Cudd_Srandom,long,unit)

CAMLprim value cudd_caml_man_Cudd_Init
(
 value _v_caml,
 value _v_numVars,
 value _v_numVarsZ,
 value _v_numSlots,
 value _v_cacheSize,
 value _v_maxMemory
)
{
  bool caml;
  int numVars, numVarsZ, numSlots,cacheSize;
  long maxMemory;
  man__t _res;
  value _vres;
  int res;
  caml = Bool_val(_v_caml);
  numVars = Int_val(_v_numVars);
  numVarsZ = Int_val(_v_numVarsZ);
  numSlots = Int_val(_v_numSlots);
  cacheSize = Int_val(_v_cacheSize);
  maxMemory = Long_val(_v_maxMemory);

  if (numVars<0) numVars = 0;
  if (numVarsZ<0) numVarsZ = 0;
  if (numSlots<=0) numSlots = CUDD_UNIQUE_SLOTS;
  if (cacheSize<=0) cacheSize = CUDD_CACHE_SLOTS;
  if (maxMemory<0) maxMemory = 0;
  _res = (man__t)malloc(sizeof(struct CuddauxMan));
  _res->man = Cudd_Init(numVars, numVarsZ, numSlots, cacheSize, maxMemory);
  _res->count = 0;
  _res->caml = caml;
  res = Cudd_AddHook(_res->man,cudd_caml_garbage,CUDD_PRE_GC_HOOK);
   if (res!=1)
     caml_failwith("Man.make: unable to add the garbage collection hook");
   if (caml){
     res = Cudd_AddHook(_res->man,Cuddaux_addCamlPreGC, CUDD_PRE_GC_HOOK);
     if (res!=1)
       caml_failwith("Man.make_caml: unable to add the caml garbage collection hook Cuddaux_addCamlPreGC");
   }
   res = Cudd_AddHook(_res->man,cudd_caml_reordering,CUDD_PRE_REORDERING_HOOK);
   if (res!=1)
     caml_failwith("Man.make: unable to add the reordering hook");

  _vres = cudd_caml_man__t_c2ml(_res);
  return _vres;
}

CAMLprim value cudd_caml_man_Cudd_Init_bytecode(value* argv, int argn)
{
  return cudd_caml_man_Cudd_Init(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

FUN_1(man,Cudd_DebugCheck,man_t,int,
	[[
	  xr = Cudd_DebugCheck(x1);
	  fflush(x1->err);
	  if (xr == CUDD_OUT_OF_MEM)
	    caml_failwith("Cudd.Man.debugcheck returned CUDD_OUT_OF_MEM");
	  ]])
FUN_1(man,Cudd_CheckKeys,man_t,bool)
FUN_2_unsafe(man,Cudd_ReadPerm,man_t,int,int)
FUN_2_unsafe(man,Cudd_ReadInvPerm,man_t,int,int)
FUN_3(man,Cudd_ReduceHeap,man_t,reorder_t,int,unit,
      [[
	bool ok = Cudd_ReduceHeap(x1,x2,x3);
	if (ok==false) caml_failwith("Cudd.Man.reduce_heap failed");
	]])
FUN_2(man,Cudd_ShuffleHeap,man_t,intarray_t,unit,
      [[
	bool ok = Cudd_ShuffleHeap(x1,x2.array);
	if (ok==false) caml_failwith("Cudd.Man.shuffle_heap failed");
	free(x2.array);
	]])
FUN_1(man,cuddGarbageCollect,man_t,int,[[xr=cuddGarbageCollect(x1,1);]])
FUN_1(man,cuddCacheFlush,man_t,unit)
FUN_2(man,Cudd_AutodynEnable,man_t,reorder_t,unit)
FUN_1(man,Cudd_AutodynDisable,man_t,unit)
CAMLprim value cudd_caml_Cudd_ReorderingStatus(value vman)
{
  man_t man = cudd_caml_man_t_ml2c(vman);
  reorder_t xr;
  int b = Cudd_ReorderingStatus(man,&xr);
  value vr;
  if (b){
    vr = alloc_small(1,0);
    Field(vr,0) = cudd_caml_reorder_t_c2ml(xr);
  } else {
    vr = Val_int(0);
  }
  return vr;
}
FUN_4(man,Cudd_MakeTreeNode,man_t,int,int,mtr_t,unit)
FUN_1(man,Cudd_FreeTree,man_t,unit)
FUN_2(man,Cuddaux_SetVarMap,man_t,intarray_t,unit,
      [[
	bool ok = Cuddaux_SetVarMap(x1,x2.array,x2.size);
	if (ok==false) caml_failwith("Cudd.Man.set_varmap failed");
	free(x2.array);
	]])
CAMLprim value cudd_caml_man_get_params(value vman)
{
  CAMLparam1(vman);
  CAMLlocal1(vres);
  man_t man = cudd_caml_man_t_ml2c(vman);
  vres = caml_alloc(19,0);
  DdNode* add = Cudd_ReadBackground(man);
  double d = cuddV(add);
  Store_field(vres,0,caml_copy_double(d));
  Store_field(vres,1,caml_copy_double(Cudd_ReadEpsilon(man)));
  Store_field(vres,2,Val_int(Cudd_ReadMinHit(man)));
  Store_field(vres,3,Val_int(Cudd_ReadMaxCacheHard(man)));
  Store_field(vres,4,Val_int(Cudd_ReadLooseUpTo(man)));
  Store_field(vres,5,Val_int(Cudd_ReadMaxLive(man)));
  Store_field(vres,6,Val_int(Cudd_ReadMaxMemory(man)));
  Store_field(vres,7,Val_int(Cudd_ReadSiftMaxSwap(man)));
  Store_field(vres,8,Val_int(Cudd_ReadSiftMaxVar(man)));
  Store_field(vres,9,Val_int(Cudd_ReadGroupcheck(man)));
  Store_field(vres,10,Val_int(Cudd_ReadArcviolation(man)));
  Store_field(vres,11,Val_int(Cudd_ReadNumberXovers(man)));
  Store_field(vres,12,Val_int(Cudd_ReadPopulationSize(man)));
  Store_field(vres,13,Val_int(Cudd_ReadRecomb(man)));
  Store_field(vres,14,Val_int(Cudd_ReadSymmviolation(man)));
  Store_field(vres,15,caml_copy_double(Cudd_ReadMaxGrowth(man)));
  Store_field(vres,16,caml_copy_double(Cudd_ReadMaxGrowthAlternate(man)));
  Store_field(vres,17,Val_int(Cudd_ReadReorderingCycle(man)));
  Store_field(vres,18,Val_int(Cudd_ReadNextReordering(man)));
  CAMLreturn(vres);
}
CAMLprim value cudd_caml_man_set_params(value vman,value v)
{
  CAMLparam2(vman,v);
  man_t man = cudd_caml_man_t_ml2c(vman);

  DdNode* add = Cudd_ReadBackground(man);
  cuddDeref(add);
  add = Cudd_addConst(man,Double_val(Field(v,0)));
  cuddRef(add);
  Cudd_SetBackground(man,add);

  Cudd_SetEpsilon(man,Double_val(Field(v,1)));
  Cudd_SetMinHit(man,Int_val(Field(v,2)));
  Cudd_SetMaxCacheHard(man,Int_val(Field(v,3)));
  Cudd_SetLooseUpTo(man,Int_val(Field(v,4)));
  Cudd_SetMaxLive(man,Int_val(Field(v,5)));
  Cudd_SetMaxMemory(man,Int_val(Field(v,6)));
  Cudd_SetSiftMaxSwap(man,Int_val(Field(v,7)));
  Cudd_SetSiftMaxVar(man,Int_val(Field(v,8)));
  Cudd_SetGroupcheck(man,Int_val(Field(v,9)));
  Cudd_SetArcviolation(man,Int_val(Field(v,10)));
  Cudd_SetNumberXovers(man,Int_val(Field(v,11)));
  Cudd_SetPopulationSize(man,Int_val(Field(v,12)));
  Cudd_SetRecomb(man,Int_val(Field(v,13)));
  Cudd_SetSymmviolation(man,Int_val(Field(v,14)));
  Cudd_SetMaxGrowth(man,Double_val(Field(v,15)));
  Cudd_SetMaxGrowthAlternate(man,Double_val(Field(v,16)));
  Cudd_SetReorderingCycle(man,Int_val(Field(v,17)));
  Cudd_SetNextReordering(man,Int_val(Field(v,18)));
  CAMLreturn(Val_unit);
}
CAMLprim value cudd_caml_man_stats(value vman)
{
  CAMLparam1(vman);
  CAMLlocal1(vres);
  man_t man = cudd_caml_man_t_ml2c(vman);
  vres = caml_alloc(20,0);
  Store_field(vres,0,caml_copy_double(Cudd_ReadCacheHits(man)));
  Store_field(vres,1,caml_copy_double(Cudd_ReadCacheLookUps(man)));
  Store_field(vres,2,Val_int(Cudd_ReadCacheSlots(man)));
  Store_field(vres,3,caml_copy_double(Cudd_ReadCacheUsedSlots(man)));
  Store_field(vres,4,Val_int(Cudd_ReadDead(man)));
  Store_field(vres,5,Val_int(Cudd_ReadGarbageCollectionTime(man)));
  Store_field(vres,6,Val_int(Cudd_ReadGarbageCollections(man)));
  Store_field(vres,7,Val_int(Cudd_ReadKeys(man)));
  //  Store_field(vres,8,Val_int(Cudd_ReadLinear(man)));
  Store_field(vres,8,Val_int(Cudd_ReadMaxCache(man)));
  Store_field(vres,9,Val_int(Cudd_ReadMinDead(man)));
  Store_field(vres,10,Val_int(Cudd_ReadNodeCount(man)));
  Store_field(vres,11,Val_int(Cudd_ReadPeakNodeCount(man)));
  Store_field(vres,12,Val_int(Cudd_ReadPeakLiveNodeCount(man)));
  Store_field(vres,13,Val_int(Cudd_ReadReorderingTime(man)));
  Store_field(vres,14,Val_int(Cudd_ReadReorderings(man)));
  Store_field(vres,15,Val_int(Cudd_ReadSize(man)));
  Store_field(vres,16,Val_int(Cudd_ReadZddSize(man)));
  Store_field(vres,17,Val_int(Cudd_ReadSlots(man)));
  Store_field(vres,18,caml_copy_double(Cudd_ReadUsedSlots(man)));
  Store_field(vres,19,caml_copy_double(Cudd_ReadSwapSteps(man)));
  CAMLreturn(vres);
}
FUN_1_unsafe(man,get_background,man_t,double,
	     [[
	       DdNode* add = Cudd_ReadBackground(x1);
	       xr = cuddV(add);
	       ]]);
FUN_1_unsafe(man,Cudd_ReadErrorCode,man_t,int);
FUN_1_unsafe(man,Cudd_ReadSize,man_t,int);
FUN_1_unsafe(man,Cudd_ReadZddSize,man_t,int);
