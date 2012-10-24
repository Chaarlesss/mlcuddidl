(** Custom Operations on VDDs*)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)


(*  ********************************************************************** *)
(** {3 Types} *)
(*  ********************************************************************** *)

(** Type of identifiers *)
type pid

(** Common information *)
type common = {
  pid: pid;     (** Identifiers for shared memoization tables *)
  arity: int;    (** Arity of the operations *)
  memo: Memo.t; (** Memoization table *)
}

(** Unary operation *)
type ('b,'c) op1 = {
  common1: common;
  closure1: 'b -> 'c;
    (** Operation on leaves *)
}

(** Binary operation *)
type ('a,'b,'c,'d) op2 = {
  common2: common;
  closure2: 'b -> 'c -> 'd;
    (** Operation on leaves *)
  ospecial2: (('a,'b) Dd.avdd -> ('a,'c) Dd.avdd -> ('a,'d) Dd.avdd option) option;
  commutative: bool;
   (** Is the operation commutative ? *)
  idempotent: bool;
   (** Is the operation idempotent ([op x x = x]) ? *)
}

(** Binary test *)
type ('a,'b,'c) test2 = {
  common2t: common;
  closure2t: 'b -> 'c -> bool;
    (** Test on leaves *)
  ospecial2t: (('a,'b) Dd.avdd -> ('a,'c) Dd.avdd -> bool option) option;
   (** Special cases *)
  symetric: bool;
    (** Is the relation symetric ? *)
  reflexive: bool;
    (** Is the relation reflexive ? ([test x x = true]) ? *)
}

(** Ternary operation *)
type ('a,'b,'c,'d,'e) op3 = {
  common3: common;
  closure3: 'b -> 'c -> 'd -> 'e;
    (** Operation on leaves *)
  ospecial3: (('a,'b) Dd.avdd -> ('a,'c) Dd.avdd -> ('a,'d) Dd.avdd -> ('a,'e) Dd.avdd option) option;
    (** Special cases *)
}

