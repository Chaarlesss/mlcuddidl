(** Binary Decision Diagrams *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

type ('a,'b) t = ('a,'b) Dd.bdd
type ('a,'b) conj = ('a,'b) Dd.conj
type pos = Dd.pos
type any = Dd.any
type var = Dd.var

type ('a, 'b, 'c) cube = ('a, ('b,  'c)  conj) t
type ('a, 'b) supp     = ('a, ('b,  pos) conj) t
type ('a, 'c) literal  = ('a, (var, 'c)  conj) t
type 'a atom           = ('a, (var, pos) conj) t

type dt       = (Man.d,any) t
type dcube    = (Man.d,any,any) cube
type dliteral = (Man.d,any) literal
type dsupp    = (Man.d,any) supp
type datom    = Man.d atom

type vt       = (Man.v,any) t
type vcube    = (Man.v,any,any) cube
type vliteral = (Man.v,any) literal
type vsupp    = (Man.v,any) supp
type vatom    = Man.v atom

(** Public type for exploring the abstract type [t] *)
type ('a,'b) bdd = ('a,'b) Dd.B.inspect =
  | Bool of bool                       (** Terminal value *)
  | Ite of int * ('a,'b) t * ('a,'b) t (** Decision on CUDD variable *)

(*  ====================================================== *)
(** {3 Extractors} *)
(*  ====================================================== *)
let manager = Dd.manager
let is_cst = Dd.is_cst
let is_complement = Dd.B.is_complement
let topvar = Dd.topvar
let dthen = Dd.B.dthen
let delse = Dd.B.delse
let cofactors = Dd.B.cofactors
let cofactor = Dd.B.cofactor
let inspect = Dd.B.inspect

(*  ====================================================== *)
(** {3 Supports} *)
(*  ====================================================== *)
let support = Dd.support
let supportsize = Dd.supportsize
let is_var_in = Dd.is_var_in
let vectorsupport = Dd.vectorsupport

(*  ====================================================== *)
(** {3  Printing} *)
(*  ====================================================== *)
let support_inter = Dd.B.support_inter
let support_union = Dd.B.support_union
let support_diff = Dd.B.support_diff
let list_of_support = Dd.list_of_support

(*  ====================================================== *)
(** {3  Constants and Variables} *)
(*  ====================================================== *)
let dtrue = Dd.B.dtrue
let dfalse = Dd.B.dfalse
let ithvar = Dd.B.ithvar
let newvar = Dd.B.newvar
let newvar_at_level = Dd.B.newvar_at_level

(*  ====================================================== *)
(** {3  Logical tests} *)
(*  ====================================================== *)

let is_true = Dd.B.is_true
let is_false = Dd.B.is_false
let is_equal = Dd.is_equal
let is_leq = Dd.B.is_leq
let is_included_in = Dd.B.is_included_in
let is_inter_empty = Dd.B.is_inter_empty
let is_equal_when = Dd.is_equal_when
let is_leq_when = Dd.B.is_leq_when
let is_ite_cst = Dd.B.is_ite_cst
let is_var_dependent = Dd.B.is_var_dependent
let is_var_essential = Dd.B.is_var_essential

(*  ====================================================== *)
(** {3  Structural information} *)
(*  ====================================================== *)

let size = Dd.size
let nbpaths = Dd.nbpaths
let nbtruepaths = Dd.B.nbtruepaths
let nbminterms = Dd.nbminterms
let density = Dd.density

(*  ====================================================== *)
(** {3  Logical operations} *)
(*  ====================================================== *)
let dnot = Dd.B.dnot
let vnot = Dd.B.vnot
let dand = Dd.B.dand
let dor = Dd.B.dor
let xor = Dd.B.xor
let nand = Dd.B.nand
let nor = Dd.B.nor
let nxor = Dd.B.nxor
let eq = Dd.B.eq
let ite = Dd.B.ite
let ite_cst = Dd.B.ite_cst
let compose = Dd.B.compose
let vectorcompose = Dd.B.vectorcompose
let intersect = Dd.B.intersect
let booleandiff = Dd.B.booleandiff

(*  ====================================================== *)
(** {3  Variable mapping} *)
(*  ====================================================== *)
let varmap = Dd.B.varmap
let permute = Dd.B.permute

(*  ====================================================== *)
(** {3  Iterators} *)
(*  ====================================================== *)
let iter_node = Dd.B.iter_node
let iter_cube = Dd.B.iter_cube
let iter_prime = Dd.B.iter_prime

(*  ====================================================== *)
(** {3  Quantifications} *)
(*  ====================================================== *)
let exist = Dd.B.exist
let forall = Dd.B.forall
let existand = Dd.B.existand
let existxor = Dd.B.existxor

(*  ====================================================== *)
(** {3  Cubes} *)
(*  ====================================================== *)
let cube_of_bdd = Dd.B.cube_of_bdd
let cube_of_minterm = Dd.cube_of_minterm
let list_of_cube = Dd.list_of_cube
let cube_and = Dd.B.cube_and
let cube_or = Dd.B.cube_or
let cube_union = Dd.B.cube_union
let pick_minterm = Dd.B.pick_minterm
let pick_cube_on_support = Dd.B.pick_cube_on_support
let pick_cubes_on_support = Dd.B.pick_cubes_on_support

