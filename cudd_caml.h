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

typedef value mlvalue;

typedef DdManager* man_t;
typedef DdNode* node_t;

typedef struct CuddauxHash* hash__t;
typedef struct CuddauxCache* cache__t;
typedef struct CuddauxMan* man__t;
typedef struct memo__t* memo__t;
typedef struct node__t node__t;
typedef Cudd_ReorderingType reorder_t;
typedef Cudd_AggregationType aggregation_t;
typedef Cudd_ErrorType error_t;


/* man */
static inline man__t cudd_caml_man__t_ml2c(value val)
{ return *((man__t*)(Data_custom_val(val))); }
value cudd_caml_man__t_c2ml(man__t man);
static inline man_t cudd_caml_man_t_ml2c(value val)
{ return ((man__t*)(Data_custom_val(val)))->man; }

static inline node__t cudd_caml_node__t_ml2c(value val)
{ return *((node__t*)(Data_custom_val(val))); }
value cudd_caml_node__t_c2ml(node__t man);
static inline node_t cudd_caml_node_t_ml2c(value val)
{ return ((node__t*)(Data_custom_val(x)))->node; }

#define DdManager_of_vnode(x) ((node__t*)(Data_custom_val(x)))->man->man



static inline Cudd_ReorderingType cudd_caml_ReorderingType_ml2c(value val)
{ return Int_val(val) }
static inline value cudd_caml_ReorderingType_c2ml(Cudd_ReorderingType x)
{ return Val_int(x); }
static inline Cudd_AggregationType cudd_caml_AggregationType_ml2c(value val)
{ return Int_val(val) }
static inline value cudd_caml_AggregationType_c2ml(Cudd_AggregationType x)
{ return Val_int(x); }
static inline Cudd_ErrorType cudd_caml_ErrorType_ml2c(value val)
{ return Int_val(val) }
static inline value cudd_caml_ErrorType_c2ml(Cudd_ErrorType x)
{ return Val_int(x); }
static inline Cudd_LazyGroupType cudd_caml_LazyGroupType_ml2c(value val)
{ return Int_val(val) }
static inline value cudd_caml_LazyGroupType_c2ml(Cudd_LazyGroupType x)
{ return Val_int(x); }
static inline Cudd_VariableType cudd_caml_VariableType_ml2c(value val)
{ return Int_val(val) }
static inline value cudd_caml_VariableType_c2ml(Cudd_VariableType x)
{ return Val_int(x); }
static inline Cudd_mtr cudd_caml_mtr_ml2c(value val)
{ int x = Int_val(val); return x==0 ? 0 : 4; }
static inline value cudd_caml_mtr_c2ml(int x)
{ int y = x==4 ? 1 : 0; return Val_int(y); }

static inline hash__t cudd_caml_hash_ml2c(value val)
{ return *((hash__t*)(Data_custom_val(val))); }
static inline cache__t cudd_caml_cache_ml2c(value val)
{ return *((cache__t*)(Data_custom_val(val))); }
static inline pid cudd_caml_pid_ml2c(value val)
{ return *((pid*)(Data_custom_val(val))); }
static inline struct node__t cudd_caml_node_ml2c(value val)
{ return *(node__t*)(Data_custom_val(val)); }

value cudd_caml_hash_c2ml(hash__t hash);
value cudd_caml_cache_c2ml(cache__t cache);
value cudd_caml_pid_c2ml(pid pid);
value cudd_caml_node_c2ml(struct node__t* no);
value cudd_caml_bdd_c2ml(struct node__t* bdd);
/*
static inline void cudd_caml_mlvalue_ml2c(value val, value* p)
{ *p = val; }
static inline value cudd_caml_mlvalue_c2ml(value* p)
{ return *p; }
#define man_of_vmanager(x) (*(man__t*)(Data_custom_val(x)))
#define node_of_vnode(x) ((node__t*)(Data_custom_val(x)))
*/
#define DdManager_of_vmanager(x) (*(man__t*)(Data_custom_val(x)))->man
#define DdManager_of_vnode(x) ((node__t*)(Data_custom_val(x)))->man->man
#define DdNode_of_vnode(x) ((node__t*)(Data_custom_val(x)))->node


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
