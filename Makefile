DIST_EXCLUDE=asmrun ocamldoc testuite experimental emacs debugger

dist:
	esy install
	esy build
	$(MAKE) install/bin/jbuilder.bc
	$(MAKE) compress

compress:
	@$(MAKE) clean-ocaml clean-lwt
	@rm -rf ocaml.tar.gz
	@tar -cvzf ocaml.tar.gz $(DIST_EXCLUDE:%=--exclude %) ocaml
	@tar -cvzf lwt.tar.gz lwt

publish:
	@$(MAKE) clean
	@$(MAKE) dist
	@npm publish

clean-ocaml:
	@(cd ocaml && git clean -fdx)

clean-lwt:
	@(cd lwt && git co -- . && git clean -fdx)

clean-jbuilder:
	@(cd jbuilder && git co -- . && git clean -fdx)

clean:
	@$(MAKE) -j clean-ocaml clean-lwt clean-jbuilder
	@git co -- .
	@git clean -fdx


ocaml-install:
	(cd ocaml \
		&& ./configure \
			--no-native-compiler \
			--no-ocamldoc \
			--no-debugger \
			--no-graph \
			--prefix $(PWD)/ocaml-install \
		&& make -j world 2>&1 > $(PWD)/ocaml-install.log \
		&& make install)
	$(MAKE) clean-ocaml

install/bin/jbuilder.bc: ocaml-install
	cd jbuilder && patch -p1 < ../jbuilder.patch
	cd jbuilder \
		&& PATH=$(PWD)/ocaml-install/bin:$(PATH) ocaml bootstrap.ml \
		&& PATH=$(PWD)/ocaml-install/bin:$(PATH) ./boot.exe -j 4
	esy ocamlstripdebug jbuilder/_build/default/bin/main.bc $(@)
