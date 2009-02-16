(* This file is part of the MLCUDDIDL Library, released under LGPL license.
   Please read the COPYING file packaged in the distribution  *)

(** Custom operations for ADDs (Internal) *)

(** This is used by modules {!Idd}, {!Rdd} and {!Vdd} *)

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
  (** Type of quantification operation *)
type ('a,'b,'c,'d) existop1
  (** Type of quantification and op1 operation.  The leaf
      operation [op:'b -> 'b -> 'b]] is assumed to be commutative
      and idempotent ([op f f=f]). 
      [existop1 op op1 supp bdd] is equivalent to
      [exist supp (op1 f)].
  *)
type ('a,'b) existand
  (** Type of combined quantification and and operation.
      [existand ~bottom op supp bdd f] is equivalent to [exist supp (ite bdd f bottom)].
  *)
type ('a,'b,'c,'d) existandop1
  (** Type of combined quantification and and operation.
      [existandop1 ~bottom op op1 supp bdd f] is equivalent to
      [op1 (exist supp (ite bdd f bottom))]. *)
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

type 'a cache = int
  (** Caching policy, where ['a] is either ['a local] or [global]. *)

(*  ---------------------------------------------------------------------- *)
(** {3 Type of registered operations} *)
(*  ---------------------------------------------------------------------- *)

type ('a,'b) op = int
  (** ['a] indicates the type and arity of the corresponding operation on leaves
      (one of [('a,'b) op1, ('a,'b,'c) op2, ...])

      ['b] indicates the caching policy.
  **)

(*  ********************************************************************** *)
(** {2 Registering and applying operations} *)
(*  ********************************************************************** *)

let global = 0
let auto = 1
let user = 2

external _internal_register_op : ddtyp:int -> cachetyp:int -> optyp:int -> commutative:bool -> idempotent:bool -> op1:int -> op:int -> 
  ((('a -> 'c) option) *
   (('b -> 'c) option) *
   (('a -> bool) option) *
   (('b -> bool) option)) ->
  ('d -> 'e) ->
  int = "camlidl_cudd_rivdd_register_op_byte" "camlidl_cudd_rivdd_register_op"

external _internal_remove_op : int -> unit = "camlidl_cudd_rivdd_remove_op"
external _internal_map_op : int -> 'a array -> 'b = "camlidl_cudd_rivdd_map_op"
external _internal_flush_op : int -> unit = "camlidl_cudd_rivdd_flush_op"

let none4 = (None, None, None, None)

let register_op1
    ~(ddtyp:int)
    ~(cachetyp:'c cache)
    (op : 'a -> 'b)
    :
    (('a,'b) op1, 'c) op
    =
  _internal_register_op
    ~ddtyp ~cachetyp ~optyp:0 ~commutative:false ~idempotent:false
     ~op1:(-1) ~op:(-1)
    none4 op

let register_op2
    ~(ddtyp:int)
    ~(cachetyp:'d cache)
    ?(commutative=false)
    ?(idempotent=false)
    ?(absorbant1:('a -> 'c option) option)
    ?(absorbant2:('b -> 'c option) option)
    ?(neutral1:('a -> bool) option)
    ?(neutral2:('b -> bool) option)
    (op : 'a -> 'b -> 'c)
    :
    (('a,'b,'c) op2, 'd) op
    =
  _internal_register_op ~ddtyp ~cachetyp ~optyp:1 ~commutative ~idempotent
    ~op1:(-1) ~op:(-1) 
    (absorbant1, absorbant2, neutral1, neutral2) op

let register_test2
    ~(ddtyp:int)
    ~(cachetyp:'c cache)
    ?(commutative=false)
    ?(reflexive=false)
    ?(bottom1:('a -> bool) option)
    ?(top2:('b -> bool) option)
    (op : 'a -> 'b -> bool)
    :
    (('a,'b) test2, 'c) op
    =
  _internal_register_op ~ddtyp ~cachetyp ~optyp:2
    ~commutative ~idempotent:reflexive
    ~op1:(-1) ~op:(-1) 
    (None, None, bottom1, top2) op

let register_op3
    ~(ddtyp:int)
    ~(cachetyp:'e local cache)
    (op : 'a -> 'b -> 'c -> 'd)
    :
    (('a,'b,'c,'d) op3, 'e local) op
    =
  _internal_register_op ~ddtyp ~cachetyp ~optyp:3 ~commutative:false ~idempotent:false
    ~op1:(-1) ~op:(-1) 
    none4 op

let register_exist
    ~(ddtyp:int)
    ~(cachetyp:'c cache)
    (op : (('a,'a,'a) op2,'b) op)
    :
    (('a,'b) exist, 'c) op
    =
  _internal_register_op ~ddtyp ~cachetyp ~optyp:4 ~commutative:false ~idempotent:false
    ~op1:(-1) ~op:op
    none4 (Obj.magic 1)

let register_existop1
    ~(ddtyp:int)
    ~(cachetyp:'e cache)
    (op1 : (('a,'b) op1,'c) op)
    (op : (('b,'b,'b) op2,'d) op)
    :
    (('a,'b,'c,'d) existop1, 'e) op
    =
  _internal_register_op ~ddtyp ~cachetyp ~optyp:5 ~commutative:false ~idempotent:false
    ~op1:op1 ~op:op
    none4 (Obj.magic 1)

let register_existand
    ~(ddtyp:int)
    ~(cachetyp:'c local cache)
    ~(bottom:'a)
    (op : (('a,'a,'a) op2,'b) op)
    :
    (('a,'b) existand, 'c local) op
    =
  _internal_register_op ~ddtyp ~cachetyp ~optyp:6 ~commutative:false ~idempotent:false
    ~op1:(-1) ~op:op
    none4 (Obj.magic bottom)

let register_existandop1
    ~(ddtyp:int)
    ~(cachetyp:'c local cache)
    ~(bottom:'b)
    (op1 : (('a,'b) op1,'c) op)
    (op : (('b,'b,'b) op2,'d) op)
    :
    (('a,'b,'c,'d) existandop1, 'e local) op
    =
  _internal_register_op ~ddtyp ~cachetyp ~optyp:7 ~commutative:false ~idempotent:false
    ~op1:op1 ~op:op 
    none4 (Obj.magic bottom)

external op2_of_exist : (('a,'b) exist, 'c) op -> (('a,'a,'a) op2, 'b) op = "camlidl_cudd_rivdd_op2_of_exist"
external op2_of_existop1 : (('a,'b,'c,'d) existop1, 'e) op -> (('b,'b,'b) op2, 'd) op = "camlidl_cudd_rivdd_op2_of_exist"
external op2_of_existand : (('a,'b) existand, 'c local) op -> (('a,'a,'a) op2, 'b) op = "camlidl_cudd_rivdd_op2_of_exist"
external op2_of_existandop1 : (('a,'b,'c,'d) existandop1, 'e local) op -> (('b,'b,'b) op2, 'd) op = "camlidl_cudd_rivdd_op2_of_exist"

external op1_of_existop1 : (('a,'b,'c,'d) existop1, 'e) op -> (('a,'b) op1, 'c) op = "camlidl_cudd_rivdd_op1_of_existop1"
external op1_of_existandop1 : (('a,'b,'c,'d) existandop1, 'e local) op -> (('a,'b) op1, 'c) op = "camlidl_cudd_rivdd_op1_of_existop1"

let flush_op (op:('a,user local) op) : unit
    =
  _internal_flush_op op

external flush_allop : unit -> unit = "camlidl_cudd_rivdd_flush_allop"

let remove_localop (op:('a, 'b local) op) : unit
    =
    _internal_remove_op op

let remove_globalop (op:('a, global) op) : unit
    =
    _internal_remove_op op

let apply_op1 (op:(('a,'b) op1, 'c) op) (dd:'d) : 'e =
  _internal_map_op op [|dd|]

let apply_op2 (op:(('a,'b,'c) op2, 'd) op) (dd1:'e) (dd2:'f) : 'g =
  _internal_map_op op [|dd1; Obj.magic dd2|]

let (apply_test2 : (('a,'b) test2, 'c) op -> 'd -> 'e -> bool) = apply_op2

let apply_op3 (op:(('a,'b,'c,'d) op3, 'e local) op) (dd1:'f) (dd2:'g) (dd3:'h) : 'i =
  _internal_map_op op [|dd1;Obj.magic dd2;Obj.magic dd3|]

let apply_exist (op:(('a,'b) exist, 'c) op) ~(supp:Man.v Bdd.t) (dd:'d) : 'd =
  _internal_map_op op [|Obj.magic supp; dd|]

let apply_existop1 (op:(('a,'b,'c,'d) existop1, 'e) op) ~(supp:Man.v Bdd.t) (dd:'f) : 'g =
  _internal_map_op op [|Obj.magic supp; dd|]

let apply_existand (op:(('a,'b) existand, 'c local) op) ~(supp:Man.v Bdd.t) (bdd:Man.v Bdd.t) (dd:'d) : 'd =
  _internal_map_op op [|Obj.magic supp; Obj.magic bdd; dd|]

let apply_existandop1 (op:(('a,'b,'c,'d) existandop1, 'e local) op) ~(supp:Man.v Bdd.t) (bdd:Man.v Bdd.t) (dd:'f) : 'g =
  _internal_map_op op [|Obj.magic supp; Obj.magic bdd; dd|]

(*  ********************************************************************** *)
(** {2 Map operations (based on automatic local caches} *)
(*  ********************************************************************** *)

let map_op1 ~ddtyp op dd
    =
  let op = register_op1 ~ddtyp ~cachetyp:auto op in
  let res =
    try apply_op1 op dd
    with _ as exn ->
      remove_localop op;
      raise exn
  in
  remove_localop op; res


let map_op2
    ~ddtyp
    ?(commutative=false)
    ?(idempotent=false)
    ?absorbant1 ?absorbant2 ?neutral1 ?neutral2
    op dd1 dd2
    =
  let op = register_op2 ~ddtyp ~cachetyp:auto ~commutative ~idempotent ?absorbant1 ?absorbant2 ?neutral1 ?neutral2 op in
  let res =
    try apply_op2 op dd1 dd2
    with _ as exn ->
      remove_localop op;
      raise exn
  in
  remove_localop op; res

let map_test2
    ~ddtyp
    ?(commutative=false)
    ?(reflexive=false)
    ?bottom1 ?top2
    op dd1 dd2
    =
  let op = register_test2 ~ddtyp ~cachetyp:auto ~commutative ~reflexive ?bottom1 ?top2 op in
  let res =
    try apply_test2 op dd1 dd2
    with _ as exn ->
      remove_localop op;
      raise exn
  in
  remove_localop op; res

let map_op3 ~ddtyp op dd1 dd2 dd3
    =
  let op = register_op3 ~ddtyp ~cachetyp:auto op in
  let res =
    try apply_op3 op dd1 dd2 dd3
    with _ as exn ->
      remove_localop op;
      raise exn
  in
  remove_localop op; res

type ('a,'b) mexist = [
  | `Op of (('a,'a,'a) op2, 'b) op
  | `Fun of 'a fexist
]
and 'a fexist = {
  op : 'a -> 'a -> 'a;
  absorbant : ('a -> bool) option;
  neutral: ('a -> bool) option
}

type ('a,'b,'c) mop1 = [
  | `Op of (('a,'b) op1, 'c) op
  | `Fun of 'a -> 'b
]

type ('a,'b) sum2 = Res of 'a | Exn of 'b

let map_exist
    ~ddtyp
    (mexist:('a,'b) mexist) 
    ~supp dd
    =
  let (op2:(('a,'a,'a) op2,'b) op) = match mexist with
    | `Op op -> op
    | `Fun fexist ->
	let funabsorbant = match fexist.absorbant with
	  | None -> None
	  | Some f -> Some (fun leaf -> if f leaf then Some leaf else None)
	in
	register_op2 ~ddtyp ~cachetyp:auto ~commutative:true ~idempotent:true ?absorbant1:funabsorbant ?absorbant2:funabsorbant ?neutral1:fexist.neutral ?neutral2:fexist.neutral fexist.op
  in
  let exist = register_exist ~ddtyp ~cachetyp:auto op2 in
  let res =
    try Res(apply_exist exist ~supp dd)
    with _ as exn -> Exn(exn)
  in
  remove_localop exist;
  begin match mexist with `Fun _ -> remove_localop op2 | _ -> () end;
  match res with
  | Res res -> res
  | Exn exn -> raise exn

let map_existop1
    ~ddtyp
    (mop1:('a,'b,'c) mop1) 
    (mexist:('b,'d) mexist) 
    ~supp dd
    =
  let (op2:(('b,'b,'b) op2,'d) op) = match mexist with
    | `Op op -> op
    | `Fun fexist ->
	let funabsorbant = match fexist.absorbant with
	  | None -> None
	  | Some f -> Some (fun leaf -> if f leaf then Some leaf else None)
	in
	register_op2 ~ddtyp ~cachetyp:auto ~commutative:true ~idempotent:true ?absorbant1:funabsorbant ?absorbant2:funabsorbant ?neutral1:fexist.neutral ?neutral2:fexist.neutral fexist.op
  in
  let op1 = match mop1 with
    | `Op op -> op
    | `Fun op -> register_op1 ~ddtyp ~cachetyp:auto op
  in
  let existop1 = register_existop1 ~ddtyp ~cachetyp:auto op2 op1 in
  let res =
    try Res(apply_existop1 existop1 ~supp dd)
    with _ as exn -> Exn(exn)
  in
  remove_localop existop1;
  begin match mop1 with `Fun _ -> remove_localop op1 | _ -> () end;
  begin match mexist with `Fun _ -> remove_localop op2 | _ -> () end;
  match res with
  | Res res -> res
  | Exn exn -> raise exn

let map_existand
    ~ddtyp
    ~(bottom:'a)
    (mexist:('a,'b) mexist) 
    ~supp bdd dd
    =
  let (op2:(('a,'a,'a) op2,'b) op) = match mexist with
    | `Op op -> op
    | `Fun fexist ->
	assert(match fexist.neutral with Some (f) -> f bottom | None -> false);
	let funabsorbant = match fexist.absorbant with
	  | None -> None
	  | Some f -> Some (fun leaf -> if f leaf then Some leaf else None)
	in
	register_op2 ~ddtyp ~cachetyp:auto ~commutative:true ~idempotent:true ?absorbant1:funabsorbant ?absorbant2:funabsorbant ?neutral1:fexist.neutral ?neutral2:fexist.neutral fexist.op
  in
  let existand = register_existand ~ddtyp ~cachetyp:auto ~bottom op2 in
  let res =
    try Res(apply_existand existand ~supp bdd dd)
    with _ as exn -> Exn(exn)
  in
  remove_localop existand;
  begin match mexist with `Fun _ -> remove_localop op2 | _ -> () end;
  match res with
  | Res res -> res
  | Exn exn -> raise exn

let map_existandop1
    ~ddtyp
    ~(bottom:'b)
    (mop1:('a,'b,'c) mop1) 
    (mexist:('b,'d) mexist) 
    ~supp bdd dd
    =
  let (op2:(('b,'b,'b) op2,'d) op) = match mexist with
    | `Op op -> op
    | `Fun fexist ->
	assert(match fexist.neutral with Some (f) -> f bottom | None -> false);
	let funabsorbant = match fexist.absorbant with
	  | None -> None
	  | Some f -> Some (fun leaf -> if f leaf then Some leaf else None)
	in
	register_op2 ~ddtyp ~cachetyp:auto ~commutative:true ~idempotent:true ?absorbant1:funabsorbant ?absorbant2:funabsorbant ?neutral1:fexist.neutral ?neutral2:fexist.neutral fexist.op
  in
  let op1 = match mop1 with
    | `Op op -> op
    | `Fun op -> register_op1 ~ddtyp ~cachetyp:auto op
  in
  let existandop1 = register_existandop1 ~ddtyp ~cachetyp:auto ~bottom op2 op1 in
  let res =
    try Res(apply_existandop1 existandop1 ~supp bdd dd)
    with _ as exn -> Exn(exn)
  in
  remove_localop existandop1;
  begin match mop1 with `Fun _ -> remove_localop op1 | _ -> () end;
  begin match mexist with `Fun _ -> remove_localop op2 | _ -> () end;
  match res with
  | Res res -> res
  | Exn exn -> raise exn

