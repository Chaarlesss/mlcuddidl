/* Conversion of datatypes and common functions */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "caml/fail.h"
#include "caml/alloc.h"
#include "caml/custom.h"
#include "caml/memory.h"
#include "caml/callback.h"
#include "caml/camlidlruntime.h"
#include "cudd_caml.h"

/* %======================================================================== */
/* \section{Global tuning (Garbage collection)} */
/* %======================================================================== */

static mlsize_t cudd_caml_heap = 1 << 20;
static value cudd_caml_gc_fun = Val_unit;
static value cudd_caml_reordering_fun = Val_unit;
static value cudd_caml_hash_clear_all_fun = Val_unit;
static char cudd_caml_msg[160];

value cudd_caml_set_gc(value _v_heap, value _v_gc, value _v_reordering)
{
  CAMLparam3(_v_heap,_v_gc,_v_reordering);
  bool firstcall;

  cudd_caml_heap = Int_val(_v_heap);
  firstcall = (cudd_caml_gc_fun==Val_unit);
  cudd_caml_gc_fun = _v_gc;
  cudd_caml_reordering_fun = _v_reordering;
  cudd_caml_hash_clear_all_fun = *caml_named_value("cudd_caml_hash_clear_all");
  if (firstcall){
    caml_register_global_root(&cudd_caml_gc_fun);
    caml_register_global_root(&cudd_caml_reordering_fun);
    caml_register_global_root(&cudd_caml_hash_clear_all_fun);
  }
  CAMLreturn(Val_unit);
}

int cudd_caml_garbage(DdManager* dd, const char* s, void* data)
{
  if (cudd_caml_gc_fun==Val_unit){
      fprintf(stderr,"mlcuddidl: cudd_caml.o: internal error: the \"let _ = set_gc ...\" line in manager.ml has not been executed\n");
      abort();
  }
  caml_callback(cudd_caml_gc_fun,Val_unit);
  return 1;
}

int cudd_caml_reordering(DdManager* dd, const char* s, void* data)
{
  if (cudd_caml_reordering_fun==Val_unit || cudd_caml_hash_clear_all_fun==Val_unit){
    fprintf(stderr,"mlcuddidl: cudd_caml.o: internal error: the \"let _ = set_gc ...\" line in manager.ml has not been executed\n");
    abort();
  }
  caml_callback(cudd_caml_hash_clear_all_fun, Val_unit);
  caml_callback(cudd_caml_reordering_fun,Val_unit);
  return 1;
}

value cudd_caml_custom_copy_shr(value arg)
{
  CAMLparam1(arg);
  CAMLlocal1(res);
  mlsize_t sz, i;
  tag_t tg;

  if (Is_long(arg)){
    caml_invalid_argument("copy_shr (probably called from Cudd.Mtbdd.unique): the argument should be a block, not a scalar value (Boolean, integer, constant constructor");
  }
  sz = Wosize_val(arg);
  if (sz == 0) CAMLreturn (arg);
  tg = Tag_val(arg);
  if (tg==Custom_tag){
    struct custom_operations *op = Custom_ops_val(arg);
    if (op->finalize!=NULL){
      caml_invalid_argument("\n\
copy_shr (probably called from Cudd.Mtbdd.unique):\n\
an OCaml value/type implemented as a custom block with a finalization\n\
function cannot be used as leaves of Mtbdds (for technical reasons).\n\
Sorry for that !\n\
The things to do is to first encapsulate the type into a record with one field:\n\
something like type 'a capsule = { val:'a }\n\
This is done automatically by module Cudd.Mtbddc.");
    }
  }
  res = caml_alloc_shr(sz, tg);
  if (tg < No_scan_tag) {
    for (i = 0; i < sz; i++) caml_initialize(&Field(res, i), Field(arg, i));
  }
  else {
    memcpy(Bp_val(res), Bp_val(arg), sz * sizeof(value));
  }
  CAMLreturn (res);
}

/* %======================================================================== */
/* \section{Custom datatypes} */
/* %======================================================================== */

/* %------------------------------------------------------------------------ */
/* \subsection{Custom functions} */
/* %------------------------------------------------------------------------ */

/* \subsubsection{Managers} */

void camlidl_custom_man_finalize(value val)
{
  struct CuddauxMan* man = man_of_vmanager(val);
  cuddauxManFree(man);
}
int camlidl_custom_man_compare(value val1, value val2)
{
  int res;
  DdManager* man1 = DdManager_of_vmanager(val1);
  DdManager* man2 = DdManager_of_vmanager(val2);
  res = (long)man1==(long)man2 ? 0 : (long)man1<(long)man2 ? -1 : 1;
  return res;
}
long camlidl_custom_man_hash(value val)
{
  DdManager* man = DdManager_of_vmanager(val);
  long hash = (long)man;
  return hash;
}

