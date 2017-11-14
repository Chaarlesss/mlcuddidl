include Makefile.config
PKGNAME = mlcuddidl
PKGVERS = 3.0.1

#---------------------------------------
# Directories
#---------------------------------------

CUDDDIR = cudd-3.0.0
SRCDIR = $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
#
# Installation directory
#
PKG-NAME = cudd

# CUDD temporary directories:

CUDDFLAVORS = base dbug prof
CUDD_SRCDIR = cuddsrc-$(1)
CUDD_BLDDIR = cuddbld-$(1)
CUDD_LIBDIR = $(call CUDD_BLDDIR,$(1))/lib
CUDD_LIB = $(call CUDD_LIBDIR,$(1))/libcudd.a

#---------------------------------------
# C part
#---------------------------------------

# Various flags for building CUDD itself with multiple flavors
CFLAGS_base = -fPIC -O3
CFLAGS_dbug = -fPIC -O0 -g
CFLAGS_prof = -fPIC -O3 $(CPROF_FLAGS)
CPPFLAGS_base =
CPPFLAGS_dbug = -DDD_CACHE_PROFILE -DDD_UNIQUE_PROFILE -DDD_VERBOSE	\
		-DDD_DEBUG -DDD_STATS -DDD_COUNT -DMTR_DEBUG
CPPFLAGS_prof =

LDFLAGS = -L$(CAMLIDL_DIR) -lcamlidl

#---------------------------------------
# Files
#---------------------------------------

IDLMODULES = hash cache memo man bdd vdd custom add

MLMODULES = hash cache memo man bdd vdd custom weakke pWeakke mtbdd mtbddc user mapleaf add

CUDDAUX_C = $(wildcard cuddaux*.c)
CCMODULES = $(CUDDAUX_C:%.c=%) $(IDLMODULES:%=%_caml) cudd_caml

LIBNAMES = cudd_caml
BASELIBS = $(addprefix $(LIBNAMES:%=lib%),.a)
DEBGLIBS = $(addprefix $(LIBNAMES:%=lib%),.d.a)				\
           $(addprefix $(LIBNAMES:%=lib%),.nd.a)
