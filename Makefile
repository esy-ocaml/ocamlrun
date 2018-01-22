DIST_EXCLUDE=asmcomp asmrun ocamldoc ocamltest testuite experimental emacs debugger

dist:
	@rm -rf ocaml.tar.gz
	@tar -cvzf ocaml.tar.gz $(DIST_EXCLUDE:%=--exclude %) ocaml
	@tar -cvzf lwt.tar.gz lwt

publish: dist
	@npm publish

clean-ocaml:
	(cd ocaml && git clean -fdx)

clean-lwt:
	(cd lwt && git co -- . && git clean -fdx)

clean: clean-ocaml clean-lwt
	git co -- .
	git clean -fdx
