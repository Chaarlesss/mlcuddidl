(** CUDD Manager *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

type 'a t
(** Type of CUDD managers, where ['a] is either [d] or [v], see below *)

type d
(** Indicates that a CUDD manager manipulates standard ADDs with
    leaves of type C double *)

type v
(** Indicates that a CUDD manager manipulates ``custom'' ADDs with
    leaves of type an [OCaml] value, see modules {!Mtbdd} and
    {!Mtbddc}. A manager cannot manipulate the two types of ADDs (for
    garbage collection reasons) *)

type dt = d t
type vt = v t
  (** Shortcuts *)

type tbool = False | True | Top
  (** Ternary Boolean type, used to defines minterms where [Top] means [True]
      or [False] *)

(** Type of error when CUDD raises an exception. *)
type error =
  | NO_ERROR
  | MEMORY_OUT
  | TOO_MANY_NODES
  | MAX_MEM_EXCEEDED
  | INVALID_ARG
  | INTERNAL_ERROR

val string_of_error : error -> string
  (** Printing function *)

(*  ====================================================== *)
(** {3 Global settings} *)
(*  ====================================================== *)

val print_limit : int ref
(** Parameter for printing functions: specify the maximum number
    of minterms to be printed. Above this numbers, only statistics on
    the BDD is printed. *)

external set_gc : heap:int -> gc:(unit -> unit) -> reordering:(unit -> unit) -> unit = "cudd_caml_set_gc"
(** [set_gc max gc reordering] performs several things:
    - It sets the ratio used/max for BDDs abstract values to
    [1/max] (see the OCaml manual for details). 1 000 000 is a
    good value.

    - It also sets for all the future managers that will be
    created the hook function to be called before a CUDD garbage
    collection, and the hook function to be called before a CUDD
    reordering. You may typically specify a OCaml garbage
    collection function for both hooks, in order to make OCaml
    dereference unused nodes, thus allowing CUDD to remove
    them. Default values are [Gc.full_major()] for both hooks.
*)

external srandom : int -> unit = "cudd_caml_man_srandom"
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Srandom}[Cudd_Srandom]}.
   Initializes the seed for the CUDD random number generator (used
   in a number of functions, like {!Bdd.pick_cubes_on_support}. *)

(*  ====================================================== *)
(** {3 Managers} *)
(*  ====================================================== *)

(** Internal, do not use ! *)
external _make : caml:bool -> numVars:int -> numVarsZ:int -> numSlots:int -> cacheSize:int -> maxMemory:int -> 'a t = "cudd_caml_man_Cudd_Init_bytecode" "cudd_caml_man_Cudd_Init"

val make_d : ?numVars:int -> ?numVarsZ:int -> ?numSlots:int -> ?cacheSize:int -> ?maxMemory:int -> unit -> d t
val make_v : ?numVars:int -> ?numVarsZ:int -> ?numSlots:int -> ?cacheSize:int -> ?maxMemory:int -> unit -> v t
(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Init}[Cudd_Init]}.

    [make_d ~numVars ~numVarsZ ~numSlots ~cacheSize ~maxMemory ()]
    creates a manager with the given parameters. [make_d ()] is
    OK. In addition, the function sets a hook function to be
    called whenever a CUDD garbage collection occurs, and a
    (dummy) hook function to be called whenever a CUDD reordering
    occurs. The defaults can be modified with {!set_gc}. *)

external debugcheck : 'a t -> bool = "cudd_caml_man_Cudd_DebugCheck"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_DebugCheck}[Cudd_DebugCheck]}.
    Returns [false] if it is OK, [true] if there is a problem, and throw
    a [Failure] exception in case of [OUT_OF_MEM]. *)

external check_keys : 'a t -> int = "cudd_caml_man_Cudd_CheckKeys"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CheckKeys}[Cudd_CheckKeys]}. *)

external copy_shr : 'a -> 'a = "cudd_caml_custom_copy_shr"
(** Internal use: duplicate a block to the major heap. Used by
    {!Mtbdd} and {!Mtbddc} modules *)

(*  ====================================================== *)
(** {3 Variables, Reordering and Mapping} *)
(*  ====================================================== *)

(** Reordering method. *)
type reorder =
  | REORDER_SAME
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

