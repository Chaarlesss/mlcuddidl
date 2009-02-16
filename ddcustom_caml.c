/* User operations on MTBDDs */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include "caml/fail.h"
#include "caml/alloc.h"
#include "caml/custom.h"
#include "caml/memory.h"
#include "caml/callback.h"
#include "caml/camlidlruntime.h"
#include "cudd_caml.h"

/* ========================================================================= */
/* Declarations */
/* ========================================================================= */

typedef struct camlidl_tabop_elt {
  value closure[5];
  /* 0: operation itself
     1: absorbant_1: function returning an optional result
     2: absorbant_2: function returning an optional result
     3: neutral_1: function returning a boolean
     4: neutral_2: function returning a boolean */
  short int optype;
  /* 0: op1
     1: op2
     2: test2
     3: op3
     4: exist
     5: existop
     6: existand
     7: existandop
  */
  short int ddtype;
  /* 0: rdd, 1:idd, 2:vdd */
  short int commutative;
  short int idempotent;
  short int cachetype;
  /* 0: global, 1: local and automatic, 2: local and manual allocation/clearing */
  DdHashTable* table;
    /* If localCache, hashtable */
  short int indexop;
  short int indexop1;
} camlidl_tabop_elt;

static camlidl_tabop_elt* camlidl_tabop = NULL;
static int camlidl_tabop_size = 6;

static value camlidl_cudd_rivdd_op_exn = Val_unit;
/* Exception */

/* ========================================================================= */
/* Registering and removing user operations */
/* ========================================================================= */

static inline int camlidl_cudd_rivdd_is_op_free(int index)
{
  return (camlidl_tabop[index].closure[0] == Val_int(0));
}

int camlidl_cudd_ddcustom_hook(DdManager* dd, const char* s, void* data)
{
  int i;
  if (camlidl_tabop != NULL){
    for (i=0; i<camlidl_tabop_size; i++){
      if (!camlidl_cudd_rivdd_is_op_free(i) && 
	  camlidl_tabop[i].table != NULL &&
	  camlidl_tabop[i].table->manager == dd){
	cuddHashTableQuit(camlidl_tabop[i].table);
	camlidl_tabop[i].table = NULL;
      }
    }
  }
  return 1;
}

value camlidl_cudd_rivdd_register_op
(value v_ddtype, value v_cachetype, value v_optype, 
 value v_commutative, value v_idempotent,
 value v_op1, value v_op, 
 value v_taboclosure, value v_closure)
{
  CAMLparam5(v_cachetype, v_optype, v_ddtype, v_commutative, v_idempotent);
  CAMLxparam4(v_op, v_op1, v_taboclosure, v_closure);
  CAMLlocal1(v_res);
  int i,j;

  /* Allocate table if first call */
  if (camlidl_tabop==NULL){
    caml_register_global_root(&camlidl_cudd_rivdd_op_exn);
    camlidl_tabop = (camlidl_tabop_elt*)malloc(camlidl_tabop_size*
					       sizeof(camlidl_tabop_elt));
    for (i=0; i<camlidl_tabop_size; i++){
      for (j=0; j<5; j++){
	camlidl_tabop[i].closure[j] = Val_int(0);
	caml_register_global_root(&camlidl_tabop[i].closure[j]);
      }
    }
  }
  /* Look for a free identifier in i */
  for (i=0; i<camlidl_tabop_size; i++){
    if (camlidl_cudd_rivdd_is_op_free(i)) break;
  }
  /* Need to resize the table ? */
  if (i==camlidl_tabop_size){
    camlidl_tabop_elt* ntab;

    ntab = (camlidl_tabop_elt*)malloc(2*camlidl_tabop_size*
				      sizeof(camlidl_tabop_elt));
    for (i=0; i<camlidl_tabop_size; i++){
      ntab[i] = camlidl_tabop[i];
      for (j=0; j<5; j++){
	caml_register_global_root(&ntab[i].closure[j]);
	caml_remove_global_root(&camlidl_tabop[i].closure[j]);
      }
    }
    for (i=camlidl_tabop_size; i<2*camlidl_tabop_size; i++){
      for (j=0; j<5; j++){
	camlidl_tabop[i].closure[j] = Val_int(0);
	caml_register_global_root(&camlidl_tabop[i].closure[j]);
      }
    }
    free(camlidl_tabop);
    camlidl_tabop = ntab;
    camlidl_tabop_size = camlidl_tabop_size * 2;
    i = camlidl_tabop_size;
  }
  /* Do now the job */
  camlidl_tabop[i].closure[0] = v_closure;
  assert(Is_block(v_taboclosure) && Wosize_val(v_taboclosure)==4);
  for (j=0; j<4; j++){
    value ov = Field(v_taboclosure,j);
    if (Is_block(ov)){
      value v = Field(ov,0);
      camlidl_tabop[i].closure[j+1] = v;
    }
  }
  camlidl_tabop[i].optype = Int_val(v_optype);
  camlidl_tabop[i].ddtype = Int_val(v_ddtype);
  camlidl_tabop[i].commutative = Int_val(v_commutative);
  camlidl_tabop[i].idempotent = Int_val(v_idempotent);
  camlidl_tabop[i].cachetype = Int_val(v_cachetype);
  camlidl_tabop[i].table = NULL;
  camlidl_tabop[i].indexop = Int_val(v_op);
  camlidl_tabop[i].indexop1 = Int_val(v_op1);
  v_res = Val_int(i);
  CAMLreturn(v_res);
}

