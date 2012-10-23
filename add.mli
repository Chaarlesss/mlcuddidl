(* File generated from add.idl *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

(** MTBDDs with floats (CUDD ADDs) *)

type t = Dd.add
(** Abstract type for ADDs (that are necessarily attached to a
    manager of type [Man.d Man.t]).

    Objects of this type contains both the top node of the ADD and
    the manager to which the node belongs. The manager can be
    retrieved with {!manager}. Objects of this type are
    automatically garbage collected. *)

(** Public type for exploring the abstract type [t] *)
type add =
  | Leaf of float      (** Terminal value *)
  | Ite of int * t * t (** Decision on CUDD variable *)

(*  ====================================================== *)
(** {3 Extractors} *)
(*  ====================================================== *)

val manager : t -> Man.dt
(** Returns the manager associated to the ADD *)

val is_cst : t -> bool
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_IsConstant}[Cudd_IsConstant]}. Is
   the ADD constant ? *)

val topvar : t -> int
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_NodeReadIndex}[Cudd_NodeReadIndex]}. Returns the index of the ADD (65535 for a constant ADD) *)

val dthen : t -> t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_T}[Cudd_T]}. Returns the positive subnode of the ADD *)

val delse : t -> t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_E}[Cudd_E]}. Returns the negative subnode of the ADD *)

val dval : t -> float
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_V}[Cudd_V]}. Returns the value of the assumed constant ADD *)

val cofactors : int -> t -> t*t
(** Returns the positive and negative cofactor of the ADD wrt the variable *)

val cofactor : t -> cube:[>Bdd.cube] Bdd.dt -> t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Cofactor}[Cudd_Cofactor]}. [cofactor add cube] evaluates [add] on the cube [cube] *)

val inspect: t -> add
(** Decomposes the top node of the ADD *)

(*  ====================================================== *)
(** {3 Supports} *)
(*  ====================================================== *)

val support : t -> Bdd.supp Bdd.dt
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Support}[Cudd_Support]}. Returns the support (positive cube) of the ADD *)

val supportsize : t -> int
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_SupportSize}[Cudd_SupportSize]}. Returns the size of the support of the ADD *)

val is_var_in : int -> t -> bool
(** [Cuddaux_IsVarIn]. Does the given variable belong to the support of the ADD ? *)

val vectorsupport : t array -> Bdd.supp Bdd.dt
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_VectorSupport}[Cudd_VectorSupport]}. Returns the support of the array of ADDs.

    Raises a [Failure] exception in case where the array is of size 0 (in such
    case, the manager is unknown, and we cannot return an empty support). *)

(*  ====================================================== *)
(** {3 Classical operations} *)
(*  ====================================================== *)

val cst : Man.dt -> float -> t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addConst}[Cudd_addConst]}. Return a constant ADD with the given value. *)

val background : Man.dt -> t

val ite : 'a Bdd.dt -> t -> t -> t
(** [Cuddaux_addIte]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addIte}[Cudd_addIte]}. If-then-else operation, with the condition being a BDD. *)

val ite_cst : 'a Bdd.dt -> t -> t -> float option
(** [Cuddaux_addIteConstant]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addIteConstant}[Cudd_addIteConstant]}. If-then-else operation, which succeeds only if the resulting node is the returned constant. *)

val eval_cst : care:'a Bdd.dt -> t -> float option
(** [Cuddaux_addEvalConst]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addEvalConst}[Cudd_addEvalConst]}. *)

val compose : var:int -> f:'a Bdd.dt -> t -> t
(** [Cuddaux_addCompose]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addCompose}[Cudd_addCompose]}. Substitutes the variable with the BDD in the ADD. *)

(** [Cuddaux_addVectorCompose]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addVectorCompose}[Cudd_addVectorCompose]}.
    Parallel substitution of every variable [var] present in the manager by the
    BDD [table.(var)] in the ADD. You can optionnally control the memoization
    policy, see {!Memo}. *)
val vectorcompose : ?memo:Memo.t -> 'a Bdd.dt array -> t -> t

(*  ====================================================== *)
(** {3 Variable mapping} *)
(*  ====================================================== *)

val varmap : t -> t
(** [Cuddaux_addVarMap]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddVarMap}[Cudd_bddVarMap]}. Permutes the variables as it has been specified with {!Man.set_varmap}. *)

val permute : ?memo:Memo.t -> perm:int array -> t -> t
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addPermute}[Cudd_addPermute]}.
   Permutes the variables as it is specified by [permut] (same format
   as in {!Man.set_varmap}). You can optionnally control the
   memoization policy, see {!Memo}. *)


