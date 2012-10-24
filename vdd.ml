(* File generated from vdd.idl *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

(** MTBDDs with OCaml values (INTERNAL) *)

type +'a t = 'a Dd.vdd
(** Type of VDDs (that are necessarily attached to a manager of
    type [Man.v Man.t]).

    Objects of this type contains both the top node of the ADD and
    the manager to which the node belongs. The manager can be
    retrieved with {!manager}. Objects of this type are
    automatically garbage collected. *)

(** Public type for exploring the abstract type [t] *)
type +'a vdd = 'a Dd.V.inspect =
| Leaf of 'a         (** Terminal value *)
| Ite of int * 'a t * 'a t (** Decision on CUDD variable *)

(* ====================================================== *)
(** {3 Extractors} *)
(* ====================================================== *)

let manager = Dd.manager
let is_cst = Dd.is_cst
let topvar = Dd.topvar
let dthen = Dd.AV.dthen
let delse = Dd.AV.delse
let cofactors = Dd.AV.cofactors
let cofactor = Dd.AV.cofactor
let dval = Dd.AV.dval
let inspect = Dd.V.inspect

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

let _background man : 'a t =  cst man (Obj.magic ())
(** Be cautious, it is not type safe (if you use  {!nodes_below_level}, etc...: you can try to retrieve a constant value of some type and [()] value of the background value will be treated as another type.*)


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
let nbminterms = Dd.nbminterms
let density = Dd.density
let nbleaves = Dd.nbleaves

(* ====================================================== *)
(** {3 Variable mapping} *)
(* ====================================================== *)
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

let transfer = Dd.AV.transfer

(* ====================================================== *)
(** {3 Printing} *)
(* ====================================================== *)

open Format

let print__minterm print_leaf fmt dd =
  if is_cst dd then print_leaf fmt (dval dd)
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
	fprintf fmt "%s -> %a" str print_leaf leaf
      end)
      dd;
    fprintf fmt "@]"
  end

let print (print_bdd: (Format.formatter -> [<Bdd.any] Bdd.vt -> unit)) print_leaf fmt dd =
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
	fprintf fmt "@[<hv>%a@ IF %a@]"
	  print_leaf leaf print_bdd (bdd:>[<Bdd.any] Bdd.vt);
	if i > 0 then
	  fprintf fmt ",@ ";
      done;
      fprintf fmt "@] }"
    end

let print_minterm print_id print_leaf formatter dd =
  print (fun fmt bdd -> Bdd.print_minterm print_id fmt (bdd:>[<Bdd.any] Bdd.vt)) print_leaf formatter dd
