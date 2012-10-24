(** MTBDDs with OCaml values *)

open Format

type +'a unique = 'a
type +'a t = 'a unique Vdd.t

type 'a table = 'a PWeakke.t

let print_table = PWeakke.print
let make_table
  ~(hash : 'leaf -> int)
  ~(equal : 'leaf -> 'leaf -> bool)
  :
  'leaf table
  =
  PWeakke.create hash equal 23

let unique (table:'a table) (elt:'a) : 'a unique =
  if Obj.is_int (Obj.repr elt) then
    elt
  else
    PWeakke.merge_map table elt Man.copy_shr

let get (leaf:'a unique) : 'a = leaf

type 'a mtbdd = 'a Vdd.vdd =
  | Leaf of 'a
  | Ite of int * 'a Vdd.t * 'a Vdd.t


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
let dval_u = Dd.AV.dval
let dval t = get (dval_u t)
let inspect_u : 'a t -> 'a unique mtbdd = Dd.V.inspect

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

let cst_u = Dd.AV.cst
let cst cudd table x = cst_u cudd (unique table x)

let _background man : 'a t =  cst_u man (Obj.magic ())
(** Be cautious, it is not type safe (if you use
    {!nodes_below_level}, etc...: you can try to retrieve a constant
    value of some type and [()] value of the background value will be
    treated as another type.*)

let ite = Dd.AV.ite
let ite_cst_u = Dd.AV.ite_cst
let eval_cst_u = Dd.AV.eval_cst
let compose = Dd.AV.compose
let vectorcompose = Dd.AV.vectorcompose

let ite_cst f1 f2 f3 =
  match ite_cst_u f1 f2 f3 with
  | None -> None
  | Some xu -> Some (get xu)
let eval_cst ~care f =
  match eval_cst_u ~care f with
  | None -> None
  | Some xu -> Some (get xu)

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

let iter_cube_u = Dd.AV.iter_cube
let iter_cube f t =
  iter_cube_u
    (fun minterm xu -> f minterm (get xu))
    t
let iter_node = Dd.AV.iter_node

(* ====================================================== *)
(** {3 Leaves and guards} *)
(* ====================================================== *)

let guard_of_node = Dd.AV.guard_of_node
let guard_of_nonbackground = Dd.AV.guard_of_nonbackground
let nodes_below_level = Dd.AV.nodes_below_level
let guard_of_leaf_u = Dd.AV.guard_of_leaf
let leaves_u = Dd.AV.leaves
let pick_leaf_u = Dd.AV.pick_leaf
let guardleafs_u = Dd.AV.guardleafs

let guard_of_leaf table dd leaf = guard_of_leaf_u dd (unique table leaf)
let leaves t = Array.map get (leaves_u t)
let pick_leaf t = get (pick_leaf_u t)
let guardleafs t = Array.map (fun (g,xu) -> (g,get xu)) (guardleafs_u t)

(* ====================================================== *)
(** {3 Minimizations} *)
(* ====================================================== *)

let constrain = Dd.AV.constrain
let tdconstrain = Dd.AV.tdconstrain
let restrict = Dd.AV.restrict
let tdrestrict = Dd.AV.tdrestrict

(* ====================================================== *)
(** {3 Miscellaneous} *)
(* ====================================================== *)

let transfer = Dd.AV.transfer

let print__minterm print_leaf fmt t =
  Vdd.print__minterm (fun fmt x -> print_leaf fmt (get x)) fmt t
let print_minterm print_id print_leaf fmt t =
  Vdd.print_minterm print_id (fun fmt x -> print_leaf fmt (get x)) fmt t
let print print_bdd print_leaf fmt t =
  Vdd.print print_bdd (fun fmt x -> print_leaf fmt (get x)) fmt t
