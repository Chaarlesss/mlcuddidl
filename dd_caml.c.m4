/* -*- mode: c -*- */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#include "caml/fail.h"
#include "caml/alloc.h"
#include "caml/custom.h"
#include "caml/memory.h"
#include "caml/callback.h"
#include "cudd_caml.h"

/* ********************************************************************** */
/* Generic functions */
/* ********************************************************************** */

FUN_1(,manager,node__t,man__t,[[xr = x1.man;]])
FUN_1_unsafe(,Cudd_IsConstant,node_t,int)
FUN_1_unsafe(,Cudd_NodeReadIndex,node_t,int)
FUN_node1_node(,Cuddaux_Support,node__t,bdd__t)
FUN_1(,Cuddaux_SupportSize,node__t,int,[[xr = Cuddaux_SupportSize(x1.man->man,x1.node);]])
FUN_2(,is_var_in,int,node__t,bool,
      [[
	DdNode* var = Cudd_bddIthVar(x2.man->man,x1);
	xr = Cuddaux_IsVarIn(x2.man->man, x2.node, var);
      ]])
CAMLprim value cudd_caml__vectorsupport(value _v_vec)
{
  CAMLparam1(_v_vec); CAMLlocal2(_v_no,_v_res);

  int size = Wosize_val(_v_vec);
  if (size==0)
    caml_invalid_argument ("Cudd.vectorsupport called with an empty array (annoying because unknown manager for true)");
  DdNode** vec = (DdNode**)malloc(size * sizeof(DdNode*));
  man__t man = cudd_caml_tnode_ml2c(_v_vec,size,vec);
  if (man==NULL){
    free(vec);
    caml_invalid_argument("Cudd.vectorsupport called with BDDs belonging to different managers !");
  }
  node__t _res;
  _res.man = man;
  _res.node = Cudd_VectorSupport(man->man, vec, size);
  free(vec);
  _v_res = cudd_caml_bdd__t_c2ml(_res);
  CAMLreturn(_v_res);
}
FUN_1(,Cudd_DagSize,node_t,int)
FUN_1(,Cudd_CountPath,node_t,double,
      [[
	xr = Cudd_CountPath(x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbpaths returned CUDD_OUT_OF_MEM");
	]])
FUN_2(, Cudd_CountMinterm, int, node__t, int,
      [[
	xr = Cudd_CountMinterm(x2.man->man,x2.node,x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbminterms returned CUDD_OUT_OF_MEM");
	]])
FUN_2(,Cudd_Density, int, node__t, int,
      [[
	xr = Cudd_Density(x2.man->man,x2.node,x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbminterms returned CUDD_OUT_OF_MEM");
	]])
FUN_2_unsafe(,is_equal,node__t,node__t,bool,
	     [[
	       if (x1.man!=x2.man) caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	       xr = (x1.node == x2.node);
	       ]])
FUN_node3(,is_equal_when,node__t,node__t,node__t,bool,[[xr=Cudd_EquivDC(x1.man->man,x1.node,x2.node,Cudd_Not(x3.node));]])
CAMLprim value cudd_caml__list_of_support(value _v_no)
{
  CAMLparam1(_v_no); CAMLlocal2(res,r);
  node__t node = cudd_caml_node__t_ml2c(_v_no);
  DdNode * N = node.node;

  res = Val_int(0);
  while (! Cudd_IsConstant(N)){
    if (Cudd_IsComplement(N)){
      caml_invalid_argument("Bdd.list_of_support not called on a positive cube\n");
    }
    r = caml_alloc_small(2,0);
    Field(r,0) = Val_int(N->index);
    Field(r,1) = res;
    res = r;
    if (! Cudd_IsConstant(cuddE(N))){
      caml_invalid_argument("Bdd.list_of_support not called on a positive cube\n");
    }
    N = cuddT(N);
  }
  CAMLreturn(res);
}
CAMLprim value cudd_caml__list_of_cube(value _v_node)
{
  CAMLparam1(_v_node); CAMLlocal3(res,r,elt);
  node__t node = cudd_caml_node__t_ml2c(_v_node);
  DdNode *zero, *f, *fv, *fnv;
  int index;
  bool sign;

  f = node.node;
  zero = Cudd_Not(DD_ONE(node.man->man));
  res = Val_int(0);
  if (f==zero)
    caml_invalid_argument("Bdd.list_of_cube called on a false cube\n");
  else {
    while (! Cudd_IsConstant(f)){
      index = Cudd_Regular(f)->index;
      fv = Cudd_T(f);
      fnv = Cudd_E(f);
      if (Cudd_IsComplement(f)){
	fv = Cudd_Not(fv);
	fnv = Cudd_Not(fnv);
      }
      if (fv==zero){
	sign = false;
	f = fnv;
      }
      else if (fnv==zero){
	sign = true;
	f = fv;
      }
      else
	caml_invalid_argument("Bdd.list_of_cube not called on a cube\n");

      elt = caml_alloc_small(2,0);
      Field(elt,0) = Val_int(index);
      Field(elt,1) = Val_bool(sign);
      r = caml_alloc_small(2,0);
      Field(r,0) = elt;
      Field(r,1) = res;
      res = r;
    }
  }
  CAMLreturn(res);
}
CAMLprim value cudd_caml__minterm_of_cube(value _v_node)
{
  CAMLparam1(_v_node); CAMLlocal1(_v_res);
  node__t node = cudd_caml_node__t_ml2c(_v_node);
  DdNode *zero, *f, *fv, *fnv;
  int i,index;
  bool sign;

  int size = Cudd_ReadSize(node.man->man);
  _v_res = caml_alloc(size,0);
  for (i=0;i<size;i++)
    Field(_v_res,i)=Val_int(2);

  f = node.node;
  zero = Cudd_Not(DD_ONE(node.man->man));
  if (f==zero)
    caml_invalid_argument("Bdd.list_of_cube called on a false cube\n");
  else {
    while (! Cudd_IsConstant(f)){
      index = Cudd_Regular(f)->index;
      fv = Cudd_T(f);
      fnv = Cudd_E(f);
      if (Cudd_IsComplement(f)){
	fv = Cudd_Not(fv);
	fnv = Cudd_Not(fnv);
      }
      if (fv==zero){
	sign = false;
	f = fnv;
      }
      else if (fnv==zero){
	sign = true;
	f = fv;
      }
      else
	caml_invalid_argument("Bdd.list_of_cube not called on a cube\n");

      Field(_v_res,index) = Val_bool(sign);
    }
  }
  CAMLreturn(_v_res);
}

CAMLprim value cudd_caml__cube_of_minterm(value _v_man, value _v_array)
{
  CAMLparam2(_v_man,_v_array); CAMLlocal1(_v_res);
  man__t man = cudd_caml_man__t_ml2c(_v_man);

  int size = Wosize_val(_v_array);
  int maxsize = (size>man->man->size) ? size : man->man->size;
  {
    DdNode* tmp = Cudd_bddIthVar(man->man,maxsize-1);
    if (tmp==NULL) caml_invalid_argument("Bdd.cube_of_minterm: probably OUT_OF_MEM");
  }
  intarray_t array;
  array.size = maxsize;
  array.array = malloc(maxsize * sizeof(int));
  int i;
  for (i=0; i < size; i++) {
    value v = Field(_v_array, i);
    array.array[i] = Int_val(v);
  }
  for (i=size; i<maxsize; i++){
    array.array[i] = 2;
  }
  node__t _res;
  _res.man = man;
  _res.node = Cudd_CubeArrayToBdd(man->man,array.array);
  free(array.array);
  _v_res = cudd_caml_bdd__t_c2ml(_res);
  CAMLreturn(_v_res);
}

/* ********************************************************************** */
/* Semi-Generic functions */
/* ********************************************************************** */

CAMLprim value cudd_caml__cofactors(value v_is_bdd, value v_var, value v_no)
{
  CAMLparam2(v_var,v_no); CAMLlocal3(vthen,velse,vres);
  bool is_bdd = Bool_val(v_is_bdd);
  int var = Int_val(v_var);
  node__t no = cudd_caml_node__t_ml2c(v_no);
  node__t nothen,noelse;

  nothen.man = noelse.man = no.man;
  nothen.node = Cudd_Cofactor(no.man->man,no.node,no.man->man->vars[var]);
  if (nothen.node==NULL){
    vres = cudd_caml_node__t_c2ml(nothen);
    goto cudd_caml_cofactors_exit;
  }
  cuddRef(nothen.node);
  noelse.node = Cudd_Cofactor(no.man->man,no.node,Cudd_Not(no.man->man->vars[var]));
  if (noelse.node==NULL){
    Cudd_RecursiveDeref(no.man->man,nothen.node);
    vres = cudd_caml_node__t_c2ml(noelse);
    goto cudd_caml_cofactors_exit;
  }
  velse = cudd_caml_bddnode__t_c2ml(is_bdd,noelse);
  cuddDeref(nothen.node);
  vthen = cudd_caml_bddnode__t_c2ml(is_bdd,nothen);
  vres = caml_alloc_small(2,0);
  Field(vres,0) = vthen;
  Field(vres,1) = velse;
 cudd_caml_cofactors_exit:
  CAMLreturn(vres);
}
CAMLprim value cudd_caml__ite_cst(value v_is_bdd, value v1, value v2, value v3)
{
  CAMLparam3(v1,v2,v3);
  CAMLlocal2(vr,vres);
  bool is_bdd = Bool_val(v_is_bdd);
  node__t x1 = cudd_caml_node__t_ml2c(v1);
  node__t x2 = cudd_caml_node__t_ml2c(v2);
  node__t x3 = cudd_caml_node__t_ml2c(v3);
  if (x1.man!=x2.man || x1.man!=x3.man)
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  DdNode* node = is_bdd ? Cudd_bddIteConstant(x1.man->man,x1.node,x2.node,x3.node) : Cuddaux_addIteConstant(x1.man->man,x1.node,x2.node,x3.node);
  value vres;
  if (node==DD_NON_CONSTANT || !Cudd_IsConstant(node))
    vres = Val_int(0);
  else {
    if (is_bdd){
      vr = Val_bool(node==DD_ONE(x1.man->man));
    } else {
      vr = Val_DdNode(x1.man->caml,node);
    }
    vres = caml_alloc_small(1,0);
    Field(vres,0) = vr;
  }
  CAMLreturn(vres);
}
CAMLprim value cudd_caml__is_ite_cst(value v_is_bdd, value v1, value v2, value v3)
{
  CAMLparam3(v1,v2,v3);
  bool is_bdd = Bool_val(v_is_bdd);
  node__t x1 = cudd_caml_node__t_ml2c(v1);
  node__t x2 = cudd_caml_node__t_ml2c(v2);
  node__t x3 = cudd_caml_node__t_ml2c(v3);
  if (x1.man!=x2.man || x1.man!=x3.man)
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  DdNode* res = is_bdd ? Cudd_bddIteConstant(x1.man->man,x1.node,x2.node,x3.node) : Cuddaux_addIteConstant(x1.man->man,x1.node,x2.node,x3.node);
  bool b = res!=DD_NON_CONSTANT && Cudd_IsConstant(res);
  value vres = Val_bool(b);
  CAMLreturn(vres);
}
CAMLprim value cudd_caml__varmap(value v_is_bdd, value v1)
{
  CAMLparam1(v1);
  bool is_bdd = Bool_val(v_is_bdd);
  node__t x1 = cudd_caml_node__t_ml2c(v1);
  node__t xr;
  xr.man = x1.man;
  xr.node = is_bdd ? Cudd_bddVarMap(x1.man->man,x1.node) : Cuddaux_addVarMap(x1.man->man,x1.node);
  value vr = cudd_caml_bddnode__t_c2ml(is_bdd,xr);
  CAMLreturn(vr);
}
CAMLprim value cudd_caml__permute(value v_is_bdd, value v_omemo, value v_perm, value v_node)
{
  CAMLparam3(v_omemo,v_node,v_perm);
  bool is_bdd = Bool_val(v_is_bdd);
  node__t node = cudd_caml_node__t_ml2c(v_node);
  int size = Wosize_val(v_perm);
  int maxsize = (size>node.man->man->size) ? size : node.man->man->size;
  intarray_t perm;
  perm.size = maxsize;
  perm.array = malloc(maxsize * sizeof(int));
  int i;
  for (i=0; i < size; i++) {
    value v = Field(v_perm, i);
    perm.array[i] = Int_val(v);
  }
  for (i=size; i<maxsize; i++){
    perm.array[i] = i;
  }
  node__t xr;
  xr.man = node.man;
  if (Is_block(v_omemo)){
    struct common common;
    common.pid = &cudd_caml__permute;
    common.arity = 1;
    common.memo = cudd_caml_memo__t_ml2c(Field(v_omemo,0));
    common.man = node.man;
    xr.node = is_bdd ?
      Cuddaux_bddPermuteCommon(&common,node.node,perm.array) :
      Cuddaux_addPermuteCommon(&common,node.node,perm.array);
  } else {
    xr.node = is_bdd ?
      Cudd_bddPermute(node.man->man,node.node,perm.array) :
      Cudd_addPermute(node.man->man,node.node,perm.array);
  }
  free(perm.array);
  value vr = cudd_caml_bddnode__t_c2ml(is_bdd,xr);
  CAMLreturn(vr);
}
CAMLprim value cudd_caml__compose(value v_is_bdd, value v_var, value v_bdd, value v_node)
{
  CAMLparam2(v_bdd,v_node);

  bool is_bdd = Bool_val(v_is_bdd);
  int var = Int_val(v_var);
  node__t bdd = cudd_caml_node__t_ml2c(v_bdd);
  node__t node = cudd_caml_node__t_ml2c(v_node);
  if (bdd.man!=node.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  node__t xr;
  xr.man = node.man;
  xr.node = is_bdd ?
    Cudd_bddCompose(node.man->man,node.node,bdd.node,var) :
    Cuddaux_addCompose(node.man->man,node.node,bdd.node,var);
  value vr = cudd_caml_bddnode__t_c2ml(is_bdd,xr);
  CAMLreturn(vr);
}
CAMLprim value cudd_caml__vectorcompose(value v_is_bdd, value v_omemo, value v_tnode, value v_node)
{
  CAMLparam3(v_omemo,v_tnode,v_node);
  bool is_bdd = Bool_val(v_is_bdd);
  node__t node = cudd_caml_node__t_ml2c(v_node);
  int size = Wosize_val(v_tnode);
  int maxsize = (size>node.man->man->size) ? size : node.man->man->size;
  DdNode** tnode = malloc(maxsize * sizeof(DdNode*));
  int i;
  for (i=0; i < size; i++) {
    value v = Field(v_tnode, i);
    node__t no = cudd_caml_node__t_ml2c(v);
    if (no.man!=node.man){
      free(tnode);
      caml_invalid_argument("Cudd.vectorcompose called with BDDs/DDs belonging to different managers !");
    }
    tnode[i] = no.node;
  }
  for (i=size; i<maxsize; i++){
    tnode[i] = node.man->man->vars[i];;
  }
  node__t xr;
  xr.man = node.man;
  if (Is_block(v_omemo)){
    struct common common;
    common.pid = &cudd_caml__vectorcompose;
    common.arity = 1;
    common.memo = cudd_caml_memo__t_ml2c(Field(v_omemo,0));
    common.man = node.man;
    xr.node = is_bdd ?
      Cuddaux_bddVectorComposeCommon(&common,node.node,tnode) :
      Cuddaux_addVectorComposeCommon(&common,node.node,tnode);
  } else {
    xr.node = is_bdd ?
      Cudd_bddVectorCompose(node.man->man,node.node,tnode) :
      Cuddaux_addVectorCompose(node.man,node.node,tnode);
  }
  free(tnode);
  value vr = cudd_caml_bddnode__t_c2ml(is_bdd,xr);
  CAMLreturn(vr);
}
CAMLprim value cudd_caml__iter_node(value v_is_bdd, value v_closure, value v_no)
{
  CAMLparam2(v_closure,v_no); CAMLlocal1(v_snode);
  bool is_bdd = Bool_val(v_is_bdd);
  node__t no = cudd_caml_node__t_ml2c(v_no);
  bool autodyn = false;
  Cudd_ReorderingType heuristic;
  if (Cudd_ReorderingStatus(no.man->man,&heuristic)){
    autodyn = true;
    Cudd_AutodynDisable(no.man->man);
  }
  node__t snode;
  DdGen* gen;
  snode.man = no.man;
  Cudd_ForeachNode(no.man->man,no.node,gen,snode.node)
    {
      v_snode = cudd_caml_bddnode__t_c2ml(is_bdd,snode);
      caml_callback(v_closure,v_snode);
    }
  if (autodyn) Cudd_AutodynEnable(no.man->man,CUDD_REORDER_SAME);
  CAMLreturn(Val_unit);
}
CAMLprim value cudd_caml__transfer(value v_is_bdd, value v1, value v2)
{
  CAMLparam2(v1,v2);
  bool is_bdd = Bool_val(v_is_bdd);
  node__t x1 = cudd_caml_node__t_ml2c(v1);
  man__t x2 = cudd_caml_man__t_ml2c(v2);
  node__t xr;
  xr.man = x2;
  xr.node = is_bdd ?
    Cudd_bddTransfer(x1.man->man,x2->man,x1.node) :
    Cuddaux_addTransfer(x1.man->man,x2->man,x1.node);
  value vr = cudd_caml_bddnode__t_c2ml(is_bdd,xr);
  CAMLreturn(vr);
}
/* ********************************************************************** */
/* BDD functions */
/* ********************************************************************** */
typedef DdNode*(*bdd_binop_ptr)(DdManager*,DdNode*,DdNode*);
bdd_binop_ptr bdd_binop_tab[17]={
  &Cudd_Cofactor,
  &Cudd_bddLiteralSetIntersection,
  &Cudd_bddAnd,
  &Cudd_bddOr,
  &Cudd_bddXor,
  &Cudd_bddIntersect,
  &Cudd_bddExistAbstract,
  &Cudd_bddUnivAbstract,
  &Cudd_bddConstrain,
  &Cuddaux_bddTDConstrain,
  &Cudd_bddRestrict,
  &Cuddaux_bddTDRestrict,
  &Cudd_bddMinimize,
  &Cudd_bddLICompaction,
  &Cudd_bddSqueeze,
  &Cuddaux_addGuardOfNode
};
FUN_3(bdd,binop,int,node__t,node__t,bdd__t,
      [[
	if (x2.man!=x3.man)
	  caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	bdd_binop_ptr ptr = bdd_binop_tab[x1];
	xr.man = x2.man;
	xr.node = ptr(x2.man->man,x2.node,x3.node);
	]])

typedef DdNode*(*bdd_terop_ptr)(DdManager*,DdNode*,DdNode*,DdNode*);
bdd_terop_ptr bdd_terop_tab[3]={
  &Cudd_bddIte,
  &Cudd_bddAndAbstract,
  &Cudd_bddXorExistAbstract
};
FUN_4(bdd,terop,int,node__t,node__t,node__t,bdd__t,
      [[
	if (x2.man!=x3.man || x2.man!=x4.man)
	  caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
	bdd_terop_ptr ptr = bdd_terop_tab[x1];
	xr.man = x2.man;
	xr.node = ptr(x2.man->man,x2.node,x3.node,x4.node);
	]])

typedef int (*bdd_decomp_ptr)(DdManager*,DdNode*,DdNode***);
bdd_decomp_ptr bdd_decomp_tab[8]={
  &Cudd_bddApproxConjDecomp,
  &Cudd_bddIterConjDecomp,
  &Cudd_bddGenConjDecomp,
  &Cudd_bddVarConjDecomp,
  &Cudd_bddApproxDisjDecomp,
  &Cudd_bddIterDisjDecomp,
  &Cudd_bddGenDisjDecomp,
  &Cudd_bddVarDisjDecomp
};
CAMLprim value cudd_caml_bdd_decomp(value v0, value v1)
{
  CAMLparam1(v1);
  node__t x1 = cudd_caml_node__t_ml2c(v1);
  DdNode** tab;
  int x0=Int_val(v0);
  bdd_decomp_ptr ptr = bdd_decomp_tab[x0];
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

FUN_1_unsafe(bdd,Cudd_IsComplement,node_t,int)
FUN_1_unsafe(bdd,is_true,node__t,bool,[[xr = (x1.node == DD_ONE(x1.man->man));]])
FUN_1_unsafe(bdd,is_false,node__t,bool,[[xr = (x1.node != DD_ONE(x1.man->man));]])
FUN_node2(bdd,Cudd_bddLeq,node__t,node__t,bool)
FUN_node2(bdd,is_inter_empty,node__t,node__t,bool, [[xr = Cudd_bddLeq(x1.man->man,x1.node,Cudd_Not(x2.node));]])
FUN_node3(bdd,is_leq_when,node__t,node__t,node__t,bool,[[xr=Cudd_bddLeqUnless(x1.man->man,x1.node,x2.node,Cudd_Not(x3.node));]])
FUN_2(bdd,is_var_dependent,int,node__t,bool,
      [[
	DdNode* v = Cudd_bddIthVar(x2.man->man,x1);
	xr = Cudd_bddVarIsDependent(x2.man->man, x2.node, v);
	]])


CAMLprim value cudd_caml_bdd_inspect(value vno)
{
  CAMLparam1(vno); CAMLlocal3(vres,vthen,velse);
  node__t no = cudd_caml_node__t_ml2c(vno);
  DdNode* N = Cudd_Regular(no.node);
  if (cuddIsConstant(N)){
   vres = caml_alloc_small(1,0);
   Field(vres,0) = Val_bool(no.node == DD_ONE(no.man->man));
  }
  else {
    node__t bthen,belse;
    bthen.man = belse.man = no.man;
    bthen.node = cuddT(N);
    belse.node = cuddE(N);
    if (Cudd_IsComplement(no.node)) {
      bthen.node = Cudd_Not(bthen.node);
      belse.node = Cudd_Not(belse.node);
    }
    vthen = cudd_caml_bdd__t_c2ml(bthen);
    velse = cudd_caml_bdd__t_c2ml(belse);
    vres = caml_alloc_small(3,1);
    Field(vres,0) = Val_int(N->index);
    Field(vres,1) = vthen;
    Field(vres,2) = velse;
  }
  CAMLreturn(vres);
}

FUN_1(bdd,Cudd_T,node__t,bdd__t,
      [[
	if (Cudd_IsConstant(x1.node))
	  caml_invalid_argument ("Bdd.dthen: constant BDD");
	xr.man = x1.man;
	xr.node = Cudd_T(x1.node);
	if (Cudd_IsComplement(x1.node)) xr.node = Cudd_Not(xr.node);
	]])
FUN_1(bdd,Cudd_E,node__t,bdd__t,
      [[
	if (Cudd_IsConstant(x1.node))
	  caml_invalid_argument ("Bdd.delse: constant BDD");
	xr.man = x1.man;
	xr.node = Cudd_E(x1.node);
	if (Cudd_IsComplement(x1.node)) xr.node = Cudd_Not(xr.node);
	]])


FUN_1(bdd,dtrue,man__t,bdd__t,[[xr.man = x1; xr.node = DD_ONE(x1->man);]])
FUN_1(bdd,dfalse,man__t,bdd__t,[[xr.man = x1; xr.node = Cudd_Not(DD_ONE(x1->man));]])
FUN_2(bdd,Cudd_bddIthVar,man__t,int,bdd__t,[[xr.man = x1; xr.node = Cudd_bddIthVar(x1->man,x2);]])
FUN_1(bdd,Cudd_bddNewVar,man__t,bdd__t,[[xr.man = x1; xr.node = Cudd_bddNewVar(x1->man);]])
FUN_2(bdd,Cudd_bddNewVarAtLevel,man__t,int,bdd__t,[[xr.man = x1; xr.node = Cudd_bddNewVarAtLevel(x1->man,x2);]])

FUN_1(bdd, Cudd_Not, node__t, bdd__t, [[xr.man=x1.man;xr.node=Cudd_Not(x1.node);]])
FUN_node1_node(bdd, Cudd_FindEssential, node__t, bdd__t)
FUN_node1_1_node(bdd, Cudd_bddBooleanDiff, node__t, int, bdd__t)

FUN_1(bdd, Cudd_CountPathsToNonZero, node_t, double,
      [[
	xr = Cudd_CountPathsToNonZero(x1);
	if (xr==(double)CUDD_OUT_OF_MEM)
	  caml_failwith("Bdd.nbpaths returned CUDD_OUT_OF_MEM");
	]])

CAMLprim value cudd_caml_pick_minterm(value _v_no)
{
  CAMLparam1(_v_no);
  CAMLlocal1(_v_array);
  node__t no = cudd_caml_node__t_ml2c(_v_no);

  int size = no.man->man->size;
  char array[1024];
  char* string = size>1024 ? (char*)malloc(size) : array;
  if (string==NULL){
    caml_failwith("Bdd.pick_minterm: out of memory");
  }
  int res = Cudd_bddPickOneCube(no.man->man,no.node,string);
  if (res==0){
    if (size>1024) free(string);
    caml_failwith("Bdd.pick_minterm: (probably) second argument is not a positive cube");
  }
  _v_array = caml_alloc(size,0);
  for(int i=0; i<size; i++){
    Store_field(_v_array,i,Val_int(array[i]));
    /* Allowed according to caml/memory.h memory.c */
  }
  if (size>1024) free(string);
  CAMLreturn(_v_array);
}

int array_of_support(DdManager* man, DdNode* supp, DdNode*** pvars, int* psize)
{
  int i,size;
  DdNode* zero;
  DdNode* one;;
  DdNode* f;
  DdNode** vars;

  f = supp;
  one = DD_ONE(man);
  zero = Cudd_Not(one);
  size = 0;
  while (! Cudd_IsConstant(f)){
    if (Cudd_IsComplement(f) || cuddE(f)!=zero){
      return 1;
    }
    f = cuddT(f);
    size++;
  }
  if (size==0) return 2;
  vars = (DdNode**)malloc(size*sizeof(DdNode*));
  f = supp;
  for (i=0; i<size; i++){
    vars[i] = Cudd_ReadVars(man,f->index);
    f = cuddT(f);
  }
  *pvars = vars;
  *psize=size;
  return 0;
}

CAMLprim value cudd_caml_pick_cube_on_support(value _v_no1, value _v_no2)
{
  CAMLparam2(_v_no1,_v_no2); CAMLlocal1(_v_res);
  node__t no1 = cudd_caml_node__t_ml2c(_v_no1);
  node__t no2 = cudd_caml_node__t_ml2c(_v_no2);
  if (no1.man!=no2.man){
    caml_invalid_argument ("Bdd.pick_cube_on_support called with BDDs belonging to different managers !");
  }
  DdNode** vars;
  int size;
  int ret = array_of_support(no1.man->man,no1.node,&vars,&size);
  if (ret==1){
    caml_invalid_argument("Bdd.pick_cube_on_support: the first argument is not a positive cube");
  }
  else if (ret==2){
    caml_failwith("Bdd.pick_cube_on_support: empty support or out of memory");
  }
  node__t res;
  res.man = no1.man;
  res.node = Cudd_bddPickOneMinterm(no2.man->man,no2.node,vars,size);
  free(vars);
  _v_res = cudd_caml_bdd__t_c2ml(res);
  CAMLreturn(_v_res);
}

CAMLprim value cudd_caml_pick_cubes_on_support(value _v_no1, value _v_k, value _v_no2)
{
  CAMLparam2(_v_no1,_v_no2); CAMLlocal2(v,_v_res);
  int k = Int_val(_v_k);
  node__t no1 = cudd_caml_node__t_ml2c(_v_no1);
  node__t no2 = cudd_caml_node__t_ml2c(_v_no2);
  if (no1.man!=no2.man){
    caml_invalid_argument ("Bdd.pick_cubes_on_support called with BDDs belonging to different managers !");
  }
  DdNode** vars;
  int size;
  int ret = array_of_support(no1.man->man,no1.node,&vars,&size);
  if (ret==1){
    caml_invalid_argument("Bdd.pick_cubes_on_support: the first argument is not a positive cube");
  }
  else if (ret==2){
    caml_failwith("Bdd.pick_cubes_on_support: empty support or out of memory");
  }
  DdNode** array = Cudd_bddPickArbitraryMinterms(no2.man->man,no2.node,vars,size,k);
  free(vars);
  if (array==NULL){
    caml_failwith("Bdd.pick_cubes_on_support: out of memory, or first argument is false, or wrong support, or number of minterms < k");
  }

  if (k==0){
    _v_res = Atom(0);
  }
  else {
    for(int i=0; i<k; i++) cuddRef(array[k]);
    cudd_caml_tnode_c2ml(no1.man,array,k);
    for(int i=0; i<k; i++) cuddDeref(array[k]);
  }
  CAMLreturn(_v_res);
}
CAMLprim value cudd_caml_bdd_iter_cube(value _v_closure, value _v_no)
{
  CAMLparam2(_v_closure,_v_no); CAMLlocal1(_v_array);
  node__t no = cudd_caml_node__t_ml2c(_v_no);

  bool autodyn = false;
  Cudd_ReorderingType heuristic;
  if (Cudd_ReorderingStatus(no.man->man,&heuristic)){
    autodyn = true;
    Cudd_AutodynDisable(no.man->man);
  }
  int size = no.man->man->size;
  DdGen* gen;
  int* array;
  double val;
  Cudd_ForeachCube(no.man->man,no.node,gen,array,val)
    {
      ARRAY_c2ml(_v_array,int,array,size);
      caml_callback(_v_closure,_v_array);
    }
  if (autodyn) Cudd_AutodynEnable(no.man->man,CUDD_REORDER_SAME);
  CAMLreturn(Val_unit);
}
CAMLprim value cudd_caml_bdd_iter_prime(value _v_closure, value _v_lower, value _v_upper)
{
  CAMLparam3(_v_closure,_v_lower,_v_upper); CAMLlocal1(_v_array);
  node__t lower = cudd_caml_node__t_ml2c(_v_lower);
  node__t upper = cudd_caml_node__t_ml2c(_v_upper);

  if (lower.man!=upper.man){
    caml_invalid_argument("Bdd.iter_prime called with BDDs belonging to different managers !");
  }
  bool autodyn = false;
  Cudd_ReorderingType heuristic;
  if (Cudd_ReorderingStatus(lower.man->man,&heuristic)){
    autodyn = true;
    Cudd_AutodynDisable(lower.man->man);
  }
  int size = lower.man->man->size;
  DdGen* gen;
  int* array;
  Cudd_ForeachPrime(lower.man->man,lower.node,upper.node,gen,array)
    {
      ARRAY_c2ml(_v_array,int,array,size);
      caml_callback(_v_closure,_v_array);
    }
  if (autodyn) Cudd_AutodynEnable(lower.man->man,CUDD_REORDER_SAME);
  CAMLreturn(Val_unit);
}

FUN_4(bdd, Cudd_bddClippingAnd, int, int, node__t, node__t, bdd__t,
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
	xr.man=x3.man;
	xr.node=Cudd_bddClippingAndAbstract(x4.man->man,x4.node,x5.node,x3.node,x1,x2);
	]])
FUN_5(bdd,Cudd_UnderApprox,int,int,bool,double,node__t,bdd__t,
      [[xr.man=x5.man; xr.node=Cudd_UnderApprox(x5.man->man,x5.node,x1,x2,x3,x4);]])
FUN_4(bdd,Cudd_RemapUnderApprox,int,int,double,node__t,bdd__t,
      [[xr.man=x4.man; xr.node=Cudd_RemapUnderApprox(x4.man->man,x4.node,x1,x2,x3);]])
FUN_6(bdd,Cudd_BiasedUnderApprox,int,int,double,double,node__t,node__t,bdd__t,
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
FUN_4(bdd,Cudd_SubsetShortPaths,int,int,bool,node__t,bdd__t,
      [[xr.man=x4.man; xr.node=Cudd_SubsetShortPaths(x4.man->man,x4.node,x1,x2,x3);]])

FUN_2(bdd,Cudd_bddTransfer, node__t, man__t, bdd__t,
      [[xr.man=x2;xr.node=Cudd_bddTransfer(x1.man->man,x2->man,x1.node);]])
FUN_node2(bdd,Cudd_bddCorrelation, node__t,node__t,double,
	  [[
	    xr=Cudd_bddCorrelation(x1.man->man,x1.node,x2.node);
	    if (xr==(double)CUDD_OUT_OF_MEM)
	      caml_failwith("Bdd.correlation returned CUDD_OUT_OF_MEM");
	    ]])
FUN_node2_1(bdd,Cudd_bddCorrelationWeights, node__t,node__t,doublearray_t, double,
	    [[
	      xr=Cudd_bddCorrelationWeights(x1.man->man,x1.node,x2.node,x3.array);
	      free(x3.array);
	      if (xr==(double)CUDD_OUT_OF_MEM)
		caml_failwith("Bdd.correlationweights returned CUDD_OUT_OF_MEM");
	      ]])

/* ********************************************************************** */
/* AVDD functions */
/* ********************************************************************** */

typedef DdNode*(*avdd_binop_ptr)(DdManager*,DdNode*,DdNode*);
avdd_binop_ptr avdd_binop_tab[5]={
  &Cudd_Cofactor,
  &Cuddaux_addConstrain,
  &Cuddaux_addTDConstrain,
  &Cuddaux_addRestrict,
  &Cuddaux_addTDRestrict,
};
FUN_3(avdd,binop,int,node__t,node__t,node__t,
      [[
	if (x2.man!=x3.man)
	  caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	bdd_binop_ptr ptr = bdd_binop_tab[x1];
	xr.man = x2.man;
	xr.node = ptr(x2.man->man,x2.node,x3.node);
	]])
FUN_1(avdd,cuddT,node__t,node__t,
      [[
	xr.man = x1.man;
	if (cuddIsConstant(x1.node))
	  caml_invalid_argument ("Bdd.dthen: constant BDD");
	xr.node = cuddT(x1.node);
	]])
FUN_1(avdd,cuddE,node__t,node__t,
      [[
	xr.man = x1.man;
	if (cuddIsConstant(x1.node))
	  caml_invalid_argument ("Bdd.delse: constant BDD");
	xr.node = cuddE(x1.node);
	]])
CAMLprim value cudd_caml_avdd_dval(value vno)
{
  CAMLparam1(vno); CAMLlocal1(vres);
  node__t no =  cudd_caml_node__t_ml2c(vno);
  if (!cuddIsConstant(no.node))
    caml_invalid_argument("Add|Vdd.dval: non constant DD");
  vres = Val_DdNode(no.man->caml,no.node);
  CAMLreturn(vres);
}
CAMLprim value cudd_caml_avdd_cst(value vman, value vleaf)
{
  CAMLparam2(vman,vleaf); CAMLlocal1(vres);
  man__t man = cudd_caml_man__t_ml2c(vman);
  CuddauxType type = Type_val(man->caml,vleaf);
  node__t _res;
  _res.man = man;
  _res.node = cuddauxUniqueType(man,&type);
  vres = cudd_caml_node__t_c2ml(_res);
  CAMLreturn(vres);
}
FUN_node3_node(avdd,Cuddaux_addIte,node__t,node__t,node__t,node__t)
CAMLprim value cudd_caml_avdd_eval_cst(value vno1, value vno2)
{
  CAMLparam2(vno1,vno2); CAMLlocal2(v,vres);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  if (no1.man!=no2.man){
    caml_invalid_argument("Dd: binary function called with nodes belonging to different managers !");
  }
  DdNode* node = Cuddaux_addEvalConst(no1.man->man,no1.node,no2.node);
  if (node==DD_NON_CONSTANT || !cuddIsConstant(node))
    vres = Val_int(0);
  else {
    v = Val_DdNode(no1.man->caml,node);
    vres = caml_alloc_small(1,0);
    Field(vres,0) = v;
  }
  CAMLreturn(vres);
}
CAMLprim value cudd_caml_avdd_is_eval_cst(value vno1, value vno2)
{
  CAMLparam2(vno1,vno2); CAMLlocal2(v,vres);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  if (no1.man!=no2.man){
    caml_invalid_argument("Dd: binary function called with nodes belonging to different managers !");
  }
  DdNode* node = Cuddaux_addEvalConst(no1.man->man,no1.node,no2.node);
  vres = Val_bool(node!=DD_NON_CONSTANT && cuddIsConstant(node));
  CAMLreturn(vres);
}
CAMLprim value cudd_caml_avdd_iter_cube(value _v_closure, value _v_no)
{
  CAMLparam2(_v_closure,_v_no); CAMLlocal2(_v_array,_v_val);
  node__t no = cudd_caml_node__t_ml2c(_v_no);

  bool autodyn = 0;
  Cudd_ReorderingType heuristic;
  if (Cudd_ReorderingStatus(no.man->man,&heuristic)){
    autodyn = 1;
    Cudd_AutodynDisable(no.man->man);
  }
  int size = no.man->man->size;
  DdGen* gen;
  int* array;
  double val;
  Cudd_ForeachCube(no.man->man,no.node,gen,array,val)
    {
      if (size==0) {
	_v_array = Atom(0);
      }
      else {
	_v_array = caml_alloc(size,0);
	for(int i=0; i<size; i++){
	  Store_field(_v_array,i,Val_int(array[i]));
	/* Allowed according to caml/memory.h memory.c */
	}
      }
      if (no.man->caml){
	CuddauxType type;
	type.dbl = val;
	_v_val = type.value;
      }
      else {
	_v_val = copy_double(val);
      }
      caml_callback2(_v_closure,_v_array,_v_val);
    }
  if (autodyn) Cudd_AutodynEnable(no.man->man,CUDD_REORDER_SAME);
  CAMLreturn(Val_unit);
}
FUN_1(avdd,guard_of_nonbackground,node__t,bdd__t,
      [[
	xr.man = x1.man;
	DdNode* add = Cudd_ReadBackground(x1.man->man);
	cuddRef(add);
	xr.node = Cuddaux_addGuardOfNode(x1.man->man,x1.node,add);
	xr.node = Cudd_Not(xr.node);
	cuddDeref(add);
	]])

CAMLprim value cudd_caml_avdd_nodes_below_level(value _v_olevel, value _v_omax, value _v_no)
{
  CAMLparam1(_v_no);
  CAMLlocal2(res,v);
  node__t no = cudd_caml_node__t_ml2c(_v_no);
  int level;
  if (Is_long(_v_olevel))
    level = CUDD_MAXINDEX;
  else {
    value _v_level = Field(_v_olevel,0);
    level = Int_val(_v_level);
  }
  int max;
  if (Is_long(_v_omax))
    max = 0;
  else {
    value _v_max = Field(_v_omax,0);
    max = Int_val(_v_max);
  }
  int size;
  cuddaux_list_t* list = Cuddaux_NodesBelowLevel(no.man->man,no.node,level,max,&size,!no.man->caml);

  /* Create and fill the array */
  if (size==0){
    res = Atom(0);
  }
  else {
    cuddaux_list_t* p; int i;
    res = caml_alloc(size,0);
    for(p=list, i=0; p!=NULL; p=p->next,i++){
      assert(p->node->ref>=1);
      no.node = p->node;
      v = cudd_caml_node__t_c2ml(no);
      Store_field(res,i,v);
    }
  }
  cuddaux_list_free(list);
  CAMLreturn(res);
}
CAMLprim value cudd_caml_avdd_guard_of_leaf(value _v_no, value _v_leaf)
{
  CAMLparam2(_v_no,_v_leaf);
  CAMLlocal1(_vres);
  node__t no = cudd_caml_node__t_ml2c(_v_no);
  CuddauxType type = Type_val(no.man->caml,_v_leaf);
  DdNode* node = cuddauxUniqueType(no.man,&type);
  cuddRef(node);
  node__t _res;
  _res.man = no.man;
  _res.node = Cuddaux_addGuardOfNode(no.man->man,no.node,node);
  cuddDeref(node);
  _vres = cudd_caml_bdd__t_c2ml(_res);
  CAMLreturn(_vres);
}
CAMLprim value cudd_caml_avdd_leaves(value _v_no)
{
  CAMLparam1(_v_no); CAMLlocal1(vres);
  node__t no = cudd_caml_node__t_ml2c(_v_no);
  int size;
  cuddaux_list_t* list = Cuddaux_NodesBelowLevel(no.man->man,no.node,CUDD_MAXINDEX,0,&size,!no.man->caml);
  /* Create and fill the array */
  if (size==0){
    vres = Atom(0);
  }
  else {
    vres =
      no.man->caml ?
      caml_alloc(size,0) :
      caml_alloc(size * Double_wosize,Double_array_tag);
    ;
    cuddaux_list_t* p; int i;
    for(p=list,i=0; p!=NULL; p=p->next,i++){
	if (no.man->caml){
	  Store_field(vres,i,cuddauxCamlV(p->node));
	}
	else {
	  Store_double_field(vres,i,cuddV(p->node));
	}
      }
  }
  cuddaux_list_free(list);
  CAMLreturn(vres);
}
CAMLprim value cudd_caml_avdd_pick_leaf(value _v_no)
{
  CAMLparam1(_v_no); CAMLlocal1(vres);
  node__t no = cudd_caml_node__t_ml2c(_v_no);
  int size;
  cuddaux_list_t* list = Cuddaux_NodesBelowLevel(no.man->man,no.node,CUDD_MAXINDEX,1,&size,!no.man->caml);
  if (list==NULL){
    caml_invalid_argument("A Mtbdd should never contain the CUDD background node !");
  }
  else {
    vres = Val_DdNode(no.man->caml,list->node);
  }
  cuddaux_list_free(list);
  CAMLreturn(vres);
}

/* ********************************************************************** */
/* ADD functions */
/* ********************************************************************** */
typedef DdNode*(*add_binop_ptr)(DdManager*,DdNode**,DdNode**);
add_binop_ptr add_binop_tab[10]={
  Cudd_addPlus,
  Cudd_addMinus,
  Cudd_addTimes,
  Cudd_addDivide,
  Cudd_addMinimum,
  Cudd_addMaximum,
  Cudd_addAgreement,
  Cudd_addDiff,
  Cudd_addThreshold,
  Cudd_addSetNZ
};
FUN_3(add,binop,int,node__t,node__t,node__t,
      [[
	if (x2.man!=x3.man)
	  caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	xr.man = x2.man;
	xr.node = Cudd_addApply(x2.man->man,add_binop_tab[x1],x2.node,x3.node);
	]])

typedef DdNode*(*add_binop2_ptr)(DdManager*,DdNode*,DdNode*);
add_binop2_ptr add_binop2_tab[2]={
  Cudd_addExistAbstract,
  Cudd_addUnivAbstract
};
FUN_3(add,binop2,int,node__t,node__t,node__t,
      [[
	if (x2.man!=x3.man)
	  caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
	DdNode* add = Cudd_BddToAdd(x2.man->man,x2.node);
	cuddRef(add);
	add_binop2_ptr ptr = add_binop2_tab[x1];
	xr.man = x2.man;
	xr.node = ptr(x2.man->man,x3.node,add);
	cuddRef(xr.node);
	Cudd_RecursiveDeref(x2.man->man,add);
	cuddDeref(xr.node);
	]])

typedef DdNode*(*add_matop_ptr)(DdManager*,DdNode*,DdNode*,DdNode**,int);
add_matop_ptr add_matop_tab[3]={
  Cudd_addMatrixMultiply,
  Cudd_addTimesPlus,
  Cudd_addTriangle
};

CAMLprim value cudd_caml_add_matop(value _v_op, value _v_array, value _v_no1, value _v_no2)
{
  CAMLparam3(_v_array,_v_no1,_v_no2); CAMLlocal1(_v_res);
  int op = Int_val(_v_op);
  node__t no1 = cudd_caml_node__t_ml2c(_v_no1);
  node__t no2 = cudd_caml_node__t_ml2c(_v_no2);
  if (no1.man!=no2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  int size = Wosize_val(_v_array);
  DdNode** array = malloc(size * sizeof(DdNode*));
  for (int i=0; i<size; i++){
    value _v_index = Field(_v_array,i);
    int index = Int_val(_v_index);
    array[i] = Cudd_bddIthVar(no1.man->man, index);
  }
  add_matop_ptr ptr = add_matop_tab[op];
  node__t no;
  no.man = no1.man;
  no.node = ptr(no1.man->man,no1.node,no2.node,array,size);
  _v_res = cudd_caml_node__t_c2ml(no);
  free(array);
  CAMLreturn(_v_res);
}

CAMLprim value cudd_caml_avdd_inspect(value vno)
{
  CAMLparam1(vno); CAMLlocal4(vres,vthen,velse,val);
  node__t no = cudd_caml_node__t_ml2c(vno);
  if (cuddIsConstant(no.node)){
    val = Val_DdNode(no.man->caml,no.node);
    vres = caml_alloc_small(1,0);
    Field(vres,0) = val;
  }
  else {
    node__t bthen,belse;
    bthen.man = belse.man = no.man;
    bthen.node = cuddT(no.node);
    belse.node = cuddE(no.node);
    vthen = cudd_caml_node__t_c2ml(bthen);
    velse = cudd_caml_node__t_c2ml(belse);
    vres = caml_alloc_small(3,1);
    Field(vres,0) = Val_int(no.node->index);
    Field(vres,1) = vthen;
    Field(vres,2) = velse;
  }
  CAMLreturn(vres);
}
FUN_node1_node(add,Cudd_addNegate,node__t,node__t)
FUN_1(add,log,node__t,node__t,
      [[
	xr.man = x1.man;
	xr.node = Cudd_addMonadicApply(x1.man->man,Cudd_addLog,x1.node);
	]])
FUN_node2(add,Cudd_addLeq,node__t,node__t,bool)
FUN_node1_node(add,Cudd_BddToAdd,node__t,node__t)
FUN_node1_node(add,Cudd_addBddPattern,node__t,bdd__t)
FUN_node1_1_node(add,Cudd_addBddThreshold,node__t,double,bdd__t)
FUN_node1_1_node(add,Cudd_addBddStrictThreshold,node__t,double,bdd__t)
FUN_3(add,Cudd_addBddInterval,node__t,double,double,bdd__t,[[xr.man=x1.man; xr.node=Cudd_addBddInterval(x1.man->man,x1.node,x2,x3);]])
