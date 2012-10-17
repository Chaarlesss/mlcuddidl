/* -*- mode: c -*- */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#include "cudd_caml.h"

FUN_1(bdd,manager,node__t,man__t,[[xr = x1.man;]])
FUN_1_unsafe(bdd,Cudd_IsConstant,node_t,int)
FUN_1_unsafe(bdd,Cudd_IsComplement,node_t,int)
FUN_1_unsafe(bdd,Cudd_NodeReadIndex,node_t,int)
FUN_node1_node(bdd,Cudd_T,node__t,bdd__t,
	   [[
	     if (Cudd_IsConstant(x1.node))
	       caml_invalid_argument ("Bdd.dthen: constant BDD");
	     xr.node = Cudd_T(no.node);
	     if (Cudd_IsComplement(x1.node)) xr.node = Cudd_Not(xr.node);
	     ]])
FUN_node1_node(bdd,Cudd_E,node__t,bdd__t,
	       [[
		 if (Cudd_IsConstant(x1.node))
		   caml_invalid_argument ("Bdd.delse: constant BDD");
		 xr.node = Cudd_E(no.node);
		 if (Cudd_IsComplement(x1.node)) xr.node = Cudd_Not(xr.node);
		 ]])
FUN_node2_node(bdd,Cudd_Cofactor,node__t, node__t, bdd__t)
FUN_node1_node(bdd,Cuddaux_Support,node__t,bdd__t)
FUN_node1(bdd,Cuddaux_SupportSize,node_t,int)
FUN_2(bdd,is_var_in,int,node__t,bool,
      [[
	DdNode* var = Cudd_bddIthVar(x2.man->man,x1);
	xr = Cuddaux_IsVarIn(x2.man->man, x2.node, var);
      ]])
FUN_node2_node(bdd,Cudd_bddLiteralSetIntersection,node__t,node__t,bdd__t)
FUN_1(bdd,dtrue,man__t,bdd__t,[[xr.man = x1; x1.node = DD_ONE(x1->man);]])
FUN_1(bdd,dfalse,man__t,bdd__t,[[xr.man = x1; x1.node = Cudd_Not(DD_ONE(x1->man));]])
FUN_2(bdd,Cudd_bddIthVar,man__t,int,bdd__t,[[xr.man = x1; x1.node = Cudd_bddIthVar(x1->man,x2);]])
FUN_1(bdd,Cudd_bddNewVar,man__t,bdd__t,[[xr.man = x1; x1.node = Cudd_bddNewVar(x1->man);]])
FUN_2(bdd,Cudd_bddNewVarAtLevel,man__t,int,[[xr.man = x1; x1.node = Cudd_bddNewVarAtLevel(x1->man,x2);]])
FUN_1_unsafe(bdd,is_true,node__t,bool,[[xr = (x1.node == DD_ONE(x1.man->man));]])
FUN_1_unsafe(bdd,is_false,node__t,bool,[[xr = (x1.node != DD_ONE(x1.man->man));]])
FUN_2_unsafe(bdd,is_equal,node__t,node__t,bool,
	     [[
	       if (x1.man!=x2.man) caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	       xr = (x1.node == x2.node);
	       ]])
FUN_node2(bdd,Cudd_bddLeq,node__t,node__t,bool)
FUN_node2(bdd,is_inter_empty,node__t,node__t,bool,
	     [[
	       if (x1.man!=x2.man) caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	       xr = Cudd_bddLeq(x1.man->man,x1.node,Cudd_Not(x2.node));
	       ]])
FUN_node3(bdd,is_equal_when,node__t,node__t,node__t,bool,[[xr=Cudd_EquivDC(x1.man->man,x1.node,x2.node,Cudd_Not(x3.node));]])
FUN_node3(bdd,is_leq_when,node__t,node__t,node__t,bool,[[xr=Cudd_bddLeqUnless(x1.man->man,x1.node,x2.node,Cudd_Not(x3.node));]])
FUN_2(bdd,is_var_dependent,int,node__t,bool,
      [[
	DdNode* v = Cudd_bddIthVar(x2.man->man,x1);
	xr = Cudd_bddVarIsDependent(x2.man->man, x2.node, v);
	]])
