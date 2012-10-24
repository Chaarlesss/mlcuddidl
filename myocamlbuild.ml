
open Format;;

 (* Open the ocamlbuild world... *)
open Ocamlbuild_plugin;;
 (* We work with commands so often... *)
open Command;;

let dvipdf = try Sys.getenv "DVIPDF" with _ -> "dvipdf"
let makeindex = try Sys.getenv "MAKEINDEX" with _ -> "makeindex"
let latex = try Sys.getenv "LATEX" with _ -> "latex"
let camlidl = try Sys.getenv "CAMLIDL" with _ -> "camlidl"
let m4 = try Sys.getenv "M4" with _ -> "m4"
let sed = try Sys.getenv "SED" with _ -> "sed"
let ccopts = Sys.getenv "CCOPTS";;

let ocamldoc_rules () =
  rule "ocamldoc: document ocaml project odocl & odoci (intro) & *odoc -> docdir (html)"
    ~insert:`top
    ~deps:["%.odocl"; "%.odoci"]
    ~prod:"%.docdir/index.html"
    ~stamp:"%.docdir/html.stamp"
    (begin fun env build ->
      let odoc_load = env "%.odocl" in
      let odoc_intro = env "%.odoci" in
      let docout = env "%.docdir/index.html" in
      let docdir = env "%.docdir" in
      let contents = string_list_of_file odoc_load in
      let dirname = Pathname.dirname odoc_load in
      let include_dirs = Pathname.include_dirs_of dirname in
      let to_build =
	List.map
	  begin fun module_name ->
	    expand_module include_dirs module_name ["odoc"]
	  end
	  contents
      in
      let odoc_paths = List.map Outcome.good (build to_build) in
      let tags = (Tags.union (tags_of_pathname docout) (tags_of_pathname docdir))++"ocaml" in
      Seq[Cmd (S[A"rm"; A"-rf"; Px docdir]);
	  Cmd (S[A"mkdir"; A"-p"; Px docdir]);
	  Cmd (S [!Options.ocamldoc;
		  S(List.map (fun a -> S[A"-load"; P a]) odoc_paths);
		  S([A"-intro";P odoc_intro]);
		  T(tags++"doc"++"docdir"); A"-d"; Px docdir])]
     end)
  ;
  rule "latex: document ocaml project odocl & *odoc -> tex"
    ~insert:`top
    ~dep:"%.odocl"
    ~prods:["%_ocamldoc.tex";"ocamldoc.sty"]
    (begin fun env build ->
      let odoc_load = env "%.odocl" in
      let odoc_tex = env "%_ocamldoc.tex" in
      let contents = string_list_of_file odoc_load in
      let dirname = Pathname.dirname odoc_load in
      let include_dirs = Pathname.include_dirs_of dirname in
      let to_build =
	List.rev_map
	  begin fun module_name ->
	    expand_module include_dirs module_name ["odoc"]
	  end
	  contents
      in
      let odoc_paths = List.map Outcome.good (build to_build) in
      let tags = (tags_of_pathname odoc_load)++"ocaml" in
      Cmd (S [!Options.ocamldoc;
	      S(List.map (fun a -> S[A"-load"; P a]) odoc_paths);
	      S([A"-noheader";A"-notrailer";A"-latextitle";A"1,part"; A"-latextitle";A"2,chapter"; A"-latextitle"; A"3,section"; A"-latextitle"; A"4,subsection"; A"-latextitle"; A"5,subsubsection"; A"-latextitle"; A"6,paragraph"; A"-latex"]);
	      T(tags++"doc"); A"-o"; Px odoc_tex]);
     end);
  rule "latex: _ocamldoc.tex & tex -> dvi"
    ~insert:`top
    ~deps:["%_ocamldoc.tex"; "%.tex"]
    ~prod:"%.dvi"
    (begin fun env build ->
      let odoc_tex = env "%.tex" in
      let dvi = env "%.dvi" in
      let tags = (tags_of_pathname dvi)++"latex"++"dvi" in
      let cmd =  Cmd (S [A latex; T tags; A"-interaction=nonstopmode"; P odoc_tex]) in
      let cmd_index = Cmd (S [A makeindex; P (env "%")]) in
      Seq[cmd;cmd_index;cmd;cmd]
     end);
  rule "latex: dvi -> pdf"
    ~dep:"%.dvi"
    ~prod:"%.pdf"
    (begin fun env build ->
      let dvi = env "%.dvi" in
      let pdf = env "%.pdf" in
      let tags = (tags_of_pathname pdf)++"dvipdf" in
      let cmd =  Cmd (S [A dvipdf; T tags; P dvi]) in
      cmd
     end);
  ()

let ocamlpack_rules () =
  let generic suffix env build =
    let mlpack = env "%.mlpack" in
    let contents = string_list_of_file mlpack in
    let dirname = Pathname.dirname mlpack in
    let include_dirs = Pathname.include_dirs_of dirname in
    let to_build =
      List.map
	begin fun module_name ->
	  expand_module include_dirs module_name [suffix]
	end
	contents
    in
    let ml_paths = List.map Outcome.good (build to_build) in
    Cmd (S [A"sh"; P "ocamlpack";
	    A"-o"; Px (env "%.mli");
	    A"-intro"; P (env "%.mlpacki");
	    A"-level"; A"2";
	    S(List.map (fun a -> P a) ml_paths)])
  in
  rule "ocamlpack: ocamlpack & mlpack & mlpacki & mli* -> mli"
    ~tags:["ocamlpack"]
    ~deps:["ocamlpack"; "%.mlpack"; "%.mlpacki"]
    ~prod:"%.mli"
    (generic "mli")
  ;
  rule "ocamlpack: ocamlpack mlpack & mlpacki & ml* -> ml"
    ~tags:["ocamlpack"]
    ~deps:["ocamlpack"; "%.mlpack"; "%.mlpacki"]
    ~prod:"%.ml"
    (generic "ml")
  ;
  ()

let m4_rules () =
  rule "m4: macros.m4 & _caml.c.m4 -> _caml.c"
    ~deps:["macros.m4"; "%_caml.c.m4"]
    ~prod:"%_caml.c"
    (begin fun env build ->
      let target = env "%_caml.c" in
      Seq [
	rm_f target;
	Cmd (S[
	  A m4; P (env "macros.m4"); P (env "%_caml.c.m4"); Sh ">"; Px target
	])
      ]
     end);
  ()

let camlidl_rules () =
  rule "camlidl: .idl & idl* & macros.m4 -> _tmp.ml _tmp.mli _tmp_stubs.c"
    ~deps:["%.idl";
	   "add.idl";
	   "bdd.idl";
	   "vdd.idl";
	   "zdd.idl";
	   "cache.idl";
	   "hash.idl";
	   "memo.idl";
	   "man.idl";
	   "custom.idl";
	   "macros.m4"]
    ~prods:["%_tmp.ml"; "%_tmp.mli"; "%_tmp_stubs.c"]
    (begin fun env build ->
      let idl = env "%.idl" in
      let macrosm4 = env "macros.m4" in
      let tmpidl = env "%_tmp.idl" in
      let cmd =
	Seq [
	  (cp idl tmpidl);
	  Cmd (S[
	    A camlidl; A"-no-include"; A"-prepro"; A (Format.sprintf "%s %s" m4 macrosm4);
	    P tmpidl
	  ])
	]
      in
      cmd
     end)
  ;
  let generic suffix env build =
    let tmpml = env ("%_tmp."^suffix) in
    let sedscriptml = env "sedscript_caml" in
    let ml = env ("%."^suffix) in
    Seq [
      (rm_f ml);
      Cmd (S[A sed; A"-f"; P sedscriptml; P tmpml; Sh ">"; Px ml])
    ]
  in
  rule "sed: _tmp.ml & sedscript_caml -> .ml"
    ~deps:["%_tmp.ml"; "sedscript_caml"]
    ~prod:"%.ml"
    (generic "ml")
  ;
  rule "sed: _tmp.mli & sedscript_caml -> .mli"
    ~deps:["%_tmp.mli"; "sedscript_caml"]
    ~prod:"%.mli"
    (generic "mli")
  ;
  rule "sed: _tmp_stubs.c & sedscript_caml -> _caml.c"
    ~deps:["%_tmp_stubs.c"; "sedscript_c"]
    ~prod:"%_caml.c"
    (begin fun env build ->
      let tmpc = env "%_tmp_stubs.c" in
      let sedscriptc = env "sedscript_c" in
      let c = env "%_caml.c" in
      Seq [
	(rm_f c);
	Cmd (S[A sed; A"-f"; P sedscriptc; P tmpc; Sh ">"; Px c])
      ]
     end);
  ()


let print_list
    ?(first=("[@[":(unit,Format.formatter,unit) format))
    ?(sep = (";@ ":(unit,Format.formatter,unit) format))
    ?(last = ("@]]":(unit,Format.formatter,unit) format))
    (print_elt: Format.formatter -> 'a -> unit)
    (fmt:Format.formatter)
    (list: 'a list)
    : unit
    =
  if list=[] then begin
    fprintf fmt first;
    fprintf fmt last;
  end
  else begin
    fprintf fmt first;
    let rec do_sep = function
    [e] -> print_elt fmt e
      | e::l -> (print_elt fmt e ; fprintf fmt sep; do_sep l)
      | [] -> failwith ""
    in
    do_sep list;
    fprintf fmt last;
  end

let c_rules () =
  let link_C_library clib a libname env build =
    let clib = env clib and a = env a and libname = env libname in
    let objs = string_list_of_file clib in
    if true then
      printf "************@.clib=%s, a=%s, libname=%s@.objs = %a@."
	clib a libname (print_list pp_print_string) objs
    ;
    let include_dirs = Pathname.include_dirs_of (Pathname.dirname a) in
    let obj_of_o x =
      if Filename.check_suffix x ".o" && !Options.ext_obj <> "o" then
	Pathname.update_extension !Options.ext_obj x
      else x
    in
    let objs =
      List.map
	(fun o -> List.map (fun dir -> dir / obj_of_o o) include_dirs)
	objs
    in
    let resluts = build objs in
    let objs = List.map Outcome.good resluts in
    Cmd(S[!Options.ocamlmklib; A"-o"; Px libname; T(tags_of_pathname a++"c"++"ocamlmklib"); atomize objs])
  in

  rule "ocaml C stubs (mine): clib & (o|obj)* -> (a|lib) & (so|dll)"
    ~insert:`top
    ~prods:["%(path:<**/>)lib%(libname:<*> and not <*.*>)"-.-(!Options.ext_lib);
	    "%(path:<**/>)dll%(libname:<*> and not <*.*>)"-.-(!Options.ext_dll)]
    ~dep:"%(path)lib%(libname).clib"
    (link_C_library
       "%(path)lib%(libname).clib" ("%(path)lib%(libname)"-.-(!Options.ext_lib))
       "%(path)%(libname)")
  ;
  ()

(* This dispatch call allows to control the execution order of your
   directives. *)
let _ = dispatch begin function
  (*c Here one can add or override new rules *)
  | After_rules ->
      (*c Here we make an extension of any rule that produces a command
	containing these tags. *)
      ocamldoc_rules ();
      ocamlpack_rules();
      m4_rules();
(*
      c_rules();
*)
       (* C compile flags *)
      flag ["c"; "compile"] & S[Sh ccopts];
      (* libs *)
      ocaml_lib ~extern:true "cudd";
      dep ["link";"use_cudd"] ["libcudd.a"];
      flag ["c"; "ocamlmklib"; "file:libcudd.a"] & S[A"-ccopt";A"-L."];
(*    flag ["link"; "library"; "ocaml"; "use_cudd"] (S[A"-cclib"; A"-L."]);
*)
      ()
  | _ -> ()
end
