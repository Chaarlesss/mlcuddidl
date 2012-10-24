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

void cudd_caml_custom_common_ml2c(value val, struct common* c)
{
  value v;
  v = Field(val, 0); c->pid = cudd_caml_pid_ml2c(v);
  v = Field(val, 1); c->arity = Int_val(v);
  v = Field(val, 2); c->memo = cudd_caml_memo__t_ml2c(v);
  c->man = NULL;
  c->exn = Val_unit;
}

void cudd_caml_custom_op1_ml2c(value val, struct op1* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->common1);
  v = Field(val, 1); c->closure1 = v;
  c->funptr1 = NULL;
}

void cudd_caml_custom_op2_ml2c(value val, struct op2* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->common2);
  v = Field(val, 1); c->closure2 = v;
  v = Field(val, 2); c->ospecial2 = v;
  v = Field(val, 3); c->commutative = Int_val(v);
  v = Field(val, 4); c->idempotent = Int_val(v);
  c->funptr2 = NULL;
}

void cudd_caml_custom_test2_ml2c(value val, struct test2* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->common2t);
  v = Field(val, 1); c->closure2t = v;
  v = Field(val, 2); c->ospecial2t = v;
  v = Field(val, 3); c->symetric = Int_val(v);
  v = Field(val, 4); c->reflexive = Int_val(v);
  c->funptr2t = NULL;
}

void cudd_caml_custom_op3_ml2c(value val, struct op3* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->common3);
  v = Field(val, 1); c->closure3 = v;
  v = Field(val, 2); c->ospecial3 = v;
  c->funptr3 = NULL;
}

void cudd_caml_custom_opN_ml2c(value val, struct opN* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->commonN);
  v = Field(val, 1); c->arityNbdd = Int_val(v);
  v = Field(val, 2); c->closureN = v;
  c->funptrN = NULL;
}

void cudd_caml_custom_opG_ml2c(value val, struct opG* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->commonG);
  v = Field(val, 1); c->arityGbdd = Int_val(v);
  v = Field(val, 2); c->closureG = v;
  c->funptrG = NULL;
  v = Field(val, 3); c->oclosureBeforeRec = v;
  c->funptrBeforeRec = NULL;
  v = Field(val, 4); c->oclosureIte = v;
  c->funptrIte = NULL;
}

void cudd_caml_custom_exist_ml2c(value val, struct exist* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->commonexist);
  v = Field(val, 1); cudd_caml_custom_op2_ml2c(v, &c->combineexist);
}

void cudd_caml_custom_existand_ml2c(value val, struct existand* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->commonexistand);
  v = Field(val, 1); cudd_caml_custom_op2_ml2c(v, &c->combineexistand);
  v = Field(val, 2); c->bottomexistand = v;
}

void cudd_caml_custom_existop1_ml2c(value val, struct existop1* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->commonexistop1);
  v = Field(val, 1); cudd_caml_custom_op2_ml2c(v, &c->combineexistop1);
  v = Field(val, 2); cudd_caml_custom_op1_ml2c(v, &c->existop1);
}

void cudd_caml_custom_existandop1_ml2c(value val, struct existandop1* c)
{
  value v;
  v = Field(val, 0); cudd_caml_custom_common_ml2c(v, &c->commonexistandop1);
  v = Field(val, 1); cudd_caml_custom_op2_ml2c(v, &c->combineexistandop1);
  v = Field(val, 2); cudd_caml_custom_op1_ml2c(v, &c->existandop1);
  v = Field(val, 3); c->bottomexistandop1 = v;
}

value cudd_caml_custom_newpid(value v)
{
  pid xr=malloc(1);
  value vr = cudd_caml_pid_c2ml(xr);
  return vr;
}

