DIST_EXCLUDE=asmcomp asmrun ocamldoc ocamltest testuite experimental emacs debugger

dist:
	@rm -rf ocaml.tar.gz
	@tar -cvf ocaml.tar.gz $(DIST_EXCLUDE:%=--exclude %) ocaml
