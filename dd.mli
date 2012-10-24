
type any     = [`any]
(* All the following types implictly includes the case of constant values (false and true) *)
type cube = [`any | `cube]
type lit  = [`any | `cube | `lit]
type supp = [`any | `cube | `pos]
type atom = [`any | `cube | `lit | `pos]

type +'a value

type ('a, 'b) t
type ('a, 'b) bdd  = ('a,'b) t constraint 'b=[>any]
type ('a, 'b) avdd = ('a, 'b value) t

type    add = (Man.d, float) avdd
type 'a vdd = (Man.v, 'a   ) avdd

(*  ********************************************************************** *)
(** {3 Applies to any diagram} *)
(*  ********************************************************************** *)

external manager : ('a,'b) t -> 'a Man.t = "cudd_caml_dd_manager"
external is_cst : ('a,'b) t -> bool = "cudd_caml_dd_Cudd_IsConstant" "noalloc"
external topvar : ('a,'b) t -> int = "cudd_caml_dd_Cudd_NodeReadIndex"
external support : ('a,'b) t -> ('a,[<supp]) bdd = "cudd_caml_dd_Cuddaux_Support"
external supportsize : ('a,'b) t -> int = "cudd_caml_dd_Cuddaux_SupportSize"
external is_var_in : int -> ('a,'b) t -> bool = "cudd_caml_dd_Cuddaux_IsVarIn"
external vectorsupport : ('a,'b) t array -> ('a,[<supp]) bdd = "cudd_caml_dd_vectorsupport"
external size : ('a,'b) t -> int = "cudd_caml_dd_Cudd_DagSize"
external nbleaves : ('a,'b) t -> int = "cudd_caml_dd_Cudd_CountLeaves"
external nbpaths : ('a,'b) t -> float = "cudd_caml_dd_Cudd_CountPath"
external nbminterms : nbvars:int -> ('a,'b) t -> float = "cudd_caml_dd_Cudd_CountMinterm"
external density : nbvars:int -> ('a,'b) t -> float = "cudd_caml_dd_Cudd_Density"
external is_equal : ('a,'b) t -> ('a,'c) t -> bool = "cudd_caml_dd_is_equal"
external is_equal_when :
  ('a,'b) t -> ('a,'c) t -> care:('a,'d) bdd -> bool = "cudd_caml_dd_is_equal_when"
external list_of_support : ('a,[>supp]) bdd -> int list = "cudd_caml_dd_list_of_support"
external list_of_cube : ('a,[>cube]) bdd -> (int * bool) list = "cudd_caml_dd_list_of_cube"
external minterm_of_cube : ('a,[>cube]) bdd -> Man.tbool array = "cudd_caml_dd_minterm_of_cube"
external cube_of_minterm : 'a Man.t -> Man.tbool array -> ('a,cube) bdd = "cudd_caml_dd_cube_of_minterm"

(*  ********************************************************************** *)
(** {3 Applies to BDD} *)
(*  ********************************************************************** *)

module B : sig
  val cofactor : ('a,'b) bdd -> cube:('a,[>cube]) bdd -> ('a,'b) bdd
  val dand : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  val dor : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  val xor : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  val intersect : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  val exist : supp:('a,[>supp]) bdd -> ('a,'b) bdd -> ('a,'b) bdd
  val forall : supp:('a,[>supp]) bdd -> ('a,'b) bdd -> ('a,'b) bdd
  val constrain : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd
  val tdconstrain : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd
  val restrict : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd
  val tdrestrict : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd
  val minimize : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd
  val licompaction : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd
  val squeeze : lower:('a,'b) bdd -> upper:('a,'c) bdd -> ('a,any) bdd
  val guard_of_node : ('a,'b) avdd -> node:('a,'b) avdd -> ('a,any) bdd
  val ite : ('a,'b) bdd -> ('a,'c) bdd -> ('a,'d) bdd -> ('a,any) bdd
  val existand :
    supp:('a,[>supp]) bdd -> ('a,'c) bdd -> ('a,'d) bdd -> ('a,any) bdd
  val existxor :
    supp:('a,[>supp]) bdd -> ('a,'c) bdd -> ('a,'d) bdd -> ('a,any) bdd
  val approxconjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  val iterconjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  val genconjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  val varconjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  val approxdisjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  val iterdisjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  val gendisjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  val vardisjdecomp :
    ('a,'b) bdd -> (('a,any) bdd * ('a,any) bdd) option
  type ('a,'b) inspect =
    | Bool of bool
    | Ite of int * ('a,'b) bdd * ('a,'b) bdd
  external inspect : ('a,'b) bdd -> ('a,'b) inspect = "cudd_caml_bdd_inspect"
  external dthen : ('a,'b) bdd -> ('a,'b) bdd = "cudd_caml_bdd_Cudd_T"
  external delse : ('a,'b) bdd -> ('a,'b) bdd = "cudd_caml_bdd_Cudd_E"
  external dtrue : 'a Man.t -> ('a,[<atom]) bdd = "cudd_caml_bdd_dtrue"
  external dfalse : 'a Man.t -> ('a,[<atom]) bdd = "cudd_caml_bdd_dfalse"
  external ithvar : 'a Man.t -> int -> ('a,[<atom]) bdd = "cudd_caml_bdd_Cudd_bddIthVar"
  external newvar : 'a Man.t -> ('a,[<atom]) bdd = "cudd_caml_bdd_Cudd_bddNewVar"
  external newvar_at_level : 'a Man.t -> int -> ('a,[<atom]) bdd = "cudd_caml_bdd_Cudd_bddNewVarAtLevel"
  external dnot : ('a,'b) bdd -> ('a,any) bdd = "cudd_caml_bdd_Cudd_Not"
  external vnot : ('a,[>lit]) bdd -> ('a,lit) bdd  = "cudd_caml_bdd_Cudd_Not"
  external is_complement : ('a,'b) bdd -> bool = "cudd_caml_bdd_Cudd_IsComplement" "noalloc"
  external is_true : ('a,'b) bdd -> bool = "cudd_caml_bdd_is_true" "noalloc"
  external is_false : ('a,'b) bdd -> bool = "cudd_caml_bdd_is_false" "noalloc"
  external is_leq : ('a,'b) bdd -> ('a,'c) bdd -> bool = "cudd_caml_bdd_Cudd_bddLeq"
  external is_inter_empty : ('a,'b) bdd -> ('a,'c) bdd -> bool = "cudd_caml_bdd_is_inter_empty"
  val is_included_in : ('a,'b) bdd -> ('a,'c) bdd -> bool
  external is_leq_when : ('a,'b) bdd -> ('a,'c) bdd -> care:('a,'d) bdd -> bool = "cudd_caml_bdd_is_leq_when"
  external is_var_dependent : int -> ('a,'b) bdd -> bool = "cudd_caml_bdd_is_var_dependent"
  val is_var_essential : int * bool -> ('a,'b) bdd -> bool
  val nand : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  val nor : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  val nxor : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  val eq : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  external cube_of_bdd : ('a,'b) bdd -> ('a,cube) bdd = "cudd_caml_bdd_Cudd_FindEssential"
  external booleandiff : ('a,'b) bdd -> int -> ('a,any) bdd = "cudd_caml_bdd_Cudd_BooleandDiff"
  val cofactors : int -> ('a,'b) bdd -> ('a,'b) bdd * ('a,'b) bdd
  val ite_cst :
    ('a,'b) bdd -> ('a,'c) bdd -> ('a,'d) bdd -> bool option
  val is_ite_cst : ('a,'b) bdd -> ('a,'c) bdd -> ('a,'d) bdd -> bool
  val varmap : ('a,'b) bdd -> ('a,'b) bdd
  val permute :
    ?memo:Memo.t -> perm:int array -> ('a,'b) bdd -> ('a,'b) bdd
  val compose : var:int -> f:('a,'c) bdd -> ('a,'b) bdd -> ('a,any) bdd
  val vectorcompose : ?memo:Memo.t -> ('a,'b) bdd array -> ('a,'c) bdd -> ('a,any) bdd
  val iter_node : (('a,any) bdd -> unit) -> ('a,'b) bdd -> unit
  val transfer : ('a,'c) bdd -> man:'b Man.t -> ('b,'c) bdd
  val support_inter : ('a,[>supp]) bdd -> ('a,[>supp]) bdd -> ('a,supp) bdd
  val support_union : ('a,[>supp]) bdd -> ('a,[>supp]) bdd -> ('a,supp) bdd
  val support_diff : ('a,[>supp]) bdd -> ('a,[>supp]) bdd -> ('a,supp) bdd
  val cube_and : ('a,[>cube]) bdd -> ('a,[>cube]) bdd -> ('a,cube) bdd
  val cube_or : ('a,[>cube]) bdd -> ('a,[>cube]) bdd -> ('a,cube) bdd
  val cube_union : ('a,[>cube]) bdd -> ('a,[>cube]) bdd -> ('a,cube) bdd
  external nbtruepaths : ('a,'b) bdd -> float = "cudd_caml_bdd_Cudd_CountPathsToNonZero"
  external pick_minterm : ('a,'b) bdd -> Man.tbool array = "cudd_caml_pick_minterm"
  external pick_cube_on_support :
    supp:('a,[>supp]) bdd -> ('a,'c) bdd -> ('a,cube) bdd = "cudd_caml_pick_cube_on_support"
  external pick_cubes_on_support :
    supp:('a,[>supp]) bdd -> nb:int -> ('a,'c) bdd -> ('a,cube) bdd array = "cudd_caml_pick_cubes_on_support"
  external iter_cube : (Man.tbool array -> unit) -> ('a,'b) bdd -> unit = "cudd_caml_bdd_iter_cube"
  external iter_prime : (Man.tbool array -> unit) -> lower:('a,'b) bdd -> upper:('a,'c) bdd -> unit = "cudd_caml_bdd_iter_prime"
  type approx = Under | Over
  external clippingand :
    depth:int ->
      approx:approx -> ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
	= "cudd_caml_bdd_Cudd_bddClippingAnd"
  external clippingexistand :
    depth:int ->
      approx:approx ->
	supp:('a,[>supp]) bdd -> ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
	  = "cudd_caml_bdd_Cudd_bddClippingAndAbstract"
  external underapprox :
    nbvars:int ->
      threshold:int ->
	safe:bool -> quality:float -> ('a,'b) bdd -> ('a,any) bdd
	  = "cudd_caml_bdd_Cudd_UnderApprox"
  external remapunderapprox :
    nbvars:int ->
      threshold:int -> quality:float -> ('a,'b) bdd -> ('a,any) bdd
	= "cudd_caml_bdd_Cudd_RemapUnderApprox"
  external biasedunderapprox :
    nbvars:int ->
      threshold:int ->
	quality_true:float ->
	  quality_false:float ->
	    bias:('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
	      = "cudd_caml_bdd_Cudd_BiasedUnderApprox_bytecode" "cudd_caml_bdd_Cudd_BiasedUnderApprox"
  val overapprox :
    nbvars:int ->
    threshold:int ->
    safe:bool -> quality:float -> ('a,'b) bdd -> ('a,any) bdd
  val remapoverapprox :
    nbvars:int ->
    threshold:int -> quality:float -> ('a,'b) bdd -> ('a,any) bdd
  val biasedoverapprox :
    nbvars:int ->
    threshold:int ->
    quality_true:float ->
    quality_false:float ->
    bias:('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd
  external subsetcompress :
    nbvars:int -> threshold:int -> ('a,'b) bdd -> ('a,any) bdd = "cudd_caml_bdd_Cudd_SubsetCompress"
  external subsetHB :
    nbvars:int -> threshold:int -> ('a,'b) bdd -> ('a,any) bdd = "cudd_caml_bdd_Cudd_subsetHB"
  external subsetSP :
    nbvars:int ->
      threshold:int -> hardlimit:bool -> ('a,'b) bdd -> ('a,any) bdd = "cudd_caml_bdd_Cudd_subsetSP"
  val supersetcompress :
    nbvars:int -> threshold:int -> ('a,'b) bdd -> ('a,any) bdd
  val supersetHB :
    nbvars:int -> threshold:int -> ('a,'b) bdd -> ('a,any) bdd
  val supersetSP :
    nbvars:int ->
    threshold:int -> hardlimit:bool -> ('a,'b) bdd -> ('a,any) bdd
  external correlation : ('a,'b) bdd -> ('a,'c) bdd -> float = "cudd_caml_bdd_Cudd_bddCorrelation"
  external correlationweights :
    ('a,'b) bdd -> ('a,'c) bdd -> weights:float array -> float = "cudd_caml_bdd_Cudd_bddCorrelationeights"
end

(*  ********************************************************************** *)
(** {3 Applies to AVDD} *)
(*  ********************************************************************** *)

module AV : sig
  val cofactor : ('a,'b) avdd -> cube:('a,[>cube]) bdd -> ('a,'b) avdd
  val constrain : ('a,'b) avdd -> care:('a,'c) bdd -> ('a,'b) avdd
  val tdconstrain : ('a,'b) avdd -> care:('a,'c) bdd -> ('a,'b) avdd
  val restrict : ('a,'b) avdd -> care:('a,'c) bdd -> ('a,'b) avdd
  val tdrestrict : ('a,'b) avdd -> care:('a,'c) bdd -> ('a,'b) avdd
  external dthen : ('a,'b) avdd -> ('a,'b) avdd = "cudd_caml_avdd_cuddT"
  external delse : ('a,'b) avdd -> ('a,'b) avdd = "cudd_camla_avdd_cuddE"
  external dval : ('a,'b) avdd -> 'b = "cudd_caml_avdd_dval"
  external cst : 'a Man.t -> 'b -> ('a,'b) avdd = "cudd_caml_avdd_cst"
  external ite : ('a,'b) bdd -> ('a,'c) avdd -> ('a,'c) avdd -> ('a,'c) avdd = "cudd_caml_avdd_Cuddaux_addIte_ite"
  external eval_cst : care:('a,'c) bdd -> ('a,'b) avdd -> 'b option = "cudd_caml_avdd_eval_cst"
  external is_eval_cst : care:('a,'c) bdd -> ('a,'b) avdd -> bool = "cudd_caml_avdd_is_eval_cst"
  val cofactors : int -> ('a,'b) avdd -> ('a,'b) avdd * ('a,'b) avdd
  val ite_cst :
    ('a,'b) bdd -> ('a,'c) avdd -> ('a,'c) avdd -> 'c option
  val is_ite_cst : ('a,'b) bdd -> ('a,'c) avdd -> ('a,'c) avdd -> bool
  val varmap : ('a,'b) avdd -> ('a,'b) avdd
  val permute : ?memo:Memo.t -> perm:int array -> ('a,'b) avdd -> ('a,'b) avdd
  val compose : var:int -> f:('a,'c) bdd -> ('a,'b) avdd -> ('a,'b) avdd
  val vectorcompose : ?memo:Memo.t -> ('a,'b) bdd array -> ('a,'c) avdd -> ('a,'c) avdd
 val iter_node : (('a,'b) avdd -> unit) -> ('a,'b) avdd -> unit
  val transfer : ('a,'c) avdd -> man:'a Man.t -> ('a,'c) avdd
  external iter_cube : (Man.tbool array -> 'b -> unit) -> ('a,'b) avdd -> unit = "cudd_caml_avbdd_iter_cube"
  val guard_of_node : ('a,'b) avdd -> node:('a,'b) avdd -> ('a,any) bdd
  external guard_of_nonbackground : ('a,'b) avdd -> ('a,any) bdd = "cudd_caml_avdd_guard_of_nonbackground"
  external nodes_below_level : ?level:int -> ?max:int -> ('a,'b) avdd -> ('a,'b) avdd array = "cudd_caml_avdd_nodes_below_level"
  external guard_of_leaf : ('a,'b) avdd -> 'b -> ('a,any) bdd = "cudd_caml_avdd_guard_of_leaf"
  external leaves : ('a,'b) avdd -> 'b array = "cudd_caml_avdd_leaves"
  external pick_leaf : ('a,'b) avdd -> 'b = "cudd_caml_avdd_pick_leaf"
  val guardleafs : ('a,'b) avdd -> (('a,any) bdd * 'b) array
end

(*  ********************************************************************** *)
(** {3 Applies to ADD} *)
(*  ********************************************************************** *)

module A : sig
  val add : add -> add -> add
  val sub : add -> add -> add
  val mul : add -> add -> add
  val div : add -> add -> add
  val min : add -> add -> add
  val max : add -> add -> add
  val agreement : add -> add -> add
  val diff : add -> add -> add
  val threshold : add -> add -> add
  val setNZ : add -> add -> add
  val exist : supp:(Man.d,[>supp]) bdd -> add -> add
  val forall : supp:(Man.d,[>supp]) bdd -> add -> add
  val matrix_multiply : int array -> add -> add -> add
  val times_plus : int array -> add -> add -> add
  val triangle : int array -> add -> add -> add
  type inspect =
    | Leaf of float
    | Ite of int * add * add
  external inspect : add -> inspect = "cudd_caml_avdd_inspect"
  external neg : add -> add = "cudd_caml_add"
  external log : add -> add = "cudd_caml_add_log"
  external is_leq : add -> add -> bool = "cudd_caml_add_Cudd_addLeq"
  external nbnonzeropaths : add -> float = "cudd_caml_bdd_Cudd_CountPathsToNonZero"
  external of_bdd : (Man.d,'a) bdd -> add = "cudd_caml_add_Cudd_BddToAdd"
  external to_bdd : add -> (Man.d,any) bdd = "cudd_caml_add_Cudd_addBddPattern"
  external to_bdd_threshold : add -> threshold:float -> (Man.d,any) bdd = "cudd_caml_add_Cudd_addBddThreshold"
  external to_bdd_strictthreshold : add -> threshold:float -> (Man.d,any) bdd = "cudd_caml_add_Cudd_addBddStrictThreshold"
  external to_bdd_interval : add -> lower:float -> upper:float -> (Man.d,any) bdd = "cudd_caml_add_Cudd_addBddInterval"
end
module V : sig
  type 'a inspect =
    | Leaf of 'a
    | Ite of int * 'a vdd * 'a vdd
  external inspect : 'a vdd -> 'a inspect = "cudd_caml_avdd_inspect"
end