value cudd_caml_custom_apply_op1(value vop, value vno)
{
  struct op1 op; cudd_caml_custom_op1_ml2c(vop,&op);
  node__t no = cudd_caml_node__t_ml2c(vno);
  op.common1.man = no.man;
  op.common1.exn = Val_unit;
  op.funptr1 = &cudd_caml_custom_op1;
  node__t res;
  Begin_roots4(vop,vno,op.common1.exn,op.closure1);
  res.man = no.man;
  res.node = Cuddaux_addApply1(&op,no.node);
  End_roots();
  if (op.common1.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.common1.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_op2(value vop, value vno1, value vno2)
{
  struct op2 op; cudd_caml_custom_op2_ml2c(vop,&op);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  if (no1.man!=no2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  op.common2.man = no1.man;
  op.common2.exn = Val_unit;
  op.funptr2 = &cudd_caml_custom_op2;
  node__t res;
  Begin_roots3(vop,vno1,vno2);
  Begin_roots3(op.common2.exn,op.closure2,op.ospecial2);
   res.man = no1.man;
   res.node = Cuddaux_addApply2(&op,no1.node,no2.node);
   End_roots();
   End_roots();
   if (op.common2.exn!=Val_unit){
     Cudd_ClearErrorCode(res.man->man);
     caml_raise(op.common2.exn);
   }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_test2(value vop, value vno1, value vno2)
{
  struct test2 op; cudd_caml_custom_test2_ml2c(vop,&op);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  if (no1.man!=no2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  op.common2t.man = no1.man;
  op.common2t.exn = Val_unit;
  op.funptr2t = &cudd_caml_custom_test2;
  bool res;
  Begin_roots3(vop,vno1,vno2);
  Begin_roots3(op.common2t.exn,op.closure2t,op.ospecial2t);
  res = Cuddaux_addTest2(&op,no1.node,no2.node);
  End_roots();
  End_roots();
  if (op.common2t.exn!=Val_unit){
    Cudd_ClearErrorCode(no1.man->man);
    caml_raise(op.common2t.exn);
  }
  if (res == -1){
    caml_failwith("Custom.apply_test2 returned -1");
  }
  return Val_bool(res);
}

value cudd_caml_custom_apply_op3(value vop, value vno1, value vno2, value vno3)
{
  struct op3 op; cudd_caml_custom_op3_ml2c(vop,&op);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  node__t no3 = cudd_caml_node__t_ml2c(vno3);
  if (no1.man!=no2.man || no1.man!=no3.man)
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  op.common3.man = no1.man;
  op.common3.exn = Val_unit;
  op.funptr3 = &cudd_caml_custom_op3;
  node__t res;
  Begin_roots4(vop,vno1,vno2,vno3);
  Begin_roots3(op.common3.exn,op.closure3,op.ospecial3);
  res.man = no1.man;
  res.node = Cuddaux_addApply3(&op,no1.node,no2.node,no3.node);
  End_roots();
  End_roots();
  if (op.common3.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.common3.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_opN(value vop, value vvec1, value vvec2)
{
  man__t man,man1,man2;
  struct opN op; cudd_caml_custom_opN_ml2c(vop,&op);
  cudd_caml_custom_opN_ml2c(vop, &op);
  int size1 = Wosize_val(vvec1);
  int size2 = Wosize_val(vvec2);
  int size=size1+size2;
  if (size!=op.commonN.arity || size1!=op.arityNbdd){
    caml_invalid_argument("Cudd.Custom.apply_opN: the arity of the operation is not equal to the size of the arrays of BDDs and VDDs");
  }
  else if (size==0){
    caml_invalid_argument("Cudd.Custom.apply_opN: empty array");
  }
  DdNode** vec = (DdNode**)malloc(size*sizeof(DdNode*));
  man = man1 = man2 = NULL;
  if (size1>0){
    man = man1 = cudd_caml_tnode_ml2c(vvec1,size1,vec);
    if (man1==NULL){
      free(vec);
      caml_invalid_argument("Custom.apply_opN called with BDDs belonging to different managers !");
    }
  }
  if (size2>0){
    man = man2 = cudd_caml_tnode_ml2c(vvec2,size2,vec+size1);
    if (man2==NULL){
      free(vec);
      caml_invalid_argument("Custom.apply_opN called with VDDs belonging to different managers !");
    }
  }
  if (size1>0 && size2>0 && man1!=man2){
    free(vec);
    caml_invalid_argument("Custom.apply_opN called with BDDs/VDDs belonging to different managers !");
  }
  op.commonN.man = man;
  op.commonN.exn = Val_unit;
  op.funptrN = &cudd_caml_custom_opNG;
  node__t res;
  Begin_roots5(vop,vvec1,vvec2,op.commonN.exn,op.closureN);
    res.man = man;
    res.node = Cuddaux_addApplyN(&op,vec);
  End_roots();
  free(vec);
  if (op.commonN.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.commonN.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_opG(value vop, value vvec1, value vvec2)
{
  man__t man,man1,man2;
  struct opG op; cudd_caml_custom_opG_ml2c(vop,&op);
  int size1 = Wosize_val(vvec1);
  int size2 = Wosize_val(vvec2);
  int size=size1+size2;
  if (size!=op.commonG.arity || size1!=op.arityGbdd){
    caml_invalid_argument("Cudd.Custom.apply_opG: the arity of the operation is not equal to the size of the arrays of BDDs and VDDs");
  }
  else if (size==0){
    caml_invalid_argument("Cudd.Custom.apply_opG: empty array");
  }
  DdNode** vec = (DdNode**)malloc(size*sizeof(DdNode*));
  man = man1 = man2 = NULL;
  if (size1>0){
    man = man1 = cudd_caml_tnode_ml2c(vvec1,size1,vec);
    if (man1==NULL){
      free(vec);
      caml_invalid_argument("Custom.apply_opG called with BDDs belonging to different managers !");
    }
  }
  if (size2>0){
    man = man2 = cudd_caml_tnode_ml2c(vvec2,size2,vec+size1);
    if (man2==NULL){
      free(vec);
      caml_invalid_argument("Custom.apply_opG called with VDDs belonging to different managers !");
    }
  }
  if (size1>0 && size2>0 && man1!=man2){
    free(vec);
    caml_invalid_argument("Custom.apply_opG called with BDDs/VDDs belonging to different managers !");
  }
  op.commonG.man = man;
  op.commonG.exn = Val_unit;
  op.funptrG = (DdNode* (*)(DdManager*, struct opG*, DdNode**))(&cudd_caml_custom_opNG);
  op.funptrBeforeRec =
    Is_block(op.oclosureBeforeRec) ?
    &cudd_caml_custom_opGbeforeRec :
    NULL;
  op.funptrIte =
    Is_block(op.oclosureIte) ?
    &cudd_caml_custom_opGite :
    NULL;
  node__t res;
  Begin_roots4(vop,vvec1,vvec2,op.commonG.exn);
  Begin_roots3(op.closureG,op.oclosureBeforeRec,op.oclosureIte);
    res.man = man;
    res.node = Cuddaux_addApplyG(&op,vec);
  End_roots();
  End_roots();
  free(vec);
  if (op.commonG.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.commonG.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_exist(value vop, value vno1, value vno2)
{
  struct exist op; cudd_caml_custom_exist_ml2c(vop,&op);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  if (no1.man!=no2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  op.commonexist.man = no1.man;
  op.commonexist.exn = Val_unit;
  op.combineexist.common2.man = no1.man;
  op.combineexist.common2.exn = Val_unit;
  op.combineexist.funptr2 = &cudd_caml_custom_op2;
  node__t res;
  Begin_roots3(vop,vno1,vno2);
  Begin_roots3(op.combineexist.common2.exn,op.combineexist.closure2,op.combineexist.ospecial2);
  res.man = no1.man;
  res.node = Cuddaux_addAbstract(&op,no2.node,no1.node);
  End_roots();
  End_roots();
  if (op.combineexist.common2.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.combineexist.common2.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_existand(value vop, value vno1, value vno2, value vno3)
{
  struct existand op; cudd_caml_custom_existand_ml2c(vop,&op);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  node__t no3 = cudd_caml_node__t_ml2c(vno3);
  if (no1.man!=no2.man || no1.man!=no3.man)
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  op.commonexistand.man = no1.man;
  op.commonexistand.exn = Val_unit;
  op.combineexistand.common2.man = no1.man;
  op.combineexistand.common2.exn = Val_unit;
  op.combineexistand.funptr2 = &cudd_caml_custom_op2;
  node__t res;
  Begin_roots4(vop,vno1,vno2,vno3);
  Begin_roots3(op.combineexistand.common2.exn,op.combineexistand.closure2,op.combineexistand.ospecial2);
  res.man = no1.man;
  res.node = NULL;
  DdNode* background =
    no1.man->caml ?
    Cuddaux_addCamlConst(no1.man->man,op.bottomexistand) :
    cuddUniqueConst(no1.man->man,Double_val(op.bottomexistand));
  ;
  if (background){
    cuddRef(background);
    res.node = Cuddaux_addBddAndAbstract(&op,no2.node,no3.node,no1.node,background);
    if (res.node) cuddRef(res.node);
    Cudd_RecursiveDeref(no1.man->man,background);
    if (res.node) cuddDeref(res.node);
  }
  End_roots();
  End_roots();
  if (op.combineexistand.common2.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.combineexistand.common2.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_existop1(value vop, value vno1, value vno2)
{
  struct existop1 op; cudd_caml_custom_existop1_ml2c(vop,&op);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  if (no1.man!=no2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  op.commonexistop1.man = no1.man;
  op.commonexistop1.exn = Val_unit;
  op.combineexistop1.common2.man = no1.man;
  op.combineexistop1.common2.exn = Val_unit;
  op.combineexistop1.funptr2 = &cudd_caml_custom_op2;
  op.existop1.common1.man = no1.man;
  op.existop1.common1.exn = Val_unit;
  op.existop1.funptr1 = &cudd_caml_custom_op1;
  node__t res;
  Begin_roots3(vop,vno1,vno2);
  Begin_roots5(op.combineexistop1.common2.exn,
	       op.existop1.common1.exn,
	       op.combineexistop1.closure2,op.combineexistop1.ospecial2,
	       op.existop1.closure1);
  res.man = no1.man;
  res.node = Cuddaux_addApplyAbstract(&op,no2.node,no1.node);
  End_roots();
  End_roots();
  if (op.existop1.common1.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.existop1.common1.exn);
  }
  else if (op.combineexistop1.common2.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.combineexistop1.common2.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}

value cudd_caml_custom_apply_existandop1(value vop, value vno1, value vno2, value vno3)
{
  struct existandop1 op; cudd_caml_custom_existandop1_ml2c(vop,&op);
  node__t no1 = cudd_caml_node__t_ml2c(vno1);
  node__t no2 = cudd_caml_node__t_ml2c(vno2);
  node__t no3 = cudd_caml_node__t_ml2c(vno3);
  if (no1.man!=no2.man || no1.man!=no3.man)
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  op.commonexistandop1.man = no1.man;
  op.commonexistandop1.exn = Val_unit;
  op.combineexistandop1.common2.man = no1.man;
  op.combineexistandop1.common2.exn = Val_unit;
  op.combineexistandop1.funptr2 = &cudd_caml_custom_op2;
  op.existandop1.common1.man = no1.man;
  op.existandop1.common1.exn = Val_unit;
  op.existandop1.funptr1 = &cudd_caml_custom_op1;
  node__t res;
  Begin_roots4(vop,vno1,vno2,vno3);
  Begin_roots5(op.combineexistandop1.common2.exn,
	       op.existandop1.common1.exn,
	       op.combineexistandop1.closure2,op.combineexistandop1.ospecial2,
	       op.existandop1.closure1);
  res.man = no1.man;
  DdNode* background =
    no1.man->caml ?
    Cuddaux_addCamlConst(no1.man->man,op.bottomexistandop1) :
    cuddUniqueConst(no1.man->man,Double_val(op.bottomexistandop1));
  ;
  if (background){
    cuddRef(background);
    res.node = Cuddaux_addApplyBddAndAbstract(&op,no2.node,no3.node,no1.node,NULL);
    if (res.node) cuddRef(res.node);
    Cudd_RecursiveDeref(no1.man->man,background);
    if (res.node) cuddDeref(res.node);
  }
  End_roots();
  End_roots();
  if (op.existandop1.common1.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.existandop1.common1.exn);
  }
  else if (op.combineexistandop1.common2.exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    caml_raise(op.combineexistandop1.common2.exn);
  }
  value vres = cudd_caml_node__t_c2ml(res);
  return vres;
}
