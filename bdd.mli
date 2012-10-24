(** Binary Decision Diagrams *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

type ('a,+'b) t = ('a,'b) Dd.bdd
  (** Abstract type for BDDs.

      Objects of type [('a,'b) t] contain both the top node of the
      BDD and the manager to which this node belongs. The manager
      can be retrieved with {!manager}. These objects are
      automatically garbage collected.

      ['a], which is either {!Man.d} or {!Man.v}, is a phantom type parameter
      that indicates the kind of manager to which the node
      belongs, see module {!Man}.

      ['b], which is constrained to be equal to [[>`any]] is a
      phantom type parameter that indicates specific properties of
      the BDD. The other tags are
      - [[`cube]: indicates a conjunction of literals or a constant
      - [[`pos]]: indicates that all literals are in positive form
      - [[`lit]]: indicates a literal or a constant
  *)

type any  = [`atom | `lit | `conj | `any]
(** Any Boolean formula *)
type cube = [`atom | `lit | `conj]
(** Conjunction of literals or constant *)
type lit  = [`atom | `lit        ]
(** Single literal or constant *)
type supp = [`atom        | `conj]
(** Conjunction of atoms (positive literals) or constant *)
type atom = [`atom               ]
(** Single atom or constant *)

type 'a dt       = (Man.d,'a) t
type 'a vt       = (Man.v,'a) t
(** Shortcuts *)

(** Public type for exploring the abstract type [t] *)
type ('a,'b) bdd =
  | Bool of bool             (** Terminal value *)
  | Ite of int * ('a,'b) t * ('a,'b) t (** Decision on CUDD variable *)

(*  ====================================================== *)
(** {3 Extractors} *)
(*  ====================================================== *)

val manager : ('a,'b) t -> 'a Man.t
(** Returns the manager associated to the BDD *)

val is_cst : ('a,'b) t -> bool
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_IsConstant}[Cudd_IsConstant]}.
    Is the BDD constant ? *)

val is_complement : ('a,'b) t -> bool
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_IsComplement}[Cudd_IsComplement]}. Is
   the BDD a complemented one ? *)

val topvar : ('a,'b) t -> int
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_NodeReadIndex}[Cudd_NodeReadIndex]}. Returns
   the index of the (top node of the) BDD, raises [Invalid_argument]
   if given a constant BDD *)

val dthen : ('a,'b) t -> ('a,'b) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_T}[Cudd_T]}. Returns
   the positive subnode of the BDD, raises [Invalid_argument] if
   given a constant BDD *)

val delse : ('a,'b) t -> ('a,'b) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_E}[Cudd_E]}. Returns
   the negative subnode of the BDD, raises [Invalid_argument] if
   given a constant BDD *)

val cofactors : int -> ('a,'b) t -> ('a,'b) t * ('a,'b) t
(** Returns the positive and negative cofactor of the BDD wrt the
    variable *)

val cofactor : ('a,'b) t -> cube:('a,[<cube]) t -> ('a,'b) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Cofactor}[Cudd_Cofactor]}. [cofactor
   bdd ~cube] evaluates [bdd] on the cube [cube] *)

val inspect: ('a,'b) t -> ('a,'b) bdd
(** Decomposes the top node of the BDD *)

(*  ====================================================== *)
(** {3  Supports} *)
(*  ====================================================== *)

val support : ('a,'b) t -> ('a,[>supp]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Support}[Cudd_Support]}. Returns
   the support of the BDD *)

val supportsize : ('a,'b) t -> int
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_SupportSize}[Cudd_SupportSize]}. Returns
   the size of the support of the BDD *)

val is_var_in : int -> ('a,'b) t -> bool
(** [Cuddaux_IsVarIn]. Does the given variable belong the support
    of the BDD ? *)

val vectorsupport : ('a,'b) t array -> ('a,[>supp]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Cudd_VectorSupport}[Cudd_Cudd_VectorSupport]}. Returns
   the support of the array of BDDs.

   Raises a [Failure] exception in case where the array is of size
   0 (in such case, the manager is unknown, and we cannot return
   an empty support).  This operation does not use the global
   cache, unlike {!support}.  *)

(*  ====================================================== *)
(** {3  Manipulation of supports} *)
(*  ====================================================== *)

val support_inter : ('a,[<supp]) t -> ('a,[<supp]) t -> ('a,[>supp]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddLiteralSetIntersection}[Cudd_bddLiteralSetIntersection]}. Intersection
   of supports *)

val support_union: ('a,[<supp]) t -> ('a,[<supp]) t -> ('a,[>supp]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddAnd}[Cudd_bddAnd]}. Union
   of supports *)

val support_diff: ('a,[<supp]) t -> ('a,[<supp]) t -> ('a,[>supp]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Cofactor}[Cudd_Cofactor]}. Difference
   of supports *)

val list_of_support: ('a,[<supp]) t -> int list
(** Converts a support into a list of variables *)

(*  ====================================================== *)
(** {3  Constants and Variables} *)
(*  ====================================================== *)

val dtrue : 'a Man.t -> ('a,[>atom]) t
(** Returns the true BDD *)

val dfalse : 'a Man.t -> ('a,[>atom]) t
(** Returns the false BDD *)

val ithvar : 'a Man.t -> int -> ('a,[>atom]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddIthVar}[Cudd_bddIthVar]}. Returns
   the BDD equivalent to the variable of the given index. *)

val newvar : 'a Man.t -> ('a,[>atom]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddNewVar}[Cudd_bddNewVar]}. Returns
   the BDD equivalent to the variable of the next unused index. *)

val newvar_at_level : 'a Man.t -> int -> ('a,[>atom]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddNewVarAtLevel}[Cudd_bddNewVarAtLevel]}. Returns
   the BDD equivalent to the variable of the next unused index and
   sets its level. *)

(*  ====================================================== *)
(** {3  Logical tests} *)
(*  ====================================================== *)

val is_true : ('a,'b) t -> bool
(** Is it a true BDD ? *)

val is_false : ('a,'b) t -> bool
(** Is it a false BDD ? *)

val is_equal : ('a,'b) t -> ('a,'c) t -> bool
(** Are the two BDDs equal ? *)

val is_leq : ('a,'b) t -> ('a,'c) t -> bool
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddLeq}[Cudd_bddLeq]}. Does
   the first BDD implies the second one ? *)

val is_included_in : ('a,'b) t -> ('a,'c) t -> bool
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddLeq}[Cudd_bddLeq]}. Same
   as {!is_leq} *)

val is_inter_empty : ('a,'b) t -> ('a,'c) t -> bool
(** Is the intersection (conjunction) of the two BDDs non empty
    (false) ? *)

val is_equal_when : ('a,'b) t -> ('a,'c) t -> care:('a,'d) t -> bool
(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_EquivDC}[Cudd_EquivDC]}. Are
    the two first BDDs equal when the third one (careset) is true ? *)

val is_leq_when : ('a,'b) t -> ('a,'c) t -> care:('a,'d) t -> bool
(** Variation of
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddLeqUnless}[Cudd_bddLeqUnless]}. Does
    the first BDD implies the second one when the third one (careset)
    is true ? *)

val is_ite_cst : ('a,'b) t -> ('a,'c) t -> ('a,'d) t -> bool
(** Is the result of [ite] constant, and if it is the case, what
    is the constant ? *)

val is_var_dependent : int -> ('a,'b) t -> bool
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddVarIsDependent}[Cudd_bddVarIsDependent]}. Is
   the given variable dependent on others in the BDD ? *)

val is_var_essential : int*bool -> ('a,'b) t -> bool
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddIsVarEssential}[Cudd_bddIsVarEssential]}. Is
   the given variable with the specified phase implied by the BDD
   ? *)

(*  ====================================================== *)
(** {3  Structural information} *)
(*  ====================================================== *)

val size : ('a,'b) t -> int
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_DagSize}[Cudd_DagSize]}. Size
   if the BDD as a graph (the number of nodes). *)

val nbpaths : ('a,'b) t -> float
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CountPath}[Cudd_CountPath]}. Number
   of paths in the BDD from the root to the leaves. *)

val nbtruepaths : ('a,'b) t -> float
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CountPathsToNonZero}[Cudd_CountPathsToNonZero]}. Number
   of paths in the BDD from the root to the true leaf. *)

val nbminterms : nbvars:int -> ('a,'b) t -> float
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CountMinterm}[Cudd_CountMinterm]}. Number
   of minterms of the BDD assuming that it depends on [nbvars]
   of variables. *)

val density : nbvars:int -> ('a,'b) t -> float
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Density}[Cudd_Density]}. Density
   of the BDD, which is the ratio of the number of minterms to the
   number of nodes. The BDD is assumed to depend on [nbvars]
   variables. *)

(*  ====================================================== *)
(** {3  Logical operations} *)
(*  ====================================================== *)

val dnot : ('a,'b) t -> ('a,any) t
val vnot : ('a,[<lit]) t -> ('a,lit) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Not}[Cudd_Not]}. Negation *)

val dand : ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddAnd}[Cudd_bddAnd]}. Conjunction/Intersection *)

val dor : ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddOr}[Cudd_bddOr]}. Disjunction/Union *)

val xor : ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddXor}[Cudd_bddXor]}. Exclusive
   union *)

val nand : ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddNand}[Cudd_bddNand]}. *)

val nor : ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddNor}[Cudd_bddNor]}. *)

val nxor : ('a,'b) t -> ('a,'c) t -> ('a,any) t
val eq : ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddXnor}[Cudd_bddXnor]}. Equality *)

val ite : ('a,'b) t -> ('a,'c) t -> ('a,'d) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddIte}[Cudd_bddIte]}.
    If-then-else operation. *)

val ite_cst : ('a,'b) t -> ('a,'c) t -> ('a,'d) t -> bool option
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddIteConstant}[Cudd_bddIteConstant]}.
    If-then-else operation that succeeds when the result is a node
    of the arguments. *)

val compose : var:int -> f:('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddCompose}[Cudd_bddCompose]}.
    [compose ~var ~f bdd] substitutes the variable [var] with the function [f] in [bdd]. *)

val vectorcompose : ?memo:Memo.t -> ('a,'b) t array -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddVectorCompose}[Cudd_bddVectorCompose]}.
   [vectorcompose table bdd] performs a parallel substitution of
   every variable [var] present in the manager by [table.(var)]
   in [bdd]. The size of [table] should be at least
   {!Man.get_bddvar_nb}. You can optionnally control the
   memoization policy, see {!Memo}. *)

val intersect : ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddIntersect}[Cudd_bddIntersect]}. Returns
   a BDD included in the intersection of the arguments. *)

val booleandiff : ('a,'b) t -> int -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddBooleanDiff}[Cudd_bddBooleanDiff]}. Boolean
   difference of the BDD with respect to the variable. *)

(*  ====================================================== *)
(** {3  Variable mapping} *)
(*  ====================================================== *)

val varmap : ('a,'b) t -> ('a,'b) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddVarMap}[Cudd_bddVarMap]}. Permutes
   the variables as it has been specified with {!Man.set_varmap}. *)

val permute : ?memo:Memo.t -> perm:int array -> ('a,'b) t -> ('a,'b) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddPermute}[Cudd_bddPermute]}.
   Permutes the variables as it is specified by [~permut] (same
   format as in {!Man.set_varmap}). You can optionnally control
   the memoization policy, see {!Memo}. *)

(*  ====================================================== *)
(** {3  Iterators} *)
(*  ====================================================== *)

val iter_node: (('a,any) t -> unit) -> ('a,'b) t -> unit
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ForeachNode}[Cudd_ForeachNode]}. Apply
   the function [f] to each (regularized) node of the BDD. *)

val iter_cube: (Man.tbool array -> unit) -> ('a,'b) t -> unit
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ForeachCube}[Cudd_ForeachCube]}. Apply
   the function [f] to each cube of the BDD. The cubes are
   specified as arrays of elements of type {!Man.tbool}. The size
   of the arrays is equal to {!Man.get_bddvar_nb}, the number of
   variables present in the manager. *)

val iter_prime: (Man.tbool array -> unit) -> lower:('a,'b) t -> upper:('a,'c) t -> unit
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_ForeachPrime}[Cudd_ForeachPrime]}. Apply
   the function [f] to each prime covering the BDD interval. The
   first BDD argument is the lower bound, the second the upper
   bound (which may be equal to the lower bound).  The primes are
   specified as arrays of elements of type {!Man.tbool}. The size
   of the arrays is equal to {!Man.get_bddvar_nb}, the number of
   variables present in the manager. *)

(*  ====================================================== *)
(** {3  Quantifications} *)
(*  ====================================================== *)

val exist : supp:('a,[<supp]) t -> ('a,'c) t -> ('a,'c) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddExistAbstract}[Cudd_bddExistAbstract]}. [exist
   supp bdd] quantifies existentially the set of variables defined by
   [supp] in the BDD. *)

val forall : supp:('a,[<supp]) t -> ('a,'c) t -> ('a,'c) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddUnivAbstract}[Cudd_bddUnivAbstract]}. [forall
   supp bdd] quantifies universally the set of variables defined by
   [supp] in the BDD. *)

val existand : supp:('a,[<supp]) t -> ('a,'c) t -> ('a,'d) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddAndAbstract}[Cudd_bddAndAbstract]}. Simultaneous
   existential quantification and intersection of BDDs. Logically,
   [existand ~supp x y = exist supp (dand x y)]. *)

val existxor : supp:('a,[<supp]) t -> ('a,'c) t -> ('a,'d) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddXorExistAbstract}[Cudd_bddXorExistAbstract]}. Simultaneous
   existential quantification and exclusive or of BDDs. Logically,
   [existxor ~supp x y = exist supp (xor x y)]. *)

(*  ====================================================== *)
(** {3  Cubes} *)
(*  ====================================================== *)

val cube_of_bdd: ('a,'b) t -> ('a,[>cube]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_FindEssential}[Cudd_FindEssential]}. Returns
   the smallest cube (in the sens of inclusion) included in the
   BDD. *)

val cube_of_minterm: 'a Man.t -> Man.tbool array -> ('a,[>cube]) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_CubeArrayToBdd}[Cudd_CubeArrayToBdd]}. Converts
   a minterm to a BDD (which is a cube). *)

val list_of_cube: ('a,[<cube]) t -> (int*bool) list
(** Converts a cube into a list of pairs of a variable and a
    phase. *)

val cube_and : ('a,[<cube]) t -> ('a,[<cube]) t -> ('a,[>cube]) t
val cube_or : ('a,[<cube]) t -> ('a,[<cube]) t -> ('a,[>cube]) t
val cube_union : ('a,[<cube]) t -> ('a,[<cube]) t -> ('a,[>cube]) t
(** [Cuddaux_bddCubeUnion]. Computes the union of cubes, which is
    the smallest cube containing both the argument cubes. *)

val pick_minterm : ('a,'b) t -> Man.tbool array
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddPickOneCube}[Cudd_bddPickOneCube]}. Picks
   randomly a minterm in the BDD. *)

val pick_cube_on_support : supp:('a,[<supp]) t -> ('a,'c) t -> ('a,[>cube]) t
(**
   {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddPickOneMinterm}[Cudd_bddPickOneMinterm]}. [pick_cube_on_support
   ~supp bdd] picks randomly a minterm/cube in the BDD, in which
   all the variables in the support [supp] have a definite value.

   The support argument should contain the support of the BDD
   (otherwise the result may be incorrect). *)

val pick_cubes_on_support : supp:('a,[<supp]) t -> nb:int -> ('a,'c) t -> ('a,[>cube]) t array
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddPickArbitraryMinterms}[Cudd_bddPickArbitraryMinterms]}. [pick_cubes_on_support
   ~supp ~nb bdd] picks randomly [nb] minterms/cubes in the BDD, in
   which all the variables in the support have a definite value. The
   support argument should contain the support of the BDD (otherwise
   the result may be incorrect).

   Fails if the effective number of such minterms in the BDD is
   less than [nb]. *)

(*  ====================================================== *)
(** {3  Minimizations} *)
(*  ====================================================== *)

(** The 6 following functions are generalized cofactor
    operations. [gencof f c] returns a BDD that coincides with [f]
    whenever [c] is true (and which is hopefully smaller). [constrain]
    enjoys in addition strong properties (see papers from Madre and
    Coudert) *)

val constrain : ('a, 'b) t -> care:('a, 'c) t -> ('a, any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddConstrain}[Cudd_bddConstrain]}. *)

val tdconstrain : ('a, 'b) t -> care:('a, 'c) t -> ('a, any) t
(** [Cuddaux_bddTDConstrain]. *)

val restrict : ('a, 'b) t -> care:('a, 'c) t -> ('a, any) t
(** [Cuddaux_bddRestrict]. *)

val tdrestrict : ('a, 'b) t -> care:('a, 'c) t -> ('a, any) t
(** [Cuddaux_bddTDRestrict]. *)

val minimize : ('a, 'b) t -> care:('a, 'c) t -> ('a, any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddMinimize}[Cudd_bddMinimize]}. *)

val licompaction : ('a, 'b) t -> care:('a, 'c) t -> ('a, any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddLICompaction}[Cudd_bddLICompaction]}. *)

val squeeze : lower:('a,'b) t -> upper:('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddSqueeze}[Cudd_bddSqueeze]}.
    [sqeeze lower upper] returns a (smaller) BDD which is in the
    functional interval [[lower,upper]]. *)

(*  ====================================================== *)
(** {3  Approximations} *)
(*  ====================================================== *)

type approx = Under | Over

val clippingand : depth:int -> approx:approx -> ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddClippingAnd}[Cudd_bddClippingAnd]}. *)

val clippingexistand : depth:int -> approx:approx -> supp:('a,[<supp]) t -> ('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddClippingAndAbstract}[Cudd_bddClippingAndAbstract]}. *)

val underapprox : nbvars:int -> threshold:int -> safe:bool -> quality:float -> ('a,'b) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_UnderApprox}[Cudd_UnderApprox]}. *)

val remapunderapprox : nbvars:int -> threshold:int -> quality:float -> ('a,'b) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_RemapUnderApprox}[Cudd_RemapUnderApprox]}.
    [remapunderapprox nvars threshold quality f] *)

val biasedunderapprox : nbvars:int -> threshold:int -> quality_true:float -> quality_false:float -> bias:('a,'b) t -> ('a,'c) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_BiasedUnderApprox}[Cudd_BiasedUnderApprox]}. *)

val overapprox : nbvars:int -> threshold:int -> safe:bool -> quality:float -> ('a,'b) t -> ('a,any) t
val remapoverapprox : nbvars:int -> threshold:int -> quality:float -> ('a,'b) t -> ('a,any) t
val biasedoverapprox : nbvars:int -> threshold:int -> quality_true:float -> quality_false:float -> bias:('a,'b) t -> ('a,'c) t -> ('a,any) t

(** For the 4 next functions, the profile is [XXcompress nvars threshold f]. *)

val subsetcompress : nbvars:int -> threshold:int -> ('a,'b) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_SubsetCompress}[Cudd_SubsetCompress]}. *)

val subsetHB : nbvars:int -> threshold:int -> ('a,'b) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_SubsetHeavyBranch}[Cudd_SubsetHeavyBranch]}. *)

val subsetSP : nbvars:int -> threshold:int -> hardlimit:bool -> ('a,'b) t -> ('a,any) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_SubsetShortPaths}[Cudd_SubsetShortPaths]}. *)

val supersetcompress : nbvars:int -> threshold:int -> ('a,'b) t -> ('a,any) t
val supersetHB : nbvars:int -> threshold:int -> ('a,'b) t -> ('a,any) t
val supersetSP : nbvars:int -> threshold:int -> hardlimit:bool -> ('a,'b) t -> ('a,any) t

(** The following functions perform two-way conjunctive (disjunctive)
    decomposition of a BDD. Returns a pair if successful, [None] if no
    decomposition has been found. *)

val approxconjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option
(** [Cudd_bddApproxConjDecomp]. *)
val iterconjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option
(** [Cudd_bddIterConjDecomp]. *)
val genconjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option
(** [Cudd_bddGenConjDecomp]. *)
val varconjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option
(** [Cudd_bddVarConjDecomp]. *)

val approxdisjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option
val iterdisjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option
val gendisjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option
val vardisjdecomp: ('a,'b) t -> (('a,any) t * ('a,any) t) option

(*  ====================================================== *)
(** {3  Miscellaneous} *)
(*  ====================================================== *)

val transfer : ('a,'c) t -> man:'b Man.t -> ('b,'c) t
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddTransfer}[Cudd_bddTransfer]}. Transfers
   a BDD to a different manager. *)

val correlation : ('a,'b) t -> ('a,'c) t -> float
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddCorrelation}[Cudd_bddCorrelation]}. Computes
   the correlation of f and g (if [f=g], their correlation is 1,
   if [f=not g], it is 0) *)

val correlationweights : ('a,'b) t -> ('a,'c) t -> weights:float array -> float
(** {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_bddCorrelationWeights}[Cudd_bddCorrelationWeights]}. *)

(*  ====================================================== *)
(** {3  Printing} *)
(*  ====================================================== *)

val _print: ('a,'b) t -> unit
(** Raw (C) printing function.  The output may mix badly with the
    OCAML output. *)

val print__minterm: Format.formatter -> ('a,[<any]) t -> unit
(** Prints the minterms of the BDD in the same way as
    {{:http://vlsi.colorado.edu/~fabio/CUDD/cuddExtDet.html#Cudd_Printminterm}[Cudd_Printminterm]}. *)

val print_minterm: (Format.formatter -> int -> unit) -> Format.formatter -> ('a,[<any]) t -> unit
(** [print_minterm bassoc fmt bdd] prints the minterms of the BDD
    using [bassoc] to convert indices of variables to names. *)

val print: (Format.formatter -> int -> unit) -> Format.formatter -> ('a,[<any]) t -> unit
(** Prints a BDD by recursively decomposing it as monomial
    followed by a tree. *)

val print_list: (Format.formatter -> int -> unit) -> Format.formatter -> (int *bool) list -> unit
