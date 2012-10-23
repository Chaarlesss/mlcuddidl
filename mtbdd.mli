(** MTBDDs with OCaml values *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

type 'a unique
  (** Type of unique representants of MTBDD leaves of type ['a].

      For technical reason, type ['a] should not be implemented as
      a custom block with finalization function. (This is checked
      and the program aborts with an error message).

      Use {!Mtbddc} module if your type does not fulfill this
      requirement.  [Mtbddc] modules automatically encapsulate the
      value into a ML type. *)

type 'a t = 'a unique Vdd.t
  (** Type of MTBDDs.

      Objects of this type contains both the top node of the MTBDD
      and the manager to which the node belongs. The manager can
      be retrieved with {!manager}. Objects of this type are
      automatically garbage collected.  *)

type 'a table = 'a unique PWeakke.t
  (** Hashtable to manage unique constants *)

val print_table :
  ?first:(unit, Format.formatter, unit) format ->
  ?sep:(unit, Format.formatter, unit) format ->
  ?last:(unit, Format.formatter, unit) format ->
  (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a table -> unit

val make_table : hash:('a -> int) -> equal:('a -> 'a -> bool) -> 'a table
  (** Building a table *)

val unique : 'a table -> 'a -> 'a unique
  (** Building a unique constant *)
val get : 'a unique -> 'a
  (** Type conversion (no computation) *)

(** Public type for exploring the abstract type [t] *)
type 'a mtbdd = 'a Vdd.vdd =
  | Leaf of 'a               (** Terminal value *)
  | Ite of int * 'a Vdd.t * 'a Vdd.t (** Decision on CUDD variable *)

(** We refer to the modules {!Add} and {!Vdd} for the description
    of the interface. *)

(* ====================================================== *)
(** {3 Extractors} *)
(* ====================================================== *)

val manager : 'a t -> Man.vt
  (** Returns the manager associated to the MTBDD *)

val is_cst : 'a t -> bool
  (** Is the MTBDD constant ? *)

val topvar : 'a t -> int
  (** Returns the index of the top node of the MTBDD (65535 for a
      constant MTBDD) *)

val dthen : 'a t -> 'a t
  (** Returns the positive subnode of the MTBDD *)

val delse : 'a t -> 'a t
  (** Returns the negative subnode of the MTBDD *)

val cofactors : int -> 'a t -> 'a t * 'a t
  (** Returns the positive and negative cofactor of the MTBDD wrt
      the variable *)

val cofactor : 'a t -> cube:[>Bdd.cube] Bdd.vt -> 'a t
  (** [cofactor mtbdd cube] evaluates [mtbbdd] on the cube [cube] *)

val dval_u : 'a t -> 'a unique
val dval : 'a t -> 'a
  (** Returns the value of the assumed constant MTBDD *)

val inspect_u : 'a t -> 'a unique mtbdd
  (** Decompose the MTBDD *)

(* ====================================================== *)
(** {3 Supports} *)
(* ====================================================== *)

val support : 'a t -> Bdd.supp Bdd.vt
val supportsize : 'a t -> int
val is_var_in : int -> 'a t -> bool
val vectorsupport : 'a t array -> Bdd.supp Bdd.vt

(* ====================================================== *)
(** {3 Classical operations} *)
(* ====================================================== *)

val cst_u : Man.vt -> 'a unique -> 'a t
val cst : Man.vt -> 'a table -> 'a -> 'a t

val ite : [>Bdd.any] Bdd.vt -> 'a t -> 'a t -> 'a t
val eval_cst_u : care:[>Bdd.any] Bdd.vt -> 'a t -> 'a unique option
val eval_cst : care:[>Bdd.any] Bdd.vt -> 'a t -> 'a option
val ite_cst_u : [>Bdd.any] Bdd.vt -> 'a t -> 'a t -> 'a unique option
val ite_cst : [>Bdd.any] Bdd.vt -> 'a t -> 'a t -> 'a option
val compose : var:int -> f:[>Bdd.any] Bdd.vt -> 'a t -> 'a t
val vectorcompose: ?memo:Memo.t -> [>Bdd.any] Bdd.vt array -> 'a t -> 'a t

(* ====================================================== *)
(** {3 Logical tests} *)
(* ====================================================== *)

val is_equal : 'a t -> 'a t -> bool
val is_equal_when : 'a t -> 'a t -> care:[>Bdd.any] Bdd.vt -> bool

val is_eval_cst : care:[>Bdd.any] Bdd.vt -> 'a t -> bool
val is_ite_cst : [>Bdd.any] Bdd.vt -> 'a t -> 'a t -> bool

(* ====================================================== *)
(** {3 Structural information} *)
(* ====================================================== *)

val size : 'a t -> int
val nbpaths : 'a t -> float
val nbminterms : nbvars:int -> 'a t -> float
val density : nbvars:int -> 'a t -> float
val nbleaves : 'a t -> int

(* ====================================================== *)
(** {3 Variable mapping} *)
(* ====================================================== *)

val varmap : 'a t -> 'a t
val permute : ?memo:Memo.t -> perm:int array -> 'a t -> 'a t

(* ====================================================== *)
(** {3 Iterators} *)
(* ====================================================== *)

val iter_cube_u : (Man.tbool array -> 'a unique -> unit) -> 'a t -> unit
val iter_cube : (Man.tbool array -> 'a -> unit) -> 'a t -> unit
val iter_node: ('a t -> unit) -> 'a t -> unit

(* ====================================================== *)
(** {3 Leaves and guards} *)
(* ====================================================== *)

val guard_of_node : 'a t -> node:'a t -> Bdd.any Bdd.vt
val guard_of_nonbackground : 'a t -> Bdd.any Bdd.vt
val nodes_below_level: ?level:int -> ?max:int -> 'a t -> 'a t array

(** Guard of the given leaf *)
val guard_of_leaf_u : 'a t -> 'a unique -> Bdd.any Bdd.vt
val guard_of_leaf : 'a table -> 'a t -> 'a -> Bdd.any Bdd.vt

(** Returns the set of leaf values (excluding the background value) *)
val leaves_u: 'a t -> 'a unique array
val leaves: 'a t -> 'a array

(** Picks (but not randomly) a non background leaf. Return [None] if the only leaf is the background leaf. *)
val pick_leaf_u : 'a t -> 'a unique
val pick_leaf : 'a t -> 'a

(** Returns the set of leaf values together with their guard in the ADD *)
val guardleafs_u : 'a t -> (Bdd.any Bdd.vt * 'a unique) array
val guardleafs : 'a t -> (Bdd.any Bdd.vt * 'a) array

(* ====================================================== *)
(** {3 Minimizations} *)
(* ====================================================== *)

val constrain: 'a t -> care:[>Bdd.any] Bdd.vt -> 'a t
val tdconstrain: 'a t -> care:[>Bdd.any] Bdd.vt -> 'a t
val restrict: 'a t -> care:[>Bdd.any] Bdd.vt -> 'a t
val tdrestrict : 'a t -> care:[>Bdd.any] Bdd.vt -> 'a t

(* ====================================================== *)
(** {3 Conversions} *)
(* ====================================================== *)

(* ====================================================== *)
(** {3 User operations} *)
(* ====================================================== *)

(**
Two options:
- By decomposition into guards and leafs: see module {!Mapleaf};
- By using CUDD cache: see module {!User}.
*)

(* ====================================================== *)
(** {3 Miscellaneous} *)
(* ====================================================== *)

val transfer : 'a t -> man:Man.vt -> 'a t

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
  (Format.formatter -> Bdd.any Bdd.vt -> unit) ->
  (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a t -> unit