value camlidl_cudd_rivdd_op2_of_exist(value v_index)
{
  int index = Int_val(v_index);
  if (camlidl_cudd_rivdd_is_op_free(index))
    caml_failwith("Ddcustom.:.op2_of_existXX: registered operation already removed !");
  int indexop = camlidl_tabop[index].indexop;
  if (indexop==-1 || camlidl_cudd_rivdd_is_op_free(indexop))
    caml_failwith("Ddcustom.op2_of_existXX: underlying registered operation already removed !");
  return Val_int(indexop);
}

value camlidl_cudd_rivdd_op1_of_existop1(value v_index)
{
  int index = Int_val(v_index);
  if (camlidl_cudd_rivdd_is_op_free(index))
    caml_failwith("Ddcustom.:.op2_of_existXX: registered operation already removed !");
   int indexop1 = camlidl_tabop[index].indexop1;
  if (indexop1==-1 || camlidl_cudd_rivdd_is_op_free(indexop1))
    caml_failwith("Ddcustom.op2_of_existXX: underlying registered operation already removed !");
  return Val_int(indexop1);
}

value camlidl_cudd_rivdd_register_op_byte(value * argv, int argn)
{
  assert(argn==9);
  return camlidl_cudd_rivdd_register_op(argv[0],argv[1],argv[2],argv[3],
					argv[4],argv[5],argv[6],argv[7],
					argv[8]);
}

value camlidl_cudd_rivdd_flush_op(value v_index)
{
  int i = Int_val(v_index);
  if (camlidl_cudd_rivdd_is_op_free(i))
    caml_failwith("Ddcustom.flush_op: registered operation already removed !");
  assert(camlidl_tabop[i].table!=NULL && camlidl_tabop[i].cachetype==2);
  cuddHashTableQuit(camlidl_tabop[i].table);
  camlidl_tabop[i].table = NULL;
  return Val_unit;
}
value camlidl_cudd_rivdd_flush_allop(value v)
{
  int i;
  if (camlidl_tabop != NULL){
    for (i=0; i<camlidl_tabop_size; i++){
      if (!camlidl_cudd_rivdd_is_op_free(i) && 
	  camlidl_tabop[i].table != NULL){
	cuddHashTableQuit(camlidl_tabop[i].table);
	camlidl_tabop[i].table = NULL;
      }
    }
  }
  return Val_unit;
}
value camlidl_cudd_rivdd_remove_op(value v_index)
{
  int j;
  int i = Int_val(v_index);
  if (camlidl_cudd_rivdd_is_op_free(i))
    caml_failwith("Ddcustom.remove_op: registered operation already removed !");
  for (j=0;j<5;j++){
    caml_modify_generational_global_root(&camlidl_tabop[i].closure[j],Val_int(0));
  }
  if (camlidl_tabop[i].table!=NULL){
    cuddHashTableQuit(camlidl_tabop[i].table);
    camlidl_tabop[i].table = NULL;
  }
  return Val_unit;
}

/* ========================================================================= */
/* Main user operations */
/* ========================================================================= */
DdNode* camlidl_cudd_rivdd_op1(DdManager* man, DDAUX_IDOP ptr, DdNode* f);

DdNode* camlidl_cudd_rivdd_op2(DdManager* man, DDAUX_IDOP ptr, DdNode* F, DdNode* G);
DdNode* camlidl_cudd_rivdd_cmpop(DdManager* man, DDAUX_IDOP ptr, DdNode* F, DdNode* G);
DdNode* camlidl_cudd_rivdd_op3(DdManager* man, DDAUX_IDOP ptr, DdNode* F, DdNode* G, DdNode* H);


