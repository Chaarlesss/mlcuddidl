(** CUDD Manager *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

(* ********************************************************************** *)
(* Copied from .mli *)
(* ********************************************************************** *)

type 'a t
type d
type v
type dt = d t
type vt = v t
type tbool = False | True | Top
type error =
    NO_ERROR
  | MEMORY_OUT
  | TOO_MANY_NODES
  | MAX_MEM_EXCEEDED
  | INVALID_ARG
  | INTERNAL_ERROR
external set_gc : heap:int -> gc:(unit -> unit) -> reordering:(unit -> unit) -> unit
  = "cudd_caml_set_gc"
external srandom : int -> unit = "cudd_caml_man_srandom"
external _make : caml:bool -> numVars:int -> numVarsZ:int -> numSlots:int -> cacheSize:int -> maxMemory:int -> 'a t
  = "cudd_caml_man_Cudd_Init_bytecode" "cudd_caml_man_Cudd_Init"
external debugcheck : 'a t -> bool = "cudd_caml_man_Cudd_DebugCheck"
external check_keys : 'a t -> int = "cudd_caml_man_Cudd_CheckKeys"
external copy_shr : 'a -> 'a = "cudd_caml_custom_copy_shr"
type reorder =
    REORDER_SAME
  | REORDER_NONE
  | REORDER_RANDOM
  | REORDER_RANDOM_PIVOT
  | REORDER_SIFT
  | REORDER_SIFT_CONVERGE
  | REORDER_SYMM_SIFT
  | REORDER_SYMM_SIFT_CONV
  | REORDER_WINDOW2
  | REORDER_WINDOW3
  | REORDER_WINDOW4
  | REORDER_WINDOW2_CONV
  | REORDER_WINDOW3_CONV
  | REORDER_WINDOW4_CONV
  | REORDER_GROUP_SIFT
  | REORDER_GROUP_SIFT_CONV
  | REORDER_ANNEALING
  | REORDER_GENETIC
  | REORDER_LINEAR
  | REORDER_LINEAR_CONVERGE
  | REORDER_LAZY_SIFT
  | REORDER_EXACT
type aggregation =
    NO_CHECK
  | GROUP_CHECK
  | GROUP_CHECK2
  | GROUP_CHECK3
  | GROUP_CHECK4
  | GROUP_CHECK5
  | GROUP_CHECK6
  | GROUP_CHECK7
  | GROUP_CHECK8
  | GROUP_CHECK9
type lazygroup = LAZY_NONE | LAZY_SOFT_GROUP | LAZY_HARD_GROUP | LAZY_UNGROUP
type vartype = VAR_PRIMARY_INPUT | VAR_PRESENT_STATE | VAR_NEXT_STATE
type mtr = MTR_DEFAULT | MTR_FIXED
external level_of_var : 'a t -> int -> int = "cudd_caml_man_Cudd_ReadPerm"
external var_of_level : 'a t -> int -> int
  = "cudd_caml_man_Cudd_ReadInvPerm"
external reduce_heap : 'a t -> reorder -> int -> unit
  = "cudd_caml_man_Cudd_ReduceHeap"
external shuffle_heap : 'a t -> int array -> unit
  = "cudd_caml_man_Cudd_ShuffleHeap"
external garbage_collect : 'a t -> int
  = "cudd_caml_man_cuddGarbageCollect"
external flush : 'a t -> unit = "cudd_caml_man_cuddCacheFlush"
external enable_autodyn : 'a t -> reorder -> unit
  = "cudd_caml_man_Cudd_AutodynEnable"
external disable_autodyn : 'a t -> unit
  = "cudd_caml_man_Cudd_AutodynDisable"
external autodyn_status : 'a t -> reorder option
  = "cudd_caml_man_Cudd_ReorderingStatus"
external group : 'a t -> int -> int -> mtr -> unit
  = "cudd_caml_man_Cudd_MakeTreeNode"
external ungroupall : 'a t -> unit = "cudd_caml_man_Cudd_FreeTree"
external set_varmap : 'a t -> int array -> unit
  = "cudd_caml_man_Cuddaux_SetVarMap"
type parameters = {
  background : float;
  epsilon : float;
  min_hit : int;
  max_cache_hard : int;
  loose_up_to : int;
  max_live : int;
  max_mem : int;
  sift_max_swap : int;
  sift_max_var : int;
  group_check : aggregation;
  arc_violation : int;
  number_xovers : int;
  population_size : int;
  recomb : int;
  symm_violation : int;
  max_growth : float;
  max_growth_alt : float;
  reordering_cycle : int;
  next_reordering : int;
}
external get_params : 'a t -> parameters = "cudd_caml_man_get_params"
external set_params : 'a t -> parameters -> unit = "cudd_caml_man_set_params"
external get_background : d t -> float = "cudd_caml_man_get_background"

type statistics = {
  cache_hits : float;
  cache_lookups : float;
  cache_slots : int;
  cache_used_slots : float;
  dead : int;
  gc_time : int;
  gc_nb : int;
  keys : int;
  linear : int;
  max_cache : int;
  min_dead : int;
  node_count : int;
  peak_node_count : int;
  peak_live_node_count : int;
  reordering_time : int;
  reordering_nb : int;
  bddvar_nb : int;
  zddvar_nb : int;
  slots : int;
  used_slots : float;
  swaps : float;
}
external stats : 'a t -> statistics = "cudd_caml_man_stats"

external error : 'a t -> error = "cudd_caml_man_Cudd_ReadError"
external get_bddvar_nb : 'a t -> int = "cudd_man_Cudd_ReadSize"
external get_zddvar_nb : 'a t -> int = "cudd_man_Cudd_ReadZddSize"

(* ********************************************************************** *)
(* Definitions *)
(* ********************************************************************** *)

let _ = set_gc ~heap:1000000 ~gc:Gc.full_major ~reordering:Gc.full_major
let _ = Callback.register_exception "invalid argument exception" (Invalid_argument "")

let print_limit = ref 30

let make_d ?(numVars=0) ?(numVarsZ=0) ?(numSlots=0) ?(cacheSize=0) ?(maxMemory=0) () =
  _make ~caml:false ~numVars ~numVarsZ ~numSlots ~cacheSize ~maxMemory
let make_v ?(numVars=0) ?(numVarsZ=0) ?(numSlots=0) ?(cacheSize=0) ?(maxMemory=0) () =
  _make ~caml:true ~numVars ~numVarsZ ~numSlots ~cacheSize ~maxMemory

let string_of_reorder = function
  | REORDER_SAME -> "SAME"
  | REORDER_NONE -> "NONE"
  | REORDER_RANDOM -> "RANDOM"
  | REORDER_RANDOM_PIVOT -> "RANDOM_PIVOT"
  | REORDER_SIFT -> "SIFT"
  | REORDER_SIFT_CONVERGE -> "SIFT_CONVERGE"
  | REORDER_SYMM_SIFT -> "SYMM_SIFT"
  | REORDER_SYMM_SIFT_CONV -> "SYMM_SIFT_CONV"
  | REORDER_WINDOW2 -> "WINDOW2"
  | REORDER_WINDOW3 -> "WINDOW3"
  | REORDER_WINDOW4 -> "WINDOW4"
  | REORDER_WINDOW2_CONV -> "WINDOW2_CONV"
  | REORDER_WINDOW3_CONV -> "WINDOW3_CONV"
  | REORDER_WINDOW4_CONV -> "WINDOW4_CONV"
  | REORDER_GROUP_SIFT -> "GROUP_SIFT"
  | REORDER_GROUP_SIFT_CONV -> "GROUP_SIFT_CONV"
  | REORDER_ANNEALING -> "ANNEALING"
  | REORDER_GENETIC -> "GENETIC"
  | REORDER_LINEAR -> "LINEAR"
  | REORDER_LINEAR_CONVERGE -> "LINEAR_CONVERGE"
  | REORDER_LAZY_SIFT -> "LAZY_SIFT"
  | REORDER_EXACT -> "EXACT"
let string_of_error = function
  | NO_ERROR -> "NO_ERROR"
  | MEMORY_OUT -> "MEMORY_OUT"
  | TOO_MANY_NODES -> "TOO_MANY_NODES"
  | MAX_MEM_EXCEEDED -> "MAX_MEM_EXCEEDED"
  | INVALID_ARG -> "INVALID_ARG"
  | INTERNAL_ERROR -> "INTERNAL_ERROR"
