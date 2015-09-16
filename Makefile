-include Makefile.config
PKGNAME = mlcuddidl
PKGVERS = 2.3.0

#---------------------------------------
# Directories
#---------------------------------------

CUDDDIR = cudd-2.5.1
SRCDIR = $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
#
# Installation directory
#
SITE-LIB = $(shell $(OCAMLFIND) printconf destdir)
PKG-NAME = cudd
SITE-LIB-PKG = $(SITE-LIB)/$(PKG-NAME)

#---------------------------------------
# C part
#---------------------------------------

CUDDLIBS = cudd mtr epd st util

ICFLAGS = $(addprefix -I$(CUDDDIR)/,$(CUDDLIBS)) \
	  -I$(CAML_DIR) -I$(CAMLIDL_DIR)
LDFLAGS = -L$(CAMLIDL_DIR) -lcamlidl

#---------------------------------------
# Files
#---------------------------------------

IDLMODULES = hash cache memo man bdd vdd custom add

MLMODULES = hash cache memo man bdd vdd custom weakke pWeakke mtbdd mtbddc user mapleaf add

CCMODULES = \
	cuddauxAddCamlTable cuddauxAddIte cuddauxBridge cuddauxCompose \
	cuddauxGenCof cuddauxMisc cuddauxUtil \
	cuddauxTDGenCof cuddauxAddApply \
	$(IDLMODULES:%=%_caml) cudd_caml

LIBNAMES = cudd_caml
BASELIBS = $(addprefix $(LIBNAMES:%=lib%),.a)
DEBGLIBS = $(addprefix $(LIBNAMES:%=lib%),.d.a)
PROFLIBS = $(addprefix $(LIBNAMES:%=lib%),.p.a)
ifneq ($(HAS_SHARED),)
  BASELIBS += $(addprefix $(LIBNAMES:%=dll%),.so)
  DEBGLIBS += $(addprefix $(LIBNAMES:%=dll%),.d.so)
endif
CCLIB = $(BASELIBS) $(DEBGLIBS) $(PROFLIBS)

FILES_TOINSTALL = META \
	$(CUDDDIR)/cudd/cudd.h $(CUDDDIR)/cudd/cuddInt.h \
	$(CUDDDIR)/mtr/mtr.h \
	$(CUDDDIR)/epd/epd.h \
	$(CUDDDIR)/st/st.h \
	$(CUDDDIR)/util/util.h \
	cuddaux.h cudd_caml.h \
	$(IDLMODULES:%=%.idl) \
	cudd.cmi cudd.cma cudd.d.cma \
	cudd.cmx cudd.cmxa cudd.a \
	cudd.d.cmxa cudd.d.a \
	cudd.p.cmx cudd.p.cmxa cudd.p.a \
	$(CCLIB)

ifneq ($(OCAMLPACK),)
FILES_TOINSTALL += cudd_ocamldoc.mli
endif

#---------------------------------------
# Rules
#---------------------------------------

# Global rules
all: $(FILES_TOINSTALL)

# Example of compilation command with ocamlfind
%.byte: %.ml
	$(OCAMLFIND) ocamlc $(OCAMLFLAGS) $(OCAMLINC) -o $@ $*.ml \
	-package cudd -linkpkg
%.opt: %.ml
	$(OCAMLFIND) ocamlopt -verbose $(OCAMLOPTFLAGS) $(OCAMLINC) -o $@ $*.ml \
	-package cudd -linkpkg

META: META.in
	sed -e "s!@VERSION@!$(PKGVERS)!g;" $< > $@;

install: $(FILES_TOINSTALL)
	$(OCAMLFIND) remove $(PKG-NAME)
	$(OCAMLFIND) install $(PKG-NAME) $^

uninstall:
	$(OCAMLFIND) remove $(PKG-NAME)