(*  ====================================================== *)
(** {3 Logical tests} *)
(*  ====================================================== *)

val is_equal: t -> t -> bool
(** Equality test *)
val is_equal_when: t -> t -> care:'a Bdd.dt -> bool
(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_EquivDC}[Cudd_EquivDC]}. Are
    the two ADDs equal when the BDD (careset) is true ? *)

val is_eval_cst : care:'a Bdd.dt -> t -> bool
(** Variation of
    [Cuddaux_addEvalConst]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addEvalConst}[Cudd_addEvalConst]}. Is
    the ADD constant when the BDD (careset) is true, and in this case
    what is its value ? *)

val is_ite_cst : 'a Bdd.dt -> t -> t -> bool
(** Is the result of [ite] constant, and if it is the case, what
    is its value ? *)

(*  ====================================================== *)
(** {3 Structural information} *)
(*  ====================================================== *)

val size :  t -> int
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_DagSize}[Cudd_DagSize]}. Size
   if the ADD as a graph (the number of nodes). *)

val nbpaths : t -> float
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CountPath}[Cudd_CountPath]}. Number
   of paths in the ADD from the root to the leafs. *)

val nbnonzeropaths : t -> float
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CountPathsToNonZero}[Cudd_CountPathsToNonZero]}. Number
   of paths in the ADD from the root to non-zero leaves. *)

val nbminterms : nbvars:int -> t -> float
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CountMinterm}[Cudd_CountMinterm]}. Number
   of minterms of the ADD knowing that it depends on the given number
   of variables. *)

val density : nbvars:int -> t -> float
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Density}[Cudd_Density]}. Density
   of the ADD, which is the ratio of the number of minterms to the
   number of nodes. The ADD is assumed to depend on [nvars]
   variables. *)

val nbleaves : t -> int
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CountLeaves}[Cudd_CountLeaves]}. Number
   of leaves. *)

(*  ====================================================== *)
(** {3 Iterators} *)
(*  ====================================================== *)

val iter_cube: (Man.tbool array -> float -> unit) -> t -> unit
(** Similar to {!Bdd.iter_cube} *)

val iter_node: (t -> unit) -> t -> unit
(** Similar to {!Bdd.iter_node} *)

(*  ====================================================== *)
(** {3 Leaves and guards} *)
(*  ====================================================== *)

val guard_of_node : t -> node:t -> Bdd.any Bdd.dt
(** [Cuddaux_addGuardOfNode]. [guard_of_node f node] returns the
    sum of the paths leading from the root node [f] to the node [node]
    of [f]. *)

val guard_of_nonbackground : t -> Bdd.any Bdd.dt
(** Guard of non background leaves *)


val nodes_below_level: ?level:int -> ?max:int -> t -> t array
(** [Cuddaux_NodesBelowLevel]. [nodes_below_level f olevel max]
    returns all (if [max<=0]), otherwise at most [max] nodes pointed
    by the ADD, indexed by a variable of level greater or equal than
    [level], and encountered first in the top-down exploration (i.e.,
    whenever a node is collected, its sons are not collected). If
    [olevel=None], then only constant nodes are collected. The
    background node may be in the result. *)

val guard_of_leaf : t -> float -> Bdd.any Bdd.dt
(** Guard of the given leaf *)

val leaves: t -> float array
(** Returns the set of leaf values (excluding the background value) *)

val pick_leaf : t -> float
(** Picks (but not randomly) a non background leaf. Return [None]
    if the only leaf is the background leaf. *)

val guardleafs : t -> (Bdd.any Bdd.dt * float) array
(** Returns the set of leaf values together with their guard in
    the ADD *)


(*  ====================================================== *)
(** {3 Minimizations} *)
(*  ====================================================== *)

(** See {!Bdd.constrain}, {!Bdd.tdconstrain}, {!Bdd.restrict}, {!Bdd.tdrestrict} *)

val constrain : t -> care:Bdd.any Bdd.dt -> t
val tdconstrain : t -> care:Bdd.any Bdd.dt -> t
val restrict : t -> care:Bdd.any Bdd.dt -> t
val tdrestrict : t -> care:Bdd.any Bdd.dt -> t

(*  ====================================================== *)
(** {3 Conversions} *)
(*  ====================================================== *)

val of_bdd : [>Bdd.any] Bdd.dt -> t
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_BddToAdd}[Cudd_BddToAdd]}. Conversion
   from BDD to 0-1 ADD *)

val to_bdd : t -> Bdd.any Bdd.dt
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addBddPattern}[Cudd_addBddPattern]}. Conversion
   from ADD to BDD by replacing all leaves different from 0 by
   true. *)

