
type 'a boolean
type ('a, 'b) conj
type pos
type any
type var
type +'a value

type ('a, 'b) t
type ('a, 'b) bdd  = ('a, 'b boolean) t
type ('a, 'b) avdd = ('a, 'b value  ) t

(* All the following types implictly includes the case of constant values (false and true) *)
type ('a, 'b, 'c) cube = ('a, ('b,  'c)  conj) bdd
type ('a, 'c) literal  = ('a, (var, 'c)  conj) bdd
type ('a, 'b) supp     = ('a, ('b,  pos) conj) bdd
type 'a atom =           ('a, (var, pos) conj) bdd

type add    = (Man.d, float) avdd
type 'a vdd = (Man.v, 'a   ) avdd

external manager : ('a, 'b) t -> 'a Man.t = "cudd_caml_manager"
external is_cst : ('a, 'b) t -> bool = "cudd_caml_Cudd_IsConstant" "noalloc"
external topvar : ('a, 'b) t -> int = "cudd_caml_Cudd_NodeReadIndex"
external support : ('a, 'b) t -> ('a,any) supp = "cudd_caml_Cuddaux_Support"
external supportsize : ('a, 'b) t -> int = "cudd_caml_Cuddaux_SupportSize"
external is_var_in : int -> ('a, 'b) t -> bool = "cudd_caml_Cuddaux_is_var_in"
external vectorsupport : ('a, 'b) t array -> ('a,'c) supp = "cudd_caml_vectorsupport"
external size : ('a, 'b) t -> int = "cudd_caml_Cudd_DagSize"
external nbleaves : ('a, 'b) t -> int = "cudd_caml_Cudd_CountLeaves"
external nbpaths : ('a, 'b) t -> float = "cudd_caml_Cudd_CountPaths"
external nbminterms : nbvars:int -> ('a, 'b) t -> float = "cudd_caml_Cudd_CountMinterm"
external density : nbvars:int -> ('a, 'b) t -> float = "cudd_caml_Cudd_Density"

external is_equal : ('a, 'b) t -> ('a, 'c) t -> bool = "cudd_caml_is_equal"
external is_equal_when : ('a, 'b) t -> ('a, 'c) t -> care:('a, 'd) bdd -> bool = "cudd_caml_bdd_is_equal_when" 

external list_of_support: ('a,'b) supp -> int list = "cudd_caml_list_of_support"
external list_of_cube: ('a,'b,'c) cube -> (int*bool) list = "cudd_caml_list_of_cube"
external minterm_of_cube: ('a,'b,'c) cube -> Man.tbool array = "cudd_caml_minterm_of_cube"
external cube_of_minterm: 'a Man.t -> Man.tbool array -> ('a, any, any) cube = "cudd_caml_cube_of_minterm"

external cofactors : is_bdd:bool -> int -> ('a, 'b) t -> ('a,'b) t * ('a,'b) t = "cudd_caml_cofactors"
external ite_cst : is_bdd:bool -> ('a, 'b) bdd -> ('a, 'c) t -> ('a, 'd) t -> ('a, 'e) t option = "cudd_caml_ite_cst"
external is_ite_cst : is_bdd:bool -> ('a, 'b) bdd -> ('a, 'c) t -> ('a, 'd) t -> bool = "cudd_caml_ite_cst"
external varmap : is_bdd:bool -> ('a, 'b) t -> ('a, 'b) t = "camlidl_cudd_varmap"
external _permute : is_bdd:bool -> ?memo:Memo.t -> perm:int array -> ('a, 'b) t -> ('a, 'b) t = "camlidl_cudd_permute_memo"
let permute ~is_bdd ?memo ~perm vdd =
  begin match memo with
  | Some memo ->
      let arity = match memo with
      | Memo.Global -> 1
      | Memo.Cache x -> Cache.arity x
      | Memo.Hash x -> Hash.arity x
      in
      if arity<>1 then
	raise (Invalid_argument "Cudd.Vdd.permute: memo.arity<>1")
      ;
  | None ->
      ()
  end;
  _permute ~is_bdd ?memo ~perm vdd

external compose : is_bdd:bool -> var:int -> f:('a, 'b) bdd -> ('a, 'c) t -> ('a, 'd) t = "cudd_caml_compose"
external _vectorcompose : is_bdd:bool -> ?memo:Memo.t -> ('a, 'b) bdd array -> ('a, 'c) t -> ('a, 'd) t = "cudd_caml_vectorcompose_memo"

let vectorcompose ~is_bdd ?memo tbdd dd =
  begin match memo with
  | Some(memo) ->
      let arity = match memo with
      | Memo.Global -> 1
      | Memo.Cache x -> Cache.arity x
      | Memo.Hash x -> Hash.arity x
      in
      if arity<>1 then
	raise (Invalid_argument "Cudd.Bdd.vectorcompose_memo: memo.arity<>1")
      ;
  | None -> ()
  end;
  _vectorcompose ~is_bdd ?memo tbdd dd
external iter_node : is_bdd:bool -> (('a,'b) t -> unit) -> ('a,'b) t -> unit = "cudd_caml_iter_node"
external transfer : is_bdd:bool -> ('a,'c) t -> man:'b Man.t -> ('b,'c) t = "cudd_caml_transfer"

module B = struct
  let (genatom : 'a atom -> ('a,'b) bdd) = Obj.magic
  let (genliteral : ('a,'b) literal -> ('a,'c) bdd) = Obj.magic
  let (gensupp : ('a,'b) supp -> ('a,'c) bdd) = Obj.magic
  let (gencube : ('a,'b,'c) cube -> ('a,'d) bdd) = Obj.magic

  external binop : int -> ('a,'b) t -> ('a,'c) t -> ('a,'d) bdd = "cudd_caml_bdd_binop"
  let (gcofactor:('a, 'b) bdd -> ('a, 'c, 'd) cube -> ('a,'b) bdd) = fun x cube -> binop 0 x cube
  let (cofactor:('a, 'b) bdd -> cube:('a, 'c, 'd) cube -> ('a,'b) bdd) = fun x ~cube -> binop 0 x cube

  let (supp_inter : ('a, 'b) supp -> ('a, 'c) supp -> ('a,any) supp) = fun x1 x2 -> binop 1 x1 x2
  let (gand : ('a,'b) bdd -> ('a,'c) bdd -> ('a,'d) bdd) = fun x1 x2 -> binop 2 x1 x2
  let (dand : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd) = gand
  let (dor : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd) = fun x1 x2 -> binop 3 x1 x2
  let (xor : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd) = fun x1 x2 -> binop 4 x1 x2
  let (intersect : ('a,'b) bdd -> ('a,'c) bdd -> ('a,any) bdd) = fun x1 x2 -> binop 5 x1 x2
  let (exist : supp:('a,'c) supp -> ('a,'b) bdd -> ('a,'b) bdd) = fun ~supp x -> binop 6 x supp
  let (forall : supp:('a,'c) supp -> ('a,'b) bdd -> ('a,'b) bdd) = fun ~supp x -> binop 7 x supp
  let (constrain : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd) = fun x ~care -> binop 8 x care
  let (tdconstrain : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd) = fun x ~care -> binop 9 x care
  let (restrict : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd) = fun x ~care -> binop 10 x care
  let (tdrestrict : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd) = fun x ~care -> binop 11 x care
  let (minimize : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd) = fun x ~care -> binop 12 x care
  let (licompaction : ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd) = fun x ~care -> binop 13 x care
  let (squeeze: ('a,'b) bdd -> care:('a,'c) bdd -> ('a,any) bdd) = fun x ~care -> binop 14 x care
  let (cube_or : ('a,'b,'c) cube -> ('a,'d,'e) cube -> ('a,any,any) cube) = fun x1 x2 -> binop 15 x1 x2
  let (guard_of_node : ('a,'b) avdd -> node:('a,'b) avdd -> ('a,any) bdd) = fun x ~node -> binop 16 x node

  external terop : int -> ('a,'b) bdd -> ('a,'c) bdd -> ('a,'d) bdd -> ('a,'e) bdd = "cudd_caml_bdd_terop"
  let ite x1 x2 x3 : ('a,any) bdd = terop 0 x1 x2 x3
  let existand ~(supp:('a,'b) supp) x1 x2 : ('a,any) bdd = terop 1 x1 x2 supp
  let existxor ~(supp:('a,'b) supp) x1 x2 : ('a,any) bdd = terop 2 x1 x2 supp

  external decomp: int -> ('a, 'b) bdd -> (('a, any) bdd * ('a, any) bdd) option = "cudd_caml_bdd_decomp"
  let approxconjdecomp x = decomp 0 x    
  let iterconjdecomp x = decomp 1 x    
  let genconjdecomp x = decomp 2 x    
  let varconjdecomp x = decomp 3 x    
  let approxdisjdecomp x = decomp 4 x    
  let iterdisjdecomp x = decomp 5 x    
  let gendisjdecomp x = decomp 6 x    
  let vardisjdecomp x = decomp 7 x    

  external dthen : ('a, 'b) bdd -> ('a, 'b) bdd = "cudd_caml_bdd_Cudd_T"
  external delse : ('a, 'b) bdd -> ('a, 'b) bdd = "cudd_caml_bdd_Cudd_E"

  external dtrue : 'a Man.t -> 'a atom = "cudd_caml_bdd_dtrue"
  external dfalse : 'a Man.t -> 'a atom = "cudd_caml_bdd_dfalse"
  external ithvar : 'a Man.t -> int -> 'a atom = "cudd_caml_bdd_Cudd_bddIthVar"
  external newvar : 'a Man.t -> 'a atom = "cudd_caml_bdd_Cudd_bddNewVar"
  external newvar_at_level : 'a Man.t -> int -> 'a atom = "cudd_caml_bdd_Cudd_bddNewVarAtLevel"
    
  external dnot : ('a, 'b) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_Not"
  external vnot : ('a,'c) literal -> ('a,any) literal = "cudd_caml_bdd_Cudd_Not"
   
  external is_complement : ('a, 'b) bdd -> bool = "cudd_caml_bdd_Cudd_IsComplement" "noalloc"
  external is_true : ('a, 'b) bdd -> bool = "cudd_caml_bdd_is_true" "noalloc"
  external is_false : ('a, 'b) bdd -> bool = "cudd_caml_bdd_is_false" "noalloc"
  external is_leq : ('a, 'b) bdd -> ('a, 'c) bdd -> bool = "cudd_caml_bdd_Cudd_bddLeq" 
  external is_inter_empty : ('a, 'b) bdd -> ('a, 'c) bdd -> bool = "cudd_caml_bdd_is_inter_empty" 
  let is_included_in = is_leq
  external is_leq_when : ('a, 'b) bdd -> ('a, 'c) bdd -> care:('a, 'd) bdd -> bool = "cudd_caml_bdd_is_leq_when"
  external is_var_dependent : int -> ('a, 'b) bdd -> bool = "cudd_caml_bdd_is_var_dependent"
  let is_var_essential (id,b) bdd = 
    is_leq bdd (let v = ithvar (manager bdd) id in if b then genatom v else vnot v)

  let nand x1 x2 = dnot (dand x1 x2)
  let nor x1 x2 = dnot (dor x1 x2)
  let nxor x1 x2 = dnot (xor x1 x2)
  let eq = nxor
    
  external cube_of_bdd: ('a, 'b) bdd -> ('a, any, any) cube = "cudd_caml_bdd_Cudd_FindEssential"

  external booleandiff : ('a, 'b) bdd -> int -> ('a, any) bdd = "cudd_caml_bdd_Cudd_BooleandDiff"
  let (cofactors : int -> ('a, 'b) bdd -> ('a, 'b) bdd * ('a, 'b) bdd) = fun x1 x2 -> cofactors ~is_bdd:true x1 x2
  let ite_cst (x1:('a,'b) bdd) (x2:('a,'c) bdd) (x3:('a,'d) bdd) : ('a,any) bdd option = ite_cst ~is_bdd:true x1 x2 x3
  let is_ite_cst (x1:('a,'b) bdd) (x2:('a,'c) bdd) (x3:('a,'d) bdd) = is_ite_cst ~is_bdd:true x1 x2 x3
  let varmap (x:('a,'b) bdd) : ('a,'b) bdd = varmap ~is_bdd:true x
  let permute ?memo ~perm (x:('a,'b) bdd) : ('a,'b) bdd = permute ~is_bdd:true ?memo ~perm x
  let compose ~var ~f (x:('a,'b) bdd) : ('a,any) bdd = compose ~is_bdd:true ~var ~f x
  let iter_node (f:('a,'b) bdd -> unit) (x:('a,'c) bdd) = iter_node ~is_bdd:true f x
  let (transfer : ('a,'c) bdd -> man:'b Man.t -> ('b,'c) bdd) = fun x ~man -> transfer ~is_bdd:true x ~man
 
  let (supp_union:('a, 'b) supp -> ('a, 'c) supp -> ('a,any) supp) = gand
  let (supp_diff:('a, 'b) supp -> ('a, 'c) supp -> ('a,'b) supp) = gcofactor
  let (cube_and : ('a,'b,'c) cube -> ('a,'d,'e) cube -> ('a,any,any) cube) = gand
  let cube_union = cube_or

  external nbtruepaths : ('a, 'b) bdd -> float = "cudd_caml_bdd_Cudd_CountPathsToNonZero"
  external pick_minterm : ('a, 'b) bdd -> Man.tbool array = "cudd_caml_pick_minterm"
  external pick_cube_on_support : supp:('a,'b) supp -> ('a, 'c) bdd -> ('a,any,any) cube = "cudd_caml_pick_cube_on_support"
  external pick_cubes_on_support : supp:('a,'b) supp -> nb:int -> ('a, 'c) bdd -> ('a,any,any) cube array = "cudd_caml_pick_cubes_on_support"

  external iter_cube: (Man.tbool array -> unit) -> ('a, 'b) bdd -> unit = "cudd_caml_bdd_iter_cube"
  external iter_prime: (Man.tbool array -> unit) -> lower:('a, 'b) bdd -> upper:('a, 'c) bdd -> unit = "cudd_caml_bdd_iter_prime"

  type approx = Under | Over
  external clippingand : depth:int -> approx:approx -> ('a, 'b) bdd -> ('a, 'c) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_bddClippingAnd"
  external clippingexistand : depth:int -> approx:approx -> supp:('a,'b) supp -> ('a, 'b) bdd -> ('a, 'c) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_bddClippingAndAbstract"

  external underapprox : nbvars:int -> threshold:int -> safe:bool -> quality:float -> ('a, 'b) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_UnderApprox"
  external remapunderapprox : nbvars:int -> threshold:int -> quality:float -> ('a, 'b) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_RemapUnderApprox"
  external biasedunderapprox : nbvars:int -> threshold:int -> quality_true:float -> quality_false:float -> bias:('a,'b) bdd -> ('a, 'c) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_BiasedUnderApprox_bytecode" "cudd_caml_bdd_Cudd_BiasedUnderApprox"
  let overapprox ~nbvars ~threshold ~safe ~quality x = dnot (underapprox ~nbvars ~threshold ~safe ~quality (dnot x))
  let remapoverapprox ~nbvars ~threshold ~quality x = dnot (remapunderapprox ~nbvars ~threshold ~quality (dnot x))
  let biasedoverapprox ~nbvars ~threshold ~quality_true ~quality_false ~bias x = dnot (biasedunderapprox ~nbvars ~threshold ~quality_true ~quality_false ~bias (dnot x))
    
  external subsetcompress : nbvars:int -> threshold:int -> ('a, 'b) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_SubsetCompress"
  external subsetHB : nbvars:int -> threshold:int -> ('a, 'b) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_subsetHB"
  external subsetSP : nbvars:int -> threshold:int -> hardlimit:bool -> ('a, 'b) bdd -> ('a, any) bdd = "cudd_caml_bdd_Cudd_subsetSP"
  let supersetcompress ~nbvars ~threshold x = dnot (subsetcompress ~nbvars ~threshold (dnot x))
  let supersetHB ~nbvars ~threshold x = dnot (subsetHB ~nbvars ~threshold (dnot x))
  let supersetSP ~nbvars ~threshold ~hardlimit x = dnot (subsetSP ~nbvars ~threshold ~hardlimit (dnot x))

  external correlation : ('a, 'b) bdd -> ('a, 'c) bdd -> float = "cudd_caml_bdd_Cudd_bddCorrelation"
  external correlationweights : ('a, 'b) bdd -> ('a, 'c) bdd -> weights:float array -> float = "cudd_caml_bdd_Cudd_bddCorrelationeights"

end

module AV = struct
  external binop : int -> ('a, 'b) t -> ('a, 'c) t -> ('a,'d) avdd = "cudd_caml_avdd_binop"
  let cofactor (x:('a,'b) avdd) ~(cube:('a, 'c, 'd) cube) : ('a,'b) avdd = binop 0 x cube
  let constrain (x:('a,'b) avdd) ~(care:('a,'c) bdd) : ('a,'b) avdd = binop 1 x care
  let tdconstrain (x:('a,'b) avdd) ~(care:('a,'c) bdd) : ('a,'b) avdd = binop 2 x care
  let restrict (x:('a,'b) avdd) ~(care:('a,'c) bdd) : ('a,'b) avdd = binop 3 x care
  let tdrestrict (x:('a,'b) avdd) ~(care:('a,'c) bdd) : ('a,'b) avdd = binop 4 x care

  external dthen : ('a,'b) avdd -> ('a,'b) avdd = "cudd_caml_avdd_cuddT"
  external delse : ('a,'b) avdd -> ('a,'b) avdd = "cudd_camla_avdd_cuddE"
  external dval : ('a,'b) avdd -> 'b = "cudd_caml_avdd_dval"
  external cst : 'a Man.t -> 'b -> ('a,'b) avdd = "camlidl_cudd_avdd_cst"
  external ite : ('a, 'b) bdd -> ('a,'c) avdd -> ('a,'c) avdd -> ('a,'c) avdd = "camlidl_cudd_avdd_Cuddaux_addIte_ite"
  external eval_cst : care:('a, 'c) bdd -> ('a,'b) avdd -> ('a,'b) avdd option = "camlidl_cudd_avdd_eval_cst"
  let is_eval_cst dd ~care = match eval_cst dd ~care with
  | None -> false
  | Some x -> is_cst x

  let (cofactors : int -> ('a,'b) avdd -> ('a,'b) avdd * ('a,'b) avdd) = fun x1 x2 -> cofactors ~is_bdd:false x1 x2
  let ite_cst (x1:('a,'b) bdd) (x2:('a,'c) avdd) (x3:('a,'c) avdd) : ('a,'c) avdd option =
    ite_cst ~is_bdd:false x1 x2 x3
  let is_ite_cst (x1:('a,'b) bdd) (x2:('a,'c) avdd) (x3:('a,'c) avdd) =
    is_ite_cst ~is_bdd:false x1 x2 x3
  let varmap (x:('a,'b) avdd) : ('a,'b) avdd = varmap ~is_bdd:false x
  let permute ?memo ~perm (x:('a,'b) avdd) : ('a,'b) avdd = permute ~is_bdd:false ?memo ~perm x
  let compose ~var ~f (x:('a,'b) avdd) : ('a,'b) avdd = compose ~is_bdd:false ~var ~f x
  let iter_node (f:('a,'b) avdd -> unit) (x:('a,'b) avdd) = iter_node ~is_bdd:false f x
  let (transfer : ('a,'c) avdd -> man:'a Man.t -> ('a,'c) avdd) = fun x ~man -> transfer ~is_bdd:false x ~man

  external iter_cube: (Man.tbool array -> 'b) -> ('a,'b) avdd -> unit = "cudd_caml_avbdd_iter_cube"

  let guard_of_node = B.guard_of_node
  external guard_of_nonbackground : ('a,'b) avdd -> ('a,any) bdd = "cudd_caml_avdd_guard_of_nonbackground"
  external nodes_below_level: ?level:int -> ?max:int -> ('a,'b) avdd -> ('a,'b) avdd array = "camlidl_cudd_avdd_nodes_below_level"
  external guard_of_leaf : ('a,'b) avdd -> 'b -> ('a,any) bdd = "camlidl_cudd_avdd_guard_of_leaf"
  external leaves: ('a,'b) avdd -> 'b array = "camlidl_cudd_avdd_leaves"
  external pick_leaf : ('a,'b) avdd -> 'b = "camlidl_cudd_avdd_pick_leaf"
  let guardleafs add =
    let tab = leaves add in
    Array.map (fun leaf -> (guard_of_leaf add leaf,leaf)) tab
end

module A = struct
  external binop : int -> add -> add -> add = "cudd_caml_add_binop"
  let add (x1:add) (x2:add) : add = binop 0 x1 x2
  let sub (x1:add) (x2:add) : add = binop 1 x1 x2
  let mul (x1:add) (x2:add) : add = binop 2 x1 x2
  let div (x1:add) (x2:add) : add = binop 3 x1 x2
  let min (x1:add) (x2:add) : add = binop 4 x1 x2
  let max (x1:add) (x2:add) : add = binop 5 x1 x2
  let agreement (x1:add) (x2:add) : add = binop 6 x1 x2
  let diff (x1:add) (x2:add) : add = binop 7 x1 x2
  let threshold (x1:add) (x2:add) : add = binop 8 x1 x2
  let setNZ (x1:add) (x2:add) : add = binop 9 x1 x2

  external binop2 : int -> supp:(Man.d,'a) supp -> add -> add = "cudd_caml_add_binop2"
  let exist ~supp x = binop2 0 ~supp x
  let forall ~supp x = binop2 1 ~supp x

  external matop : int -> int array -> add -> add -> add = "cudd_caml_add_matop"
  let matrix_multiply tab x1 x2 = matop 0 tab x1 x2
  let times_plus tab x1 x2 = matop 0 tab x1 x2
  let triangle tab x1 x2 = matop 0 tab x1 x2

  external neg : add -> add = "cudd_caml_add"
  external log : add -> add = "cudd_caml_add_log"
  external is_leq : add -> add -> bool = "cudd_caml_add_Cudd_addLeq"
  external nbnonzeropaths : add -> float = "cudd_caml_bdd_Cudd_CountPathsToNonZero"
  external of_bdd : (Man.d,'a) bdd -> add = "camlidl_cudd_add_Cudd_BddToAdd"
  external to_bdd : add -> (Man.d,any) bdd = "camlidl_cudd_add_Cudd_addBddPattern"
  external to_bdd_threshold : add -> threshold:float -> (Man.d,any) bdd = "camlidl_cudd_add_Cudd_addBddThreshold"
  external to_bdd_strictthreshold : add -> threshold:float -> add = "camlidl_cudd_add_Cudd_addBddStrictThreshold"
  external to_bdd_interval : add -> lower:float -> upper:float -> add = "camlidl_cudd_add_Cudd_addBddIntervall"
end