(** N-ary operation *)
type ('a,'b,'c) opN = {
  commonN: common;
  arityNbdd: int;
  closureN: ('a,Bdd.any) Bdd.t array -> ('a,'b) Dd.avdd array -> ('a,'c) Dd.avdd option;
    (** Operation on leaves *)
}

(** N-ary general operation *)
type ('a,'b,'c) opG = {
  commonG: common;
  arityGbdd: int;
  closureG: ('a,Bdd.any) Bdd.t array -> ('a,'b) Dd.avdd array -> ('a,'c) Dd.avdd option;
  oclosureBeforeRec: (int*bool -> ('a,Bdd.any) Bdd.t array -> ('a,'b) Dd.avdd array -> (('a,Bdd.any) Bdd.t array * ('a,'b) Dd.avdd array)) option;
  oclosureIte: (int -> ('a,'c) Dd.avdd -> ('a,'c) Dd.avdd -> ('a,'c) Dd.avdd) option;
}

(** Existential quantification *)
type ('a,'b) exist = {
  commonexist: common;
  combineexist: ('a,'b,'b,'b) op2;
    (** Combining operation when a decision is eliminated *)
}

(** Existential quantification combined with intersection *)
type ('a,'b) existand = {
  commonexistand: common;
  combineexistand: ('a,'b,'b,'b) op2;
    (** Combining operation when a decision is eliminated *)
  bottomexistand: 'b;
    (** Value returned when intersecting with [Bdd.dfalse] *)
}

(** Existential quantification *)
type ('a,'b,'c) existop1 = {
  commonexistop1: common;
  combineexistop1: ('a,'c,'c,'c) op2;
    (** Combining operation when a decision is eliminated *)
  existop1: ('b,'c) op1;
    (** Unary operations applied before elimination *)
}

(** Existential quantification combined with intersection *)
type ('a,'b,'c) existandop1 = {
  commonexistandop1: common;
  combineexistandop1: ('a,'c,'c,'c) op2;
    (** Combining operation when a decision is eliminated *)
  existandop1: ('b,'c) op1;
    (** Unary operations applied before elimination *)
  bottomexistandop1: 'c;
    (** Value returned when intersecting with [Bdd.dfalse] *)
}

(*  ********************************************************************** *)
(** {3 Applying operations} *)
(*  ********************************************************************** *)

external newpid : unit -> pid
	= "cudd_caml_custom_newpid"

external apply_op1 : ('b,'c) op1 -> ('a,'b) Dd.avdd -> ('a,'c) Dd.avdd
	= "cudd_caml_custom_apply_op1"

external apply_op2 : ('a,'b,'c,'d) op2 -> ('a,'b) Dd.avdd -> ('a,'c) Dd.avdd -> ('a,'d) Dd.avdd
	= "cudd_caml_custom_apply_op2"

external apply_test2 : ('a,'b,'c) test2 -> ('a,'b) Dd.avdd -> ('a,'c) Dd.avdd -> bool
	= "cudd_caml_custom_apply_test2"

external apply_op3 : ('a,'b,'c,'d,'e) op3 -> ('a,'b) Dd.avdd -> ('a,'c) Dd.avdd -> ('a,'d) Dd.avdd -> ('a,'e) Dd.avdd
	= "cudd_caml_custom_apply_op3"

external apply_opN : ('a,'b,'c) opN -> ('a,Bdd.any) Bdd.t array -> ('a,'b) Dd.avdd array -> ('a,'c) Dd.avdd = "cudd_caml_custom_apply_opN"
external apply_opG : ('a,'b,'c) opG -> ('a,Bdd.any) Bdd.t array -> ('a,'b) Dd.avdd array -> ('a,'c) Dd.avdd = "cudd_caml_custom_apply_opG"

external apply_exist : ('a,'b) exist -> supp:('a,[>Bdd.supp]) Bdd.t -> ('a,'b) Dd.avdd -> ('a,'b) Dd.avdd
	= "cudd_caml_custom_apply_exist"

external apply_existand : ('a,'b) existand -> supp:('a,[>Bdd.supp]) Bdd.t -> guard:('a,[>Bdd.any]) Bdd.t -> ('a,'b) Dd.avdd -> ('a,'b) Dd.avdd
	= "cudd_caml_custom_apply_existand"

external apply_existop1 : ('a,'b,'c) existop1 -> supp:('a,[>Bdd.supp]) Bdd.t -> ('a,'b) Dd.avdd -> ('a,'c) Dd.avdd
	= "cudd_caml_custom_apply_existop1"

external apply_existandop1 : ('a,'b,'c) existandop1 -> supp:('a,[>Bdd.supp]) Bdd.t -> guard:('a,[>Bdd.any]) Bdd.t -> ('a,'b) Dd.avdd -> ('a,'c) Dd.avdd
	= "cudd_caml_custom_apply_existandop1"

(*  ********************************************************************** *)
(** {3 Making operations} *)
(*  ********************************************************************** *)

let make_common ?memo arity =
  let pid = newpid () in
  let memo = match memo with
    | None -> Memo.Hash(Hash.create arity)
    | Some x ->
	let ok = match x with
	    | Memo.Global -> arity<=2
	    | Memo.Hash x -> (Hash.arity x) = arity
	    | Memo.Cache x -> (Cache.arity x) = arity
	in
	if not ok then
	  raise (Invalid_argument "User.make_common: expected arity is not the same as arity in memo argument")
	;
	x
  in
  { pid; arity; memo }

let make_op1 ?memo op =
  let common = make_common 1 ?memo in
  { common1 = common; closure1=op }

let make_op2
    ?memo
    ?(commutative=false)
    ?(idempotent=false)
    ?special
    op
    =
  let common = make_common 2 ?memo in
  {
    common2=common;
    closure2=op;
    ospecial2=special;
    commutative=commutative;
    idempotent=idempotent;
  }
let make_test2
    ?memo
    ?(symetric=false)
    ?(reflexive=false)
    ?special
    op
    =
  let common = make_common 2 ?memo in
  {
    common2t=common;
    closure2t=op;
    ospecial2t=special;
    symetric;
    reflexive;
  }
let make_op3
    ?memo
    ?special
    op
    =
  let common = make_common 3 ?memo in
  {
    common3=common;
    closure3=op;
    ospecial3=special;
  }
let make_opN ?memo ~arityB ~arityV op =
  let common = make_common ?memo (arityB+arityV) in
  { commonN=common; arityNbdd=arityB; closureN=op; }
let make_opG ?memo ?beforeRec ?ite ~arityB ~arityV op =
  let common = make_common ?memo (arityB+arityV) in
  {
    commonG=common;
    arityGbdd=arityB;
    closureG=op;
    oclosureBeforeRec=beforeRec;
    oclosureIte=ite;
  }
let make_exist ?memo combine =
  let common = make_common 2 ?memo in
  { commonexist=common; combineexist=combine }
let make_existand ?memo ~bottom combine =
  let common = make_common 3 ?memo in
  { commonexistand=common; combineexistand=combine; bottomexistand=bottom }
let make_existop1 ?memo ~op1 combine =
  let common = make_common 2 ?memo in
  { commonexistop1=common; combineexistop1=combine; existop1=op1 }
let make_existandop1 ?memo ~op1 ~bottom combine =
  let common = make_common 3 ?memo in
  { commonexistandop1=common; combineexistandop1=combine; existandop1=op1; bottomexistandop1=bottom }

(*  ********************************************************************** *)
(** {3 Clearing memoization structures} *)
(*  ********************************************************************** *)

let clear_common common = Memo.clear common.memo
let clear_op1 op = clear_common op.common1
let clear_op2 op = clear_common op.common2
let clear_op3 op = clear_common op.common3
let clear_opN op = clear_common op.commonN
let clear_opG op = clear_common op.commonG
let clear_test2 op = clear_common op.common2t
let clear_exist op = clear_common op.commonexist
let clear_existand op = clear_common op.commonexistand
let clear_existop1 op = clear_common op.commonexistop1
let clear_existandop1 op = clear_common op.commonexistandop1

(*  ********************************************************************** *)
(** {3 Map operations} *)
(*  ********************************************************************** *)

let map_op1 ?memo op d1 =
  let op = make_op1 ?memo op in
  let res = apply_op1 op d1 in
  if memo=None then Memo.clear op.common1.memo;
  res

let map_op2
    ?memo
    ?commutative ?idempotent
    ?special
    op d1 d2
    =
  let op =
    make_op2 ?memo
      ?commutative ?idempotent
      ?special op
  in
  let res = apply_op2 op d1 d2 in
  if memo=None then Memo.clear op.common2.memo;
  res

let map_op3 ?memo ?special op d1 d2 d3
    =
  let op = make_op3 ?memo ?special op in
  let res = apply_op3 op d1 d2 d3 in
  if memo=None then Memo.clear op.common3.memo;
  res

let map_opN ?memo op tbdd tvdd
    =
  let arityB = Array.length tbdd in
  let arityV = Array.length tvdd in
  let op = make_opN ?memo ~arityB ~arityV op in
  let res = apply_opN op tbdd tvdd in
  if memo=None then Memo.clear op.commonN.memo;
  res

let map_test2
    ?memo
    ?symetric ?reflexive
    ?special
    op d1 d2
    :
    bool
    =
  let op =
    make_test2 ?memo
      ?symetric ?reflexive
      ?special op
  in
  let res = apply_test2 op d1 d2 in
  if memo=None then Memo.clear op.common2t.memo;
  res