(** Type of aggregation methods. *)
type aggregation =
  | NO_CHECK
  | GROUP_CHECK
  | GROUP_CHECK2
  | GROUP_CHECK3
  | GROUP_CHECK4
  | GROUP_CHECK5
  | GROUP_CHECK6
  | GROUP_CHECK7
  | GROUP_CHECK8
  | GROUP_CHECK9

(** Group type for lazy sifting. *)
type lazygroup =
  | LAZY_NONE
  | LAZY_SOFT_GROUP
  | LAZY_HARD_GROUP
  | LAZY_UNGROUP

(** Variable type. Currently used only in lazy sifting. *)
type vartype =
  | VAR_PRIMARY_INPUT
  | VAR_PRESENT_STATE
  | VAR_NEXT_STATE

(** Is variable order inside group fixed or not ? *)
type mtr =
  | MTR_DEFAULT
  | MTR_FIXED

val string_of_reorder : reorder -> string
(** Printing function *)


external level_of_var : 'a t -> int -> int = "cudd_caml_man_Cudd_ReadPerm"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadPerm}[Cudd_ReadPerm]}. Returns
   the level of the variable (its order in the BDD) *)

external var_of_level : 'a t -> int -> int = "cudd_caml_man_Cudd_ReadInvPerm"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadInvPerm}[Cudd_ReadInvPerm]}. Returns
   the variable associated to the given level. *)

external reduce_heap : 'a t -> reorder -> int -> unit = "cudd_caml_man_Cudd_ReduceHeap"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReduceHeap}[Cudd_ReduceHeap]}. Main
   reordering function, that applies the given heuristic. The
   provided integer is a bound below which no reordering takes
   place. *)

external shuffle_heap : 'a t -> int array -> unit = "cudd_caml_man_Cudd_ShuffleHeap"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ShuffleHeap}[Cudd_ShuffleHeap]}. Reorder
   variables according to the given permutation. *)

external garbage_collect : 'a t -> int = "cudd_caml_man_cuddGarbageCollect"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddAllDet.html#cuddGarbageCollect}[cuddGarbageCollect]}. Force
   a garbage collection (with cache clearing) *)

external flush : 'a t -> unit = "cudd_caml_man_cuddCacheFlush"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddAllDet.html#cuddCacheFlush}[cuddCacheFlush]}. Clear
   the global cache *)

external enable_autodyn : 'a t -> reorder -> unit = "cudd_caml_man_Cudd_AutodynEnable"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_AutodynEnable}[Cudd_AutodynEnable]}. Enables
   dynamic reordering with the given heuristics. *)

external disable_autodyn : 'a t -> unit = "cudd_caml_man_Cudd_AutodynDisable"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_AutodynDisable}[Cudd_AutodynDisable]}. Disables
   dynamic reordering. *)


external autodyn_status : 'a t -> reorder option = "cudd_caml_man_Cudd_ReorderingStatus"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReorderingStatus}[Cudd_ReorderingStatus]}. Returns
   [None] if dynamic reordering is disables, [Some(heuristic)]
   otherwise. *)

external group : 'a t -> int -> int -> mtr -> unit = "cudd_caml_man_Cudd_MakeTreeNode"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_MakeTreeNode}[Cudd_MakeTreeNode]}.
   [group man low size typ] creates a new variable group, ranging
   from index [low] to index [low+size-1], in which [typ]
   specifies if reordering is allowed inside the group. *)

external ungroupall : 'a t -> unit = "cudd_caml_man_Cudd_FreeTree"
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_FreeTree}[Cudd_FreeTree]}. Removes
   all the groups in the manager. *)

external set_varmap : 'a t -> int array -> unit = "cudd_caml_man_Cuddaux_SetVarMap"
(**
   [Cuddaux_SetVarMap]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_SetVarMap}[Cudd_SetVarMap]}. Initializes
   the global mapping table, used by functions {!Bdd.varmap},
   {!Vdd.varmap}, {!Mtbdd.varmap}, {!Mtbddc.varmap},... Convenient
   when the same mapping is applied several times, because the the
   different calls reuse the same cache. *)

(*  ====================================================== *)
(** {3 Parameters} *)
(*  ====================================================== *)

