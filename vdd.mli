(** MTBDDs with OCaml values (INTERNAL) *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)


type +'a t
(** Type of VDDs (that are necessarily attached to a manager of
    type [Man.v Man.t]).

    Objects of this type contains both the top node of the ADD
    and the manager to which the node belongs. The manager can
    be retrieved with {!manager}. Objects of this type are
    automatically garbage collected. *)

(** Public type for exploring the abstract type [t] *)
type +'a vdd =
| Leaf of 'a               (** Terminal value *)
| Ite of int * 'a t * 'a t (** Decision on CUDD variable *)



(** We refer to the module {!Add} for the description of the
    interface, as it is nearly identical to {!Add}, except that real
    leaves are replaced by OCaml leaves.

    IMPORTANT NOTE: this is an internal module, which assumes that leaves are
    either immediate values (booleans, integers, constant sums),
    or values allocated with caml_alloc_shr (that can
    be moved only during a memory compaction).

    The only case where you may use directly {!Vdd} without worrying is when the
    leaves are represented as immediate values (booleans, integers, constant
    sums) in the heap.

    Otherwise, use module {!Mtbdd} or {!Mtbddc} to be safe and to
    ensure that you do not have two constant MTBDDs pointing to
    different but semantically equivalent values.
*)


(* ====================================================== *)
(** {3 Extractors} *)
(* ====================================================== *)

val manager : 'a t -> Man.v Man.t
val is_cst : 'a t -> bool
val topvar : 'a t -> int
val dthen : 'a t -> 'a t
val delse : 'a t -> 'a t
val cofactors : int -> 'a t -> 'a t * 'a t
val cofactor : 'a t -> cube:(Man.v,'b,'c) Bdd.cube -> 'a t
val dval : 'a t -> 'a
val inspect: 'a t -> 'a vdd

(* ====================================================== *)
(** {3 Supports} *)
(* ====================================================== *)

val support : 'a t -> Bdd.vsupp
val supportsize : 'a t -> int
val is_var_in : int -> 'a t -> bool
val vectorsupport : 'a t array -> Bdd.vsupp

(* ====================================================== *)
(** {3 Classical operations} *)
(* ====================================================== *)

val cst : Man.vt -> 'a -> 'a t

(** Be cautious, it is not type safe (if you use
    {!nodes_below_level}, etc...: you can try to retrieve a constant
    value of some type and [()] value of the background value will be
    treated as another type.*)
val _background : Man.vt -> 'a t

val ite : (Man.v,'b) Bdd.t -> 'a t -> 'a t -> 'a t
val ite_cst : (Man.v,'b) Bdd.t -> 'a t -> 'a t -> 'a t option
val eval_cst : 'a t -> (Man.v,'b) Bdd.t -> 'a t option
val compose : var:int -> f:(Man.v,'b) Bdd.t -> 'a t -> 'a t

val vectorcompose : ?memo:Memo.t -> (Man.v,'b) Bdd.t array -> 'a t -> 'a t

(* ====================================================== *)
(** {3 Logical tests} *)
(* ====================================================== *)

val is_equal : 'a t -> 'a t -> bool
val is_equal_when : 'a t -> 'a t -> care:(Man.v,'b) Bdd.t -> bool
val is_eval_cst : 'a t -> care:(Man.v,'b) Bdd.t -> 'a option
val is_ite_cst : (Man.v,'b) Bdd.t -> 'a t -> 'a t -> 'a option

(* ====================================================== *)
(** {3 Structural information} *)
(* ====================================================== *)

val size : 'a t -> int
val nbpaths : 'a t -> float
val nbnonzeropaths : 'a t -> float
val nbminterms : int -> 'a t -> float
val density : int -> 'a t -> float
val nbleaves : 'a t -> int

(* ====================================================== *)
(** {3 Variable mapping} *)
(* ====================================================== *)

val varmap : 'a t -> 'a t


(** Variant with controllable memoization policy. *)
val permute : ?memo:Memo.t -> 'a t -> int array -> 'a t
(* ====================================================== *)
(** {3 Iterators} *)
(* ====================================================== *)

val iter_cube: (Man.tbool array -> 'a -> unit) -> 'a t -> unit
val iter_node: ('a t -> unit) -> 'a t -> unit

(* ====================================================== *)
(** {3 Leaves and guards} *)
(* ====================================================== *)

val guard_of_node : 'a t -> 'a t -> Bdd.vt
val guard_of_nonbackground : 'a t -> Bdd.vt


(** [Cuddaux_NodesBelowLevel]. [nodes_below_level ?max f olevel] returns all (if [max=None]), otherwise at most [Some max] nodes pointed by the ADD, indexed by a variable of level greater or equal than [level], and encountered first in the top-down exploration (i.e., whenever a node is collected, its sons are not collected). If [olevel=None], then only constant nodes are collected. *)
val nodes_below_level: ?max:int -> 'a t -> int option -> 'a t array


(** Guard of the given leaf *)
val guard_of_leaf : 'a t -> 'a -> Bdd.vt

(** Returns the set of leaf values (excluding the background value) *)
val leaves: 'a t -> 'a array

(** Picks (but not randomly) a non background leaf. Return [None] if the only leaf is the background leaf. *)
val pick_leaf : 'a t -> 'a


(** Returns the set of leaf values together with their guard in the ADD *)
val guardleafs : 'a t -> (Bdd.vt * 'a) array

(* ====================================================== *)
(** {3 Minimizations} *)
(* ====================================================== *)

val constrain: 'a t -> care:(Man.v,'b) Bdd.t -> 'a t
val tdconstrain: 'a t -> care:(Man.v,'b) Bdd.t -> 'a t
val restrict: 'a t -> care:(Man.v,'b) Bdd.t -> 'a t
val tdrestrict : 'a t -> care:(Man.v,'b) Bdd.t -> 'a t

(* ====================================================== *)
(** {3 Conversions} *)
(* ====================================================== *)
(* ====================================================== *)
(** {3 User operations} *)
(* ====================================================== *)

(**
Two options:
- By decomposition into guards and leafs: see module {!Mapleaf}
- By using CUDD cache: see module {!User}
*)

(* ====================================================== *)
(** {3 Miscellaneous} *)
(* ====================================================== *)

val transfer : 'a t -> Man.v Man.t -> 'a t

(* ====================================================== *)
(** {3 Printing} *)
(* ====================================================== *)

val print__minterm:
  (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a t -> unit
val print_minterm:
  (Format.formatter -> int -> unit) ->
  (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a t -> unit
val print:
  (Format.formatter -> (Man.v,'b) Bdd.t -> unit) ->
  (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a t -> unit