static inline
void freetable_if_different_manager(DdManager* man, camlidl_tabop_elt* elt)
{
  if (elt->table!=NULL && elt->table->manager != man){
    cuddHashTableQuit(elt->table);
    elt->table = NULL;
  }
}
static inline
void freetable_auto(camlidl_tabop_elt* elt)
{  
  if (elt->cachetype == 1 && elt->table != NULL){
    cuddHashTableQuit(elt->table);
    elt->table=NULL;
  }
}
static inline
int alloctable(DdManager* man,
			camlidl_tabop_elt* elt,
			int arity)
{
  if (elt->cachetype > 0 && elt->table==NULL){
    elt->table = cuddHashTableInit(man,arity,2);
    return (elt->table!=NULL);
  }
  else
    return 1;
}

value camlidl_cudd_rivdd_map_op(value v_index, value v_tno)
{
  CAMLparam2(v_index, v_tno); CAMLlocal2(v_no,v_res);
  int i,size;
  node__t no[3];
  node__t res;
  int index = Int_val(v_index);
  camlidl_tabop_elt* elt = &camlidl_tabop[index];
  camlidl_tabop_elt* eltop =
    elt->indexop>=0 ?
    &camlidl_tabop[elt->indexop] :
    NULL;
  camlidl_tabop_elt* eltop1 =
    elt->indexop1>=0 ?
    &camlidl_tabop[elt->indexop1] :
    NULL;

  /* Initialize exception */
  camlidl_cudd_rivdd_op_exn = Val_unit;
  /* Conversion from CAML */
  size = Wosize_val(v_tno);
  for (i=0; i<size; i++){
    v_no = Field(v_tno,i);
    camlidl_cudd_node_ml2c(v_no, &no[i]);
  }

  res.man = no[0].man;
  res.node = NULL;

  /* */
  freetable_if_different_manager(res.man->man, elt);
  if (eltop) freetable_if_different_manager(res.man->man, eltop);
  if (eltop1) freetable_if_different_manager(res.man->man, eltop1);

  switch (elt->optype){
  case 0: /* op1 */
    if (size!=1) abort();
    if (alloctable(res.man->man,elt,1)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    res.node = Cuddaux_addApply1(res.man->man,elt->table,elt,camlidl_cudd_rivdd_op1,no[0].node);
    break;
  case 1: /* op2 */
    if (size!=2) abort();
    if (no[0].man!=no[1].man){
      failwith("Dd: binary function called with nodes belonging to different managers !");
    }
    if (alloctable(res.man->man,elt,2)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    res.node = Cuddaux_addApply2(res.man->man, elt->table, elt, elt->commutative,
				 camlidl_cudd_rivdd_op2, no[0].node, no[1].node);
    break;
  case 2: /* test2 */
    if (size!=2) abort();
    if (no[0].man!=no[1].man){
      failwith("Dd: binary function called with nodes belonging to different managers !");
    }
    if (alloctable(res.man->man,elt,2)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    i = Cuddaux_addTest2(res.man->man, elt->table, elt, elt->commutative,
			 camlidl_cudd_rivdd_cmpop,no[0].node,no[1].node);
    break;
  case 3: /* op3 */
    if (size!=3) abort();
    if (no[0].man!=no[1].man || no[0].man!=no[2].man){
      failwith("Dd: ternary function called with nodes belonging to different managers !");
    }
    if (alloctable(res.man->man,elt,3)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    res.node = Cuddaux_addApply3(res.man->man,elt->table,elt,camlidl_cudd_rivdd_op3,no[0].node,no[1].node,no[2].node);
    break;
  case 4: /* exist */
    if (size!=2) abort();
    if (no[0].man!=no[1].man){
      failwith("Dd: binary function called with nodes belonging to different managers !");
    }
    if (alloctable(res.man->man,elt,2)==0 ||
	alloctable(res.man->man,eltop,2)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    res.node = Cuddaux_addAbstract(res.man->man, elt->table, eltop->table, eltop,
				   camlidl_cudd_rivdd_op2,no[1].node,no[0].node);
    break;
  case 5: /* existop1 */
    if (size!=2) abort();
    if (no[0].man!=no[1].man){
      failwith("Dd: binary function called with nodes belonging to different managers !");
    }
    if (alloctable(res.man->man,elt,2)==0 ||
	alloctable(res.man->man,eltop,2)==0 ||
	alloctable(res.man->man,eltop1,1)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    res.node = Cuddaux_addApplyAbstract(res.man->man, elt->table, eltop->table, eltop1->table,
					eltop, eltop1, 
					camlidl_cudd_rivdd_op2,camlidl_cudd_rivdd_op1,
					no[1].node,no[0].node);
    break;
  case 6: /* existand */
    if (size!=3) abort();    
    if (no[0].man!=no[1].man || no[0].man!=no[2].man){
      failwith("Dd: ternary function called with nodes belonging to different managers !");
    }
    if (alloctable(res.man->man,elt,2)==0 ||
	alloctable(res.man->man,eltop,2)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    {
      cuddauxType type = Type_val(elt->ddtype,elt->closure[0]);
      DdNode* background = cuddauxUniqueType(elt->ddtype==2,res.man->man,&type);
      if (background==NULL)
	goto camlidl_cudd_rivdd_mapop_end;
      cuddRef(background);
      res.node = Cuddaux_addBddAndAbstract(res.man->man, elt->table, eltop->table,
					   eltop, camlidl_cudd_rivdd_op2,
					   no[1].node,no[2].node,no[0].node,background);
      cuddDeref(background);
    }
    break;
  case 7: /* existandapply */
    if (size!=3) abort();    
    if (no[0].man!=no[1].man || no[0].man!=no[2].man){
      failwith("Dd: ternary function called with nodes belonging to different managers !");
    }
    if (alloctable(res.man->man,elt,2)==0 ||
	alloctable(res.man->man,eltop,2)==0 ||
	alloctable(res.man->man,eltop1,1)==0){
      goto camlidl_cudd_rivdd_mapop_end;
    }
    {
      cuddauxType type = Type_val(elt->ddtype,elt->closure[0]);
      DdNode* background = cuddauxUniqueType(elt->ddtype==2,res.man->man,&type);
      if (background==NULL)
	goto camlidl_cudd_rivdd_mapop_end;
      cuddRef(background);
      res.node = Cuddaux_addApplyBddAndAbstract(res.man->man, elt->table, eltop->table, eltop1->table,
						eltop, eltop1, 
						camlidl_cudd_rivdd_op2,camlidl_cudd_rivdd_op1,
						no[1].node,no[2].node,no[0].node,background);
      cuddDeref(background);
    }
    break;
  }
 camlidl_cudd_rivdd_mapop_end:
  freetable_auto(elt);
  if (eltop != NULL) freetable_auto(eltop);
  if (eltop1 != NULL) freetable_auto(eltop1);
  if (camlidl_cudd_rivdd_op_exn!=Val_unit){
    Cudd_ClearErrorCode(res.man->man);
    assert(Is_exception_result(camlidl_cudd_rivdd_op_exn));
    caml_raise(Extract_exception(camlidl_cudd_rivdd_op_exn));
  }

  switch (elt->optype){
  case 2:
    /* Force the exception if error */
    v_res = (i==-1) ? camlidl_cudd_node_c2ml(&res) : Val_bool(i);
      break;
  default:
    v_res = camlidl_cudd_node_c2ml(&res);
    break;
  }
  CAMLreturn(v_res);
}

/* ========================================================================= */
/* Terminal cases of user operations */
/* ========================================================================= */

static
DdNode* camlidl_cudd_rivdd_mapop_result(int ddtype, DdManager* man, value _v_val)
{
  DdNode* res;

  if (Is_exception_result(_v_val)){
    camlidl_cudd_rivdd_op_exn = _v_val;
    res = NULL;
  }
  else {
    cuddauxType type = Type_val(ddtype,_v_val);
    res = cuddauxUniqueType(ddtype==2,man,&type);
  }
  return res;
}

DdNode* camlidl_cudd_rivdd_op1(DdManager* man, DDAUX_IDOP ptr, DdNode* f)
{
  value _v_f,_v_val;
  DdNode *res;

  assert (f->ref>=1);
  if (cuddIsConstant(f)){
    cuddauxType type;
    camlidl_tabop_elt* elt = (camlidl_tabop_elt*)ptr;

    _v_f = _v_val = Val_unit;
    Begin_roots2(_v_f,_v_val)
      _v_f = Val_DdNode(elt->ddtype,f);
      _v_val = caml_callback_exn(elt->closure[0], _v_f);
      res = camlidl_cudd_rivdd_mapop_result(elt->ddtype,man,_v_val);
    End_roots()
  }
  else {
    res = NULL;
  }
  return res;
}

DdNode* camlidl_cudd_rivdd_op2(DdManager* man, DDAUX_IDOP ptr, DdNode* F, DdNode* G)
{
  value _v_F,_v_G,_v_val;
  DdNode *res;
  node__t noF,noG;
  camlidl_tabop_elt* elt = (camlidl_tabop_elt*)ptr;

  if (elt->idempotent && F==G) {
    return F;
  }
  if (!cuddIsConstant(F) && !cuddIsConstant(G)){
    return NULL;
  }
  res = NULL;
  _v_F = _v_G = _v_val = Val_unit;
  Begin_roots3(_v_F,_v_G,_v_val)
    if (cuddIsConstant(F) && !cuddIsConstant(G)){
      if (elt->closure[1] != Val_unit){
	_v_F = Val_DdNode(elt->ddtype,F);
	_v_val = caml_callback_exn(elt->closure[1], _v_F);
	if (Is_exception_result(_v_val)){
	  camlidl_cudd_rivdd_op_exn = _v_val;
	  goto camlidl_cudd_rivdd_op2_exit;
	}
	else if (Is_block(_v_val)){
	  _v_val = Field(_v_val,0);
	  goto camlidl_cudd_rivdd_op2_end;
	}
      }
      if (elt->closure[3] != Val_unit){
	_v_F = Val_DdNode(elt->ddtype,F);
	_v_val = caml_callback_exn(elt->closure[3], _v_F);
	if (Is_exception_result(_v_val)){
	  camlidl_cudd_rivdd_op_exn = _v_val;
	  goto camlidl_cudd_rivdd_op2_exit;
	}
	else if (Bool_val(_v_val)){
	  res = G;
	}
      }
    }
    else if (cuddIsConstant(G) && !cuddIsConstant(F)){
      if (elt->closure[2] != Val_unit){
	_v_G = Val_DdNode(elt->ddtype,G);
	_v_val = caml_callback_exn(elt->closure[2], _v_G);
	if (Is_exception_result(_v_val)){
	  camlidl_cudd_rivdd_op_exn = _v_val;
	  goto camlidl_cudd_rivdd_op2_exit;
	}
	else if (Is_block(_v_val)){
	  _v_val = Field(_v_val,0);
	  goto camlidl_cudd_rivdd_op2_end;
	}
      }
      if (elt->closure[4] != Val_unit){
	_v_G = Val_DdNode(elt->ddtype,G);
	_v_val = caml_callback_exn(elt->closure[4], _v_G);
	if (Is_exception_result(_v_val)){
	  camlidl_cudd_rivdd_op_exn = _v_val;
	  goto camlidl_cudd_rivdd_op2_exit;
	}
	else if (Bool_val(_v_val)){
	  res = G;
	}
      }
    }
    else {
      switch (elt->ddtype){
      case 0:
	_v_F = copy_double(cuddV(F));
	_v_G = copy_double(cuddV(G));
	break;
      case 1:
	_v_F = Val_int((int)(cuddV(F)));
	_v_G = Val_int((int)(cuddV(G)));
	break;
      case 2:
	_v_F = cuddauxCamlV(F);
	_v_G = cuddauxCamlV(G);
	break;
      default: abort();
      }
      _v_val = caml_callback2_exn(elt->closure[0], _v_F, _v_G);
    camlidl_cudd_rivdd_op2_end:
      res = camlidl_cudd_rivdd_mapop_result(elt->ddtype,man,_v_val);
    }
 camlidl_cudd_rivdd_op2_exit:
  End_roots()
  return res;
}

DdNode* camlidl_cudd_rivdd_cmpop(DdManager* man, DDAUX_IDOP ptr, DdNode* F, DdNode* G)
{
  value _v_F,_v_G,_v_val;
  DdNode *res;
  camlidl_tabop_elt* elt = (camlidl_tabop_elt*)ptr;

  res = NULL;
  if (elt->idempotent && F==G) {
    return DD_ONE(man);
  }
  if (!cuddIsConstant(F) && !cuddIsConstant(G)){
    return NULL;
  }
  res = NULL;
  _v_F = _v_G = _v_val = Val_unit;
  Begin_roots3(_v_F,_v_G,_v_val)
    if (cuddIsConstant(F) && !cuddIsConstant(G)){
      if (elt->closure[3] != Val_unit){
	_v_F = Val_DdNode(elt->ddtype,F);
	_v_val = caml_callback_exn(elt->closure[3], _v_F);
	if (Is_exception_result(_v_val)){
	  camlidl_cudd_rivdd_op_exn = _v_val;
	}
	else if (Bool_val(_v_val)){
	  res = DD_ONE(man);
	}
      }
    }
    else if (cuddIsConstant(G) && !cuddIsConstant(F)){
      if (elt->closure[4] != Val_unit){
	_v_G = Val_DdNode(elt->ddtype,G);
	_v_val = caml_callback_exn(elt->closure[4], _v_G);
	if (Is_exception_result(_v_val)){
	  camlidl_cudd_rivdd_op_exn = _v_val;
	}
	else if (Bool_val(_v_val)){
	  res = DD_ONE(man);
	}
      }
    }
    else {
      switch (elt->ddtype){
      case 0:
	_v_F = copy_double(cuddV(F));
	_v_G = copy_double(cuddV(G));
	break;
      case 1:
	_v_F = Val_int((int)(cuddV(F)));
	_v_G = Val_int((int)(cuddV(G)));
	break;
      case 2:
	_v_F = cuddauxCamlV(F);
	_v_G = cuddauxCamlV(G);
	break;
      default: abort();
      }
      _v_val = caml_callback2_exn(elt->closure[0], _v_F, _v_G);
      if (Is_exception_result(_v_val)){
	camlidl_cudd_rivdd_op_exn = _v_val;
      }
      else {
	DdNode* one = DD_ONE(man);
	res = (Bool_val(_v_val) ? one : Cudd_Not(one));
      }
    }
 camlidl_cudd_rivdd_cmpop_end:
  End_roots()
    return res;
}

DdNode* camlidl_cudd_rivdd_op3(DdManager* man, DDAUX_IDOP ptr, DdNode* F, DdNode* G, DdNode* H)
{
  value _v_F,_v_G,_v_H,_v_val;
  DdNode *res;
  camlidl_tabop_elt* elt = (camlidl_tabop_elt*)ptr;

  if (cuddIsConstant(F) && cuddIsConstant(G) && cuddIsConstant(H)) {
    _v_F = _v_G = _v_H = _v_val = Val_unit;
    Begin_roots4(_v_F,_v_G,_v_H,_v_val)
    switch (elt->ddtype){
    case 0:
      _v_F = copy_double(cuddV(F));
      _v_G = copy_double(cuddV(G));
      _v_H = copy_double(cuddV(H));
      break;
    case 1:
      _v_F = Val_int((int)(cuddV(F)));
      _v_G = Val_int((int)(cuddV(G)));
      _v_H = Val_int((int)(cuddV(H)));
      break;
    case 2:
      _v_F = cuddauxCamlV(F);
      _v_G = cuddauxCamlV(G);
      _v_H = cuddauxCamlV(H);
      break;
    default: abort();
    }
    _v_val = caml_callback3_exn(elt->closure[0], _v_F, _v_G, _v_H);
    res = camlidl_cudd_rivdd_mapop_result(elt->ddtype,man,_v_val);
    End_roots()
  }
  else {
    res = NULL;
  }
  return res;
}


/*
value camlidl_cudd_rivdd_mapexistopl(value _v_ddtype,
				    value _v_absorbant,
				    value _v_f, value _v_no1, value _v_no2)
{
  CAMLparam5(_v_ddtype,_v_absorbant,_v_f,_v_no1,_v_no2);
  CAMLlocal1(_v_res);
  node__t no1,no2,_res;
  DdNode* background;
  cuddauxType absorbant;

  if (!camlidl_op_initialized) camlidl_op_initialize();
  if (camlidl_cudd_rivdd_opl_closure != Val_unit){
    failwith("Rdd|Idd|Vdd.mapexistopl: this family of functions cannot be called recursively !");
  }
  camlidl_cudd_rivdd_ddtype = Int_val(_v_ddtype);
  absorbant = Type_val(camlidl_cudd_rivdd_ddtype,_v_absorbant);
  camlidl_cudd_rivdd_opl_idempotent = 0;
  camlidl_cudd_rivdd_opl_isabsorbant = 0;
  camlidl_cudd_rivdd_opl_isneutral = 0;
  camlidl_cudd_rivdd_opl_closure = _v_f;
  camlidl_cudd_rivdd_op_exn = Val_unit;
  camlidl_cudd_node_ml2c(_v_no1,&no1);
  camlidl_cudd_node_ml2c(_v_no2,&no2);
  background = cuddauxUniqueType(camlidl_cudd_rivdd_ddtype==2,no1.man->man,&absorbant);
  if (background==0){
    _res.man = no1.man;
    _res.node = NULL;
  }
  else {
    cuddRef(background);
    _res.man = no1.man;
    _res.node = Cuddaux_addAbstractLocal(no1.man->man, camlidl_cudd_rivdd_mapop2l_aux, no2.node, no1.node, background);
    Cudd_RecursiveDeref(no1.man->man,background);
  }
  camlidl_cudd_rivdd_opl_closure = Val_unit;
  if (camlidl_cudd_rivdd_op_exn!=Val_unit){
    assert(_res.node==NULL);
    assert(Is_exception_result(camlidl_cudd_rivdd_op_exn));
    caml_raise(Extract_exception(camlidl_cudd_rivdd_op_exn));
  }
  else
    _v_res = camlidl_cudd_node_c2ml(&_res);
  CAMLreturn(_v_res);
}
value camlidl_cudd_rivdd_mapexistandopl(value _v_ddtype,
					value _v_absorbant,
					value _v_opexist, value _v_no1, value _v_no2, value _v_no3)
{
  CAMLparam5(_v_ddtype,_v_absorbant,_v_opexist,_v_no1,_v_no2);
  CAMLxparam1(_v_no3);
  CAMLlocal1(_v_res);
  node__t no1,no2,no3,_res;
  DdNode* background;
  cuddauxType absorbant;

  if (!camlidl_op_initialized) camlidl_op_initialize();
  if (camlidl_cudd_rivdd_opl_closure != Val_unit){
    failwith("Rdd|Idd|Vdd.mapexistandopl: this family of functions cannot be called recursively !");
  }
  camlidl_cudd_rivdd_ddtype = Int_val(_v_ddtype);
  absorbant = Type_val(camlidl_cudd_rivdd_ddtype,_v_absorbant);
  camlidl_cudd_rivdd_opl_idempotent = 0;
  camlidl_cudd_rivdd_opl_isabsorbant = 0;
  camlidl_cudd_rivdd_opl_isneutral = 0;
  camlidl_cudd_rivdd_opl_closure = _v_opexist;
  camlidl_cudd_rivdd_op_exn = Val_unit;
  camlidl_cudd_node_ml2c(_v_no1,&no1);
  camlidl_cudd_node_ml2c(_v_no2,&no2);
  camlidl_cudd_node_ml2c(_v_no3,&no3);
  background = cuddauxUniqueType(camlidl_cudd_rivdd_ddtype,no1.man->man,&absorbant);
  if (background==0){
    _res.man = no1.man;
    _res.node = NULL;
  }
  else {
    cuddRef(background);
    _res.man = no1.man;
    _res.node = Cuddaux_addBddAndAbstractLocal(no1.man->man, camlidl_cudd_rivdd_mapop2l_aux, no2.node, no3.node, no1.node, background);
    Cudd_RecursiveDeref(no1.man->man,background);
  }
  camlidl_cudd_rivdd_opl_closure = Val_unit;
  if (camlidl_cudd_rivdd_op_exn!=Val_unit){
    assert(_res.node==NULL);
    assert(Is_exception_result(camlidl_cudd_rivdd_op_exn));
    caml_raise(Extract_exception(camlidl_cudd_rivdd_op_exn));
  }
  else
    _v_res = camlidl_cudd_node_c2ml(&_res);
  CAMLreturn(_v_res);
}
value camlidl_cudd_rivdd_mapexistandopl_byte(value * argv, int argn)
{
  return camlidl_cudd_rivdd_mapexistandopl(argv[0],argv[1],argv[2],argv[3],
					   argv[4],argv[5]);
}
value camlidl_cudd_rivdd_mapexistandapplyopl(value _v_ddtype,
					    value _v_absorbant,
					    value _v_op, value _v_opexist,
					    value _v_no1, value _v_no2, value _v_no3)
{
  CAMLparam5(_v_ddtype,_v_absorbant,_v_op,_v_opexist,_v_no1);
  CAMLxparam2(_v_no2,_v_no3);
  CAMLlocal1(_v_res);
  node__t no1,no2,no3,_res;
  DdNode* background;
  cuddauxType absorbant;

  if (!camlidl_op_initialized) camlidl_op_initialize();
  if (camlidl_cudd_rivdd_opl_closure != Val_unit ||
      camlidl_cudd_rivdd_op1l_closure != Val_unit){
    failwith("Rdd|Idd|Vdd.mapexistandapplyopl: this family of functions cannot be called recursively !");
  }
  camlidl_cudd_rivdd_ddtype = Int_val(_v_ddtype);
  absorbant = Type_val(camlidl_cudd_rivdd_ddtype,_v_absorbant);
  camlidl_cudd_rivdd_opl_idempotent = 0;
  camlidl_cudd_rivdd_opl_isabsorbant = 0;
  camlidl_cudd_rivdd_opl_isneutral = 0;
  camlidl_cudd_rivdd_op1l_closure = _v_op;
  camlidl_cudd_rivdd_opl_closure = _v_opexist;
  camlidl_cudd_rivdd_op_exn = Val_unit;
  camlidl_cudd_node_ml2c(_v_no1,&no1);
  camlidl_cudd_node_ml2c(_v_no2,&no2);
  camlidl_cudd_node_ml2c(_v_no3,&no3);
  background = cuddauxUniqueType(camlidl_cudd_rivdd_ddtype, no1.man->man, &absorbant);
  if (background==0){
    _res.man = no1.man;
    _res.node = NULL;
  }
  else {
    cuddRef(background);
    _res.man = no1.man;
    _res.node = Cuddaux_addApplyBddAndAbstractLocal(no1.man->man, camlidl_cudd_rivdd_mapop1l_aux, camlidl_cudd_rivdd_mapop2l_aux, no2.node, no3.node, no1.node, background);
    Cudd_RecursiveDeref(no1.man->man,background);
  }
  camlidl_cudd_rivdd_opl_closure = Val_unit;
  camlidl_cudd_rivdd_op1l_closure = Val_unit;
  if (camlidl_cudd_rivdd_op_exn!=Val_unit){
    assert(_res.node==NULL);
    assert(Is_exception_result(camlidl_cudd_rivdd_op_exn));
    caml_raise(Extract_exception(camlidl_cudd_rivdd_op_exn));
  }
  else
    _v_res = camlidl_cudd_node_c2ml(&_res);
  CAMLreturn(_v_res);
}
value camlidl_cudd_rivdd_mapexistandapplyopl_byte(value * argv, int argn)
{
  return camlidl_cudd_rivdd_mapexistandapplyopl(argv[0],argv[1],argv[2],argv[3],
					   argv[4],argv[5],argv[6]);
}
value camlidl_cudd_rivdd_mapvectorcomposeapply(value _v_vec, value _v_op, value _v_no)
{
  CAMLparam3(_v_vec,_v_op,_v_no); CAMLlocal2(_v,_v_res);
  DdNode **vec;
  int size;
  bdd__t no;
  bdd__t _res;
  int i;

  if (!camlidl_op_initialized) camlidl_op_initialize();
  if (camlidl_cudd_rivdd_opl_closure != Val_unit ||
      camlidl_cudd_rivdd_op1l_closure != Val_unit){
    failwith("Rdd|Idd|Vdd.mapvectorcomposeapplyop: this family of functions cannot be called recursively !");
  }
  camlidl_cudd_rivdd_op1l_closure = _v_op;
  camlidl_cudd_rivdd_op_exn = Val_unit;
  camlidl_cudd_node_ml2c(_v_no, &no);
  size = Wosize_val(_v_vec);
  vec = (DdNode**)malloc(size * sizeof(DdNode*));
  for (i = 0; i<size; i++) {
    bdd__t _no;
    _v = Field(_v_vec, i);
    camlidl_cudd_node_ml2c(_v, &_no);
    if (_no.man != no.man)
      failwith("Rdd|Idd|Vdd.mapvectorcomposeapply called with BDDs belonging to different managers !");
    vec[i] = _no.node;
  }
  _res.man = no.man;
  _res.node = Cuddaux_addApplyVectorCompose(no.man->man, camlidl_cudd_rivdd_mapop1l_aux, no.node, vec);
  camlidl_cudd_rivdd_op1l_closure = Val_unit;
  free(vec);
  if (camlidl_cudd_rivdd_op_exn!=Val_unit){
    assert(_res.node==NULL);
    assert(Is_exception_result(camlidl_cudd_rivdd_op_exn));
    caml_raise(Extract_exception(camlidl_cudd_rivdd_op_exn));
  }
  else
    _v_res = camlidl_cudd_node_c2ml(&_res);
  CAMLreturn(_v_res);
}
*/
/*
  if (camlidl_tabop[i].cachetype>0){
    DdHashTable* table;
    switch(camlidl_tabop[i].optype){
    case 0:
      table = cuddHashTableInit(res.man->man,1,2);
      break;
    case 1:
    case 2:
      table = cuddHashTableInit(res.man->man,2,2);
      break;
    case 3:
      table = cuddHashTableInit(res.man->man,3,2);
    }
    if (table == NULL){
      camlidl_cudd_rivdd_remove_op(Val_int(i));
      caml_failwith("Could not allocate
*/