(*  ====================================================== *)
(** {3  Minimizations} *)
(*  ====================================================== *)
let constrain = Dd.B.constrain
let tdconstrain = Dd.B.tdconstrain
let restrict = Dd.B.restrict
let tdrestrict = Dd.B.tdrestrict
let minimize = Dd.B.minimize
let licompaction = Dd.B.licompaction
let squeeze = Dd.B.squeeze

(*  ====================================================== *)
(** {3  Approximations} *)
(*  ====================================================== *)
type approx = Dd.B.approx = Under | Over
let clippingand = Dd.B.clippingand
let clippingexistand = Dd.B.clippingexistand

let underapprox = Dd.B.underapprox
let remapunderapprox = Dd.B.remapunderapprox
let biasedunderapprox = Dd.B.biasedunderapprox
let overapprox = Dd.B.overapprox
let remapoverapprox = Dd.B.remapoverapprox
let biasedoverapprox = Dd.B.biasedoverapprox

let subsetcompress = Dd.B.subsetcompress
let subsetHB = Dd.B.subsetHB
let subsetSP = Dd.B.subsetSP
let supersetcompress = Dd.B.supersetcompress
let supersetHB = Dd.B.supersetHB
let supersetSP = Dd.B.supersetSP

let approxconjdecomp = Dd.B.approxconjdecomp
let iterconjdecomp = Dd.B.iterconjdecomp
let genconjdecomp = Dd.B.genconjdecomp
let varconjdecomp = Dd.B.varconjdecomp
let approxdisjdecomp = Dd.B.approxdisjdecomp
let iterdisjdecomp = Dd.B.iterdisjdecomp
let gendisjdecomp = Dd.B.gendisjdecomp
let vardisjdecomp = Dd.B.vardisjdecomp

(*  ====================================================== *)
(** {3  Miscellaneous} *)
(*  ====================================================== *)

let transfer = Dd.B.transfer
let correlation = Dd.B.correlation
let correlationweights = Dd.B.correlationweights

(*  ====================================================== *)
(** {3  Printing} *)
(*  ====================================================== *)

(** Raw (C) printing function.  The output may mix badly with the OCAML output. *)
external _print: ('a,'b) t -> unit = "camlidl_cudd_print"

open Format

let print__minterm fmt bdd =
  if is_false bdd then pp_print_string fmt "false"
  else if is_true bdd then pp_print_string fmt "true"
  else
    let nb = nbpaths bdd in
    if nb > (float_of_int !Man.print_limit) then
      fprintf fmt "bdd with %i nodes and %g paths" (size bdd) nb
  else begin
    fprintf fmt "@[<v>";
    let first = ref true in
    iter_cube
      (begin fun cube ->
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
	pp_print_string fmt str
      end)
      bdd;
    fprintf fmt "@]"
  end

let print_minterm print_id fmt bdd =
  let _print fmt bdd =
    if is_true bdd then pp_print_string fmt "true"
    else if is_false bdd then pp_print_string fmt "false"
    else begin
    fprintf fmt "@[<hov>";
    let first = ref true in
    iter_cube
      (begin fun cube ->
	if not !first then
	  fprintf fmt " +@ @[<hov>"
	else begin
	  first := false;
	  fprintf fmt "@[<hov>"
	end;
	let firstm = ref true in
	Array.iteri
	  (begin fun i elt ->
	    match elt with
	    | Man.False ->
		if not !firstm then fprintf fmt "^@," else firstm := false;
		fprintf fmt "!%a" print_id i
	    | Man.True ->
		if not !firstm then fprintf fmt "^@," else firstm := false;
		fprintf fmt "%a" print_id i
	    | Man.Top -> ()
	  end)
	  cube;
	fprintf fmt "@]"
      end)
      bdd;
    fprintf fmt "@]"
  end
  in
  let nb = nbpaths bdd in
  if nb > (float_of_int !Man.print_limit) then
    fprintf fmt "@[<hv>bdd with %i nodes and %g paths@,(mon=%a)@]"
      (size bdd) nb
      _print (cube_of_bdd bdd)
  else
    _print fmt bdd


let rec print_list print_id formatter = function
  | (v,b)::suite ->
      fprintf formatter "%s%a"(if b then "" else "!") print_id v;
      if suite<>[] then
	fprintf formatter "^@,%a" (print_list print_id) suite
  | [] -> ()

let rec print print_id formatter bdd =
  if is_true bdd then
    pp_print_string formatter "true"
  else if is_false bdd then
    pp_print_string formatter "false"
  else
    let mon = cube_of_bdd bdd in
    let reste = cofactor bdd mon in
    let istrue = is_true mon in
    if not istrue then
      fprintf formatter "@[<h>%a@]" (print_list print_id) (list_of_cube mon);
    match inspect reste with
    | Bool(_) -> ()
    | Ite(var,alors,sinon) ->
	if not istrue then pp_print_char formatter '^';
	fprintf formatter "ITE(@[<hv>%a;@,%a;@,%a)@]"
	  print_id var (print print_id) alors (print print_id) sinon
