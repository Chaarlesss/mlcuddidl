# -*- mode: makefile -*-

include Makefile.config

#---------------------------------------
# Directories
#---------------------------------------

SRCDIR = $(shell pwd)
#
# Installation directory
#
PKG-NAME = cudd

#---------------------------------------
# Files
#---------------------------------------

FILES_TOINSTALL = \
	$(MLMODULES:%=%.ml) $(MLMODULES:%=%.mli) \
	$(MLMODULES:%=%.cmt) $(MLMODULES:%=%.cmti) \
	$(MLMODULES:%=%.cmi) cudd.cma \
	$(MLMODULES:%=%.cmx) cudd.cmxa cudd.a \
	$(MLMODULES:%=%.p.cmx) cudd.p.cmxa cudd.p.a

all:
	$(OCAMLBUILD) all.otarget
clib:
	$(OCAMLBUILD) libcudd.a

prog.native:
	$(OCAMLBUILD) prog.native

doc:
	$(OCAMLBUILD) doc.otarget

install: $(FILES_TOINSTALL)
	$(OCAMLFIND) remove $(PKG-NAME)
	$(OCAMLFIND) install $(PKG-NAME) META $(FILES_TOINSTALL:%=_build/%)

uninstall:
	$(OCAMLFIND) remove $(PKG-NAME)

clean:
	$(OCAMLBUILD) -clean

distclean: clean
	/bin/rm -f TAGS myocamlbuild

homepage: doc
	hyperlatex index
	scp -r index.html _build/cudd.docdir _build/cudd.pdf \
		avedon:/home/wwwpop-art/people/bjeannet/bjeannet-forge/cudd
	ssh avedon chmod -R ugoa+rx /home/wwwpop-art/people/bjeannet/bjeannet-forge/cudd

.PHONY: TAGS
tags: TAGS
TAGS: $(MLMODULES:%=%.mli) $(MLMODULES:%=%.ml)
	ocamltags $^