val to_bdd_threshold : t -> threshold:float -> Bdd.any Bdd.dt
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addBddThreshold}[Cudd_addBddThreshold]}. Conversion
   from ADD to BDD by replacing all leaves greater than or equal to
   the threshold by true. *)

val to_bdd_strictthreshold : t -> threshold:float -> Bdd.any Bdd.dt
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addBddStrictThreshold}[Cudd_addBddStrictThreshold]}. Conversion
   from ADD to BDD by replacing all leaves strictly greater than the
   threshold by true.*)

val to_bdd_interval : t -> lower:float -> upper:float -> Bdd.any Bdd.dt
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addBddInterval}[Cudd_addBddInterval]}. Conversion
   from ADD to BDD by replacing all leaves in the interval by
   true. *)

(*  ====================================================== *)
(** {3 Quantifications} *)
(*  ====================================================== *)

val exist : supp:[>Bdd.supp] Bdd.dt -> t -> t
(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addExistAbstract}[Cudd_addExistAbstract]}. Abstracts
    all the variables in the cube from the ADD by summing over all
    possible values taken by those variables. *)

val forall : supp:[>Bdd.supp] Bdd.dt -> t -> t
(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addUnivAbstract}[Cudd_addUnivAbstract]}. Abstracts
    all the variables in the cube from the ADD by taking the product
    over all possible values taken by those variables. *)

(*  ====================================================== *)
(** {3 Algebraic operations} *)
(*  ====================================================== *)

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html# Cudd_addLeq}[ Cudd_addLeq]}. *)
val is_leq : t -> t -> bool

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addPlus}[Cudd_addPlus]}. *)
val add : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addMinus}[Cudd_addMinus]}. *)
val sub : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addTimes}[Cudd_addTimes]}. *)
val mul : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addDivide}[Cudd_addDivide]}. *)
val div : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addMinimum}[Cudd_addMinimum]}. *)
val min : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addMaximum}[Cudd_addMaximum]}. *)
val max : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addAgreement}[Cudd_addAgreement]}. *)
val agreement : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addDiff}[Cudd_addDiff]}. *)
val diff : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addThreshold}[Cudd_addThreshold]}. *)
val threshold : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addSetNZ}[Cudd_addSetNZ]}. *)
val setNZ : t -> t -> t

(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addLog}[Cudd_addLog]}. *)
val log : t -> t

(*  ====================================================== *)
(** {3 Matrix operations} *)
(*  ====================================================== *)

(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addMatrixMultiply}[Cudd_addMatrixMultiply]}.

    [matrix_multiply z A B] performs matrix multiplication of [A] and [B], with [z]
    being the summation variables, which means that they are used to refer columns
    of [A] and to rows of [B]. *)
val matrix_multiply : int array -> t -> t -> t

(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addTimesPlus}[Cudd_addTimesPlus]}. *)
val times_plus : int array -> t -> t -> t

(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_addTriangle}[Cudd_addTriangle]}. *)
val triangle : int array -> t -> t -> t

(*  ====================================================== *)
(** {3 User operations} *)
(*  ====================================================== *)

(* ====================================================== *)
(** {4 By decomposition into guards and leaves} *)
(* ====================================================== *)

val mapleaf1 : default:t -> (Bdd.any Bdd.dt -> float -> float) -> t -> t
val mapleaf2 : default:t -> (Bdd.any Bdd.dt -> float -> float -> float) -> t -> t -> t

(* ====================================================== *)
(** {4 By using CUDD cache} *)
(* ====================================================== *)

(** Consult {!User} for explanations. *)

open Custom


(** {5 Type of operations} *)

type op1 = (float, float) Custom.op1
type op2 = (Man.d,float, float, float) Custom.op2
type op3 = (Man.d,float, float, float, float) Custom.op3
type opN = (Man.d,float, float) Custom.opN
type opG = (Man.d,float, float) Custom.opG
type test2 = (Man.d,float, float) Custom.test2
type exist = (Man.d,float) Custom.exist
type existand = (Man.d,float) Custom.existand
type existop1 = (Man.d,float,float) Custom.existop1
type existandop1 = (Man.d,float,float) Custom.existandop1

(** {5 Making operations} *)
val make_op1 : ?memo:Memo.t -> (float -> float) -> op1
val make_op2 :
  ?memo:Memo.t ->
  ?commutative:bool -> ?idempotent:bool ->
  ?special:(t -> t -> t option) ->
  (float -> float -> float) -> op2
val make_op3 :
  ?memo:Memo.t ->
  ?special:(t -> t -> t -> t option) ->
  (float -> float -> float -> float) -> op3
