/* Conversion of datatypes and common functions */

/* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  */

#ifndef __CUDD_CAML_H__
#define __CUDD_CAML_H__

#include <stdio.h>
#include <assert.h>

#include "cuddInt.h"
#include "cuddaux.h"

#include "caml/mlvalues.h"

typedef struct CuddauxHash* hash__t;
typedef struct CuddauxCache* cache__t;
typedef struct CuddauxMan* man__t;
typedef struct memo__t memo__t;
typedef struct node__t node__t;
typedef struct node__t bdd__t;
typedef Cudd_ReorderingType reorder_t;
typedef Cudd_AggregationType aggregation_t;
typedef Cudd_ErrorType error_t;
typedef Cudd_LazyGroupType lazygroup_t;
typedef Cudd_VariableType variabletype_t;
typedef int mtr_t;

extern struct custom_operations cudd_caml_custom_hash;
extern struct custom_operations cudd_caml_custom_cache;
extern struct custom_operations cudd_caml_custom_man;
extern struct custom_operations cudd_caml_custom_node;
extern struct custom_operations cudd_caml_custom_bdd;
extern struct custom_operations cudd_caml_custom_pid;


/* ********************************************************************** */
/* man.ml */
/* ********************************************************************** */
static inline man__t cudd_caml_man__t_ml2c(value val)
{ return *((man__t*)(Data_custom_val(val))); }
value cudd_caml_man__t_c2ml(man__t man);
static inline DdManager* cudd_caml_man_t_ml2c(value val)
{
  man__t man = cudd_caml_man__t_ml2c(val);
  return man->man;
}
static inline reorder_t cudd_caml_reorder_t_ml2c(value val) { return Int_val(val); }
static inline value cudd_caml_reorder_t_c2ml(reorder_t x) { return Val_int(x); }
static inline aggregation_t cudd_caml_aggregation_t_ml2c(value val) { return Int_val(val); }
static inline value cudd_caml_aggregation_t_c2ml(aggregation_t x) { return Val_int(x); }
static inline error_t cudd_caml_error_t_ml2c(value val){ return Int_val(val); }
static inline value cudd_caml_error_t_c2ml(error_t x) { return Val_int(x); }
static inline lazygroup_t cudd_caml_lazygroup_t_ml2c(value val) { return Int_val(val); }
static inline value cudd_caml_lazygroup_t_c2ml(lazygroup_t x) { return Val_int(x); }
static inline variabletype_t cudd_caml_variabletype_t_ml2c(value val) { return Int_val(val); }
static inline value cudd_caml_variabletype_t_c2ml(variabletype_t x) { return Val_int(x); }
static inline mtr_t cudd_caml_mtr_t_ml2c(value val) { int x = Int_val(val); return x==0 ? 0 : 4; }
static inline value cudd_caml_mtr_t_c2ml(int x) { int y = x==4 ? 1 : 0; return Val_int(y); }

/* ********************************************************************** */
/* hash.ml, cache.ml and memo.ml */
/* ********************************************************************** */

static inline hash__t cudd_caml_hash__t_ml2c(value val)
{ return *((hash__t*)(Data_custom_val(val))); }
static inline cache__t cudd_caml_cache__t_ml2c(value val)
{ return *((cache__t*)(Data_custom_val(val))); }
static inline pid cudd_caml_pid_ml2c(value val)
{ return *((pid*)(Data_custom_val(val))); }
memo__t cudd_caml__memo_t_ml2c(value val);

static inline value cudd_caml_hash__t_c2ml(hash__t hash)
{
  value val = caml_alloc_custom(&cudd_caml_custom_hash, sizeof(hash__t), 0, 1);
  *(hash__t*)(Data_custom_val(val)) = hash;
  return val;
}
static inline value cudd_caml_cache__t_c2ml(cache__t cache)
{
  value val = caml_alloc_custom(&cudd_caml_custom_cache, sizeof(cache__t), 0, 1);
  *(cache__t*)(Data_custom_val(val)) = cache;
  return val;
}
static inline value cudd_caml_pid_c2ml(pid pidd)
{
  value val = caml_alloc_custom(&cudd_caml_custom_pid, sizeof(pid), 0, 1);
  *(pid*)(Data_custom_val(val)) = pidd;
  return val;
}

/* ********************************************************************** */
/* decision diagrams */
/* ********************************************************************** */

static inline node__t cudd_caml_node__t_ml2c(value val)
{ return *((node__t*)(Data_custom_val(val))); }
value cudd_caml_node__t_c2ml(node__t no);
value cudd_caml_bdd__t_c2ml(node__t no);
static inline value cudd_caml_bddnode__t_c2ml(bool is_bdd,node__t no)
{ return is_bdd ? cudd_caml_bdd__t_c2ml(no) : cudd_caml_node__t_c2ml(no); }

/* Variations */
static inline DdNode* cudd_caml_node_t_ml2c(value val)
{ return ((node__t*)(Data_custom_val(val)))->node; }

