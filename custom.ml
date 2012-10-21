(** Custom Operations on VDDs*)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)


(** Type of identifiers *)
type pid

and mlvalue

(** Common information *)
type common = {
  pid: pid;
  arity: int;
  memo: Memo.t;
}

(** Unary operation *)
type ('a,'b) op1 = {
  common1: common;
  closure1: 'a -> 'b;
}

(** Binary operation *)
type ('a,'b,'c) op2 = {
  common2: common;
  closure2: 'a -> 'b -> 'c;
  ospecial2: ('a Vdd.t -> 'b Vdd.t -> 'c Vdd.t option) option;
  commutative: bool;
  idempotent: bool;
}

(** Binary test *)
type ('a,'b) test2 = {
  common2t: common;
  closure2t: 'a -> 'b -> bool;
  ospecial2t: ('a Vdd.t -> 'b Vdd.t -> bool option) option;
  symetric: bool;
  reflexive: bool;
}

(** Ternary operation *)
type ('a,'b,'c,'d) op3 = {
  common3: common;
  closure3: 'a -> 'b -> 'c -> 'd;
  ospecial3: ('a Vdd.t -> 'b Vdd.t -> 'c Vdd.t -> 'd Vdd.t option) option;
}

(** N-ary operation *)
type ('a,'b,'c) opN = {
  commonN: common;
  arityNbdd: int;
  closureN: 'a Bdd.vt array -> 'b Vdd.t array -> 'c Vdd.t option;
}

(** N-ary general operation *)
type ('a,'b,'c) opG = {
  commonG: common;
  arityGbdd: int;
  closureG: 'a Bdd.vt array -> 'b Vdd.t array -> 'c Vdd.t option;
  oclosureBeforeRec: (int*bool -> 'a Bdd.vt array -> 'b Vdd.t array -> (Bdd.any Bdd.vt array * 'b Vdd.t array)) option;
  oclosureIte: (int -> 'c Vdd.t -> 'c Vdd.t -> 'c Vdd.t) option;
}

(** Existential quantification *)
type 'a exist = {
  commonexist: common;
  combineexist: ('a,'a,'a) op2;
}

(** Existential quantification combined with intersection *)
type 'a existand = {
  commonexistand: common;
  combineexistand: ('a,'a,'a) op2;
  bottomexistand: 'a;
}

(** Existop1ential quantification *)
type ('a,'b) existop1 = {
  commonexistop1: common;
  combineexistop1: ('b,'b,'b) op2;
  existop1: ('a,'b) op1;
}

(** Existential quantification combined with intersection *)
type ('a,'b) existandop1 = {
  commonexistandop1: common;
  combineexistandop1: ('b,'b,'b) op2;
  existandop1: ('a,'b) op1;
  bottomexistandop1: 'b;
}

external newpid : unit -> pid
	= "cudd_caml_custom_newpid"

external apply_op1 : ('a,'b) op1 -> 'a Vdd.t -> 'b Vdd.t
	= "cudd_caml_custom_apply_op1"

external apply_op2 : ('a,'b,'c) op2 -> 'a Vdd.t -> 'b Vdd.t -> 'c Vdd.t
	= "cudd_caml_custom_apply_op2"

external apply_test2 : ('a,'b) test2 -> 'a Vdd.t -> 'b Vdd.t -> bool
	= "cudd_caml_custom_apply_test2"

external apply_op3 : ('a,'b,'c,'d) op3 -> 'a Vdd.t -> 'b Vdd.t -> 'c Vdd.t -> 'd Vdd.t
	= "cudd_caml_custom_apply_op3"


external apply_opN : ('a,'b,'c) opN -> 'a Bdd.vt array -> 'b Vdd.t array -> 'c Vdd.t = "camlidl_cudd_apply_opN"
external apply_opG : ('a,'b,'c) opG -> 'a Bdd.vt array -> 'b Vdd.t array -> 'c Vdd.t = "camlidl_cudd_apply_opG"

external _apply_exist : 'a exist -> supp:[>Bdd.supp] Bdd.vt -> 'a Vdd.t -> 'a Vdd.t
	= "cudd_caml_custom__apply_exist"

external _apply_existand : 'a existand -> supp:[>Bdd.supp] Bdd.vt -> guard:[>Bdd.supp] Bdd.vt -> 'a Vdd.t -> 'a Vdd.t
	= "cudd_caml_custom__apply_existand"

external _apply_existop1 : ('a,'b) existop1 -> supp:[>Bdd.supp] Bdd.vt -> 'a Vdd.t -> 'b Vdd.t
	= "cudd_caml_custom__apply_existop1"

external _apply_existandop1 : ('a,'b) existandop1 -> supp:[>Bdd.supp] Bdd.vt -> gaurd:[>Bdd.supp] Bdd.vt -> 'a Vdd.t -> 'b Vdd.t
	= "cudd_caml_custom__apply_existandop1"