val make_opN :
  ?memo:Memo.t ->
  arityB:int -> arityV:int ->
  (Bdd.any Bdd.dt array -> t array -> t option) ->
  opN
val make_opG :
  ?memo:Memo.t ->
  ?beforeRec:(int*bool -> Bdd.any Bdd.dt array -> t array -> (Bdd.any Bdd.dt array * t array)) ->
  ?ite:(int -> t -> t -> t) ->
  arityB:int -> arityV:int ->
  (Bdd.any Bdd.dt array -> t array -> t option) ->
  opG
val make_test2 :
  ?memo:Memo.t ->
  ?symetric:bool -> ?reflexive:bool ->
  ?special:(t -> t -> bool option) ->
  (float -> float -> bool) -> test2
val make_exist : ?memo:Memo.t -> op2 -> exist
val make_existand : ?memo:Memo.t -> bottom:float -> op2 -> existand
val make_existop1 : ?memo:Memo.t -> op1:op1 -> op2 -> existop1
val make_existandop1 :
  ?memo:Memo.t -> op1:op1 -> bottom:float -> op2 -> existandop1

(** {5 Clearing memoization tables} *)

val clear_op1 : op1 -> unit
val clear_op2 : op2 -> unit
val clear_op3 : op3 -> unit
val clear_opN : opN -> unit
val clear_opG : opG -> unit
val clear_test2 : test2 -> unit
val clear_exist : exist -> unit
val clear_existand : existand -> unit
val clear_existop1 : existop1 -> unit
val clear_existandop1 : existandop1 -> unit

(** {5 Applying operations} *)

val apply_op1 : op1 -> t -> t
val apply_op2 : op2 -> t -> t -> t
val apply_op3 : op3 -> t -> t -> t -> t
val apply_opN : opN -> Bdd.any Bdd.dt array -> t array -> t
val apply_opG : opG -> Bdd.any Bdd.dt array -> t array -> t
val apply_test2 : test2 -> t -> t -> bool
val apply_exist : exist -> supp:[>Bdd.supp] Bdd.dt -> t -> t
val apply_existand : existand -> supp:[>Bdd.supp] Bdd.dt -> guard:[>Bdd.any] Bdd.dt -> t -> t
val apply_existop1 : existop1 -> supp:[>Bdd.supp] Bdd.dt -> t -> t
val apply_existandop1 : existandop1 -> supp:[>Bdd.supp] Bdd.dt -> guard:[>Bdd.any] Bdd.dt -> t -> t

(** {5 Map functions} *)

val map_op1 : ?memo:Memo.t -> (float -> float) -> t -> t
val map_op2 :
  ?memo:Memo.t ->
  ?commutative:bool -> ?idempotent:bool ->
  ?special:(t -> t -> t option) ->
  (float -> float -> float) -> t -> t -> t
val map_op3 :
  ?memo:Memo.t ->
  ?special:(t -> t -> t -> t option) ->
  (float -> float -> float -> float) -> t -> t -> t -> t
val map_opN :
  ?memo:Memo.t ->
  (Bdd.any Bdd.dt array -> t array -> t option) ->
  Bdd.any Bdd.dt array -> t array -> t
val map_test2 :
  ?memo:Memo.t ->
  ?symetric:bool -> ?reflexive:bool ->
  ?special:(t -> t -> bool option) ->
  (float -> float -> bool) -> t -> t -> bool

(*  ====================================================== *)
(** {3 Miscellaneous} *)
(*  ====================================================== *)

(** [Cuddaux_addTransfer]/{{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddTransfer}[Cudd_bddTransfer]}. Transfers a ADD to a different manager. *)
val transfer : t -> man:Man.dt -> t

(*  ====================================================== *)
(** {3 Printing} *)
(*  ====================================================== *)


(** C printing function. The output may mix badly with the OCaml output. *)
val _print: t -> unit


(** Prints the minterms of the BDD in the same way as {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Printminterm}[Cudd_Printminterm]}. *)
val print__minterm: Format.formatter -> t -> unit

(** [print_minterm print_id print_leaf fmt bdd] prints the minterms of the BDD using [print_id] to print indices of variables and [print_leaf] to print leaf values. *)
val print_minterm:
  (Format.formatter -> int -> unit) ->
  (Format.formatter -> float -> unit) ->
  Format.formatter -> t -> unit

(** Prints a BDD by recursively decomposing it as monomial followed by a tree. *)
val print:
  (Format.formatter -> int -> unit) ->
  (Format.formatter -> float -> unit) ->
  Format.formatter -> t -> unit