struct custom_operations camlidl_custom_manager = {
  "cudd_caml_custom_node",
  &camlidl_custom_man_finalize,
  &camlidl_custom_man_compare,
  &camlidl_custom_man_hash,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

/* \subsubsection{Hashtables} */

void camlidl_custom_hash_finalize(value val)
{
  struct CuddauxHash* hash;
  cudd_caml_hash_ml2c(val,&hash);
  cuddauxHashFree(hash);
}
int camlidl_custom_hash_compare(value val1, value val2)
{
  struct CuddauxHash* hash1,*hash2;
  cudd_caml_hash_ml2c(val1,&hash1);
  cudd_caml_hash_ml2c(val2,&hash2);
  ptrdiff_t res = hash1->hash - hash2->hash;
  res = res > 0 ? 1 : (res < 0 ? -1 : 0);
  return res;
}
long camlidl_custom_hash_hash(value val)
{
  struct CuddauxHash* hash;
  cudd_caml_hash_ml2c(val,&hash);
  return (long)hash->hash;
}

struct custom_operations camlidl_custom_hash = {
  "cudd_caml_custom_hash",
  &camlidl_custom_hash_finalize,
  &camlidl_custom_hash_compare,
  &camlidl_custom_hash_hash,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

/* \subsubsection{Local Caches} */

void camlidl_custom_cache_finalize(value val)
{
  struct CuddauxCache* cache;
  cudd_caml_cache_ml2c(val,&cache);
  cuddauxCacheFree(cache);
}
int camlidl_custom_cache_compare(value val1, value val2)
{
  struct CuddauxCache* cache1,*cache2;
  cudd_caml_cache_ml2c(val1,&cache1);
  cudd_caml_cache_ml2c(val2,&cache2);
  ptrdiff_t res = cache1->cache - cache2->cache;
  res = res > 0 ? 1 : (res < 0 ? -1 : 0);
  return (int)res;
}
long camlidl_custom_cache_cache(value val)
{
  struct CuddauxCache* cache;
  cudd_caml_cache_ml2c(val,&cache);
  return (long)cache->cache;
}

struct custom_operations camlidl_custom_cache = {
  "cudd_caml_custom_cache",
  &camlidl_custom_cache_finalize,
  &camlidl_custom_cache_compare,
  &camlidl_custom_cache_cache,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

/* \subsubsection{PID)} */

void camlidl_custom_custom_pid_finalize(value val)
{
  pid pid = *(void**)(Data_custom_val(val));
  free(pid);
}
int camlidl_custom_custom_pid_compare(value val1, value val2)
{
  pid pid1 = *(void**)(Data_custom_val(val1));
  pid pid2 = *(void**)(Data_custom_val(val2));
  return (pid1==pid2 ? 0 : (pid1<pid2 ? -1 : 1));
}
long camlidl_custom_custom_pid_hash(value val)
{
  pid pid = *(void**)(Data_custom_val(val));
  long hash = (long)pid;
  return hash;
}
struct custom_operations camlidl_custom_custom_pid = {
  "cudd_caml_custom_custom_pid",
  &camlidl_custom_custom_pid_finalize,
  &camlidl_custom_custom_pid_compare,
  &camlidl_custom_custom_pid_hash,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

/* \subsubsection{Standard nodes (BDDs \& ADDs)} */

void camlidl_custom_node_finalize(value val)
{
  node__t* no = node_of_vnode(val);
  DdNode* node = no->node;
  assert (Cudd_Regular(node)->ref >= 1);
  Cudd_RecursiveDeref(no->man->man,node);
  cuddauxManFree(no->man);
}
int camlidl_custom_node_compare(value val1, value val2)
{
  int res;
  DdManager* man1 = DdManager_of_vnode(val1);
  DdNode* node1 = DdNode_of_vnode(val1);
  DdManager* man2 = DdManager_of_vnode(val2);
  DdNode* node2 = DdNode_of_vnode(val2);

  res = (long)man1==(long)man2 ? 0 : ( (long)man1<(long)man2 ? -1 : 1);
  if (res==0)
    res = (long)node1==(long)node2 ? 0 : ( (long)node1<(long)node2 ? -1 : 1);
  return (int)res;
}
long camlidl_custom_node_hash(value val)
{
  DdNode* node = DdNode_of_vnode(val);
  long hash = (long)node;
  return hash;
}

struct custom_operations camlidl_custom_node = {
  "cudd_caml_custom_node",
  &camlidl_custom_node_finalize,
  &camlidl_custom_node_compare,
  &camlidl_custom_node_hash,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

/* \subsubsection{BDD nodes} */

void camlidl_custom_bdd_finalize(value val)
{
  node__t* no = node_of_vnode(val);
  DdNode* node = no->node;
  assert((Cudd_Regular(node))->ref >= 1);
  Cudd_IterDerefBdd(no->man->man,node);
  cuddauxManFree(no->man);
}

struct custom_operations camlidl_custom_bdd = {
  "cudd_caml_custom_bdd",
  &camlidl_custom_bdd_finalize,
  &camlidl_custom_node_compare,
  &camlidl_custom_node_hash,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

/* %------------------------------------------------------------------------ */
/* \subsection{ML/C conversion functions} */
/* %------------------------------------------------------------------------ */

/* \subsubsection{Managers} */
value cudd_caml_man_c2ml(struct CuddauxMan** man)
{
  value val;
  if((*man)->man==NULL)
    caml_failwith("Cudd: a function returned a null manager");
  val = caml_alloc_custom(&camlidl_custom_manager, sizeof(struct CuddauxMan**), 0, 1);
  *((struct CuddauxMan**)(Data_custom_val(val))) = *man;
  cuddauxManRef(*man);
  return val;
}

/* \subsubsection{Hashtables} */

value cudd_caml_hash_c2ml(struct CuddauxHash** hash)
{
  value val;

  val = caml_alloc_custom(&camlidl_custom_hash, sizeof(struct CuddauxHash**), 0,1);
  *((struct CuddauxHash**)(Data_custom_val(val))) = *hash;
  return val;
}

/* \subsubsection{Local caches} */

value cudd_caml_cache_c2ml(struct CuddauxCache** cache)
{
  value val;

  val = caml_alloc_custom(&camlidl_custom_cache, sizeof(struct CuddauxCache**), 0,1);
  *((struct CuddauxCache**)(Data_custom_val(val))) = *cache;
  return val;
}

value cudd_caml_pid_c2ml(pid* ppid)
{
  value val;
  val = caml_alloc_custom(&camlidl_custom_custom_pid, sizeof(pid), 0, 1);
  *((void**)(Data_custom_val(val))) = *ppid;
  return val;
}

/* \subsubsection{Standard nodes (BDDs \& ADDs)} */

#ifndef NDEBUG
int node_compteur = 0;
int bdd_compteur=0;
#define START_node 0
#define START_bdd 0
#define FREQ_node 500
#define FREQ_bdd 5000
#endif

value cudd_caml_node_c2ml(struct node__t* no)
{
  value val;

  if(no->node==0){
    Cudd_ErrorType err = Cudd_ReadErrorCode(no->man->man);
    Cudd_ClearErrorCode(no->man->man);
    char *s;
    switch(err){
    case CUDD_NO_ERROR: s = "CUDD_NO_ERROR"; break;
    case CUDD_MEMORY_OUT: s = "CUDD_MEMORY_OUT"; break;
    case CUDD_TOO_MANY_NODES: s = "CUDD_TOO_MANY_NODES"; break;
    case CUDD_MAX_MEM_EXCEEDED: s = "CUDD_MAX_MEM_EXCEEDED"; break;
    case CUDD_INVALID_ARG: s = "CUDD_INVALID_ARG"; break;
    case CUDD_INTERNAL_ERROR: s = "CUDD_INTERNAL_ERROR"; break;
    default: s = "CUDD_UNKNOWN"; break;
    }
    sprintf(cudd_caml_msg,
	    "Cudd: a function returned a null ADD/BDD node; ErrorCode = %s",
	    s);
    caml_failwith(cudd_caml_msg);
  }
  cuddRef(no->node);
  cuddauxManRef(no->man);
  /*
  caml_gc_full_major(Val_unit);
  cuddGarbageCollect(no->man->man,1);
  assert(Cudd_CheckKeys(no->man->man)==0);
  assert(Cudd_DebugCheck(no->man->man)==0);
  */
  /*
#ifndef NDEBUG
  node_compteur++;
  if (node_compteur > START_node && node_compteur % FREQ_node == 0){
    int res1,res2;
    fprintf(stderr,"node_check(%d,%d)...",node_compteur,bdd_compteur);
    gc_full_major(Val_unit);
    res1 = Cudd_ReduceHeap(no->man,CUDD_REORDER_NONE,0);
    res2 = Cudd_DebugCheck(no->man);
    if (!res1 || res2){
      fprintf(stderr,"node\nnode_compteur=%d, bdd_compteur=%d\n",
	      node_compteur,bdd_compteur);
      abort();
    }
    fprintf(stderr,"done\n");
  }
#endif
  */

  val = caml_alloc_custom(&camlidl_custom_node, sizeof(struct node__t), 1, cudd_caml_heap);
  *(node__t*)(Data_custom_val(val)) = *no;
  return val;
}

/* \subsubsection{BDD nodes} */

value cudd_caml_bdd_c2ml(struct node__t* bdd)
{
  value val;

  if(bdd->node==0){
    Cudd_ErrorType err = Cudd_ReadErrorCode(bdd->man->man);
    char *s;
    switch(err){
    case CUDD_NO_ERROR: s = "CUDD_NO_ERROR"; break;
    case CUDD_MEMORY_OUT: s = "CUDD_MEMORY_OUT"; break;
    case CUDD_TOO_MANY_NODES: s = "CUDD_TOO_MANY_NODES"; break;
    case CUDD_MAX_MEM_EXCEEDED: s = "CUDD_MAX_MEM_EXCEEDED"; break;
    case CUDD_INVALID_ARG: s = "CUDD_INVALID_ARG"; break;
    case CUDD_INTERNAL_ERROR: s = "CUDD_INTERNAL_ERROR"; break;
    default: s = "CUDD_UNKNOWN"; break;
    }
    sprintf(cudd_caml_msg,
	    "Cudd: a function returned a null BDD node; ErrorCode = %s",
	    s);
    caml_failwith(cudd_caml_msg);
  }

  cuddRef(bdd->node);
  cuddauxManRef(bdd->man);
  /*
  caml_gc_full_major(Val_unit);
  cuddGarbageCollect(bdd->man->man,1);
  assert(Cudd_CheckKeys(bdd->man->man)==0);
  assert(Cudd_DebugCheck(bdd->man->man)==0);
  */
  val = caml_alloc_custom(&camlidl_custom_bdd, sizeof(struct node__t), 1, cudd_caml_heap);
  *(node__t*)(Data_custom_val(val)) = *bdd;
  return val;
}

/* %======================================================================== */
/* \section{Extractors} */
/* %======================================================================== */

value cudd_caml_bdd_inspect(value vno)
{
  CAMLparam1(vno); CAMLlocal3(vres,vthen,velse);
  bdd__t no;
  DdNode* N;

  cudd_caml_node_ml2c(vno, &no);
  N = Cudd_Regular(no.node);
  if (cuddIsConstant(N)){
   vres = caml_alloc_small(1,0);
   if (no.node == DD_ONE(no.man->man))
     Field(vres,0) = Val_true;
   else
     Field(vres,0) = Val_false;
  }
  else {
    bdd__t bthen,belse;

    bthen.man = belse.man = no.man;
    bthen.node = cuddT(N);
    belse.node = cuddE(N);
    if (Cudd_IsComplement(no.node)) {
      bthen.node = Cudd_Not(bthen.node);
      belse.node = Cudd_Not(belse.node);
    }
    vthen = cudd_caml_bdd_c2ml(&bthen);
    velse = cudd_caml_bdd_c2ml(&belse);
    vres = caml_alloc_small(3,1);
    Field(vres,0) = Val_int(N->index);
    Field(vres,1) = vthen;
    Field(vres,2) = velse;
  }
  CAMLreturn(vres);
}


value cudd_caml_add_cofactors(value v_var, value v_no)
{
  CAMLparam2(v_var,v_no); CAMLlocal3(vthen,velse,vres);
  int var;
  add__t no;
  add__t nothen,noelse;

  var = Int_val(v_var);
  cudd_caml_node_ml2c(v_no, &no);

  nothen.man = noelse.man = no.man;
  nothen.node = Cudd_Cofactor(no.man->man,no.node,no.man->man->vars[var]);
  if (nothen.node==NULL){
    vres = cudd_caml_node_c2ml(&nothen);
    CAMLreturn(vres);
  }
  cuddRef(nothen.node);
  noelse.node = Cudd_Cofactor(no.man->man,no.node,Cudd_Not(no.man->man->vars[var]));
  if (noelse.node==NULL){
    Cudd_RecursiveDeref(no.man->man,nothen.node);
    vres = cudd_caml_node_c2ml(&noelse);
    CAMLreturn(vres);
  }
  velse = cudd_caml_node_c2ml(&noelse);
  cuddDeref(nothen.node);
  vthen = cudd_caml_node_c2ml(&nothen);
  vres = caml_alloc_small(2,0);
  Field(vres,0) = vthen;
  Field(vres,1) = velse;
  CAMLreturn(vres);
}


value cudd_caml_avdd_inspect(value vno)
{
  CAMLparam1(vno); CAMLlocal4(vres,vthen,velse,val);
  add__t no;

  cudd_caml_node_ml2c(vno, &no);
  if (cuddIsConstant(no.node)){
    val = Val_DdNode(no.man->caml,no.node);
    vres = caml_alloc_small(1,0);
    Field(vres,0) = val;
  }
  else {
    add__t bthen,belse;

    bthen.man = belse.man = no.man;
    bthen.node = cuddT(no.node);
    belse.node = cuddE(no.node);
    vthen = cudd_caml_node_c2ml(&bthen);
    velse = cudd_caml_node_c2ml(&belse);
    vres = caml_alloc_small(3,1);
    Field(vres,0) = Val_int(no.node->index);
    Field(vres,1) = vthen;
    Field(vres,2) = velse;
  }
  CAMLreturn(vres);
}


value cudd_caml_avdd_is_ite_cst(value vno1, value vno2, value vno3)
{
  CAMLparam3(vno1,vno2,vno3); CAMLlocal2(v,vres);
  node__t no1;
  node__t no2;
  node__t no3;
  DdNode* node;

  cudd_caml_node_ml2c(vno1, &no1);
  cudd_caml_node_ml2c(vno2, &no2);
  cudd_caml_node_ml2c(vno3, &no3);
  if (no1.man!=no2.man || no1.man!=no3.man){
    caml_invalid_argument("Dd: ternary function called with nodes belonging to different managers !");
  }
  DdNode* node = Cuddaux_addIteConstant(no1.man->man,no1.node,no2.node,no3.node);
  if (node==DD_NON_CONSTANT || ! cuddIsConstant(node))
    vres = Val_int(0);
  else {
    v = Val_DdNode(no1.man->caml,node);
    vres = caml_alloc_small(1,0);
    Field(vres,0) = v;
  }
  CAMLreturn(vres);
}

/* %======================================================================== */
/* \section{Supports} */
/* %======================================================================== */

man__t cudd_caml_tnode_ml2c(value _v_vec, int size, DdNode** vec)
{
  value _v_no;
  node__t no;
  man__t man;
  int i;

  if (size>0){
    _v_no = Field(_v_vec, 0);
    cudd_caml_node_ml2c(_v_no, &no);
    vec[0] = no.node;
    man = no.man;
    for (i=1; i<size; i++) {
      _v_no = Field(_v_vec, i);
      cudd_caml_node_ml2c(_v_no, &no);
      vec[i] = no.node;
      if (no.man != man){
	return 0;
      }
    }
    return man;
  }
  else
    return NULL;
}
value cudd_caml_tnode_c2ml(man__t man, DdNode** vec, int size)
{
  value _v_res=0,_v_no=0;
  node__t no;
  int i;

  Begin_roots2(_v_res,_v_no){
    _v_res = caml_alloc(size,0);
    for (i=0; i<size; i++) {
      no.man = man;
      no.node = vec[i];
      _v_no = cudd_caml_node_c2ml(&no);
      Store_field(_v_res,i,_v_no);
    }
  } End_roots();
  return _v_res;
}

value cudd_caml_add_vectorsupport2(value _v_vec1, value _v_vec2)
{
  CAMLparam2(_v_vec1,_v_vec2); CAMLlocal2(_v_no,_v_res);
  DdNode **vec; /*in*/
  int size1,size2,size; /*in*/
  bdd__t _res;
  man__t man1,man2,man;
  int i,index;

  size1 = Wosize_val(_v_vec1);
  size2 = Wosize_val(_v_vec2);
  size = size1+size2;
  if (size==0)
    caml_invalid_argument ("Add.vectorsupport2 called with two empty arrays (annoying because unknown manager for true)");
  vec = (DdNode**)malloc(size * sizeof(DdNode*));
  man = man1 = man2 = NULL;
  if (size1>0){
    man = man1 = cudd_caml_tnode_ml2c(_v_vec1,size1,vec);
    if (man1==NULL){
      free(vec);
      caml_invalid_argument("Add.vectorsupport2 called with BDDs belonging to different managers !");
    }
  }
  if (size2>0){
    man = man2 = cudd_caml_tnode_ml2c(_v_vec2,size2,vec+size1);
    if (man2==NULL){
      free(vec);
      caml_invalid_argument("Add.vectorsupport2 called with ADDs belonging to different managers !");
    }
  }
  if (size1>0 && size2>0 && man1!=man2){
    free(vec);
    caml_invalid_argument("Add.vectorsupport2 called with BDDs/ADDs belonging to different managers !");
  }
  _res.man = man;
  _res.node = Cudd_VectorSupport(_res.man->man, vec, size);
  free(vec);
  _v_res = cudd_caml_bdd_c2ml(&_res);
  CAMLreturn(_v_res);
}

/* %======================================================================== */
/* \section{Logical operations} */
/* %======================================================================== */

value cudd_caml_bdd_vectorcompose(value _v_vec, value _v_no)
{ return cudd_caml_abdd_vectorcompose(true,_v_vec,_v_no); }
value cudd_caml_add_vectorcompose(value _v_vec, value _v_no)
{ return cudd_caml_abdd_vectorcompose(false,_v_vec,_v_no); }

value cudd_caml_abdd_vectorcompose(bool bdd, value _v_vec, value _v_no)
{
  CAMLparam2(_v_vec,_v_no); CAMLlocal2(_v,_vres);
  DdNode **vec; /*in*/
  int size; /*in*/
  bdd__t no; /*in*/
  bdd__t _res;
  int i, maxsize;

  cudd_caml_node_ml2c(_v_no, &no);
  size = Wosize_val(_v_vec);
  maxsize = (size>no.man->man->size) ? size : no.man->man->size;
  vec = (DdNode**)malloc(maxsize * sizeof(DdNode*));
  if (size>0){
    man__t man = cudd_caml_tnode_ml2c(_v_vec,size,vec);
    if (man==NULL || man!=no.man){
      free(vec);
      caml_invalid_argument("Bdd.vectorcompose called with BDDs belonging to different managers !");
    }
  }
  for (i=size; i<maxsize; i++){
    vec[i] = no.man->man->vars[i];
  }
  _res.man = no.man;
  if (bdd){
    _res.node = Cudd_bddVectorCompose(no.man->man, no.node, vec);
    _vres = cudd_caml_bdd_c2ml(&_res);
  } else {
    _res.node = Cuddaux_addVectorCompose(no.man, no.node, vec);
    _vres = cudd_caml_node_c2ml(&_res);
  }
  free(vec);
  CAMLreturn(_vres);
}

static void cudd_caml_memo_ml2c(value _v_memo, struct memo__t* memo)
{
  value _v;
  memo->discr = -1;
  if (Is_long(_v_memo)) {
    switch (Int_val(_v_memo)) {
    case 0: /* Global */
      memo->discr = Global;
      break;
    }
  } else {
    switch (Tag_val(_v_memo)) {
    case 0: /* Cache */
      memo->discr = Cache;
      _v = Field(_v_memo, 0);
      cudd_caml_cache_ml2c(_v, &memo->u.cache);
      break;
    case 1: /* Hash */
      memo->discr = Hash;
      _v = Field(_v_memo, 0);
      cudd_caml_hash_ml2c(_v, &memo->u.hash);
      break;
    }
  }
}
/* %======================================================================== */
/* \section{Variable Mapping} */
/* %======================================================================== */


/* %======================================================================== */
/* \section{Iterators} */
/* %======================================================================== */

value cudd_caml_iter_node(value _v_closure, value _v_no)
{
  CAMLparam2(_v_closure,_v_no); CAMLlocal1(_v_snode);
  DdGen* gen;
  bdd__t no;
  bdd__t snode;
  int autodyn;
  Cudd_ReorderingType heuristic;

  cudd_caml_node_ml2c(_v_no,&no);
  autodyn = 0;
  if (Cudd_ReorderingStatus(no.man->man,&heuristic)){
    autodyn = 1;
    Cudd_AutodynDisable(no.man->man);
  }
  snode.man = no.man;
  Cudd_ForeachNode(no.man->man,no.node,gen,snode.node)
    {
      _v_snode = cudd_caml_node_c2ml(&snode);
      caml_callback(_v_closure,_v_snode);
    }
  if (autodyn) Cudd_AutodynEnable(no.man->man,CUDD_REORDER_SAME);
  CAMLreturn(Val_unit);
}



/* %======================================================================== */
/* \section{Cubes} */
/* %======================================================================== */


/* %======================================================================== */
/* \section{Guards and leaves} */
/* %======================================================================== */


/* List of leaves of an add or vdd. */
value cudd_caml_print(value _v_no)
{
  CAMLparam1(_v_no);
  node__t no;

  cudd_caml_node_ml2c(_v_no,&no);
  fflush(stdout);
  Cudd_PrintMinterm(no.man->man,no.node);
  fflush(stdout);
  CAMLreturn(Val_unit);
}
value cudd_caml_invalid_exception(const char* msg)
{
  CAMLparam0();
  CAMLlocal3(_v_tag,_v_str,_v_pair);
  _v_tag = *caml_named_value("invalid argument exception");
  _v_str = caml_copy_string("Custom.XXX: a function returned a diagram on a different manager !");
  _v_pair = caml_alloc_small(2,0);
  Field(_v_pair,0) = _v_tag;
  Field(_v_pair,1) = _v_str;
  CAMLreturn(_v_pair);
}
static
DdNode* cudd_caml_custom_result(struct common* common, value _v_val)
{
  DdNode* res;

  if (Is_exception_result(_v_val)){
    common->exn = Extract_exception(_v_val);
    res = NULL;
  }
  else {
    CuddauxType type = Type_val(common->man->caml,_v_val);
    res = cuddauxUniqueType(common->man,&type);
  }
  return res;
}
static
DdNode* cudd_caml_custom_resultbool(struct common* common, value _v_val)
{
  DdNode* res;

  if (Is_exception_result(_v_val)){
    common->exn = Extract_exception(_v_val);
    res = NULL;
  }
  else {
    res = DD_ONE(common->man->man);
    if (_v_val==Val_false) res = Cudd_Not(res);
  }
  return res;
}

DdNode* cudd_caml_custom_op1(DdManager* dd, struct op1* op, DdNode* f)
{
  CAMLparam0();
  CAMLlocal2(_v_f,_v_val);
  DdNode *res;

  assert (f->ref>=1);
  if (cuddIsConstant(f)){
    CuddauxType type;
    _v_f = Val_DdNode(op->common1.man->caml,f);
    _v_val = caml_callback_exn(op->closure1, _v_f);
    res = cudd_caml_custom_result(&op->common1,_v_val);
  }
  else {
    res = NULL;
  }
  CAMLreturnT(DdNode*,res);
}

DdNode* cudd_caml_custom_op2(DdManager* dd, struct op2* op,
				DdNode* F, DdNode* G)
{
  value _v_F=0,_v_G=0,_v_val=0;
  DdNode *res;
  node__t noF,noG;

  res = NULL;

  if (cuddIsConstant(F) || cuddIsConstant(G)){
    if (cuddIsConstant(F) && cuddIsConstant(G)){
      Begin_roots3(_v_F,_v_G,_v_val){
	if (op->common2.man->caml){
	  _v_F = cuddauxCamlV(F);
	  _v_G = cuddauxCamlV(G);
	}
	else {
	  _v_F = copy_double(cuddV(F));
	  _v_G = copy_double(cuddV(G));
	}
	_v_val = caml_callback2_exn(op->closure2, _v_F, _v_G);
	res = cudd_caml_custom_result(&op->common2,_v_val);
      } End_roots();
    }
    else if (op->ospecial2 != Val_int(0)){
      Begin_roots3(_v_F,_v_G,_v_val){
	noF.man = op->common2.man; noF.node = F;
	noG.man = op->common2.man; noG.node = G;
	_v_F = cudd_caml_node_c2ml(&noF);
	_v_G = cudd_caml_node_c2ml(&noG);
	_v_val = Field(op->ospecial2,0);
	_v_val = caml_callback2_exn(_v_val,_v_F,_v_G);
	if (Is_exception_result(_v_val)){
	  op->common2.exn = Extract_exception(_v_val);
	}
	else if (Is_block(_v_val)){
	  node__t no;
	  _v_val = Field(_v_val,0);
	  cudd_caml_node_ml2c(_v_val,&no);
	  if (op->common2.man->man == no.man->man){
	    res = no.node;
	  }
	  else {
	    op->common2.exn = cudd_caml_invalid_exception("Custom.map_op2: the special function returned a diagram on a different manager !");
	  }
	}
      } End_roots();
    }
  }
  return res;
}
DdNode* cudd_caml_custom_op3(DdManager* dd, struct op3* op, DdNode* F, DdNode* G, DdNode* H)
{
  value _v_F=0,_v_G=0,_v_H=0,_v_val=0;
  DdNode *res;
  node__t noF,noG,noH;

  res = NULL;
  if (cuddIsConstant(F) || cuddIsConstant(G) || cuddIsConstant(H)){
    if (cuddIsConstant(F) && cuddIsConstant(G) && cuddIsConstant(H)){
      Begin_roots4(_v_F,_v_G,_v_H,_v_val){
	if (op->common3.man->caml){
	  _v_F = cuddauxCamlV(F);
	  _v_G = cuddauxCamlV(G);
	  _v_H = cuddauxCamlV(H);
	}
	else {
	  _v_F = copy_double(cuddV(F));
	  _v_G = copy_double(cuddV(G));
	  _v_H = copy_double(cuddV(H));
	}
	_v_val = caml_callback3_exn(op->closure3,_v_F,_v_G,_v_H);
	res = cudd_caml_custom_result(&op->common3,_v_val);
      } End_roots();
    }
    else if (op->ospecial3 != Val_int(0)){
      Begin_roots4(_v_F,_v_G,_v_H,_v_val){
	noF.man = op->common3.man; noF.node = F;
	noG.man = op->common3.man; noG.node = G;
	noH.man = op->common3.man; noH.node = H;
	_v_F = cudd_caml_node_c2ml(&noF);
	_v_G = cudd_caml_node_c2ml(&noG);
	_v_H = cudd_caml_node_c2ml(&noH);
	_v_val = Field(op->ospecial3,0);
	_v_val = caml_callback3_exn(_v_val,_v_F,_v_G,_v_H);
	if (Is_exception_result(_v_val)){
	  op->common3.exn = Extract_exception(_v_val);
	}
	else if (Is_block(_v_val)){
	  node__t no;
	  _v_val = Field(_v_val,0);
	  cudd_caml_node_ml2c(_v_val,&no);
	  if (op->common3.man->man == no.man->man)
	    res = no.node;
	  else {
	    op->common3.exn = cudd_caml_invalid_exception("Custom.map_op3: the special function returned a diagram on a different manager !");
	  }
	}
      } End_roots();
    }
  }
  return res;
}

DdNode* cudd_caml_custom_test2(DdManager* dd, struct test2* op, DdNode* F, DdNode* G)
{
  value _v_F=0,_v_G=0,_v_val=0;
  DdNode *res;
  node__t noF,noG;

  res = NULL;

  if (cuddIsConstant(F) || cuddIsConstant(G)){
    if (cuddIsConstant(F) && cuddIsConstant(G)){
      Begin_roots3(_v_F,_v_G,_v_val){
	if (op->common2t.man->caml){
	  _v_F = cuddauxCamlV(F);
	  _v_G = cuddauxCamlV(G);
	}
	else {
	  _v_F = copy_double(cuddV(F));
	  _v_G = copy_double(cuddV(G));
	}
	_v_val = caml_callback2_exn(op->closure2t, _v_F, _v_G);
	res = cudd_caml_custom_resultbool(&op->common2t,_v_val);
      } End_roots();
    }
    else if (op->ospecial2t != Val_int(0)){
      Begin_roots3(_v_F,_v_G,_v_val){
	noF.man = op->common2t.man; noF.node = F;
	noG.man = op->common2t.man; noG.node = G;
	_v_F = cudd_caml_node_c2ml(&noF);
	_v_G = cudd_caml_node_c2ml(&noG);
	_v_val = Field(op->ospecial2t,0);
	_v_val = caml_callback2_exn(_v_val,_v_F,_v_G);
	if (Is_exception_result(_v_val)){
	  op->common2t.exn = Extract_exception(_v_val);
	}
	else if (Is_block(_v_val)){
	  node__t no;
	  _v_val = Field(_v_val,0);
	  res = DD_ONE(op->common2t.man->man);
	  if (_v_val==Val_false) res = Cudd_Not(res);
	}
      } End_roots();
    }
  }
  return res;
}

DdNode* cudd_caml_custom_opNG(DdManager* dd, struct opN* op, DdNode** tnode)
{
  value _v_tno1=0,_v_tno2=0,_v_val=0;
  DdNode *res;
  node__t no;
  int arity, arityB, arityV, i;
  bool onecst;
  res = NULL;

  arity = op->commonN.arity;
  arityB = op->arityNbdd;
  arityV = arity - arityB;

  onecst = false;
  for(i=0; i<arity; i++){
    if (Cudd_IsConstant(tnode[i])){
      onecst = true;
      break;
    }
  }
  if (onecst){
    Begin_roots3(_v_tno1,_v_tno2,_v_val){
      _v_tno1 = cudd_caml_tnode_c2ml(op->commonN.man,tnode,arityB);
      _v_tno2 = cudd_caml_tnode_c2ml(op->commonN.man,tnode+arityB,arityV);
      _v_val = caml_callback2_exn(op->closureN,_v_tno1,_v_tno2);
      if (Is_exception_result(_v_val)){
	op->commonN.exn = Extract_exception(_v_val);
      }
      else if (Is_block(_v_val)){
	_v_val = Field(_v_val,0);
	cudd_caml_node_ml2c(_v_val,&no);
	if (op->commonN.man == no.man)
	  res = no.node;
	else
	  op->commonN.exn = cudd_caml_invalid_exception("Custom.apply_opN: the closure function returned a diagram on a different manager !");
      }
    } End_roots();
  }
  return res;
}

int cudd_caml_custom_opGbeforeRec(DdManager* dd, struct opG* op, DdNode* no, DdNode** tnode)
{
  value _v_index=0,_v_bool=0,_v_pair=0,_v_tno1=0,_v_tno2=0,_v_val=0;
  int arity, arityB, arityV, i;
  man__t man1=NULL,man2=NULL;
  int res = 0;

  arity = op->commonG.arity;
  arityB = op->arityGbdd;
  arityV = arity - arityB;

  Begin_roots4(_v_pair,_v_tno1,_v_tno2,_v_val);
  _v_index = Val_int(Cudd_Regular(no)->index);
  _v_bool = Val_bool(!Cudd_IsComplement(no));
  _v_pair = caml_alloc_small(2,0);
  Field(_v_pair,0) = _v_index;
  Field(_v_pair,1) = _v_bool;
  _v_tno1 = cudd_caml_tnode_c2ml(op->commonG.man,tnode,arityB);
  _v_tno2 = cudd_caml_tnode_c2ml(op->commonG.man,tnode+arityB,arityV);
  assert(Is_block(op->oclosureBeforeRec));
  _v_val = Field(op->oclosureBeforeRec,0);
  _v_val = caml_callback3_exn(_v_val,_v_pair,_v_tno1,_v_tno2);
  if (Is_exception_result(_v_val)){
    op->commonG.exn = Extract_exception(_v_val);
  }
  else {
    assert(Is_block(_v_val));
    _v_tno1 = Field(_v_val,0);
    _v_tno2 = Field(_v_val,1);
    if ((int)Wosize_val(_v_tno1)!=arityB || (int)Wosize_val(_v_tno2)!=arityV){
      op->commonG.exn = cudd_caml_invalid_exception("Custom.apply_opG: the beforeRec function returned arrays with wrong dimensions !");
      goto cudd_caml_custom_opGbeforeRec_end;
    }
    if (arityB>0){
      man1 = cudd_caml_tnode_ml2c(_v_tno1,arityB,tnode);
      if (man1==NULL) {
	op->commonG.exn = cudd_caml_invalid_exception("Custom.apply_opG: the beforeRec function called with BDDs/VDDs on different managers !");
	goto cudd_caml_custom_opGbeforeRec_end;
      }
    }
    if (arityV>0){
      man2 = cudd_caml_tnode_ml2c(_v_tno2,arityV,tnode+arityB);
      if (man2==NULL) {
	op->commonG.exn = cudd_caml_invalid_exception("Custom.apply_opG: the beforeRec function called with BDDs/VDDs on different managers !");
	goto cudd_caml_custom_opGbeforeRec_end;
      }
    }
    if (arityB>0 && arityV>0 && man1!=man2){
      op->commonG.exn = cudd_caml_invalid_exception("Custom.apply_opG: the beforeRec function called with BDDs/VDDs on different managers !");
      goto cudd_caml_custom_opGbeforeRec_end;
    }
    _v_pair = caml_alloc_small(2,0);
    Field(_v_pair,0) = _v_tno1;
    Field(_v_pair,1) = _v_tno2;
    res = 1;
  }
 cudd_caml_custom_opGbeforeRec_end:
  End_roots();
  return res;
}


DdNode* cudd_caml_custom_opGite(DdManager* dd, struct opG* op, int index, DdNode* T, DdNode* E)
{
  CAMLparam0();
  CAMLlocal4(_v_no1,_v_no2,_v_no,_v_val);
  node__t no1,no2,no;
  DdNode* res = NULL;

  no1.man = op->commonG.man;
  no2.man = op->commonG.man;
  no1.node = T;
  no2.node = E;
  _v_no1 = cudd_caml_node_c2ml(&no1);
  _v_no2 = cudd_caml_node_c2ml(&no2);
  _v_val = Field(op->oclosureIte,0);
  _v_no = caml_callback3_exn(_v_val,Val_int(index),_v_no1,_v_no2);
  if (Is_exception_result(_v_no)){
    op->commonG.exn = Extract_exception(_v_no);
  }
  else {
    cudd_caml_node_ml2c(_v_no,&no);
    res = no.node;
  }
  CAMLreturnT(DdNode*,res);
}