type parameters = {

  (** {6 RDDs} *)

  background: float;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadBackground}[Cudd_ReadBackground]}. *)
  epsilon : float;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadEpsilon}[Cudd_ReadEpsilon]}. *)

  (** {6 Manager} *)

  min_hit : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMinHit}[Cudd_ReadMinHit]}. *)
  max_cache_hard : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMinHit}[Cudd_ReadMinHit]}. *)
  loose_up_to : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadLooseUpTo}[Cudd_ReadLooseUpTo]}. *)
  max_live : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMaxLive}[Cudd_ReadMaxLive]}. *)
  max_mem : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMaxMemory}[Cudd_ReadMaxMemory]}. *)

 (** {6 Reordering} *)

  sift_max_swap : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadSiftMaxSwap}[Cudd_ReadSiftMaxSwap]}. *)
  sift_max_var : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadSiftMaxVar}[Cudd_ReadSiftMaxVar]}. *)
  group_check : aggregation;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadSiftMaxVar}[Cudd_ReadSiftMaxVar]}. *)
  arc_violation : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadArcviolation}[Cudd_ReadArcviolation]}. *)
  number_xovers : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadNumberXovers}[Cudd_ReadNumberXovers]}. *)
  population_size : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadPopulationSize}[Cudd_ReadPopulationSize]}. *)
  recomb : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadRecomb}[Cudd_ReadRecomb]}. *)
  symm_violation : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadSymmviolation}[Cudd_ReadSymmviolation]}. *)

  (** {6 Dynamic Reordering} *)

  max_growth : float;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMaxGrowth}[Cudd_ReadMaxGrowth]}. *)
  max_growth_alt : float;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMaxGrowthAlternate}[Cudd_ReadMaxGrowthAlternate]}. *)
  reordering_cycle : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadReorderingCycle}[Cudd_ReadReorderingCycle]}. *)
  next_reordering : int;
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadNextReordering}[Cudd_ReadNextReordering]}. *)
}

external get_params : 'a t -> parameters = "cudd_caml_man_get_params"
external set_params : 'a t -> parameters -> unit = "cudd_caml_man_set_params"
external get_background : d t -> float = "cudd_caml_man_get_background"

(*  ====================================================== *)
(** {3 Statistics} *)
(*  ====================================================== *)

type statistics = {
  cache_hits : float;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadCacheHits}[Cudd_ReadCacheHits]}. *)
 cache_lookups : float;
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadCacheLookUps}[Cudd_ReadCacheLookUps]}. *)
  cache_slots : int;
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadCacheSlots}[Cudd_ReadCacheSlots]}. *)
  cache_used_slots : float;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadCacheUsedSlots}[Cudd_ReadCacheUsedSlots]}. *)
 dead : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadDead}[Cudd_ReadDead]}. *)
 gc_time : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadGarbageCollectionTime}[Cudd_ReadGarbageCollectionTime]}. *)
 gc_nb : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadGarbageCollections}[Cudd_ReadGarbageCollections]}. *)
 keys : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadKeys}[Cudd_ReadKeys]}. *)
 linear : int;
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadLinear}[Cudd_ReadLinear]}. *)
  max_cache : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMaxCache}[Cudd_ReadMaxCache]}. *)
min_dead : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadMinDead}[Cudd_ReadMinDead]}. *)
 node_count : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadNodeCount}[Cudd_ReadNodeCount]}. *)
 peak_node_count : int;
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadPeakNodeCount}[Cudd_ReadPeakNodeCount]}. *)
  peak_live_node_count : int;
  (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadPeakNodeCount}[Cudd_ReadPeakLiveNodeCount]}. *)
  reordering_time : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadReorderingTime}[Cudd_ReadReorderingTime]}. *)
 reordering_nb : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadReorderings}[Cudd_ReadReorderings]}. *)
 bddvar_nb : int;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadSize}[Cudd_ReadSize]}. *)
 zddvar_nb : int;
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadZddSize}[Cudd_ReadZddSize]}. *)
  slots : int;
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadSlots}[Cudd_ReadSlots]}. *)
  used_slots : float;
 (** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ReadUsedSlots}[Cudd_ReadUsedSlots]}. *)
 swaps : float;
}

external stats : 'a t -> statistics = "cudd_caml_man_stats"
external error : 'a t -> error = "cudd_caml_man_Cudd_ReadError"
external get_bddvar_nb : 'a t -> int = "cudd_man_Cudd_ReadSize"
external get_zddvar_nb : 'a t -> int = "cudd_man_Cudd_ReadZddSize"
