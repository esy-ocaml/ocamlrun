#!/bin/bash

export PREFIX="$PWD/install"

_do () {
  set -u
  set -e
  set -o pipefail

  createOCamlrunWrapper () {
    local filename="$PREFIX/bin/$2"
    printf "#!/bin/bash\\n" > "$filename"
    printf "export OCAMLLIB='%s/lib/ocaml'\\n" "$PREFIX" >> "$filename"
    printf '%s/bin/ocamlrun %s/bin/%s "$@"' "$PREFIX" "$PREFIX" "$1" >> "$filename"
    chmod +x "$PREFIX/bin/$2"
  }

  ./configure --no-native-compiler --no-ocamldoc --no-debugger --no-graph --prefix "$PREFIX"

  make -j -C byterun
  cp byterun/ocamlrun boot/ocamlrun
	make -j -C stdlib \
	  COMPILER="../boot/ocamlc -use-prims ../byterun/primitives" all
  (cd stdlib; cp stdlib.cma std_exit.cmo ./*.cmi camlheader ../boot);
  (cd boot; ln -s ../byterun/libcamlrun.a .);

  make -j utils/config.cmo
  make -j utils/misc.cmo
  make -j -C tools ocamlmklib

  cp boot/ocamlc ocamlc
  make -j -C otherlibs/unix
  make -j -C otherlibs/systhreads
  make -j -C otherlibs/bigarray
  make -j -C otherlibs/str

  mkdir -p "$PREFIX/lib/ocaml/stublibs" "$PREFIX/bin"
  echo "$PREFIX/lib/ocaml" > "$PREFIX/lib/ocaml/ld.conf"
  make -j -C byterun install
  make -j -C stdlib install
  make -j -C otherlibs/unix install
  make -j -C otherlibs/systhreads install
  make -j -C otherlibs/bigarray install
  make -j -C otherlibs/str install
  cp boot/ocamlc "$PREFIX/bin/ocamlc.bc"
  cp boot/ocamldep "$PREFIX/bin/ocamldep.bc"
  cp tools/ocamlmklib "$PREFIX/bin"

  cp otherlibs/unix/dllunix.so "$PREFIX/lib/ocaml"
  cp otherlibs/systhreads/dllthreads.so "$PREFIX/lib/ocaml"

  createOCamlrunWrapper "ocamlc.bc" "ocamlc"
  createOCamlrunWrapper "ocamldep.bc" "ocamldep"
  createOCamlrunWrapper "ocaml.bc" "ocaml"

  chmod +x "$PREFIX/bin/ocamlrun"
}
export -f _do

_test () {
  ("$PREFIX/bin/ocamlrun" ./test > /dev/null)
  return $?
}
export -f _test

# check if we already have ocamlrun built
# some package managers (yarn) build the same package multiple times so this is
# why we do this check
if  _test > /dev/null 2>&1; then
  exit 0
fi

LOG=$(cd ocaml && _do)
if [ $? -ne 0 ]; then
  echo "$LOG"
  exit 1
fi

if ! _test; then
  echo "error: ocamlrun wasn't built correctly, unable to execute test file"
  exit 1
fi