FUN_1(bdd,Cudd_DagSize,node_t,int)
FUN_1(bdd,Cudd_CountPaths,node_t,double,
      [[
	xr = Cudd_CountPaths(x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbpaths returned CUDD_OUT_OF_MEM");
	]])
FUN_1(bdd, Cudd_CountPathsToNonZero, node_t, double,
      [[
	xr = Cudd_CountPathsToNonZero(x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbpaths returned CUDD_OUT_OF_MEM");
	]])
FUN_2(bdd, Cudd_CountMinterm, int, node__t, int,
      [[
	xr = Cudd_CountMinterm(x2.man->man,x2.node,x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbminterms returned CUDD_OUT_OF_MEM");
	]])
FUN_2(bdd, Cudd_Density, int, node__t, int,
      [[
	xr = Cudd_Density(x2.man->man,x2.node,x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbminterms returned CUDD_OUT_OF_MEM");
	]])
FUN_node1_node(bdd, Cudd_Not, node__t, bdd__t)
FUN_node2_node(bdd, Cudd_bddAnd, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cudd_bddOr, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cudd_bddXor, node__t, node__t, bdd__t)
FUN_node3_node(bdd,Cudd_BddIte, node__t, node__t, node__t, bdd__t)
value cudd_caml_Cudd_bddIteConstant(value v1, value v2, value v3)
{
  CAMLparam3(v1,v2,v3);
  CAMLlocal1(v);
  node__t x1 = cudd_caml_node__t_ml2c(v1);
  node__t x2 = cudd_caml_node__t_ml2c(v2);
  node__t x3 = cudd_caml_node__t_ml2c(v3);
  if (x1.man!=x2.man || x1.man!=x3.man) 
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  DdNode* res = Cudd_bddIteConstant(x1.man->man,x1.node,x2.node,x3.node);
  value vres;
  if (res==DD_NON_CONSTANT)
    vres = Val_int(0);
  else {
    value v = cudd_caml_bdd__t_c2ml(res);
    vres = caml_alloc_small(1,0);
    Field(vres,0) = v;
  }
  CAMLreturn vres;
}
FUN3(bdd, Cudd_bddCompose, int, node__t, node__t, bdd__t,
     [[
       if (x2.man!=x3.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
       xr.man = x3.man;
       xr.node = Cudd_bddCompose(x3.man->man,x3.node,x2.node,x1);
       ]])
FUN_node2_node(bdd, Cudd_bddIntersect, node__t, node__t, bdd__t)
FUN_node1_node(bdd, Cudd_bddVarMap, node__t, bdd__t)
FUN_node2(bdd, Cudd_bddExistAbstract, node__t, node__t, bdd__t,
	  [[xr.man=x1.man;xr.node=Cudd_bddExistAbstract(x2.man->man,x2.node,x1.node);]])
FUN_node3(bdd, Cudd_bddAndAbstract,  node__t, node__t, node__t, bdd__t,
	  [[xr.man=x1.man;xr.node=Cudd_bddAndAbstract(x2.man->man,x2.node,x3.node,x1.node);]])
FUN_node3(bdd, Cudd_bddXorExistAbstract, node__t, node__t, node__t, bdd__t,
	  [[xr.man=x1.man;xr.node=Cudd_bddXorExistAbstract(x2.man->man,x2.node,x3.node,x1.node);]])
FUN_node1_1_node(bdd, Cudd_bddBooleanDiff, node__t, int, bdd__t)

FUN_node1_node(bdd, Cudd_FindEssential, node__t, bdd__t)
FUN_node2_node(bdd, Cuddaux_bddCubeUnion, node__t, node__t, bdd__t)

FUN_node2_node(bdd, Cudd_bddConstrain, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cuddaux_bddTDConstrain, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cudd_bddRestrict, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cuddaux_bddTDRestrict, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cudd_bddMinimize, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cudd_bddLICompaction, node__t, node__t, bdd__t)
FUN_node2_node(bdd, Cudd_bddSqueeze, node__t, node__t, bdd__t)

FUN_4(bdd, Cudd_bddClippingAnd, int, int, node__t, node__t, bdd__t)
      [[
	if (x3.man!=x4.man)
	  caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	xr.man=x3.man;
	xr.node=Cudd_bddClippingAnd(x3.man->man,x3.node,x4.node,x1,x2);
	]])
FUN_5(bdd, Cudd_bddClippingAndAbstract, int, int, node__t, node__t, node__t, bdd__t,
      [[
	if (x3.man!=x4.man || x3.man!=x5.man)
	  caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
	xr.man=x1.man;
	xr.node=Cudd_bddClippingAnd(x4.man->man,x4.node,x5.node,x3.node,x1,x2);
	]])
FUN_5(bdd,Cudd_UnderApprox,int,int,bool,double,node__t,bdd__t,
      [[xr.man=x5.man; xr.node=Cudd_UnderApprox(x5.man,x5.node,x1,x2,x3,x4);]])
FUN_4(bdd,Cudd_RemapUnderApprox,int,int,double,node__t,bdd__t,
      [[xr.man=x4.man; xr.node=Cudd_RemapUnderApprox(x4.man,x4.node,x1,x2,x3);]])
FUN_6(bdd,Cudd_BiasedUnderApprox,int,int,double,double,node__t,node__t,bdd__t
      [[
	if (x5.man!=x6.man)
	  caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	xr.man=x5.man;
	xr.node=Cudd_BiasedUnderApprox(x6.man->man,x6.node,x5.node,x1,x2,x3,x4);
	]])
FUN_3(bdd,Cudd_SubsetCompress,int,int,node__t,bdd__t,
      [[xr.man=x3.man; xr.node=Cudd_SubsetCompress(x3.man->man,x3.node,x1,x2);]])
FUN_3(bdd,Cudd_SubsetHeavyBranch,int,int,node__t,bdd__t,
      [[xr.man=x3.man; xr.node=Cudd_SubsetHeavyBranch(x3.man->man,x3.node,x1,x2);]])
FUN_4(bdd,Cudd_SubsetShortPaths,int,int,int,node__t,bdd__t,
      [[xr.man=x3.man; xr.node=Cudd_SubsetShortPaths(x3.man->man,x3.node,x1,x2,x3);]])

typedef int(*)(DdManager*,Ddnode*,DdNode***) decomp_ptr;
decomp_ptr decomp_tab[4]={
  &Cudd_bddApproxConjDecomp,
  &Cudd_bddIterConjDecomp,
  &Cudd_bddGenConjDecomp,
  &Cudd_bddVarConjDecomp
}


CAMLprim cudd_caml_bdd_decomp(value v0, value v1)
{
  CAMLparam1(v1);
  node__t x1 = cudd_caml_node__t_ml2c(v1);
  DdNode** tab;
  int x0=Int_val(v0);
  decomp_ptr ptr = decomp_tab[x0];
  int res = ptr(x1.man->man,x1.node,&tab);
  value vres;
  if (res==0)
    caml_failwith("Bdd.YYYdecomp: decomposition function failed (probably CUDD_OUT_OF_MEM)");
  else if (res==1){
    Cudd_IterDerefBdd(x1.man->man,tab[0]);
    free(tab);
    vres = Val_int(0);
  }
  else {
    CAMLlocal3(_v_a,_v_b,_v_pair);
    node__t a,b;
    a.man = b.man = x1.man;
    a.node = tab[0];
    b.node = tab[1];
    cuddDeref(a.node);
    _v_a = cudd_caml_bdd__t_c2ml(a);
    cuddDeref(b.node);
    _v_b = cudd_caml_bdd__t_c2ml(b);
    _v_pair = alloc_small(0,2);
    Field(_v_pair,0) = _v_a;
    Field(_v_pair,1) = _v_b;
    vres = alloc_small(0,1);
    Field(vres,0) = _v_pair;
    free(tab);
  }
  CAMLreturn(vres);
}
FUN_2(bdd,Cudd_bddTransfer, node__t, man__t, bdd__t,
      [[xr.man=x2;xr.node=Cudd_bddTransfer(x1.man->man,x2->man,x1.node);]])
FUN_node2(bdd,Cudd_bddCorrelation, node__t,node__t,double,
	  [[
	    xr=Cudd_bddCorrelation(x1.man->man,x1.node,x2.node);
	    if (xr==(double)CUDD_OUT_OF_MEM)
	      caml_failwith("Bdd.correlation returned CUDD_OUT_OF_MEM");
	    ]])
FUN_node2_1(bdd,Cudd_bddCorrelationWeights, node__t,node__t,doublearray_t,double,
	    [[
	      xr=Cudd_bddCorrelationWeights(x1.man->man,x1.node,x2.node,x3.array);
	      free(x3.array);
	      if (xr==(double)CUDD_OUT_OF_MEM)
		caml_failwith("Bdd.correlationweights returned CUDD_OUT_OF_MEM");
	      ]])

