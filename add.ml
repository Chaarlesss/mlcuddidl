(* File generated from add.idl *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

(** MTBDDs with floats (CUDD ADDs) *)

type t = Dd.add
  (** Abstract type for ADDs (that are necessarily attached to a manager of type [Man.d Man.t]).

    Objects of this type contains both the top node of the ADD and the manager to which the node belongs. The manager can be retrieved with {!manager}. Objects of this type are automatically garbage collected. *)


(** Public type for exploring the abstract type [t] *)
type add = Dd.A.inspect =
| Leaf of float      (** Terminal value *)
| Ite of int * t * t (** Decision on CUDD variable *)

(*  ====================================================== *)
(** {3 Extractors} *)
(*  ====================================================== *)

let manager = Dd.manager
let is_cst = Dd.is_cst
let topvar = Dd.topvar
let dthen = Dd.AV.dthen
let delse = Dd.AV.delse
let cofactors = Dd.AV.cofactors
let cofactor = Dd.AV.cofactor
let dval = Dd.AV.dval
let inspect = Dd.A.inspect

(* ====================================================== *)
(** {3 Supports} *)
(* ====================================================== *)

let support = Dd.support
let supportsize = Dd.supportsize
let is_var_in = Dd.is_var_in
let vectorsupport = Dd.vectorsupport

(* ====================================================== *)
(** {3 Classical operations} *)
(* ====================================================== *)

let cst = Dd.AV.cst

let background man = cst man (Man.get_background man)
let ite = Dd.AV.ite
let ite_cst = Dd.AV.ite_cst
let eval_cst = Dd.AV.eval_cst
let compose = Dd.AV.compose
let vectorcompose = Dd.AV.vectorcompose

(* ====================================================== *)
(** {3 Logical tests} *)
(* ====================================================== *)

let is_equal = Dd.is_equal
let is_equal_when = Dd.is_equal_when
let is_eval_cst = Dd.AV.is_eval_cst
let is_ite_cst = Dd.AV.is_ite_cst

(* ====================================================== *)
(** {3 Structural information} *)
(* ====================================================== *)

let size = Dd.size
let nbpaths = Dd.nbpaths
let nbnonzeropaths = Dd.A.nbnonzeropaths
let nbminterms = Dd.nbminterms
let density = Dd.density
let nbleaves = Dd.nbleaves

(*  ====================================================== *)
(** {3 Variable mapping} *)
(*  ====================================================== *)

let varmap = Dd.AV.varmap
let permute = Dd.AV.permute

(* ====================================================== *)
(** {3 Iterators} *)
(* ====================================================== *)

let iter_cube = Dd.AV.iter_cube
let iter_node = Dd.AV.iter_node

(* ====================================================== *)
(** {3 Leaves and guards} *)
(* ====================================================== *)

let guard_of_node = Dd.AV.guard_of_node
let guard_of_nonbackground = Dd.AV.guard_of_nonbackground
let nodes_below_level = Dd.AV.nodes_below_level
let guard_of_leaf = Dd.AV.guard_of_leaf
let leaves = Dd.AV.leaves
let pick_leaf = Dd.AV.pick_leaf
let guardleafs = Dd.AV.guardleafs

(* ====================================================== *)
(** {3 Minimizations} *)
(* ====================================================== *)

let constrain = Dd.AV.constrain
let tdconstrain = Dd.AV.tdconstrain
let restrict = Dd.AV.restrict
let tdrestrict = Dd.AV.tdrestrict

(*  ====================================================== *)
(** {3 Conversions} *)
(*  ====================================================== *)

let of_bdd = Dd.A.of_bdd
let to_bdd = Dd.A.to_bdd
let to_bdd_threshold = Dd.A.to_bdd_threshold
let to_bdd_strictthreshold = Dd.A.to_bdd_strictthreshold
let to_bdd_interval = Dd.A.to_bdd_interval

(*  ====================================================== *)
(** {3 Quantifications} *)
(*  ====================================================== *)

let exist = Dd.A.exist
let forall = Dd.A.forall

(*  ====================================================== *)
(** {3 Algebraic operations} *)
(*  ====================================================== *)

let is_leq = Dd.A.is_leq
let add = Dd.A.add
let sub = Dd.A.sub
let mul = Dd.A.mul
let div = Dd.A.div
let min = Dd.A.min
let max = Dd.A.max
let agreement = Dd.A.agreement
let diff = Dd.A.diff
let threshold = Dd.A.threshold
let setNZ = Dd.A.setNZ
let log = Dd.A.log

(*  ====================================================== *)
(** {3 Matrix operations} *)
(*  ====================================================== *)

let matrix_multiply = Dd.A.matrix_multiply
let times_plus = Dd.A.times_plus
let triangle = Dd.A.triangle

(*  ====================================================== *)
(** {3 User operations} *)
(*  ====================================================== *)
(* ====================================================== *)
(** {4 By decomposition into guards and leaves} *)
(* ====================================================== *)

let mapleaf1 : default:t -> ('a Bdd.dt -> float -> float) -> t -> t =
  fun ~default f add ->
  let manager = manager add in
  let leaves = leaves add in
  let res = ref default in
  for i=0 to pred (Array.length leaves) do
    let leaf = leaves.(i) in
    let guard = guard_of_leaf add leaves.(i) in
    let nleaf = f guard leaf in
    res := ite guard (cst manager nleaf) !res
  done;
  !res

let mapleaf2 : default:t -> ('a Bdd.dt -> float -> float -> float) -> t -> t -> t =
  fun ~default f add1 add2 ->
  let manager = manager add1 in
  let leaves1 = leaves add1 in
  let res = ref default in
  for i1=0 to pred (Array.length leaves1) do
    let leaf1 = leaves1.(i1) in
    let guard1 = guard_of_leaf add1 leaf1 in
    let add2 = ite guard1 add2 default in
    let leaves2 = leaves add2 in
    for i2=0 to pred (Array.length leaves2) do
      let leaf2 = leaves2.(i2) in
      let guard2 = guard_of_leaf add2 leaf2 in
      let nleaf = f guard2 leaf1 leaf2 in
      res := ite guard2 (cst manager nleaf) !res
    done
  done;
  !res

(* ====================================================== *)
(** {4 By using CUDD cache} *)
(* ====================================================== *)

(** Consult {!User} for explanations. *)

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

let make_op1 = Custom.make_op1
let make_op2 = Custom.make_op2
let make_op3 = Custom.make_op3
let make_opN = Custom.make_opN
let make_opG = Custom.make_opG
let make_test2 = Custom.make_test2
let make_exist = Custom.make_exist
let make_existand = Custom.make_existand
let make_existop1 = Custom.make_existop1
let make_existandop1 = Custom.make_existandop1

let apply_op1 = Custom.apply_op1
let apply_op2 = Custom.apply_op2
let apply_op3 = Custom.apply_op3
let apply_opN = Custom.apply_opN
let apply_opG = Custom.apply_opG
let apply_test2 = Custom.apply_test2
let apply_exist = Custom.apply_exist
let apply_existand = Custom.apply_existand
let apply_existop1 = Custom.apply_existop1
let apply_existandop1 = Custom.apply_existandop1

let clear_op1 = Custom.clear_op1
let clear_op2 = Custom.clear_op2
let clear_op3 = Custom.clear_op3
let clear_opN = Custom.clear_opN
let clear_opG = Custom.clear_opG
let clear_test2 = Custom.clear_test2
let clear_exist = Custom.clear_exist
let clear_existand = Custom.clear_existand
let clear_existop1 = Custom.clear_existop1
let clear_existandop1 = Custom.clear_existandop1

let map_op1 = Custom.map_op1
let map_op2 = Custom.map_op2
let map_op3 = Custom.map_op3
let map_opN = Custom.map_opN
let map_test2 = Custom.map_test2

(*  ====================================================== *)
(** {3 Miscellaneous} *)
(*  ====================================================== *)

let transfer = Dd.AV.transfer

(*  ====================================================== *)
(** {3 Printing} *)
(*  ====================================================== *)

(** C printing function. The output may mix badly with the OCaml output. *)
external _print: t -> unit = "cudd_caml_abdd_print"


open Format

let print__minterm fmt dd =
  if is_cst dd then pp_print_float fmt (dval dd)
  else
    let nb = nbpaths dd in
    if nb > (float_of_int !Man.print_limit) then
      fprintf fmt "dd with %i nodes, %i leaves and %g paths" (size dd) (nbleaves dd) nb
  else begin
    fprintf fmt "@[<v>";
    let first = ref true in
    iter_cube
      (begin fun cube leaf ->
	if not !first then fprintf fmt "@ " else first := false;
	let str = String.create (Array.length cube) in
	Array.iteri
	  (begin fun i elt ->
	    str.[i] <-
	      begin match elt with
	      | Man.False -> '0'
	      | Man.True -> '1'
	      | Man.Top -> '-'
	      end
	  end)
	  cube;
	fprintf fmt "%s -> %g" str leaf
      end)
      dd;
    fprintf fmt "@]"
  end

let print_minterm print_id print_leaf fmt dd =
  if is_cst dd then print_leaf fmt (dval dd)
  else
    let nb = nbpaths dd in
    if nb > (float_of_int !Man.print_limit) then
      fprintf fmt "dd with %i nodes, %i leaves and %g paths" (size dd) (nbleaves dd) nb
  else begin
    let leaves = leaves dd in
    fprintf fmt "{ @[<v>";
    for i=Array.length leaves - 1 downto 0 do
      let leaf = leaves.(i) in
      let bdd = guard_of_leaf dd leaf in
      fprintf fmt "%a IF %a"
	print_leaf leaf (Bdd.print_minterm print_id) bdd;
      if i > 0 then
	fprintf fmt ",@ ";
    done;
    fprintf fmt "@] }"
  end

let rec print print_id print_leaf formatter dd =
  match inspect dd with
  | Leaf(v) -> print_leaf formatter v
  | Ite(var,alors,sinon) ->
      fprintf formatter "ITE(@[<hv>%a;@,%a;@,%a)@]"
	print_id var (print print_id print_leaf) alors (print print_id print_leaf) sinon
