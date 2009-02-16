(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

(** Custom operations for ADDs (Internal) *)

(** Internal module, used by modules {!Idd}, {!Rdd} and {!Vdd} *)

(*  ********************************************************************** *)
(** {2 Types of registered operations} *)
(*  ********************************************************************** *)

(*  ---------------------------------------------------------------------- *)
(** {3 Operations on leaves of MTBDDs} *)
(*  ---------------------------------------------------------------------- *)

type ('a,'b) op1
  (** Type of unary operations ['a -> 'b] *) 
type ('a,'b,'c) op2
  (** Type of binary operations ['a -> 'b -> 'c] *) 
type ('a,'b) test2
  (** Type of binary tests ['a -> 'b -> bool] *) 
type ('a,'b,'c,'d) op3
  (** Type of ternary operations ['a -> 'b -> 'c -> 'd] *) 
type ('a,'b) exist
  (** Type of quantification operation [supp -> 'a -> 'a].  The leaf
      operation [op:'a -> 'a -> 'a]] is assumed to be commutative
      and idempotent ([op f f=f]).  When a Boolean variable in [supp] is
      quantified out, [op:'a -> 'a -> 'a] is used to combine the two branch of the diagram.
  *)
type ('a,'b,'c,'d) existop1
  (** Type of quantification and op1 operation.  The leaf
      operation [op:'b -> 'b -> 'b]] is assumed to be commutative
      and idempotent ([op f f=f]). 
      [existop1 op op1 supp bdd] is equivalent to
      [exist supp (op1 f)].
  *)
type ('a,'b) existand
  (** Type of combined quantification and and operation. The leaf
      operation [op:'a -> 'a -> 'a]] is assumed to be commutative, idempotent ([op f f=f]).
      and also [op f bottom = f].
      [existand ~bottom op supp bdd f] is equivalent to [exist supp (ite bdd f bottom)].
  *)
type ('a,'b,'c,'d) existandop1
  (** Type of combined quantification, and and op1 operation. The leaf
      operation [op:'b -> 'b -> 'b]] is assumed to be commutative, idempotent ([op f f=f]), and
      also [op f bottom = f].
      [existandop1 ~bottom op op1 supp bdd f] is equivalent to
      [exist supp (ite bdd (op1 f) bottom))]. *)
type ('a,'b) vectorcomposeop1

(*  ---------------------------------------------------------------------- *)
(** {3 Caching policy} *)
(*  ---------------------------------------------------------------------- *)

(** {4 Local cache} *)

type auto
  (** The local table is cleared automatically at the end on the
      operation on MTBDDs.  Hence, there is no reuse between two
      calls to the same MTBDD operation.  

      Default option, as there is no danger to do tricky
      errors.
  *)
type user
  (** It is up to the user to clear regularly the local
      table. Forgetting to do so will prevent garbage collection
      of nodes stored in the table, which can only grow. 

      The OCaml closure defining the function should not use free
      variables that may be modified and so impact its result:
      they would act as hidden parameters that are not taken into
      account in the cache.

      If such hidden parameters are modified, the cache should be cleared with {!flush_cache} 
  *)

type 'a local
  (** Local cache (hashtable) policy, where ['a] is either [auto] or [user]. *)

(** {4 Global cache} *)

type global
  (** The operation on MTBDDs is memoized in the global cache.

      Same remark as for [user local] concerning free
      variables.acting as hidden parameters. If hidden parameters
      are modified, the global cache should be cleared with
      {!Man.flush_cache}.
  *)

(** {4 Caching policy} *)

type 'a cache 
  (** Caching policy, where ['a] is either ['a local] or [global]. *)

(*  ---------------------------------------------------------------------- *)
(** {3 Type of registered operations} *)
(*  ---------------------------------------------------------------------- *)

type ('a,'b) op
  (** ['a] indicates the type and arity of the corresponding operation on leaves
      (one of [('a,'b) op1, ('a,'b,'c) op2, ...])

      ['b] indicates the caching policy.
  **)

(*  ********************************************************************** *)
(** {2 Registering and managing operations} *)
(*  ********************************************************************** *)

val global : global cache
val auto : auto local cache
val user : user local cache

val register_op1 :
  ddtyp:int ->
  cachetyp:'c cache -> ('a -> 'b) -> (('a, 'b) op1, 'c) op

val register_op2 :
  ddtyp:int ->
  cachetyp:'d cache ->
  ?commutative:bool ->
  ?idempotent:bool ->
  ?absorbant1:('a -> 'c option) ->
  ?absorbant2:('b -> 'c option) ->
  ?neutral1:('a -> bool) ->
  ?neutral2:('b -> bool) -> ('a -> 'b -> 'c) -> (('a, 'b, 'c) op2, 'd) op

val register_test2 :
  ddtyp:int ->
  cachetyp:'c cache ->
  ?commutative:bool ->
  ?reflexive:bool ->
  ?bottom1:('a -> bool) ->
  ?top2:('b -> bool) -> ('a -> 'b -> bool) -> (('a, 'b) test2, 'c) op

val register_op3 :
  ddtyp:int ->
  cachetyp:'e local cache ->
  ('a -> 'b -> 'c -> 'd) -> (('a, 'b, 'c, 'd) op3, 'e local) op

val register_exist :
  ddtyp:int ->
  cachetyp:'c cache -> (('a, 'a, 'a) op2, 'b) op -> (('a,'b) exist, 'c) op

val register_existop1 :
  ddtyp:int ->
  cachetyp:'e cache -> 
  (('a, 'b) op1, 'c) op -> 
  (('b, 'b, 'b) op2, 'd) op -> 
  (('a,'b,'c,'d) existop1, 'e) op

val register_existand :
  ddtyp:int ->
  cachetyp:'c local cache -> 
  bottom:'a ->
  (('a, 'a, 'a) op2, 'b) op -> (('a,'b) existand, 'c local) op

val register_existandop1 :
  ddtyp:int ->
  cachetyp:'e local cache -> 
  bottom:'b ->
  (('a, 'b) op1, 'c) op -> 
  (('b, 'b, 'b) op2, 'd) op -> 
  (('a,'b,'c,'d) existandop1, 'e local) op

external op2_of_exist : (('a,'b) exist, 'c) op -> (('a,'a,'a) op2, 'b) op = "camlidl_cudd_rivdd_op2_of_exist"
external op2_of_existop1 : (('a,'b,'c,'d) existop1, 'e) op -> (('b,'b,'b) op2, 'd) op = "camlidl_cudd_rivdd_op2_of_exist"
external op2_of_existand : (('a,'b) existand, 'c local) op -> (('a,'a,'a) op2, 'b) op = "camlidl_cudd_rivdd_op2_of_exist"
external op2_of_existandop1 : (('a,'b,'c,'d) existandop1, 'e local) op -> (('b,'b,'b) op2, 'd) op = "camlidl_cudd_rivdd_op2_of_exist"

external op1_of_existop1 : (('a,'b,'c,'d) existop1, 'e) op -> (('a,'b) op1, 'c) op = "camlidl_cudd_rivdd_op1_of_existop1"
external op1_of_existandop1 : (('a,'b,'c,'d) existandop1, 'e local) op -> (('a,'b) op1, 'c) op = "camlidl_cudd_rivdd_op1_of_existop1"



val flush_op : ('a, user local) op -> unit
external flush_allop : unit -> unit = "camlidl_cudd_rivdd_flush_allop"

val remove_localop : ('a, 'b local) op -> unit
val remove_globalop : ('a, global) op -> unit

(*  ********************************************************************** *)
(** {2 Applying operations} *)
(*  ********************************************************************** *)

val apply_op1 : (('a, 'b) op1, 'c) op -> 'd -> 'e
val apply_op2 : (('a, 'b, 'c) op2, 'd) op -> 'e -> 'f -> 'g
val apply_test2 : (('a, 'b) test2, 'c) op -> 'd -> 'e -> bool
val apply_op3 :
  (('a, 'b, 'c, 'd) op3, 'e local) op -> 'f -> 'g -> 'h -> 'i
val apply_exist : (('a,'b) exist, 'c) op -> supp:(Man.v Bdd.t) -> 'd -> 'd
val apply_existop1 : (('a,'b,'c,'d) existop1, 'e) op -> supp:(Man.v Bdd.t) -> 'f -> 'g
val apply_existand : (('a,'b) existand, 'c local) op -> supp:(Man.v Bdd.t) -> Man.v Bdd.t -> 'd -> 'd
val apply_existandop1 : (('a,'b,'c,'d) existandop1, 'e local) op -> supp:(Man.v Bdd.t) -> Man.v Bdd.t -> 'f -> 'g

(*  ********************************************************************** *)
(** {2 Map operations (based on automatic local caches} *)
(*  ********************************************************************** *)

val map_op1 : ddtyp:int -> ('a -> 'b) -> 'c -> 'd
val map_op2 :
  ddtyp:int ->
  ?commutative:bool ->
  ?idempotent:bool ->
  ?absorbant1:('a -> 'b option) ->
  ?absorbant2:('c -> 'b option) ->
  ?neutral1:('a -> bool) ->
  ?neutral2:('c -> bool) -> ('a -> 'c -> 'b) -> 'd -> 'e -> 'f
val map_test2 :
  ddtyp:int ->
  ?commutative:bool ->
  ?reflexive:bool ->
  ?bottom1:('a -> bool) ->
  ?top2:('b -> bool) -> ('a -> 'b -> bool) -> 'c -> 'd -> bool
val map_op3 : ddtyp:int -> ('a -> 'b -> 'c -> 'd) -> 'e -> 'f -> 'g -> 'h

type ('a, 'b) mexist =
    [ `Fun of 'a fexist | `Op of (('a, 'a, 'a) op2, 'b) op ]
and 'a fexist = {
  op : 'a -> 'a -> 'a;
  absorbant : ('a -> bool) option;
  neutral : ('a -> bool) option;
}

type ('a, 'b, 'c) mop1 = [ `Fun of 'a -> 'b | `Op of (('a, 'b) op1, 'c) op ]

val map_exist :
  ddtyp:int -> ('a, 'b) mexist -> supp:Man.v Bdd.t -> 'c -> 'c
val map_existop1 :
  ddtyp:int ->
  ('a, 'b, 'c) mop1 -> ('b, 'd) mexist -> supp:Man.v Bdd.t -> 'e -> 'f
val map_existand :
  ddtyp:int ->
  bottom:'a ->
  ('a, 'b) mexist -> supp:Man.v Bdd.t -> Man.v Bdd.t -> 'c -> 'c
val map_existandop1 :
  ddtyp:int ->
  bottom:'b ->
  ('a, 'b, 'c) mop1 -> ('b, 'd) mexist ->
  supp:Man.v Bdd.t -> Man.v Bdd.t -> 'e -> 'f

