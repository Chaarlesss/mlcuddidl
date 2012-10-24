(** Custom Operations on VDDs*)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)


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
val make_op1 : ?memo:Memo.t -> ('a -> 'b) -> ('a, 'b) op1
val make_op2 :
  ?memo:Memo.t ->
  ?commutative:bool ->
  ?idempotent:bool ->
  ?special:(('a, 'b) Dd.avdd -> ('a, 'c) Dd.avdd -> ('a, 'd) Dd.avdd option) ->
  ('b -> 'c -> 'd) -> ('a, 'b, 'c, 'd) op2
val make_test2 :
  ?memo:Memo.t ->
  ?symetric:bool ->
  ?reflexive:bool ->
  ?special:(('a, 'b) Dd.avdd -> ('a, 'c) Dd.avdd -> bool option) ->
  ('b -> 'c -> bool) -> ('a, 'b, 'c) test2
val make_op3 :
  ?memo:Memo.t ->
  ?special:(('a, 'b) Dd.avdd ->
	    ('a, 'c) Dd.avdd -> ('a, 'd) Dd.avdd -> ('a, 'e) Dd.avdd option) ->
  ('b -> 'c -> 'd -> 'e) -> ('a, 'b, 'c, 'd, 'e) op3
val make_opN :
  ?memo:Memo.t ->
  arityB:int ->
  arityV:int ->
  (('a, Bdd.any) Bdd.t array ->
   ('a, 'b) Dd.avdd array -> ('a, 'c) Dd.avdd option) ->
  ('a, 'b, 'c) opN
val make_opG :
  ?memo:Memo.t ->
  ?beforeRec:(int * bool ->
	      ('a, Bdd.any) Bdd.t array ->
	      ('a, 'b) Dd.avdd array ->
	      ('a,Bdd.any) Bdd.t array * ('a, 'b) Dd.avdd array) ->
  ?ite:(int -> ('a, 'c) Dd.avdd -> ('a, 'c) Dd.avdd -> ('a, 'c) Dd.avdd) ->
  arityB:int ->
  arityV:int ->
  (('a, Bdd.any) Bdd.t array ->
   ('a, 'b) Dd.avdd array -> ('a, 'c) Dd.avdd option) ->
  ('a, 'b, 'c) opG
val make_exist : ?memo:Memo.t -> ('a, 'b, 'b, 'b) op2 -> ('a, 'b) exist
val make_existand :
  ?memo:Memo.t -> bottom:'a -> ('b, 'a, 'a, 'a) op2 -> ('b, 'a) existand
val make_existop1 :
  ?memo:Memo.t ->
  op1:('a, 'b) op1 -> ('c, 'b, 'b, 'b) op2 -> ('c, 'a, 'b) existop1
val make_existandop1 :
  ?memo:Memo.t ->
  op1:('a, 'b) op1 ->
  bottom:'b -> ('c, 'b, 'b, 'b) op2 -> ('c, 'a, 'b) existandop1

val clear_op1 : ('a, 'b) op1 -> unit
val clear_op2 : ('a, 'b, 'c, 'd) op2 -> unit
val clear_op3 : ('a, 'b, 'c, 'd, 'e) op3 -> unit
val clear_opN : ('a, 'b, 'c) opN -> unit
val clear_opG : ('a, 'b, 'c) opG -> unit
val clear_test2 : ('a, 'b, 'c) test2 -> unit
val clear_exist : ('a, 'b) exist -> unit
val clear_existand : ('a, 'b) existand -> unit
val clear_existop1 : ('a, 'b, 'c) existop1 -> unit
val clear_existandop1 : ('a, 'b, 'c) existandop1 -> unit

val map_op1 :
  ?memo:Memo.t -> ('a -> 'b) -> ('c, 'a) Dd.avdd -> ('c, 'b) Dd.avdd

val map_op2 :
  ?memo:Memo.t ->
  ?commutative:bool ->
  ?idempotent:bool ->
  ?special:(('a, 'b) Dd.avdd -> ('a, 'c) Dd.avdd -> ('a, 'd) Dd.avdd option) ->
  ('b -> 'c -> 'd) ->
  ('a, 'b) Dd.avdd -> ('a, 'c) Dd.avdd -> ('a, 'd) Dd.avdd

val map_op3 :
  ?memo:Memo.t ->
  ?special:(('a, 'b) Dd.avdd ->
	    ('a, 'c) Dd.avdd -> ('a, 'd) Dd.avdd -> ('a, 'e) Dd.avdd option) ->
  ('b -> 'c -> 'd -> 'e) ->
  ('a, 'b) Dd.avdd ->
  ('a, 'c) Dd.avdd -> ('a, 'd) Dd.avdd -> ('a, 'e) Dd.avdd

val map_opN :
  ?memo:Memo.t ->
  (('a, Bdd.any) Bdd.t array ->
   ('a, 'b) Dd.avdd array -> ('a, 'c) Dd.avdd option) ->
  ('a, Bdd.any) Bdd.t array -> ('a, 'b) Dd.avdd array -> ('a, 'c) Dd.avdd

val map_test2 :
  ?memo:Memo.t ->
  ?symetric:bool ->
  ?reflexive:bool ->
  ?special:(('a, 'b) Dd.avdd -> ('a, 'c) Dd.avdd -> bool option) ->
  ('b -> 'c -> bool) -> ('a, 'b) Dd.avdd -> ('a, 'c) Dd.avdd -> bool
