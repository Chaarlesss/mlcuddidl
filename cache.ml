(** Local caches *)

(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

type t
  (** Abstract type for local caches *)

external _create : int -> int -> int -> t = "cudd_caml_cache__create"
external arity : t -> int = "cudd_caml_cache_arity"
external clear : t -> unit = "cudd_caml_cache_clear"

let create ?(size=0) ?(maxsize=max_int) ~arity =
  _create arity size maxsize

let create1 ?size ?maxsize () =
  (create ?size ?maxsize ~arity:1)
let create2 ?size ?maxsize () =
  (create ?size ?maxsize ~arity:2)
let create3 ?size ?maxsize () =
  (create ?size ?maxsize ~arity:3)
