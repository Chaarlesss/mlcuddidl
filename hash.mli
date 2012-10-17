(** User hashtables *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

type t
  (** Abstract type for user hashtables *)

external _create : int -> int -> t = "cudd_caml_hash__create"

(** Internal table *)
val table : t Weak.t ref

(** [create ~size:n arity] create a hashtable of arity [arity], of the
    optional size [n] *)
val create : ?size:int -> int -> t

(** Returns the arity of the hashtable *)
external arity : t -> int = "cudd_caml_hash_arity"

(** Clears the content of the hashtable *)
external clear : t -> unit = "cudd_caml_hash_clear"

(** Clears the content of all created hashtables *)
val clear_all : unit -> unit
