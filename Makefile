DIST_EXCLUDE=asmcomp asmrun ocamldoc ocamltest testuite experimental emacs debugger

dist:
	@rm -rf ocaml.tar.gz
	@tar -cvzf ocaml.tar.gz $(DIST_EXCLUDE:%=--exclude %) ocaml

publish: dist
	@npm publish