mostlyclean: clean
	(cd $(CUDDDIR); $(MAKE) clean)
	/bin/rm -f Makefile.depend TAGS META
	/bin/rm -f $(IDLMODULES:%=%.ml) $(IDLMODULES:%=%.mli) $(IDLMODULES:%=%_caml.c) html/*
	/bin/rm -f -r tmp
	/bin/rm -f mlcuddidl.?? mlcuddidl.??? mlcuddidl.info example example.opt mlcuddidl.tex ocamldoc.tex *.dvi style.css ocamldoc.sty index.html

distclean: mostlyclean
	(cd $(CUDDDIR); $(MAKE) distclean; /bin/rm -f *.a)

clean:
	/bin/rm -f cuddtop *.byte *.opt
	/bin/rm -f cuddaux.?? cuddaux.??? cuddaux.info
	/bin/rm -f *.[ao] *.so *.cm[ioxat] *.cmti *.cmxa *.opt *.opt2 *.annot cudd_ocamldoc.mli
	/bin/rm -f cmttb*
	/bin/rm -fr html

# ---

EXTRA_OBJs = cuddall
BASEOBJS =  $(CCMODULES:%=%.o) $(EXTRA_OBJs:%=%.o)
DEBGOBJS =  $(CCMODULES:%=%.d.o) $(EXTRA_OBJs:%=%.d.o)
PROFOBJS =  $(CCMODULES:%=%.p.o) $(EXTRA_OBJs:%=%.p.o)

# CAML rules

OCAMLMKLIB := $(OCAMLMKLIB) -verbose
OCAMLMKLIBd := $(OCAMLMKLIB) -ocamlopt "$(OCAMLOPT) -g" -ccopt -g
OCAMLMKLIBp := $(OCAMLMKLIB) -ocamlopt "$(OCAMLOPT) -p" -ccopt -p

$(BASELIBS): cudd.cma cudd.cmxa
$(DEBGLIBS): cudd.d.cma cudd.d.cmxa
$(PROFLIBS): cudd.p.cmxa

cudd.cma: %.cma: %.cmo $(BASEOBJS)
	$(OCAMLMKLIB) -o $* -oc $*_caml $^ $(LDFLAGS)
%.d.cma: %.d.cmo $(DEBGOBJS)
	$(OCAMLMKLIBd) -o $*.d -oc $*_caml.d $^ $(LDFLAGS)

cudd.cmxa: %.cmxa: %.cmx $(BASEOBJS)
	$(OCAMLMKLIB) -o $* -oc $*_caml $^ $(LDFLAGS)
%.d.cmxa: %.cmx $(DEBGOBJS)
	$(OCAMLMKLIBd) -o $*.d -oc $*_caml.d $^ $(LDFLAGS)
%.p.cmxa: %.p.cmx $(PROFOBJS)
	$(OCAMLMKLIBp) -o $*.p -oc $*_caml.p $^ $(LDFLAGS)

cudd.cmo cudd.cmi: $(MLMODULES:%=%.cmo)
	$(OCAMLC) $(OCAMLFLAGS) $(OCAMLINC) -pack -o $@ $^
cudd.d.cmo: $(MLMODULES:%=%.d.cmo)
	$(OCAMLC) $(OCAMLFLAGS) $(OCAMLINC) -g -pack -o $@ $^
cudd.cmx: $(MLMODULES:%=%.cmx)
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -pack -o $@ $^
cudd.p.cmx:  $(MLMODULES:%=%.p.cmx)
	$(OCAMLOPT) $(OCAMLOPTFLAGS_PROF) -p -pack -o $@ $^


# .PRECIOUS: %.o

# CAML libraries

define cuddall_make
	$(MAKE) -C $(CUDDDIR) clean;
	$(MAKE) -C $(CUDDDIR)						\
	  CC="$(CC)"							\
	  CXX="$(CXX)"							\
	  RANLIB="$(RANLIB)"						\
	  XCFLAGS="$(XCFLAGS)"						\
	  $(1)								\
	  DIRS="$(CUDDLIBS)";
	tmp=$$(mktemp -d ./tmp.XXXX);					\
	trap "rm -rf $${tmp};" EXIT QUIT INT;				\
	abs_cudddir=$(SRCDIR)/$(CUDDDIR);				\
	(								\
	 cd "$${tmp}";							\
	 for i in $(CUDDLIBS); do					\
	   $(AR) x "$${abs_cudddir}/$$i/lib$$i.a";			\
	 done;								\
	 $(LD) -r -o $@ *.o;						\
	);								\
	ln "$${tmp}/$@";
endef

cuddall.o:
	$(call cuddall_make,ICFLAGS="$(CFLAGS)",)
cuddall.p.o:
	$(call cuddall_make,ICFLAGS="$(CFLAGS_PROF)",.p)
cuddall.d.o:
	$(call cuddall_make,ICFLAGS="$(CFLAGS_DEBUG)"			\
	       DDDEBUG="-DDD_DEBUG -DDD_VERBOSE -DDD_STATS		\
			-DDD_CACHE_PROFILE -DDD_UNIQUE_PROFILE		\
			-DDD_COUNT" MTRDEBUG="-DMTR_DEBUG",.d)

# HTML and LATEX rules
.PHONY: html

cudd_ocamldoc.mli: cudd.mlpacki $(MLMODULES:%=%.mli)
	$(OCAMLPACK) -o $@ -intro cudd.mlpacki -level 2 $(MLMODULES:%=%.mli)

mlcuddidl.pdf: mlcuddidl.dvi
	$(DVIPDF) mlcuddidl.dvi
mlcuddidl.dvi: cudd_ocamldoc.mli
	mkdir -p tmp
	cp cudd_ocamldoc.mli tmp/cudd.mli
	(cd tmp; $(OCAMLC) $(OCAMLINC) -c cudd.mli)
	$(OCAMLDOC) $(OCAMLINC) -I tmp \
-t "MLCUDDIDL: OCaml interface for CUDD library, version $(PKGVERS), 01/02/11" \
-latextitle 1,part -latextitle 2,chapter -latextitle 3,section -latextitle 4,subsection -latextitle 5,subsubsection -latextitle 6,paragraph -latextitle 7,subparagraph \
-latex -o ocamldoc.tex tmp/cudd.mli
	$(SED) -e 's/\\documentclass\[11pt\]{article}/\\documentclass[10pt,twosdie,a4paper]{book}\\usepackage{ae,fullpage,makeidx,fancyhdr}\\usepackage[ps2pdf]{hyperref}\\pagestyle{fancy}\\setlength{\\parindent}{0em}\\setlength{\\parskip}{0.5ex}\\sloppy\\makeindex\\author{Bertrand Jeannet}/' -e 's/\\end{document}/\\appendix\\printindex\\end{document}/' ocamldoc.tex >mlcuddidl.tex
	$(LATEX) mlcuddidl
	$(MAKEINDEX) mlcuddidl
	$(LATEX) mlcuddidl
	$(LATEX) mlcuddidl

dot: $(MLMODULES:%=%.ml)
	$(OCAMLDOC) -dot -dot-reduce -o cudd.dot $(MLMODULES:%=%.ml)

html: mlcuddidl.odoci cudd_ocamldoc.mli
	mkdir -p tmp
	cp cudd_ocamldoc.mli tmp/cudd.mli
	(cd tmp; $(OCAMLC) $(OCAMLINC) -c cudd.mli)
	mkdir -p html
	$(OCAMLDOC) $(OCAMLINC) -I tmp -html -d html -colorize-code -intro mlcuddidl.odoci tmp/cudd.mli

homepage: html mlcuddidl.pdf
	hyperlatex index
	scp -r index.html html mlcuddidl.pdf Changes \
		avedon:/home/wwwpop-art/people/bjeannet/mlxxxidl-forge/mlcuddidl
	ssh avedon chmod -R ugoa+rx /home/wwwpop-art/people/bjeannet/mlxxxidl-forge/mlcuddidl


#--------------------------------------------------------------
# IMPLICIT RULES AND DEPENDENCIES
#--------------------------------------------------------------

.SUFFIXES: .c .h .o .ml .mli .cmi .cmo .cmx .idl .d.o _caml.c

#-----------------------------------
# IDL
#-----------------------------------

# Generates X_caml.c, X.ml, X.mli from X.idl

# sed -f sedscript_caml allows to remove prefixes generated by camlidl
# grep --extended-regexp '^(.)+$$' removes blanks lines

# tmp: $(IDLMODULES:%=%.idl) macros.m4
# 	mkdir -p tmp
# 	for i in $(IDLMODULES); do \
# 		$(M4) macros.m4 $${i}.idl > tmp/$${i}.idl; \
# 	done;

tmp: macros.m4
	mkdir -p tmp;
	for i in $(IDLMODULES); do $(M4) macros.m4 $${i}.idl > tmp/$${i}.idl; done;

# sedscript_caml sedscript_c
%_caml.c %.ml %.mli: %.idl tmp sedscript_caml sedscript_c
	@echo "module $*";
	(cd tmp; $(CAMLIDL) -no-include -nocpp -I . $*.idl);
	$(SED) -f sedscript_c tmp/$*_stubs.c >$*_caml.c;
	$(SED) -f sedscript_caml tmp/$*.ml >$*.ml;
	$(SED) -f sedscript_caml tmp/$*.mli >$*.mli;

# $(IDLMODULES:%=%_caml.c) $(IDLMODULES:%=%.ml) $(IDLMODULES:%=%.mli): $(addprefix tmp/,$(IDLMODULES)) sedscript_caml sedscript_c
# 	for i in $(IDLMODULES); do \
# 		echo "module $$i"; \
# 		(cd tmp; $(CAMLIDL) -no-include -nocpp -I . $${i}.idl ); \
# 		$(SED) -f sedscript_c tmp/$${i}_stubs.c >$${i}_caml.c; \
# 		$(SED) -f sedscript_caml tmp/$${i}.ml >$${i}.ml; \
# 		$(SED) -f sedscript_caml tmp/$${i}.mli >$${i}.mli; \
# 	done
# #		$(CAMLIDL) -no-include -prepro "$(M4) macros.m4" -I $(SRCDIR) tmp/$${i}.idl; 

#-----------------------------------
# C
#-----------------------------------

%.o: %.c cudd_caml.h cuddaux.h
	$(OCAMLOPT) -ccopt "$(CFLAGS) $(ICFLAGS) $(XCFLAGS)" -o $@ -c $<
%.p.o: %.c cudd_caml.h cuddaux.h
	$(OCAMLOPT) -ccopt "$(CFLAGS_PROF) $(ICFLAGS) $(XCFLAGS) -o $@" -c $<
%.d.o: %.c cudd_caml.h cuddaux.h
	$(OCAMLOPT) -ccopt "$(CFLAGS_DEBUG) $(ICFLAGS) $(XCFLAGS) -g -o $@" -c $<

#-----------------------------------
# CAML
#-----------------------------------

%.cmi: %.mli
	$(OCAMLC) $(OCAMLFLAGS) $(OCAMLINC) -c $<

%.cmo: %.ml %.cmi
	$(OCAMLC) $(OCAMLFLAGS) $(OCAMLINC) -c $<

%.d.cmo: %.ml %.cmi %.cmo
	$(OCAMLC) $(OCAMLFLAGS) $(OCAMLINC) -o $@ -g -c $<

$(MLMODULES:%=%.cmx): %.cmx: %.ml %.cmi
	$(OCAMLOPT) $(OCAMLOPTFLAGS) $(OCAMLINC) -for-pack Cudd -c $<

$(MLMODULES:%=%.p.cmx): %.p.cmx: %.ml %.cmi
	$(OCAMLOPT) -p $(OCAMLOPTFLAGS) $(OCAMLINC) -for-pack Cudd -c -o $@ $<

#-----------------------------------
# Dependencies
#-----------------------------------

depend: Makefile.depend
Makefile.depend: $(IDLMODULES:%=%.ml) $(IDLMODULES:%=%.mli)
	$(OCAMLDEP) $(MLMODULES:%=%.mli) $(MLMODULES:%=%.ml) >Makefile.depend

-include Makefile.depend

#-----------------------------------
# OPAM Packaging
#-----------------------------------

# see `https://github.com/nberth/opam-dist'
ifneq ($(OPAM_DIST_DIR),)

  OPAM_DIR = opam
  OPAM_FILES = descr opam files

  MLSRCS = $(filter-out $(IDLMODULES),$(MLMODULES))
  DIST_FILES = *.idl *.c *.h *.itarget *.odoci *.mlpack *.mlpacki	\
   *.mllib *.m4 *.texi *.tex META.in $(MLSRCS:%=%.ml)			\
   $(MLSRCS:%=%.mli) $(CUDDDIR) Changes README COPYING TODO Makefile	\
   Makefile.cudd Makefile.config.* sedscript_* _tags ocamlpack		\
   example.ml session.ml configure

  -include $(OPAM_DIST_DIR)/opam-dist.mk

endif

# ---

# Disable parallel builds
.NOTPARALLEL:

# ---