/*
#define DdManager_of_vnode(x) ((node__t*)(Data_custom_val(x)))->man->man
#define DdManager_of_vmanager(x) (*(man__t*)(Data_custom_val(x)))->man
#define DdManager_of_vnode(x) ((node__t*)(Data_custom_val(x)))->man->man
#define DdNode_of_vnode(x) ((node__t*)(Data_custom_val(x)))->node
*/

value cudd_caml_set_gc(value _v_heap, value _v_gc, value _v_reordering);
int cudd_caml_garbage(DdManager* dd, const char* s, void* data);
int cudd_caml_reordering(DdManager* dd, const char* s, void* data);
value cudd_caml_custom_copy_shr(value arg);

value cudd_caml_bdd_inspect(value vno);
value cudd_caml_bdd_cofactors(value v_var, value v_no);
value cudd_caml_add_cofactors(value v_var, value v_no);

value cudd_caml_avdd_dval(value vno);
value cudd_caml_avdd_cst(value vman, value vleaf);
value cudd_caml_avdd_inspect(value vno);
value cudd_caml_avdd_is_eval_cst(value vno1, value vno2);
value cudd_caml_avdd_is_ite_cst(value vno1, value vno2, value vno3);
value cudd_caml_list_of_support(value _v_no);
value cudd_caml_invalid_exception(const char* msg);
man__t cudd_caml_tnode_ml2c(value _v_vec, int size, DdNode** vec);
value cudd_caml_tnode_c2ml(man__t man, DdNode** vec, int size);
value cudd_caml_bdd_vectorsupport(value _v_vec);
value cudd_caml_add_vectorsupport2(value _v_vec1, value _v_vec2);

value cudd_caml_abdd_vectorcompose(bool bdd, value _v_vec, value _v_no);
value cudd_caml_bdd_vectorcompose(value _v_vec, value _v_no);
value cudd_caml_add_vectorcompose(value _v_vec, value _v_no);

value cudd_caml_abdd_vectorcompose_memo(bool bdd, value _v_memo,value _v_vec, value _v_no);
value cudd_caml_bdd_vectorcompose_memo(value _v_memo,value _v_vec, value _v_no);
value cudd_caml_add_vectorcompose_memo(value _v_memo,value _v_vec, value _v_no);
value cudd_caml_abdd_permute(bool bdd, value _v_no, value _v_permut);
value cudd_caml_bdd_permute(value _v_no, value _v_permut);
value cudd_caml_add_permute(value _v_no, value _v_permut);
value cudd_caml_abdd_permute_memo(bool bdd, value _v_memo, value _v_no, value _v_permut);
value cudd_caml_bdd_permute_memo(value _v_memo, value _v_no, value _v_permut);
value cudd_caml_add_permute_memo(value _v_memo, value _v_no, value _v_permut);

value cudd_caml_iter_node(value _v_closure, value _v_no);
value cudd_caml_bdd_iter_cube(value _v_closure, value _v_no);
value cudd_caml_avdd_iter_cube(value _v_closure, value _v_no);
value cudd_caml_bdd_iter_prime(value _v_closure, value _v_lower, value _v_upper);
value cudd_caml_cube_of_bdd(value _v_no);
value cudd_caml_cube_of_minterm(value _v_man, value _v_array);
value cudd_caml_list_of_cube(value _v_no);
value cudd_caml_pick_minterm(value _v_no);
int array_of_support(DdManager* man, DdNode* supp, DdNode*** pvars, int* psize);
value cudd_caml_pick_cube_on_support(value _v_no1, value _v_no2);
value cudd_caml_pick_cubes_on_support(value _v_no1, value _v_no2, value _v_k);
value cudd_caml_avdd_guard_of_leaf(value _v_no, value _v_leaf);
value cudd_caml_avdd_nodes_below_level(value _v_no, value _v_olevel, value _v_omax);
value cudd_caml_avdd_leaves(value _v_no);
value cudd_caml_avdd_pick_leaf(value _v_no);
value cudd_caml_print(value _v_no);

DdNode* cudd_caml_custom_op1(DdManager* dd, struct op1* op, DdNode* node);
DdNode* cudd_caml_custom_op2(DdManager* dd, struct op2* op, DdNode* node1, DdNode* node2);
DdNode* cudd_caml_custom_op3(DdManager* dd, struct op3* op, DdNode* node1, DdNode* node2, DdNode* node3);
DdNode* cudd_caml_custom_opNG(DdManager* dd, struct opN* op, DdNode** node);
int cudd_caml_custom_opGbeforeRec(DdManager* dd, struct opG* op, DdNode* no, DdNode** tnode);
DdNode* cudd_caml_custom_opGite(DdManager* dd, struct opG* op, int index, DdNode* T, DdNode* E);
DdNode* cudd_caml_custom_test2(DdManager* dd, struct test2* op, DdNode* node1, DdNode* node2);

#endif