PROFLIBS = $(addprefix $(LIBNAMES:%=lib%),.p.a)
ifneq ($(HAS_SHARED),)
  BASELIBS += $(addprefix $(LIBNAMES:%=dll%),.so)
  DEBGLIBS += $(addprefix $(LIBNAMES:%=dll%),.d.so)			\
              $(addprefix $(LIBNAMES:%=dll%),.nd.so)
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
	/bin/rm -f Makefile.depend TAGS META
	/bin/rm -f $(IDLMODULES:%=%.ml) $(IDLMODULES:%=%.mli) $(IDLMODULES:%=%_caml.c) html/*
	/bin/rm -f -r tmp
	/bin/rm -f mlcuddidl.?? mlcuddidl.??? mlcuddidl.info example example.opt mlcuddidl.tex ocamldoc.tex *.dvi style.css ocamldoc.sty index.html
	for x in $(CUDDFLAVORS); do						\
	  if test -f "$(call CUDD_SRCDIR,$$x)/config.h"; then 			\
	    if test -f "$(call CUDD_LIB,$$x)"; then 				\
	      $(MAKE) -C "$(call CUDD_SRCDIR,$$x)" uninstall || true;		\
	    fi;									\
	    $(MAKE) -C "$(call CUDD_SRCDIR,$$x)" clean || true;			\
	  fi;									\
	  rm -f -r cuddbld-$$x;							\
	done;

distclean: mostlyclean
	rm -f -r Makefile.config;
	for x in $(CUDDFLAVORS); do rm -f -r cuddsrc-$$x; done;

clean:
	/bin/rm -f cuddtop *.byte *.opt
	/bin/rm -f cuddaux.?? cuddaux.??? cuddaux.info
	/bin/rm -f *.[ao] *.so *.cm[ioxat] *.cmti *.cmxa *.opt *.opt2 *.annot cudd_ocamldoc.mli
	/bin/rm -f cmttb*
	/bin/rm -fr html

# ---

define cudddir
	mkdir -p $(2);
	( srcdir="$(SRCDIR)/$(CUDDDIR)"; 					\
	  cd $(2) && CPPFLAGS="$(CPPFLAGS_$(1))" CFLAGS="$(CFLAGS_$(1))"	\
	  "$${srcdir}/configure" DOXYGEN=					\
		--prefix "$(SRCDIR)/$(call CUDD_BLDDIR,$(1))"			\
	 	--srcdir="$${srcdir}" --disable-dependency-tracking		\
		--disable-shared --enable-static $(3); ) ||			\
	  { rm -rf $(2); false; }
endef

.PRECIOUS: $(call CUDD_SRCDIR,%)/config.h
$(call CUDD_SRCDIR,%)/config.h:
	$(call cudddir,$*,$(call CUDD_SRCDIR,$*));

.PRECIOUS: $(call CUDD_LIB,%)
$(call CUDD_LIB,%): $(call CUDD_SRCDIR,%)/config.h
	+$(MAKE) -C $(call CUDD_SRCDIR,$*) install;

define cuddall
	tmpdir=$$(mktemp -d tmp.XXX); trap "rm -rf $${tmpdir};" EXIT QUIT INT;	\
	( cd "$${tmpdir}"; $(AR) x $(SRCDIR)/$<; $(LD) -r -o $(2) *.o; )
endef

.PRECIOUS: cuddall-%.o
cuddall-%.o: $(call CUDD_LIB,%)
	$(call cuddall,$*,$(SRCDIR)/$@)

# ---

# CAML libraries

$(BASELIBS): cudd.cma cudd.cmxa
$(DEBGLIBS): cudd.d.cma cudd.d.cmxa
$(PROFLIBS): cudd.p.cmxa

BASEOBJS = $(CCMODULES:%=%.o) cuddall-base.o
DEBGOBJS = $(CCMODULES:%=%.d.o) cuddall-dbug.o
PROFOBJS = $(CCMODULES:%=%.p.o) cuddall-prof.o

OCAMLMKLIB := $(OCAMLMKLIB) -verbose
OCAMLMKLIBd := $(OCAMLMKLIB) -ocamlopt "$(OCAMLOPT)" -g -ccopt -g
OCAMLMKLIBp := $(OCAMLMKLIB) -ocamlopt "$(OCAMLOPT) -p" -ccopt -p

cudd.a: cudd.cmxa
cudd.d.a: cudd.d.cmxa
cudd.p.a: cudd.p.cmxa

cudd.cma: %.cma: %.cmo $(BASEOBJS)
	$(OCAMLMKLIB) -o $* -oc $*_caml $^ $(LDFLAGS)
%.d.cma: %.d.cmo $(DEBGOBJS)
	$(OCAMLMKLIBd) -o $*.d -oc $*_caml.d $^ $(LDFLAGS)

cudd.cmxa: %.cmxa: %.cmx $(BASEOBJS)
	$(OCAMLMKLIB) -o $* -oc $*_caml $^ $(LDFLAGS)
%.d.cmxa: %.cmx $(DEBGOBJS)
	$(OCAMLMKLIBd) -o $*.d -oc $*_caml.nd $^ $(LDFLAGS)
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

# HTML and LATEX rules
.PHONY: html

ifneq ($(OCAMLPACK),)

cudd_ocamldoc.mli: cudd.mlpacki $(MLMODULES:%=%.mli)
	sh $(OCAMLPACK) -o $@ -title "Interface to CUDD library"	\
	   -intro cudd.mlpacki $(MLMODULES)

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
	$(OCAMLDOC) -dot -dot-reduce -o cudd.dot $^

html: mlcuddidl.odoci cudd_ocamldoc.mli
	mkdir -p tmp html;
	cp cudd_ocamldoc.mli tmp/cudd.mli;
	$(OCAMLDOC) $(OCAMLINC) -I tmp -html -d html -colorize-code \
	  -intro mlcuddidl.odoci tmp/cudd.mli || { rm -rf html; false; }

# homepage: html mlcuddidl.pdf
# 	hyperlatex index
# 	scp -r index.html html mlcuddidl.pdf Changes \
# 		avedon:/home/wwwpop-art/people/bjeannet/mlxxxidl-forge/mlcuddidl
# 	ssh avedon chmod -R ugoa+rx /home/wwwpop-art/people/bjeannet/mlxxxidl-forge/mlcuddidl

endif

#--------------------------------------------------------------
# IMPLICIT RULES AND DEPENDENCIES
#--------------------------------------------------------------

.SUFFIXES: .c .h .o .ml .mli .cmi .cmo .cmx .idl .p.o .d.o _caml.c

#-----------------------------------
# IDL
#-----------------------------------

M4 ?= m4
SED ?= sed
CAMLIDL ?= camlidl

.PRECIOUS: tmp/%.idl
tmp/%.idl: %.idl macros.m4 Makefile.config
	@mkdir -p tmp;
	$(M4) macros.m4 $< > $@

$(IDLMODULES:%=%.mli): %.mli: %.ml
$(IDLMODULES:%=%_caml.c): %_caml.c: %.ml
$(IDLMODULES:%=%.ml): %.ml: %.idl $(IDLMODULES:%=tmp/%.idl) sedscript_caml sedscript_c
	(cd tmp; $(CAMLIDL) -no-include -nocpp -I . $*.idl);
	$(SED) -f sedscript_c tmp/$*_stubs.c > $*_caml.c;
	$(SED) -f sedscript_caml tmp/$*.ml > $*.ml;
	$(SED) -f sedscript_caml tmp/$*.mli > $*.mli;

#-----------------------------------
# C
#-----------------------------------

IDLINC = -I $(CAML_DIR) -I $(CAMLIDL_DIR)
CUDDINC = -I $(CUDDDIR) -I $(CUDDDIR)/st -I $(CUDDDIR)/mtr -I $(CUDDDIR)/epd \
	  -I $(CUDDDIR)/util -I $(CUDDDIR)/cudd -I $(call CUDD_SRCDIR,$(1))
CUDDAUX_INC = $(CUDDINC) $(IDLINC)

$(CCMODULES:%=%.o): %.o: %.c cudd_caml.h cuddaux.h $(call CUDD_SRCDIR,base)/config.h
	$(OCAMLOPT) $(call CUDDAUX_INC,base) -ccopt "$(CFLAGS_base) -o $@"  -c $<
$(CCMODULES:%=%.p.o): %.p.o: %.c cudd_caml.h cuddaux.h $(call CUDD_SRCDIR,prof)/config.h
	$(OCAMLOPT) $(call CUDDAUX_INC,prof) -p -ccopt "$(CFLAGS_prof) -w -o $@" -c $<
$(CCMODULES:%=%.d.o): %.d.o: %.c cudd_caml.h cuddaux.h $(call CUDD_SRCDIR,dbug)/config.h
	$(OCAMLOPT) $(call CUDDAUX_INC,dbug) -g -ccopt "$(CFLAGS_dbug) -w -o $@" -c $<

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

OCAMLDEP ?= ocamldep

.PHONY: depend
depend: Makefile.depend
Makefile.depend: $(MLMODULES:%=%.mli) $(MLMODULES:%=%.ml)
	$(OCAMLDEP) -one-line $+ |						\
	  $(SED) -e '/\.cm[ox]/ { p; s/\.cmo/.d.cmo/; s/\.cmx/.p.cmx/; }' > $@

ifeq ($(findstring distclean,$(MAKECMDGOALS))$(findstring mostlyclean,$(MAKECMDGOALS)),)
  -include Makefile.depend
endif

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
