(** Local caches *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

type t
  (** Abstract type for local caches *)

external _create : int -> int -> int -> t = "cudd_caml_cache__create"

val create : ?size:int -> ?maxsize:int -> arity:int -> t
val create1 : ?size:int -> ?maxsize:int -> unit -> t
val create2 : ?size:int -> ?maxsize:int -> unit -> t
val create3 : ?size:int -> ?maxsize:int -> unit -> t
  (** Creates local caches of the given arity, with initial size [size] and
      maximal size [maxsize]. *)

(** Returns the arity of the local cache. *)
external arity : t -> int = "cudd_caml_cache_arity"

(** Clears the content of the local cache. *)
external clear : t -> unit = "cudd_caml_cache_clear"
