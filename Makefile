DIST_EXCLUDE=asmcomp asmrun ocamldoc ocamltest testuite experimental emacs debugger

dist:
	esy install
	esy build
	$(MAKE) install/bin/ocaml.bc
	$(MAKE) install/bin/jbuilder.bc
	$(MAKE) compress

compress:
	@$(MAKE) clean-ocaml clean-lwt
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

install/bin/ocaml.bc:
	(cd ocaml \
		&& ./configure \
			--no-native-compiler \
			--no-ocamldoc \
			--no-debugger \
			--no-graph \
			--prefix $(PWD)/ocaml-install \
		&& make -j world \
		&& make install)
	esy ocamlstripdebug $(PWD)/ocaml-install/bin/ocaml $(@)

install/bin/jbuilder.bc: install/bin/ocaml.bc
	cd jbuilder \
		&& PATH=$(PWD)/ocaml-install/bin:$(PATH) ocaml bootstrap.ml \
		&& PATH=$(PWD)/ocaml-install/bin:$(PATH) ./boot.exe -j 4
	esy ocamlstripdebug ocaml/ocaml $(@)
